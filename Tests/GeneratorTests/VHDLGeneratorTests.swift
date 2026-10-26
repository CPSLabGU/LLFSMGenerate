// VHDLGeneratorTests.swift
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
//

import Foundation
import SwiftUtils
import Testing
import VHDLKripkeStructureGenerator
import VHDLMachines
import VHDLParsing

@testable import GeneratorCommands

/// Test class for ``VHDLGenerator``.
@Suite
final class VHDLGeneratorTests: MachineTester {

    /// A Kripke structure generator.
    let generator = VHDLKripkeStructureGenerator()

    /// Test the main method generates the `VHDL` file correctly.
    @Test
    func testRunGeneratesVHDL() throws {
        let machine = Machine.machine0
        VHDLGenerator.main([pathRaw])
        let vhdlPath = machine0Path.appendingPathComponent("build/vhdl/Machine0.vhd", isDirectory: false)
        guard let representation = MachineRepresentation(machine: machine, name: .machine0) else {
            Issue.record("Failed to create VHDL for machine.")
            return
        }
        let vhdlFile = VHDLFile(representation: representation)
        #expect(vhdlFile.rawValue + "\n" == (try String(contentsOf: vhdlPath, encoding: .utf8)))
    }

    /// Test that the main method throws the correct error for an invalid machine.
    @Test
    func testRunThrowsErrorForInvalidMachine() throws {
        var machine = Machine.machine0
        guard let onEntry = VariableName(rawValue: "OnEntry") else {
            Issue.record("Failed to create machine.")
            return
        }
        machine.machineSignals += [LocalSignal(type: .stdLogic, name: onEntry)]
        let data = try encoder.encode(machine)
        try data.write(to: jsonFile)
        var generator = try VHDLGenerator.parseAsRoot([pathRaw])
        let error = #expect(throws: GenerationError.self) { try generator.run() }
        #expect(error == .invalidGeneration(message: "Failed to generate VHDL for Machine0."))
    }

    /// Test the correct error is thrown for paths without the correct extension.
    @Test
    func testPathWithoutExtension() throws {
        let invalidPath = self.machineScope.appendingPathComponent("invalid", isDirectory: true)
        try self.manager.copyItem(at: self.machine0Path, to: invalidPath)
        defer { _ = try? self.manager.removeItem(at: invalidPath) }
        var command = try VHDLGenerator.parse([invalidPath.path])
        let error = #expect(throws: GenerationError.self) { try command.run() }
        #expect(
            error
                == .invalidFormat(
                    message: "The machine specified is invalid. "
                        + "Please make sure you specify a machine with the .machine extension and valid name."
                )
        )
    }

    /// Test correct errors are thrown for paths with only the machine extension.
    @Test
    func testEmptyMachinePath() throws {
        let path = self.machineScope.appendingPathComponent(".machine", isDirectory: true)
        try self.manager.copyItem(at: self.machine0Path, to: path)
        defer { _ = try? self.manager.removeItem(at: path) }
        var command = try VHDLGenerator.parse([path.path])
        let error = #expect(throws: GenerationError.self) { try command.run() }
        #expect(
            error
                == .invalidFormat(
                    message: "The machine specified is invalid. "
                        + "Please make sure you specify a machine with the .machine extension and valid name."
                )
        )
    }

    /// Test that VHDL keyword in machine name throw an error.
    @Test
    func testVHDLNameInPath() throws {
        let path = self.machineScope.appendingPathComponent("signal.machine", isDirectory: true)
        try self.manager.copyItem(at: self.machine0Path, to: path)
        defer { _ = try? self.manager.removeItem(at: path) }
        var command = try VHDLGenerator.parse([path.path])
        let error = #expect(throws: GenerationError.self) { try command.run() }
        #expect(
            error
                == .invalidFormat(
                    message: "The machine specified is invalid. "
                        + "Please make sure you specify a machine with the .machine extension and valid name."
                )
        )
    }

    /// Test the VHDL generator creates the correct Kripke structure.
    @Test
    func testRunGeneratesKripkeStructure() throws {
        let machine = Machine.machine0
        VHDLGenerator.main(["--include-kripke-structure", pathRaw])
        guard
            let representation = MachineRepresentation(machine: machine, name: .machine0),
            let files = generator.generateAll(representation: representation)
        else {
            Issue.record("Failed to create VHDL for machine.")
            return
        }
        files.preferredFilename = "build"
        try assertContents(wrapper: files, parentFolder: machine0Path)
    }

    /// Test that the `VHDL` file is created correctly for an arrangement.
    @Test
    func testArrangementCreation() throws {
        Generate.main([self.arrangement1Folder.path])
        VHDLGenerator.main([self.arrangement1Folder.path])
        guard
            let contents = self.manager.contents(
                atPath: self.machineScope
                    .appendingPathComponent(
                        "Arrangement1.arrangement/build/vhdl/Arrangement1.vhd",
                        isDirectory: false
                    )
                    .path
            )
        else {
            Issue.record("File doesn't exist!")
            return
        }
        let expected = ArrangementRepresentation(
            arrangement: .pingArrangement,
            name: .arrangement1
        )?
        .file.rawValue
        #expect(expected != nil)
        #expect(String(data: contents, encoding: .utf8) == expected)
    }

    /// Test that invalid names are detected.
    @Test
    func testArrangementCreationFailsForInvalidName() throws {
        let newDir = self.machineScope.appendingPathComponent(
            "Arrangement1.new.arrangement",
            isDirectory: true
        )
        try self.manager.moveItem(at: self.arrangement1Folder, to: newDir)
        defer { try? self.manager.removeItem(at: newDir) }
        var command = try VHDLGenerator.parse([newDir.path])
        let error = #expect(throws: GenerationError.self) { try command.run() }
        #expect(
            error
                == .invalidFormat(
                    message: "The arrangement is not named correctly!"
                )
        )
    }

    /// Test that the arrangement creation works when `vhdl` folder already exists.
    @Test
    func testArrangementCreationWhenVHDLExists() throws {
        Generate.main([self.arrangement1Folder.path])
        VHDLGenerator.main([self.arrangement1Folder.path])
        VHDLGenerator.main([self.arrangement1Folder.path])
        guard
            let contents = self.manager.contents(
                atPath: self.machineScope
                    .appendingPathComponent(
                        "Arrangement1.arrangement/build/vhdl/Arrangement1.vhd",
                        isDirectory: false
                    )
                    .path
            )
        else {
            Issue.record("File doesn't exist!")
            return
        }
        let expected = ArrangementRepresentation(
            arrangement: .pingArrangement,
            name: .arrangement1
        )?
        .file.rawValue
        #expect(expected != nil)
        #expect(String(data: contents, encoding: .utf8) == expected)
    }

    /// Test that the arrangement creation works when machines are already compiled.
    @Test
    func testArrangementCreationWhenMachinesHaveVHDL() throws {
        Generate.main([self.pingMachineFolder.path])
        Generate.main([self.arrangement1Folder.path])
        VHDLGenerator.main([self.pingMachineFolder.path])
        VHDLGenerator.main([self.arrangement1Folder.path])
        guard
            let contents = self.manager.contents(
                atPath: self.machineScope
                    .appendingPathComponent(
                        "Arrangement1.arrangement/build/vhdl/Arrangement1.vhd",
                        isDirectory: false
                    )
                    .path
            )
        else {
            Issue.record("File doesn't exist!")
            return
        }
        let expected = ArrangementRepresentation(
            arrangement: .pingArrangement,
            name: .arrangement1
        )?
        .file.rawValue
        #expect(expected != nil)
        #expect(String(data: contents, encoding: .utf8) == expected)
    }

    /// Assert a file wrapper contents recursively against the file system.
    func assertContents(wrapper: FileWrapper, parentFolder: URL) throws {
        guard wrapper.isDirectory else {
            guard let name = wrapper.preferredFilename else {
                Issue.record("Failed to read file contents.")
                return
            }
            try assertContents(name: name, wrapper: wrapper, parentFolder: parentFolder)
            return
        }
        guard let files = wrapper.fileWrappers, let name = wrapper.preferredFilename else {
            let name = wrapper.preferredFilename ?? wrapper.filename ?? "<unknown file>"
            let wrapperString =
                "{ \(wrapper.isDirectory), \(wrapper.fileWrappers ?? [:]) }" + "\n\(parentFolder.path)"
            Issue.record("Failed to read file contents in \(name).\nWrapper: \(wrapperString)")
            return
        }
        let path = parentFolder.appendingPathComponent(name, isDirectory: true)
        try files.forEach { try assertContents(name: $0.0, wrapper: $0.1, parentFolder: path) }
    }

    /// Accumulator function for `assertContents`.
    func assertContents(name: String, wrapper: FileWrapper, parentFolder: URL) throws {
        guard !wrapper.isDirectory else {
            try assertContents(wrapper: wrapper, parentFolder: parentFolder)
            return
        }
        guard let data = wrapper.regularFileContents else {
            Issue.record("Failed to read file contents in \(name).")
            return
        }
        let contents = String(data: data, encoding: .utf8)
        let result = try String(
            contentsOf: parentFolder.appendingPathComponent("\(name)", isDirectory: false),
            encoding: .utf8,
        )
        #expect(contents == result)
    }

}
