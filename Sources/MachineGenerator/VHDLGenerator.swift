// VHDLGenerator.swift
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

import ArgumentParser
import Foundation
import JavascriptModel
import SwiftUtils
import VHDLKripkeStructureGenerator
import VHDLMachines
import VHDLParsing

/// A sub-command that generates VHDL source files from LLFSM definitions.
struct VHDLGenerator: ParsableCommand {

    /// The configuration for the command.
    static var configuration = CommandConfiguration(
        commandName: "vhdl",
        abstract: "A utility for generating VHDL source files from LLFSM definitions."
    )

    /// Whether to include the Kripke Structure generator program with the machine.
    @Flag(help: "Create the Kripke Structure generator program with the machine.")
    var includeKripkeStructure = false

    /// The shared options between other subcommands.
    @OptionGroup var options: PathArgument

    /// Runs the command.
    @inlinable
    mutating func run() throws {
        guard !options.pathURL.lastPathComponent.lowercased().hasSuffix(".arrangement") else {
            try createArrangement()
            return
        }
        let buildFolder = options.pathURL.appendingPathComponent("build", isDirectory: true)
        try self.createMachine(sourcePath: options.pathURL, destinationPath: buildFolder)
    }

    func createArrangement() throws {
        let nameRaw = options.pathURL.lastPathComponent.dropLast(".arrangement".count)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        guard !nameRaw.isEmpty, let name = VariableName(rawValue: nameRaw) else {
            throw GenerationError.invalidFormat(message: "The arrangement is not named correctly!")
        }
        let decoder = JSONDecoder()
        let modelData = try Data(
            contentsOf: options.pathURL.appendingPathComponent("model.json", isDirectory: false)
        )
        let model = try decoder.decode(ArrangementModel.self, from: modelData)
        let arrangementFile = options.pathURL.appendingPathComponent("arrangement.json", isDirectory: false)
        let data = try Data(contentsOf: arrangementFile)
        let arrangement = try decoder.decode(Arrangement.self, from: data)
        let f: (Machine, VariableName) -> MachineRepresentation? = {
            MachineRepresentation(machine: $0, name: $1)
        }
        guard
            let representation = ArrangementRepresentation(
                arrangement: arrangement, name: name, createMachine: f
            ),
            let vhdlFile = representation.file.rawValue.data(using: .utf8)
        else {
            throw GenerationError.invalidFormat(message: "The arrangement contains invalid data!")
        }
        let buildFolder = options.pathURL.appendingPathComponent("build", isDirectory: true)
        let vhdlFolder = buildFolder.appendingPathComponent("vhdl", isDirectory: true)
        let destination = vhdlFolder.appendingPathComponent(
            "\(name.rawValue).vhd", isDirectory: false
        )
        let manager = FileManager.default
        if manager.fileExists(atPath: vhdlFolder.path) {
            try manager.removeItem(at: vhdlFolder)
        }
        try manager.createDirectory(at: vhdlFolder, withIntermediateDirectories: true)
        try model.machines.forEach {
            let path = URL(fileURLWithPath: $0.path, isDirectory: true)
            var cleanCommand = try CleanCommand.parse([path.path])
            try cleanCommand.run()
            var generateCommand = try Generate.parse([path.path])
            try generateCommand.run()
            var vhdlCommand = try VHDLGenerator.parse([path.path])
            try vhdlCommand.run()
            let machineVHDLFolder = path.appendingPathComponent("build/vhdl", isDirectory: true)
            let files = try manager.contentsOfDirectory(
                at: machineVHDLFolder, includingPropertiesForKeys: nil
            )
            guard files.allSatisfy({ $0.lastPathComponent.lowercased().hasSuffix(".vhd") }) else {
                throw GenerationError.invalidGeneration(
                    message: "Failed to generate VHDL for machine \(path.lastPathComponent)"
                )
            }
            try files.forEach {
                let target = vhdlFolder.appendingPathComponent($0.lastPathComponent, isDirectory: false)
                if manager.fileExists(atPath: target.path) {
                    try manager.removeItem(at: target)
                }
                try manager.copyItem(at: $0, to: target)
            }
        }
        if manager.fileExists(atPath: destination.path) {
            try manager.removeItem(at: destination)
        }
        try vhdlFile.write(to: destination, options: .atomic)
    }

    func createMachine(sourcePath: URL, destinationPath: URL) throws {
        let path = sourcePath.appendingPathComponent("machine.json", isDirectory: false)
        let data = try Data(contentsOf: path)
        let machine = try JSONDecoder().decode(Machine.self, from: data)
        let nameRaw = sourcePath.lastPathComponent
        guard
            nameRaw.hasSuffix(".machine"),
            nameRaw != ".machine",
            let name = VariableName(rawValue: String(nameRaw.dropLast(8)))
        else {
            throw GenerationError.invalidFormat(
                message: "The machine specified is invalid. " +
                    "Please make sure you specify a machine with the .machine extension and valid name."
            )
        }
        guard let representation = MachineRepresentation(machine: machine, name: name) else {
            throw GenerationError.invalidGeneration(
                message: "Failed to generate VHDL for \(name.rawValue)."
            )
        }
        let buildFolder = destinationPath
        guard includeKripkeStructure else {
            let file = VHDLFile(representation: representation)
            let vhdlFolder = buildFolder.appendingPathComponent("vhdl", isDirectory: true)
            let vhdlPath = vhdlFolder.appendingPathComponent(
                "\(representation.entity.name.rawValue).vhd", isDirectory: false
            )
            try FileManager.default.createDirectory(at: vhdlFolder, withIntermediateDirectories: true)
            try (file.rawValue + "\n").write(to: vhdlPath, atomically: true, encoding: .utf8)
            return
        }
        guard let files = VHDLKripkeStructureGenerator().generateAll(representation: representation) else {
            throw GenerationError.invalidGeneration(
                message: "Failed to generate Kripke Structure for \(name.rawValue)."
            )
        }
        try files.write(to: buildFolder, options: .atomic, originalContentsURL: nil)
    }

}
