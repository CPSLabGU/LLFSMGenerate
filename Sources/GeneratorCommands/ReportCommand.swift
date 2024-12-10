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

/// A command to produce human-readable information about an LLFSM.
///
/// This struct allows the generation of human-readable reports detailing the code within an LLFSM and other
/// statistics about the machine.
public struct ReportCommand: ParsableCommand {

    /// The command configuration.
    public static var configuration = CommandConfiguration(
        commandName: "report",
        abstract: "Report Statistics about the generated machine."
    )

    /// A helper JSON decoder.
    @inlinable var decoder: JSONDecoder {
        JSONDecoder()
    }

    /// A helper file manager.
    @inlinable var manager: FileManager {
        FileManager.default
    }

    /// A path to the machine to report.
    @OptionGroup @usableFromInline var path: PathArgument

    /// Whether to write the report to a file.
    @Option(name: .shortAndLong, help: "The output file to write the report to.")
    @usableFromInline var output: String?

    /// The url to the file to write the report to.
    @inlinable var outputURL: URL? {
        output.flatMap { URL(fileURLWithPath: $0, isDirectory: false) }
    }

    /// The default path to the generated kripke structure.
    @inlinable var kripkeStructureURL: URL {
        path.pathURL.appending(component: "output.json", directoryHint: .notDirectory)
    }

    /// Default init.
    @inlinable
    public init() {}

    /// Run the report.
    ///
    /// This method generates a human-readable version of the LLFSM and other statistics associated with the
    /// machine.
    @inlinable
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

    /// Write the given report to a file if it exists.
    ///
    /// This method attempts to write the contents of `report` to the `outputURL` if it is not `nil`.
    /// If the file already exists, it is removed before writing the new report. When the `outputURL` is
    /// `nil`, this method instead prints the report to the screen.
    /// - Parameter report: The report to write.
    @inlinable
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

/// Add helpers for report creation.
extension String {

    /// Create the report for a machine.
    ///
    /// This init generates a human-readable report containing the code and variables within a machine. The
    /// format is very similar to YAML and contains all of the relevant information about the design of the
    /// LLFSM.
    /// - Parameters:
    ///   - machine: The machine model to generate the report from.
    ///   - name: The name of the machine.
    @inlinable
    init(reportForMachine machine: MachineModel, name: String) {
        let stateData = machine.states.map { state in
            let actions = state.actions
                .compactMap {
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
        let clockData = machine.clocks
            .map {
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

    /// Generate the report for a Kripke structure.
    ///
    /// Create a report detailing the statistics of the machines kripke structure.
    /// - Parameter structure: The structure to create the report for.
    @inlinable
    init(reportForStructure structure: KripkeStructure) {
        let nodes = structure.nodes.count
        let edges = structure.edges.values.reduce(0) { $0 + $1.count }
        let data = """
            - Nodes: \(nodes)
            - Edges: \(edges)
            """
        self.init(category: "Kripke Structure", data: data)
    }

    /// Attempt to create a subsection within a report.
    ///
    /// This init attempts to create a subheading with name `category` within a report. If the `data` is
    /// empty, then only the subheading is returned. The subheading and data is formatted similar to YAML,
    /// via:
    /// ```
    /// - category:
    ///     data
    /// ```
    /// The data is indented by 4 spaces and newlined after the subheading.
    /// - Parameters:
    ///   - category: The category of the report to create a subheading from.
    ///   - data: The data to include in the new section.
    @inlinable
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
