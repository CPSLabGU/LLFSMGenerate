// MachineModelTests.swift
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

@testable import JavascriptModel
import XCTest

/// Test class for ``MachineModel``.
final class MachineModelTests: XCTestCase {

    /// The default states in the machine under test.
    let states = [
        StateModel(
            name: "state1",
            variables: "state1_variables",
            actions: [
                ActionModel(name: "action1", code: "state1_code1")
            ],
            layout: StateLayout(position: Point2D(x: 0, y: 0), dimensions: Point2D(x: 1, y: 1))
        ),
        StateModel(
            name: "state2",
            variables: "state2_variables",
            actions: [
                ActionModel(name: "action1", code: "state2_code1")
            ],
            layout: StateLayout(position: Point2D(x: 2, y: 2), dimensions: Point2D(x: 3, y: 3))
        )
    ]

    /// The default transitions in this machine.
    let transitions = [
        TransitionModel(
            source: "state1",
            target: "state2",
            condition: "condition",
            layout: TransitionLayout(path: BezierPath(
                source: Point2D(x: 1, y: 1),
                target: Point2D(x: 2, y: 2),
                control0: Point2D(x: 1, y: 2),
                control1: Point2D(x: 2, y: 1)
            ))
        )
    ]

    /// Test the init sets the stored properties correctly.
    func testInit() {
        let model = MachineModel(
            states: states,
            externalVariables: "externals",
            machineVariables: "machines",
            includes: "includes",
            transitions: transitions
        )
        XCTAssertEqual(model.states, states)
        XCTAssertEqual(model.externalVariables, "externals")
        XCTAssertEqual(model.machineVariables, "machines")
        XCTAssertEqual(model.includes, "includes")
        XCTAssertEqual(model.transitions, transitions)
    }

    /// Test the state setter mutates the stored properties correctly.
    func testStateSetter() {
        var model = MachineModel(
            states: states,
            externalVariables: "externals",
            machineVariables: "machines",
            includes: "includes",
            transitions: transitions
        )
        let newStates = [
            StateModel(
                name: "state3",
                variables: "state3_variables",
                actions: [
                    ActionModel(name: "action1", code: "state3_code1")
                ],
                layout: StateLayout(position: Point2D(x: 3, y: 3), dimensions: Point2D(x: 4, y: 4))
            )
        ]
        model.states = newStates
        XCTAssertEqual(model.states, newStates)
        XCTAssertEqual(model.externalVariables, "externals")
        XCTAssertEqual(model.machineVariables, "machines")
        XCTAssertEqual(model.includes, "includes")
        XCTAssertEqual(model.transitions, transitions)
    }

    /// Test primitive setters function correctly.
    func testPrimitveSetters() {
        var model = MachineModel(
            states: states,
            externalVariables: "externals",
            machineVariables: "machines",
            includes: "includes",
            transitions: transitions
        )
        model.externalVariables = "newExternals"
        XCTAssertEqual(model.states, states)
        XCTAssertEqual(model.externalVariables, "newExternals")
        XCTAssertEqual(model.machineVariables, "machines")
        XCTAssertEqual(model.includes, "includes")
        XCTAssertEqual(model.transitions, transitions)
        model.machineVariables = "newMachines"
        XCTAssertEqual(model.states, states)
        XCTAssertEqual(model.externalVariables, "newExternals")
        XCTAssertEqual(model.machineVariables, "newMachines")
        XCTAssertEqual(model.includes, "includes")
        XCTAssertEqual(model.transitions, transitions)
        model.includes = "newIncludes"
        XCTAssertEqual(model.states, states)
        XCTAssertEqual(model.externalVariables, "newExternals")
        XCTAssertEqual(model.machineVariables, "newMachines")
        XCTAssertEqual(model.includes, "newIncludes")
        XCTAssertEqual(model.transitions, transitions)
    }

    /// Test transition setter functions correctly.
    func testTransitionSetters() {
        var model = MachineModel(
            states: states,
            externalVariables: "externals",
            machineVariables: "machines",
            includes: "includes",
            transitions: transitions
        )
        let newTransitions = [
            TransitionModel(
                source: "state3",
                target: "state1",
                condition: "condition",
                layout: TransitionLayout(path: BezierPath(
                    source: Point2D(x: 4, y: 4),
                    target: Point2D(x: 5, y: 5),
                    control0: Point2D(x: 6, y: 6),
                    control1: Point2D(x: 7, y: 7)
                ))
            )
        ]
        model.transitions = newTransitions
        XCTAssertEqual(model.states, states)
        XCTAssertEqual(model.externalVariables, "externals")
        XCTAssertEqual(model.machineVariables, "machines")
        XCTAssertEqual(model.includes, "includes")
        XCTAssertEqual(model.transitions, newTransitions)
    }

}
