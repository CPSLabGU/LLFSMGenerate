// Machine+jsInit.swift
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
import JavascriptModel
import VHDLMachines
import VHDLParsing

extension Machine {

    public init?(model: MachineModel, path: URL? = nil) {
        let actionNames = Set(model.states.flatMap { $0.actions.map(\.name) })
        let actionVariableNames = actionNames.compactMap(VariableName.init(rawValue:))
        guard actionVariableNames.count == actionNames.count else {
            return nil
        }
        let getStatements: (String) -> [String] = {
            $0.components(separatedBy: ";")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
                .map { $0 + ";" }
        }
        let includes = getStatements(model.includes)
        let parsedIncludes = includes.compactMap { Include(rawValue: $0) }
        guard parsedIncludes.count == includes.count else {
            return nil
        }
        let machineSignalsRaw = getStatements(model.machineVariables)
        let machineSignals = machineSignalsRaw.compactMap { LocalSignal(rawValue: $0) }
        guard machineSignalsRaw.count == machineSignals.count else {
            return nil
        }
        let name = path?.deletingPathExtension().lastPathComponent ?? "Machine0"
        let machinePath = path ?? URL(fileURLWithPath: "/tmp/Machine0.machine", isDirectory: true)
        guard let machineName = VariableName(rawValue: name) else {
            return nil
        }
        let externalsRaw = model.externalVariables.components(separatedBy: ";")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { $0 +  ";" }
        let externalSignals = externalsRaw.compactMap(PortSignal.init(rawValue:))
        guard externalsRaw.count == externalSignals.count else {
            return nil
        }
        let clocks = model.clocks.compactMap(Clock.init(model:))
        guard clocks.count == model.clocks.count, !clocks.isEmpty else {
            return nil
        }
        let states = model.states.compactMap { State(model: $0) }
        guard states.count == model.states.count else {
            return nil
        }
        let transitions = model.transitions.compactMap { Transition(model: $0, states: states) }
        guard
            transitions.count == model.transitions.count,
            let initialName = VariableName(rawValue: model.initialState),
            let initialState = states.firstIndex(where: { $0.name == initialName })
        else {
            return nil
        }
        var suspendedIndex: Int?
        if let suspendedState = model.suspendedState {
            guard
                let suspendedName = VariableName(rawValue: suspendedState),
                let index = states.firstIndex(where: { $0.name == suspendedName })
            else {
                return nil
            }
            suspendedIndex = index
        }
        self.init(
            actions: actionVariableNames,
            name: machineName,
            path: machinePath,
            includes: parsedIncludes,
            externalSignals: externalSignals,
            clocks: clocks,
            drivingClock: 0,
            dependentMachines: [:],
            machineSignals: machineSignals,
            isParameterised: false,
            parameterSignals: [],
            returnableSignals: [],
            states: states,
            transitions: transitions,
            initialState: initialState,
            suspendedState: suspendedIndex,
            architectureHead: nil,
            architectureBody: nil
        )
    }

}
