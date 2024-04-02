// InstallCommandTests.swift
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

import ArgumentParser
import Foundation
@testable import MachineGenerator
import XCTest

/// Test class for ``InstallCommand``.
final class InstallCommandTests: MachineTester {

    /// The name of the vivado project.
    let vivadoName = "Project1"

    /// The path to the vivado project.
    var vivadoPath: URL {
        self.machinesFolder.appendingPathComponent("vivado_project", isDirectory: true)
    }

    /// The path to the destination of the VHDL sources.
    var vhdlSourcesPath: URL {
        self.vivadoPath.appendingPathComponent("\(vivadoName).srcs/sources_1/new", isDirectory: true)
    }

    /// The path to the project file.
    var projectFilePath: URL {
        self.vivadoPath.appendingPathComponent("\(vivadoName).xpr", isDirectory: false)
    }

    /// Setup install locations before every run.
    override func setUp() {
        super.setUp()
        guard
            (try? self.manager.createDirectory(at: vivadoPath, withIntermediateDirectories: true)) != nil,
            manager.createFile(atPath: self.projectFilePath.path, contents: nil),
            (try? self.manager.createDirectory(at: vhdlSourcesPath, withIntermediateDirectories: true)) != nil
        else {
            XCTFail("Failed to create vivado project.")
            return
        }
        Generate.main([self.machine0Path.path])
        VHDLGenerator.main([self.machine0Path.path])
    }

    /// Remove install locations.
    override func tearDown() {
        super.tearDown()
        XCTAssertNotNil(try? self.manager.removeItem(at: vivadoPath))
    }

    /// Test files are copied correctly.
    func testInstallCommandWorksLocally() throws {
        try manager.removeItem(
            at: self.vivadoPath.appendingPathComponent("\(vivadoName).srcs", isDirectory: true)
        )
        let previousProjectContents = try String(contentsOf: self.projectFilePath, encoding: .utf8)
        InstallCommand.main([self.machine0Path.path, self.vivadoPath.path])
        let vhdlFilePath = self.buildFolder.appendingPathComponent("vhdl/Machine0.vhd", isDirectory: false)
        let contents = try String(contentsOf: vhdlFilePath, encoding: .utf8)
        let vivadoVHDLFile = self.vivadoPath.appendingPathComponent("Machine0.vhd", isDirectory: false)
        let vivadoContents = try String(contentsOf: vivadoVHDLFile, encoding: .utf8)
        XCTAssertEqual(contents, vivadoContents)
        let files = try self.manager.contentsOfDirectory(at: self.vivadoPath, includingPropertiesForKeys: nil)
        XCTAssertEqual(files.count, 2)
        let expected: Set<URL> = [self.projectFilePath, vivadoVHDLFile]
        XCTAssertTrue(files.allSatisfy { expected.contains($0) })
        XCTAssertEqual(Set(files).count, 2)
        XCTAssertEqual(
            try String(
                contentsOf: self.buildFolder.appendingPathComponent("vhdl/Machine0.vhd", isDirectory: false),
                encoding: .utf8
            ),
            try String(contentsOf: vivadoVHDLFile, encoding: .utf8)
        )
        XCTAssertEqual(previousProjectContents, try String(contentsOf: self.projectFilePath, encoding: .utf8))
    }

}
