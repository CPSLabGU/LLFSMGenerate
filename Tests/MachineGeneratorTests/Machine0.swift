// Machine0.swift
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

    init?(machine0LocatedInFolder path: URL) {
        let machine0Path = path.appendingPathComponent("Machine0.machine", isDirectory: true)
        guard var machine = Machine.initial(path: machine0Path) else {
            return nil
        }
        machine.name = .machine0
        machine.externalSignals = [
            PortSignal(type: .stdLogic, name: .x, mode: .input),
            PortSignal(type: .stdLogic, name: .y, mode: .output)
        ]
        machine.clocks = [
            Clock(name: .clk, frequency: 50, unit: .MHz)
        ]
        machine.drivingClock = 0
        machine.isParameterised = false
        machine.suspendedState = nil
        machine.machineSignals = [
            LocalSignal(type: .stdLogic, name: .machineX)
        ]
        machine.parameterSignals = []
        machine.returnableSignals = []
        machine.states = [
            State(
                name: .initial,
                actions: [
                    .onEntry: .statement(statement: .assignment(
                        name: .variable(reference: .variable(name: .initialX)),
                        value: .logical(operation: .and(
                            lhs: .reference(variable: .variable(reference: .variable(name: .x))),
                            rhs: .reference(variable: .variable(reference: .variable(name: .machineX)))
                        ))
                    )),
                    .onExit: .statement(statement: .assignment(
                        name: .variable(reference: .variable(name: .y)),
                        value: .reference(variable: .variable(reference: .variable(name: .initialX)))
                    ))
                ],
                signals: [LocalSignal(type: .stdLogic, name: .initialX)],
                externalVariables: [.x, .y]
            ),
            State(
                name: .finished,
                actions: [:],
                signals: [],
                externalVariables: []
            )
        ]
        machine.initialState = 0
        machine.transitions = [
            Transition(condition: .conditional(condition: .literal(value: true)), source: 0, target: 1)
        ]
        machine.includes = [
            .library(value: .ieee),
            .include(statement: UseStatement(nonEmptyComponents: [
                .module(name: .ieee),
                .module(name: VariableName(rawValue: "std_logic_1164")!),
                .all
            ])!),
            .include(statement: UseStatement(nonEmptyComponents: [
                .module(name: .ieee),
                .module(name: VariableName(rawValue: "math_real")!),
                .all
            ])!)
        ]
        self = machine
    }

}

extension MachineModel {

    static let machine0 = MachineModel(
        states: [
            StateModel(
                name: "Initial",
                variables: "signal InitialX: std_logic;",
                externalVariables: "x\ny",
                actions: [
                    ActionModel(name: "OnEntry", code: "InitialX <= x and machineX;"),
                    ActionModel(name: "OnExit", code: "y <= InitialX;")
                ],
                layout: StateLayout(
                    position: Point2D(x: 0.0, y: 0.0),
                    dimensions: Point2D(x: 200.0, y: 100.0)
                )
            ),
            StateModel(
                name: "Finished", variables: "", externalVariables: "", actions: [], layout: StateLayout(
                    position: Point2D(x: 0.0, y: 300.0), dimensions: Point2D(x: 200.0, y: 100.0)
                )
            )
        ],
        externalVariables: "x: in std_logic;\ny: out std_logic;",
        machineVariables: "signal machineX: std_logic;",
        includes: "library IEEE;\nuse IEEE.std_logic_1164.all;\nuse IEEE.math_real.all;",
        transitions: [
            TransitionModel(
                source: "Initial", target: "Finished", condition: "true", layout: TransitionLayout(
                    path: BezierPath(
                        source: Point2D(x: 100.0, y: 100.0),
                        target: Point2D(x: 100.0, y: 300.0),
                        control0: Point2D(x: 100.0, y: 175.0),
                        control1: Point2D(x: 100.0, y: 250.0)
                    )
                )
            )
        ],
        initialState: "Initial",
        suspendedState: nil,
        clocks: [ClockModel(name: "clk", frequency: "50 MHz")]
    )

}

extension VariableName {

    static let clk = VariableName(rawValue: "clk")!

    static let ieee = VariableName(rawValue: "IEEE")!

    static let finished = VariableName(rawValue: "Finished")!

    static let initial = VariableName(rawValue: "Initial")!

    static let initialX = VariableName(rawValue: "InitialX")!

    static let `internal` = VariableName(rawValue: "Internal")!

    static let machine0 = VariableName(rawValue: "Machine0")!

    static let machineX = VariableName(rawValue: "machineX")!

    static let onEntry = VariableName(rawValue: "OnEntry")!

    static let onExit = VariableName(rawValue: "OnExit")!

    static let x = VariableName(rawValue: "x")!

    static let y = VariableName(rawValue: "y")!

}
