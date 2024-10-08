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
import XCTest

@testable import GeneratorCommands

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
        self.vivadoPath.appendingPathComponent("\(vivadoName).srcs", isDirectory: true)
    }

    /// The path to the `sources_1` folder.
    var sources1Path: URL {
        self.vhdlSourcesPath.appendingPathComponent("sources_1", isDirectory: true)
    }

    /// The path to the `new` folder.
    var newPath: URL {
        self.sources1Path.appendingPathComponent("new", isDirectory: true)
    }

    /// The path to the project file.
    var projectFilePath: URL {
        self.vivadoPath.appendingPathComponent("\(vivadoName).xpr", isDirectory: false)
    }

    /// Setup install locations before every run.
    override func setUp() {
        super.setUp()
        let projectContents = Data("project file!".utf8)
        guard
            (try? self.manager.createDirectory(at: vivadoPath, withIntermediateDirectories: true)) != nil,
            manager.createFile(atPath: self.projectFilePath.path, contents: projectContents),
            (try? self.manager.createDirectory(at: newPath, withIntermediateDirectories: true)) != nil
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

    /// Test the computed properties create the correct values.
    func testComputedProperties() throws {
        let command = try InstallCommand.parse([self.machine0Path.path, self.vivadoPath.path])
        XCTAssertEqual(command.installURL, self.vivadoPath)
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
        let expected: Set<String> = [self.projectFilePath.path, vivadoVHDLFile.path]
        XCTAssertTrue(files.map(\.path).allSatisfy { expected.contains($0) })
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

    /// Test files are copied for vivado installation.
    func testInstallCommandWorksForVivado() throws {
        let previousProjectContents = try String(contentsOf: self.projectFilePath, encoding: .utf8)
        InstallCommand.main([self.machine0Path.path, "--vivado", self.vivadoPath.path])
        XCTAssertEqual(try String(contentsOf: self.projectFilePath, encoding: .utf8), previousProjectContents)
        let projectFiles = try manager.contentsOfDirectory(
            at: self.vivadoPath,
            includingPropertiesForKeys: nil
        )
        XCTAssertEqual(projectFiles.count, 2)
        XCTAssertEqual(Set(projectFiles).count, 2)
        let expected: Set<String> = [self.projectFilePath.path, self.vhdlSourcesPath.path]
        XCTAssertTrue(projectFiles.map(\.path).allSatisfy(expected.contains))
        XCTAssertEqual(
            try manager.contentsOfDirectory(at: self.vhdlSourcesPath, includingPropertiesForKeys: nil)
                .map(\.path),
            [self.sources1Path.path]
        )
        XCTAssertEqual(
            try manager.contentsOfDirectory(at: self.sources1Path, includingPropertiesForKeys: nil)
                .map(\.path),
            [self.newPath.path]
        )
        let vhdlFiles = try manager.contentsOfDirectory(at: self.newPath, includingPropertiesForKeys: nil)
        XCTAssertEqual(
            vhdlFiles.map(\.path),
            [self.newPath.appendingPathComponent("Machine0.vhd", isDirectory: false).path]
        )
        let vhdlFilePath = self.buildFolder.appendingPathComponent("vhdl/Machine0.vhd", isDirectory: false)
        let contents = try String(contentsOf: vhdlFilePath, encoding: .utf8)
        XCTAssertEqual(contents, try String(contentsOf: vhdlFilePath, encoding: .utf8))
    }

    /// Test that an error is thrown for folders without the `.machine` extension.
    func testThrowsErrorForIncorrectMachineFolder() throws {
        let command = try InstallCommand.parse([self.machinesFolder.path, self.vivadoPath.path])
        XCTAssertThrowsError(try command.run()) {
            guard let error = $0 as? GenerationError else {
                XCTFail("Error is not of type GenerationError.")
                return
            }
            XCTAssertEqual(error, .invalidMachine(message: "The path provided is not a machine."))
        }
    }

    /// Test that the correct error is thrown for a file path to the machine.
    func testThrowsErrorForFilePath() throws {
        let newFile = self.vivadoPath.appendingPathComponent("Machine0.machine", isDirectory: false)
        XCTAssertTrue(self.manager.createFile(atPath: newFile.path, contents: Data("new file".utf8)))
        let command = try InstallCommand.parse([newFile.path, self.vivadoPath.path])
        XCTAssertThrowsError(try command.run()) {
            guard let error = $0 as? GenerationError else {
                XCTFail("Error is not of type GenerationError.")
                return
            }
            XCTAssertEqual(error, .invalidMachine(message: "The path provided is not a valid machine."))
        }
    }

    /// Test that the correct error is thrown for an invalid install location.
    func testThrowsErrorForInvalidInstallLocation() throws {
        let command = try InstallCommand.parse([self.machine0Path.path, self.projectFilePath.path])
        XCTAssertThrowsError(try command.run()) {
            guard let error = $0 as? GenerationError else {
                XCTFail("Error is not of type GenerationError.")
                return
            }
            XCTAssertEqual(error, .invalidInput(message: "The install directory is incorrect."))
        }
    }

    /// Test that the correct error is thrown when the VHDL files are not generated.
    func testThrowsErrorForMissingBuildFolder() throws {
        try manager.removeItem(at: self.buildFolder)
        let command = try InstallCommand.parse([self.machine0Path.path, self.vivadoPath.path])
        XCTAssertThrowsError(try command.run()) {
            guard let error = $0 as? GenerationError else {
                XCTFail("Error is not of type GenerationError.")
                return
            }
            XCTAssertEqual(
                error,
                .invalidGeneration(
                    message: "The build folder does not exist. Have you generated the VHDL files?"
                )
            )
        }
    }

    /// Test that the correct error is thrown when untracked files are placed in the build folder.
    func testThrowsErrorForCorruptedBuildFolder() throws {
        let corruptedFile = self.buildFolder.appendingPathComponent("vhdl/Machine0", isDirectory: false)
        XCTAssertTrue(
            self.manager.createFile(
                atPath: corruptedFile.path,
                contents: Data("corrupted".utf8)
            )
        )
        let command = try InstallCommand.parse([self.machine0Path.path, self.vivadoPath.path])
        XCTAssertThrowsError(try command.run()) {
            guard let error = $0 as? GenerationError else {
                XCTFail("Error is not of type GenerationError.")
                return
            }
            XCTAssertEqual(
                error,
                .invalidGeneration(
                    message: "The build folder is corrupted! Please regenerate the VHDL files."
                )
            )
        }
    }

    /// Test that the correct error is thrown when the vivado project is invalid.
    func testVivadoGenerationThrowsErrorForInvalidVivadoProject() throws {
        try manager.removeItem(at: self.projectFilePath)
        let command = try InstallCommand.parse([self.machine0Path.path, "--vivado", self.vivadoPath.path])
        XCTAssertThrowsError(try command.run()) {
            guard let error = $0 as? GenerationError else {
                XCTFail("Error is not of type GenerationError.")
                return
            }
            XCTAssertEqual(
                error,
                .invalidInput(message: "The install directory is not a valid vivado project.")
            )
        }
    }

    /// Test that the correct error is thrown when the vivado project is missing key folders.
    func testVivadoGenerationThrowsErrorForCorruptedVivadoProject() throws {
        try manager.removeItem(at: self.vhdlSourcesPath)
        let command = try InstallCommand.parse([self.machine0Path.path, "--vivado", self.vivadoPath.path])
        XCTAssertThrowsError(try command.run()) {
            guard let error = $0 as? GenerationError else {
                XCTFail("Error is not of type GenerationError.")
                return
            }
            XCTAssertEqual(
                error,
                .invalidInput(message: "The vivado project is not set up correctly.")
            )
        }
    }

}
