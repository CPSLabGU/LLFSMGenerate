// CleanCommandTests.swift
// VHDLMachineTransformations
// 
// Created by Morgan McColl.
// Copyright © 2024 Morgan McColl. All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above
//    copyright notice, this list of conditions and the following
//    disclaimer in the documentation and/or other materials
//    provided with the distribution.
// 
// 3. All advertising materials mentioning features or use of this
//    software must display the following acknowledgement:
// 
//    This product includes software developed by Morgan McColl.
// 
// 4. Neither the name of the author nor the names of contributors
//    may be used to endorse or promote products derived from this
//    software without specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER
// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
// LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
// -----------------------------------------------------------------------
// This program is free software; you can redistribute it and/or
// modify it under the above terms or under the terms of the GNU
// General Public License as published by the Free Software Foundation;
// either version 2 of the License, or (at your option) any later version.
// 
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this program; if not, see http://www.gnu.org/licenses/
// or write to the Free Software Foundation, Inc., 51 Franklin Street,
// Fifth Floor, Boston, MA  02110-1301, USA.

@testable import MachineGenerator
import VHDLMachines
import XCTest

/// Test class for ``CleanCommand``.
final class CleanCommandTests: MachineTester {

    /// A file manager.
    let manager = FileManager.default

    /// Build the machine before every test.
    override func setUp() {
        super.setUp()
        let path = self.machine0Path.path
        LLFSMGenerate.main(["model", path])
        LLFSMGenerate.main(["vhdl", "--include-kripke-structure", path])
        var isDirectory: ObjCBool = true
        XCTAssertTrue(manager.fileExists(atPath: self.jsonFile.path, isDirectory: &isDirectory))
        XCTAssertFalse(isDirectory.boolValue)
        XCTAssertTrue(manager.fileExists(atPath: self.buildFolder.path, isDirectory: &isDirectory))
        XCTAssertTrue(isDirectory.boolValue)
    }

    /// Test the clean command removes all generated files.
    func testCleanCommand() throws {
        let commandTypeErased = try CleanCommand.parseAsRoot([self.machine0Path.path])
        guard var command = commandTypeErased as? CleanCommand else {
            XCTFail("Failed to create command.")
            return
        }
        XCTAssertFalse(command.cleanBuildFolder)
        try command.run()
        XCTAssertFalse(manager.fileExists(atPath: self.jsonFile.path))
        XCTAssertFalse(manager.fileExists(atPath: self.buildFolder.path))
        var isDirectory: ObjCBool = true
        XCTAssertTrue(manager.fileExists(atPath: self.modelFile.path, isDirectory: &isDirectory))
        XCTAssertFalse(isDirectory.boolValue)
    }

    /// Test command doesn't throw errors when files don't exist.
    func testCleanCommandStillWorksWithoutBuild() throws {
        CleanCommand.main([self.machine0Path.path])
        CleanCommand.main([self.machine0Path.path])
        XCTAssertFalse(manager.fileExists(atPath: self.jsonFile.path))
        XCTAssertFalse(manager.fileExists(atPath: self.buildFolder.path))
        var isDirectory: ObjCBool = true
        XCTAssertTrue(manager.fileExists(atPath: self.modelFile.path, isDirectory: &isDirectory))
        XCTAssertFalse(isDirectory.boolValue)
    }

    /// Test that the correct error is thrown when the build folder is malformed.
    func testCommandThrowsErrorForInvalidBuildFolder() throws {
        try manager.removeItem(atPath: self.buildFolder.path)
        guard manager.createFile(atPath: self.buildFolder.path, contents: nil) else {
            XCTFail("Failed to create build file.")
            return
        }
        let commandTypeErased = try CleanCommand.parseAsRoot([self.machine0Path.path])
        guard var command = commandTypeErased as? CleanCommand else {
            XCTFail("Failed to create command.")
            return
        }
        XCTAssertThrowsError(try command.run()) {
            guard let error = $0 as? GenerationError else {
                XCTFail("Failed to throw correct error.")
                return
            }
            XCTAssertEqual(error, .invalidExportation(message: "Found a file at the build folders location."))
        }
    }

    /// Test that the correct error is thrown when the machine file is malformed.
    func testCommandThrowsErrorForInvalidMachine() throws {
        try manager.removeItem(at: jsonFile)
        let newPath = URL(fileURLWithPath: jsonFile.path, isDirectory: true)
        try manager.createDirectory(at: newPath, withIntermediateDirectories: true)
        let commandTypeErased = try CleanCommand.parseAsRoot([self.machine0Path.path])
        guard var command = commandTypeErased as? CleanCommand else {
            XCTFail("Failed to create command.")
            return
        }
        XCTAssertThrowsError(try command.run()) {
            guard let error = $0 as? GenerationError else {
                XCTFail("Failed to throw correct error.")
                return
            }
            XCTAssertEqual(
                error, .invalidExportation(message: "Found a directory at the machine files location.")
            )
        }
    }

    /// Test that the `--clean-build-folder` flag ignores the machine file.
    func testFlagPreservesMachine() throws {
        CleanCommand.main(["--clean-build-folder", self.machine0Path.path])
        var isDirectory: ObjCBool = true
        XCTAssertTrue(manager.fileExists(atPath: self.jsonFile.path, isDirectory: &isDirectory))
        XCTAssertFalse(isDirectory.boolValue)
        XCTAssertFalse(manager.fileExists(atPath: self.buildFolder.path))
    }

}
