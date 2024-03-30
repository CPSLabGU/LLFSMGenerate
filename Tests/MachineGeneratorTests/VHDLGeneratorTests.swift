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
@testable import MachineGenerator
import VHDLKripkeStructureGenerator
import VHDLMachines
import VHDLParsing
import XCTest

#if os(Linux)
import IO
#endif

/// Test class for ``VHDLGenerator``.
final class VHDLGeneratorTests: MachineTester {

    /// A Kripke structure generator.
    let generator = VHDLKripkeStructureGenerator()

    /// Test the main method generates the `VHDL` file correctly.
    func testRunGeneratesVHDL() throws {
        guard let machine = Machine(machine0LocatedInFolder: self.machine0Path) else {
            XCTFail("Failed to create machine.")
            return
        }
        VHDLGenerator.main([pathRaw])
        let vhdlPath = machine0Path.appendingPathComponent("build/Machine0.vhd", isDirectory: false)
        guard let representation = MachineRepresentation(machine: machine) else {
            XCTFail("Failed to create VHDL for machine.")
            return
        }
        let vhdlFile = VHDLFile(representation: representation)
        XCTAssertEqual(vhdlFile.rawValue + "\n", try String(contentsOf: vhdlPath))
    }

    /// Test that the main method throws the correct error for an invalid machine.
    func testRunThrowsErrorForInvalidMachine() throws {
        guard
            var machine = Machine(machine0LocatedInFolder: self.machine0Path),
            let onEntry = VariableName(rawValue: "OnEntry")
        else {
            XCTFail("Failed to create machine.")
            return
        }
        machine.machineSignals += [LocalSignal(type: .stdLogic, name: onEntry)]
        let data = try encoder.encode(machine)
        try data.write(to: jsonFile)
        var generator = try VHDLGenerator.parseAsRoot([pathRaw])
        XCTAssertThrowsError(try generator.run()) {
            guard let error = $0 as? GenerationError else {
                XCTFail("Thrown incorrect error.")
                return
            }
            XCTAssertEqual(error, .invalidGeneration(message: "Failed to generate VHDL for Machine0."))
        }
    }

    /// Test the VHDL generator creates the correct Kripke structure.
    func testRunGeneratesKripkeStructure() throws {
        guard let machine = Machine(machine0LocatedInFolder: self.machine0Path) else {
            XCTFail("Failed to create machine.")
            return
        }
        VHDLGenerator.main(["--include-kripke-structure", pathRaw])
        guard
            let representation = MachineRepresentation(machine: machine),
            let files = generator.generateAll(representation: representation)
        else {
            XCTFail("Failed to create VHDL for machine.")
            return
        }
        files.preferredFilename = "build"
        try assertContents(wrapper: files, parentFolder: machine0Path)
    }

    /// Assert a file wrapper contents recursively against the file system.
    func assertContents(wrapper: FileWrapper, parentFolder: URL) throws {
        guard
            wrapper.isDirectory, let files = wrapper.fileWrappers, let name = wrapper.preferredFilename
        else {
            XCTFail("Failed to read file contents in \(wrapper.preferredFilename ?? "<unknown file>").")
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
        guard
            let data = wrapper.regularFileContents, let contents = String(data: data, encoding: .utf8)
        else {
            XCTFail("Failed to read file contents in \(name).")
            return
        }
        #if os(macOS)
            let result = try String(
                    contentsOf: parentFolder.appendingPathComponent("\(name)", isDirectory: false)
                )
                .replacingOccurrences(of: "\r", with: "\n")
        #else
            let result = try String(
                contentsOf: parentFolder.appendingPathComponent("\(name)", isDirectory: false)
            )
        #endif
        XCTAssertEqual(contents, result)
    }

}
