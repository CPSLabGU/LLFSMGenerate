// GraphTests.swift
// LLFSMGenerate
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
import VHDLKripkeStructures
import XCTest

/// Test class for ``GraphCommand``.
final class GraphTests: MachineTester {

    /// The path to the dot file.
    var dotFile: URL {
        self.packageRootPath.appendingPathComponent("output.dot", isDirectory: false)
    }

    /// The dot file in the build folder.
    var buildDotFile: URL {
        self.pingMachineBuildFolder.appendingPathComponent("output.dot", isDirectory: false)
    }

    /// Remove the dot file after every test.
    override func tearDown() {
        super.tearDown()
        try? manager.removeItem(at: self.dotFile)
    }

    /// Test the kripke structure is generated correctly for a machine.
    func testMachineGeneration() throws {
        XCTAssertFalse(manager.fileExists(atPath: dotFile.path))
        GraphCommand.main(["--machine", self.pingMachineFolder.path])
        var isDirectory: ObjCBool = false
        XCTAssertTrue(manager.fileExists(atPath: dotFile.path, isDirectory: &isDirectory))
        XCTAssertFalse(isDirectory.boolValue)
        XCTAssertFalse(try Data(contentsOf: dotFile).isEmpty)
    }

    /// Test the kripke structure is generated correctly for a machine with a destination.
    func testMachineGenerationWithDestination() throws {
        XCTAssertFalse(manager.fileExists(atPath: buildDotFile.path))
        GraphCommand.main(["--machine", self.pingMachineFolder.path, "--destination", self.buildDotFile.path])
        var isDirectory: ObjCBool = false
        XCTAssertTrue(manager.fileExists(atPath: buildDotFile.path, isDirectory: &isDirectory))
        XCTAssertFalse(isDirectory.boolValue)
        XCTAssertFalse(try Data(contentsOf: buildDotFile).isEmpty)
    }

    /// Test the generation given the file as a path.
    func testGeneration() throws {
        XCTAssertFalse(manager.fileExists(atPath: dotFile.path))
        GraphCommand.main([self.pingMachineKripkeStructure.path])
        var isDirectory: ObjCBool = false
        XCTAssertTrue(manager.fileExists(atPath: dotFile.path, isDirectory: &isDirectory))
        XCTAssertFalse(isDirectory.boolValue)
        XCTAssertFalse(try Data(contentsOf: dotFile).isEmpty)
    }

    /// Test that generation works with a destination.
    func testGenerationWithDestination() throws {
        XCTAssertFalse(manager.fileExists(atPath: buildDotFile.path))
        GraphCommand.main([self.pingMachineKripkeStructure.path, "--destination", self.buildDotFile.path])
        var isDirectory: ObjCBool = false
        XCTAssertTrue(manager.fileExists(atPath: buildDotFile.path, isDirectory: &isDirectory))
        XCTAssertFalse(isDirectory.boolValue)
        XCTAssertFalse(try Data(contentsOf: buildDotFile).isEmpty)
    }

    /// Test that the command throws an error for an invalid machine.
    func testGenerationThrowsErrorForInvalidMachine() throws {
        let command = try GraphCommand.parse(["--machine", self.pingMachineKripkeStructure.path])
        XCTAssertThrowsError(try command.run()) {
            guard let error = $0 as? GenerationError, case .invalidInput(let message) = error else {
                XCTFail("Expected GenerationError but got \($0)")
                return
            }
            XCTAssertEqual(message, "The path must be a valid machines location.")
        }
        XCTAssertFalse(manager.fileExists(atPath: dotFile.path))
    }

    /// Test that the correct error is thrown when the kripke structure is not present.
    func testCommandThrowsErrorForMissingKripkeStructure() throws {
        try manager.removeItem(at: self.pingMachineKripkeStructure)
        let command = try GraphCommand.parse([self.pingMachineKripkeStructure.path])
        XCTAssertThrowsError(try command.run()) {
            guard let error = $0 as? GenerationError, case .invalidMachine(let message) = error else {
                XCTFail("Expected GenerationError but got \($0)")
                return
            }
            XCTAssertEqual(message, "The Kripke structure does not exist at this specified location.")
        }
        XCTAssertFalse(manager.fileExists(atPath: dotFile.path))
    }

    /// Test command overwrites existing `.dot` file.
    func testCommandOverwritesFile() throws {
        XCTAssertTrue(manager.createFile(atPath: dotFile.path, contents: nil))
        GraphCommand.main([self.pingMachineKripkeStructure.path, "--destination", self.dotFile.path])
        var isDirectory: ObjCBool = false
        XCTAssertTrue(manager.fileExists(atPath: dotFile.path, isDirectory: &isDirectory))
        XCTAssertFalse(isDirectory.boolValue)
        XCTAssertFalse(try Data(contentsOf: dotFile).isEmpty)
    }

    /// Test that the file is created in a subdirectory that exists.
    func testCommandPlacesFileInFolderthatExists() throws {
        try manager.createDirectory(at: self.pingMachineBuildFolder, withIntermediateDirectories: true)
        XCTAssertFalse(manager.fileExists(atPath: self.buildDotFile.path))
        GraphCommand.main([
            self.pingMachineKripkeStructure.path, "--destination", self.pingMachineBuildFolder.path
        ])
        var isDirectory: ObjCBool = false
        XCTAssertTrue(manager.fileExists(atPath: buildDotFile.path, isDirectory: &isDirectory))
        XCTAssertFalse(isDirectory.boolValue)
        XCTAssertFalse(try Data(contentsOf: buildDotFile).isEmpty)
    }

    /// Test that the file is created in a subdirectory that doesn't exist.
    func testCommandPlacesFileInFolder() throws {
        XCTAssertFalse(manager.fileExists(atPath: self.pingMachineBuildFolder.path))
        GraphCommand.main([
            self.pingMachineKripkeStructure.path, "--destination", self.pingMachineBuildFolder.path
        ])
        var isDirectory: ObjCBool = false
        XCTAssertTrue(manager.fileExists(atPath: buildDotFile.path, isDirectory: &isDirectory))
        XCTAssertFalse(isDirectory.boolValue)
        XCTAssertFalse(try Data(contentsOf: buildDotFile).isEmpty)
    }

}
