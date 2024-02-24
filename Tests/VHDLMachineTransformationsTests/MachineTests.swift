// MachineTests.swift
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

import JavascriptModel
import VHDLMachines
@testable import VHDLMachineTransformations
import VHDLParsing
import XCTest

/// Test class for `Machine` extensions.
final class MachineTests: XCTestCase {

    /// The default states in the machine under test.
    let states = [
        StateModel(
            name: "state1",
            variables: "signal s1_x: std_logic;",
            externalVariables: "y",
            actions: [
                ActionModel(name: "OnExit", code: "y <= s1_x;")
            ],
            layout: StateLayout(position: Point2D(x: 0, y: 0), dimensions: Point2D(x: 1, y: 1))
        ),
        StateModel(
            name: "state2",
            variables: "signal s2_x: std_logic;",
            externalVariables: "",
            actions: [
                ActionModel(name: "OnEntry", code: "s2_x <= '0';")
            ],
            layout: StateLayout(position: Point2D(x: 2, y: 2), dimensions: Point2D(x: 3, y: 3))
        )
    ]

    /// The default transitions in this machine.
    let transitions = [
        TransitionModel(
            source: "state1",
            target: "state2",
            condition: "true",
            layout: TransitionLayout(path: BezierPath(
                source: Point2D(x: 1, y: 1),
                target: Point2D(x: 2, y: 2),
                control0: Point2D(x: 1, y: 2),
                control1: Point2D(x: 2, y: 1)
            ))
        )
    ]

    /// The clocks in the machine.
    let clocks = [
        ClockModel(name: "clk", frequency: "100 MHz")
    ]

    /// The model under test.
    lazy var model = MachineModel(
        states: states,
        externalVariables: "y: out std_logic;",
        machineVariables: "signal x: std_logic;",
        includes: "library IEEE;\nuse std_logic_1164.all;",
        transitions: transitions,
        initialState: "state1",
        suspendedState: "state2",
        clocks: clocks
    )

    // swiftlint:disable force_unwrapping

    /// The expected machine.
    var expected = Machine(
        actions: [VariableName(rawValue: "OnEntry")!, VariableName(rawValue: "OnExit")!],
        name: VariableName(rawValue: "Machine0")!,
        path: URL(fileURLWithPath: "/tmp/Machine0.machine", isDirectory: true),
        includes: [
            .library(value: VariableName(rawValue: "IEEE")!),
            .include(statement: UseStatement(rawValue: "use std_logic_1164.all;")!)
        ],
        externalSignals: [PortSignal(type: .stdLogic, name: VariableName(rawValue: "y")!, mode: .output)],
        clocks: [Clock(name: VariableName(rawValue: "clk")!, frequency: 100, unit: .MHz)],
        drivingClock: 0,
        dependentMachines: [:],
        machineSignals: [LocalSignal(type: .stdLogic, name: VariableName(rawValue: "x")!)],
        isParameterised: false,
        parameterSignals: [],
        returnableSignals: [],
        states: [
            State(
                name: VariableName(rawValue: "state1")!,
                actions: [
                    VariableName(rawValue: "OnExit")!: .statement(statement: .assignment(
                        name: .variable(reference: .variable(name: VariableName(rawValue: "y")!)),
                        value: .reference(variable: .variable(
                            reference: .variable(name: VariableName(rawValue: "s1_x")!)
                        ))
                    ))
                ],
                signals: [LocalSignal(type: .stdLogic, name: VariableName(rawValue: "s1_x")!)],
                externalVariables: [VariableName(rawValue: "y")!]
            ),
            State(
                name: VariableName(rawValue: "state2")!,
                actions: [
                    VariableName(rawValue: "OnEntry")!: .statement(statement: .assignment(
                        name: .variable(reference: .variable(name: VariableName(rawValue: "s2_x")!)),
                        value: .literal(value: .bit(value: .low))
                    ))
                ],
                signals: [LocalSignal(type: .stdLogic, name: VariableName(rawValue: "s2_x")!)],
                externalVariables: []
            )
        ],
        transitions: [
            Transition(condition: .conditional(condition: .literal(value: true)), source: 0, target: 1)
        ],
        initialState: 0,
        suspendedState: 1
    )

    // swiftlint:disable function_body_length

    /// Initialise the test properties before each test.
    override func setUp() {
        model = MachineModel(
            states: states,
            externalVariables: "y: out std_logic;",
            machineVariables: "signal x: std_logic;",
            includes: "library IEEE;\nuse std_logic_1164.all;",
            transitions: transitions,
            initialState: "state1",
            suspendedState: "state2",
            clocks: clocks
        )
        expected = Machine(
            actions: [VariableName(rawValue: "OnEntry")!, VariableName(rawValue: "OnExit")!],
            name: VariableName(rawValue: "Machine0")!,
            path: URL(fileURLWithPath: "/tmp/Machine0.machine", isDirectory: true),
            includes: [
                .library(value: VariableName(rawValue: "IEEE")!),
                .include(statement: UseStatement(rawValue: "use std_logic_1164.all;")!)
            ],
            externalSignals: [PortSignal(type: .stdLogic, name: VariableName(rawValue: "y")!, mode: .output)],
            clocks: [Clock(name: VariableName(rawValue: "clk")!, frequency: 100, unit: .MHz)],
            drivingClock: 0,
            dependentMachines: [:],
            machineSignals: [LocalSignal(type: .stdLogic, name: VariableName(rawValue: "x")!)],
            isParameterised: false,
            parameterSignals: [],
            returnableSignals: [],
            states: [
                State(
                    name: VariableName(rawValue: "state1")!,
                    actions: [
                        VariableName(rawValue: "OnExit")!: .statement(statement: .assignment(
                            name: .variable(reference: .variable(name: VariableName(rawValue: "y")!)),
                            value: .reference(variable: .variable(
                                reference: .variable(name: VariableName(rawValue: "s1_x")!)
                            ))
                        ))
                    ],
                    signals: [LocalSignal(type: .stdLogic, name: VariableName(rawValue: "s1_x")!)],
                    externalVariables: [VariableName(rawValue: "y")!]
                ),
                State(
                    name: VariableName(rawValue: "state2")!,
                    actions: [
                        VariableName(rawValue: "OnEntry")!: .statement(statement: .assignment(
                            name: .variable(reference: .variable(name: VariableName(rawValue: "s2_x")!)),
                            value: .literal(value: .bit(value: .low))
                        ))
                    ],
                    signals: [LocalSignal(type: .stdLogic, name: VariableName(rawValue: "s2_x")!)],
                    externalVariables: []
                )
            ],
            transitions: [
                Transition(condition: .conditional(condition: .literal(value: true)), source: 0, target: 1)
            ],
            initialState: 0,
            suspendedState: 1
        )
    }

    // swiftlint:enable function_body_length

    // swiftlint:enable force_unwrapping

    /// Test the model is converted correctly.
    func testConversionInit() {
        XCTAssertEqual(Machine(model: model), expected)
        let path = URL(fileURLWithPath: "/tmp/subdir/NewMachine.machine", isDirectory: true)
        // swiftlint:disable:next force_unwrapping
        expected.name = VariableName(rawValue: "NewMachine")!
        expected.path = path
        XCTAssertEqual(Machine(model: model, path: path), expected)
    }

    /// Test for incorrect actions.
    func testInvalidActions() {
        model.states[0].actions = [ActionModel(name: "1 2 3", code: "null;")]
        XCTAssertNil(Machine(model: model))
        model.states[0].actions = [ActionModel(name: "OnExit", code: "invalid code")]
        XCTAssertNil(Machine(model: model))
    }

    /// Test for invalid includes.
    func testInvalidIncludes() {
        model.includes += "\ninvalid code;"
        XCTAssertNil(Machine(model: model))
        model.includes = "This is invalid"
        XCTAssertNil(Machine(model: model))
        model.includes = ""
        expected.includes = []
        XCTAssertEqual(Machine(model: model), expected)
    }

    /// Test for invalid machine variables.
    func testInvalidMachineVariables() {
        model.machineVariables += "\ninvalid code;"
        XCTAssertNil(Machine(model: model))
        model.machineVariables = "This is invalid"
        XCTAssertNil(Machine(model: model))
        model.machineVariables = ""
        expected.machineSignals = []
        XCTAssertEqual(Machine(model: model), expected)
    }

    /// Test invalid path.
    func testInvalidPath() {
        XCTAssertNil(
            Machine(model: model, path: URL(fileURLWithPath: "/tmp/invalid path", isDirectory: true))
        )
    }

    /// Test invalid external variables are detected.
    func testInvalidExternals() {
        model.externalVariables += "\ninvalid code;"
        XCTAssertNil(Machine(model: model))
        model.externalVariables = "This is invalid"
        XCTAssertNil(Machine(model: model))
        model.externalVariables = ""
        expected.externalSignals = []
        XCTAssertEqual(Machine(model: model), expected)
    }

    /// Test invalid clocks are detected.
    func testInvalidClocks() {
        model.clocks += [ClockModel(name: "invalid name", frequency: "100 Hz")]
        XCTAssertNil(Machine(model: model))
        model.clocks = [ClockModel(name: "clk", frequency: "Invalid freq")]
        XCTAssertNil(Machine(model: model))
        model.clocks = []
        XCTAssertNil(Machine(model: model))
    }

    /// Test for invalid transitions.
    func testInvalidTransitions() {
        model.transitions += [
            TransitionModel(
                source: "state2",
                target: "state1",
                condition: "invalid condition",
                layout: TransitionLayout(path: BezierPath(
                    source: Point2D(x: 2, y: 2),
                    target: Point2D(x: 2, y: 1),
                    control0: Point2D(x: 1, y: 2),
                    control1: Point2D(x: 1, y: 1)
                ))
            )
        ]
        XCTAssertNil(Machine(model: model))
        model.transitions = transitions
        model.transitions[0].source = "invalidState"
        XCTAssertNil(Machine(model: model))
        model.transitions = []
        expected.transitions = []
        XCTAssertEqual(Machine(model: model), expected)
    }

    /// Test for invalid initial and suspended states.
    func testInvalidInitialSuspended() {
        var invalidInitial = model
        invalidInitial.states[0].name = "NotInitialState"
        XCTAssertNil(Machine(model: invalidInitial))
        invalidInitial.initialState = ""
        XCTAssertNil(Machine(model: invalidInitial))
        invalidInitial.initialState = "state3"
        XCTAssertNil(Machine(model: invalidInitial))
        var invalidSuspended = model
        invalidSuspended.states[0].name = "NotSuspendedState"
        XCTAssertNil(Machine(model: invalidSuspended))
        invalidSuspended.suspendedState = ""
        XCTAssertNil(Machine(model: invalidSuspended))
        invalidSuspended.suspendedState = "state3"
        XCTAssertNil(Machine(model: invalidSuspended))
        model.suspendedState = nil
        XCTAssertNotNil(Machine(model: model))
        model.suspendedState = "state3"
        XCTAssertNil(Machine(model: model))
    }

    /// Test for unique names.
    func testUniqueNames() {
        model.clocks[0].name = "Machine0"
        XCTAssertNil(Machine(model: model))
        model.clocks[0].name = "OnEntry"
        XCTAssertNil(Machine(model: model))
        model.clocks[0].name = "x"
        XCTAssertNil(Machine(model: model))
        model.clocks[0].name = "y"
        XCTAssertNil(Machine(model: model))
        model.clocks[0].name = "s1_x"
        XCTAssertNil(Machine(model: model))
        model.clocks[0].name = "state1"
        XCTAssertNil(Machine(model: model))
    }

}
