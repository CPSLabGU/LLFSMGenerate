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

/// Add conversion initialiser between ``ArrangementModel`` and `Arrangement`.
extension Arrangement {

    /// Create an `Arrangement` from its javascript representation.
    /// - Parameter model: The javascript model to convert.
    /// - Parameter basePath: The path of the directory containing the arrangement folder.
    @inlinable
    public init?(model: ArrangementModel, basePath: URL) {
        let keyNames = model.machines.map(\.name)
        guard keyNames.count == Set(keyNames).count else {
            return nil
        }
        let machineTuples: [(MachineInstance, MachineMapping)] = model.machines
            .compactMap { (reference: MachineReference) -> (MachineInstance, MachineMapping)? in
                guard
                    let instance = MachineInstance(reference: reference),
                    let mapping = MachineMapping(reference: reference, basePath: basePath)
                else {
                    return nil
                }
                return (instance, mapping)
            }
        guard
            machineTuples.count == model.machines.count,
            machineTuples.count == Set(machineTuples.map { $0.0 }).count
        else {
            return nil
        }
        let machines = Dictionary(uniqueKeysWithValues: machineTuples)
        let externalsRaw = model.externalVariables.components(separatedBy: ";")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let externalSignals = externalsRaw.compactMap { PortSignal(rawValue: $0 + ";") }
        let signalsRaw = model.globalVariables.components(separatedBy: ";")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        let localSignals = signalsRaw.compactMap { LocalSignal(rawValue: $0 + ";") }
        let clocks = model.clocks.compactMap { Clock(model: $0) }
        let clockNames = clocks.map(\.name)
        let signalNames = localSignals.map(\.name) + externalSignals.map(\.name)
        let allNames = clockNames + signalNames
        let globalMappings = model.globalMappings.compactMap {
            VHDLMachines.VariableMapping(mapping: $0)
        }
        guard
            externalSignals.count == externalsRaw.count,
            localSignals.count == signalsRaw.count,
            clocks.count == model.clocks.count,
            globalMappings.count == model.globalMappings.count,
            Set(allNames).count == allNames.count
        else {
            return nil
        }
        self.init(
            mappings: machines,
            externalSignals: externalSignals,
            signals: localSignals,
            clocks: clocks,
            globalMappings: globalMappings
        )
    }

}

/// Add init from javascript model.
extension MachineInstance {

    /// Create a `MachineInstace` from its javascript model.
    /// - Parameter reference: The ``MachineReferece`` js model to convert.
    @inlinable
    init?(reference: MachineReference) {
        let url = URL(fileURLWithPath: reference.path, isDirectory: true)
        let nameRaw = url.lastPathComponent
        guard
            nameRaw.hasSuffix(".machine"),
            let name = VariableName(rawValue: reference.name),
            let type = VariableName(rawValue: String(nameRaw.dropLast(8)))
        else {
            return nil
        }
        self.init(name: name, type: type)
    }

}

/// Add init from js model.
extension MachineMapping {

    /// Create a `MachineMapping` from its javascript model.
    /// - Parameter reference: The ``MachineReferece`` js model to convert.
    /// - Parameter basePath: The path of the directory containing the arrangement folder.
    @inlinable
    init?(reference: MachineReference, basePath: URL) {
        let url = URL(fileURLWithPath: reference.path, isDirectory: true, relativeTo: basePath)
            .appendingPathComponent("model.json", isDirectory: false)
        print(url.path)
        fflush(stdout)
        guard
            let data = try? Data(contentsOf: url),
            let machineModel = try? JSONDecoder().decode(MachineModel.self, from: data),
            let machine = Machine(model: machineModel)
        else {
            return nil
        }
        let mappings: [VHDLMachines.VariableMapping] = reference.mappings.compactMap {
            VHDLMachines.VariableMapping(mapping: $0)
        }
        guard mappings.count == reference.mappings.count else {
            return nil
        }
        self.init(machine: machine, with: mappings)
    }

}

/// Add init from js model.
extension VHDLMachines.VariableMapping {

    /// Create a `VariableMapping` from its javascript model.
    /// - Parameter mapping: The ``VariableMapping`` js model to convert.
    @inlinable
    init?(mapping: JavascriptModel.VariableMapping) {
        guard
            let source = VariableName(rawValue: mapping.source),
            let destination = VariableName(rawValue: mapping.destination)
        else {
            return nil
        }
        self.init(source: source, destination: destination)
    }

}
