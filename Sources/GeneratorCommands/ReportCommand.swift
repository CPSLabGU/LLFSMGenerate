// ReportCommand.swift
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
import JavascriptModel
import StringHelpers
import VHDLKripkeStructures

public struct ReportCommand: ParsableCommand {

    /// The command configuration.
    public static var configuration = CommandConfiguration(
        commandName: "report",
        abstract: "Report Statistics about the generated machine."
    )

    @inlinable var decoder: JSONDecoder {
        JSONDecoder()
    }

    @inlinable var manager: FileManager {
        FileManager.default
    }

    /// A path to the machine to report.
    @OptionGroup @usableFromInline var path: PathArgument

    @Option(name: .shortAndLong, help: "The output file to write the report to.")
    @usableFromInline var output: String?

    @inlinable var outputURL: URL? {
        output.flatMap { URL(fileURLWithPath: $0, isDirectory: false) }
    }

    @inlinable var kripkeStructureURL: URL {
        path.pathURL.appending(component: "output.json", directoryHint: .notDirectory)
    }

    /// Default init.
    @inlinable
    public init() {}

    public func run() throws {
        let structurePath = self.kripkeStructureURL.path
        let data = try Data(contentsOf: path.pathURL.appendingPathComponent("model.json", isDirectory: false))
        let machine = try decoder.decode(MachineModel.self, from: data)
        let machineReport = String(reportForMachine: machine, name: path.pathURL.lastPathComponent)
        guard manager.fileExists(atPath: structurePath) else {
            try writeReport(report: String(category: "Machine", data: machineReport) + "\n")
            return
        }
        let structureData = try Data(contentsOf: kripkeStructureURL)
        let kripkeStructure = try decoder.decode(KripkeStructure.self, from: structureData)
        let structureReport = String(reportForStructure: kripkeStructure)
        let report = """
        \(String(category: "Machine", data: machineReport))
        \(String(category: "Kripke Structure", data: structureReport))

        """
        try writeReport(report: report)
    }

    func writeReport(report: String) throws {
        guard let outputURL else {
            print(report)
            return
        }
        if manager.fileExists(atPath: outputURL.path) {
            try manager.removeItem(at: outputURL)
        }
        try report.write(to: outputURL, atomically: true, encoding: .utf8)
    }

}

extension String {

    init(reportForMachine machine: MachineModel, name: String) {
        let stateData = machine.states.map { state in
            let actions = state.actions.compactMap {
                guard !$0.code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                    return nil
                }
                return """
                - \($0.name):
                \($0.code.indent(amount: 1))
                """
            }
            .joined(separator: "\n\n")
            let transitions = machine.transitions.filter { $0.source == state.name }
                .enumerated()
                .map {
                    "- \($0): \($1.condition)"
                }
                .joined(separator: "\n")
            let stateInfo = """
            \(String(category: "External Variables", data: state.externalVariables))
            \(String(category: "State Variables", data: state.variables))
            \(String(category: "Actions", data: actions))
            \(String(category: "Transitions", data: transitions))
            """
            return String(category: state.name, data: stateInfo)
        }
        let clockData = machine.clocks.map {
            """
            - \($0.name) \($0.frequency)
            """
        }
        .joined(separator: "\n")
        let machineInfo = """
        \(String(category: "External Variables", data: machine.externalVariables))
        \(String(category: "Machine Variables", data: machine.machineVariables))
        \(String(category: "Clocks", data: clockData))
        \(String(category: "States", data: stateData.joined(separator: "\n")))
        \(String(category: "Initial State", data: machine.initialState))
        \(String(category: "Suspended State", data: machine.suspendedState ?? ""))
        \(String(category: "Includes", data: machine.includes))
        """
        self.init(category: name, data: machineInfo)
    }

    init(reportForStructure structure: KripkeStructure) {
        let nodes = structure.nodes.count
        let edges = structure.edges.values.reduce(0) { $0 + $1.count }
        let data = """
        - Nodes: \(nodes)
        - Edges: \(edges)
        """
        self.init(category: "Kripke Structure", data: data)
    }

    init(category: String, data: String) {
        if data.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            self = "- \(category):"
        } else {
            self = """
            - \(category):
            \(data.indent(amount: 1))
            """
        }
    }

}
