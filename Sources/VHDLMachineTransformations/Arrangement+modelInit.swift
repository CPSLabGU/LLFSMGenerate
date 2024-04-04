// Arrangement+modelInit.swift
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

import Foundation
import JavascriptModel
import VHDLMachines
import VHDLParsing

extension Arrangement {

    public init?(model: ArrangementModel) {
        let decoder = JSONDecoder()
        let machineTuples: [(VariableName, MachineMapping)] = model.machines
            .compactMap { (reference: MachineReference) -> (VariableName, MachineMapping)? in
                guard
                    let name = VariableName(rawValue: reference.name),
                    let data = try? Data(
                        contentsOf: URL(fileURLWithPath: reference.path, isDirectory: true)
                            .appendingPathComponent("model.json", isDirectory: false)
                    ),
                    let machine = try? decoder.decode(Machine.self, from: data)
                else {
                    return nil
                }
                let mappings: [[VHDLMachines.VariableMapping]] = model.machines.compactMap {
                    let mappings: [VHDLMachines.VariableMapping] = $0.mappings.compactMap {
                        guard
                            let source = VariableName(rawValue: $0.source),
                            let destination = VariableName(rawValue: $0.destination)
                        else {
                            return nil
                        }
                        return VHDLMachines.VariableMapping(source: source, destination: destination)
                    }
                    guard mappings.count == $0.mappings.count else {
                        return nil
                    }
                    return mappings
                }
                guard
                    mappings.count == model.machines.count,
                    let mapping = MachineMapping(machine: machine, with: mappings.flatMap { $0 })
                else {
                    return nil
                }
                return (name, mapping)
            }
        guard machineTuples.count == Set(machineTuples.map { $0.0 }).count else {
            return nil
        }
        let machines = Dictionary(uniqueKeysWithValues: machineTuples)
        let externalsRaw = model.externalVariables.components(separatedBy: ";")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let externalSignals = externalsRaw.compactMap { PortSignal(rawValue: $0 + ";") }
        guard externalSignals.count == externalsRaw.count else {
            return nil
        }
        let signalsRaw = model.globalVariables.components(separatedBy: ";")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let localSignals = signalsRaw.compactMap { LocalSignal(rawValue: $0 + ";") }
        guard localSignals.count == signalsRaw.count else {
            return nil
        }
        let clocks = model.clocks.compactMap { Clock(model: $0) }
        guard clocks.count == model.clocks.count else {
            return nil
        }
        let clockNames = clocks.map(\.name)
        let signalNames = localSignals.map(\.name) + externalSignals.map(\.name)
        let machineNames: [VariableName] = Array(machines.keys)
        let allNames = clockNames + signalNames + machineNames
        guard Set(allNames).count == allNames.count else {
            return nil
        }
        self.init(
            machines: machines,
            externalSignals: externalSignals,
            signals: localSignals,
            clocks: clocks
        )
    }

}
