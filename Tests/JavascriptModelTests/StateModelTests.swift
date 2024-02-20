// StateModelTests.swift
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

/// Tests for the `StateModel` model.
final class StateModelTests: XCTestCase {

    /// Test the `init` sets the stored properties correctly.
    func testInit() {
        let actions = [ActionModel(name: "OnEntry", code: "123")]
        let layout = StateLayout(position: Point2D(x: 0, y: 0), dimensions: Point2D(x: 1, y: 1))
        let state = StateModel(name: "name", variables: "variables", actions: actions, layout: layout)
        XCTAssertEqual(state.name, "name")
        XCTAssertEqual(state.variables, "variables")
        XCTAssertEqual(state.actions, actions)
        XCTAssertEqual(state.layout, layout)
    }

    /// Test the setters mutate the stored properties correctly.
    func testSetters() {
        let actions = [ActionModel(name: "OnEntry", code: "123")]
        let layout = StateLayout(position: Point2D(x: 0, y: 0), dimensions: Point2D(x: 1, y: 1))
        var state = StateModel(name: "name", variables: "variables", actions: actions, layout: layout)
        state.name = "newName"
        XCTAssertEqual(state.name, "newName")
        XCTAssertEqual(state.variables, "variables")
        XCTAssertEqual(state.actions, actions)
        XCTAssertEqual(state.layout, layout)
        state.variables = "newVariables"
        XCTAssertEqual(state.name, "newName")
        XCTAssertEqual(state.variables, "newVariables")
        XCTAssertEqual(state.actions, actions)
        XCTAssertEqual(state.layout, layout)
        let newActions = [ActionModel(name: "OnExit", code: "456")]
        state.actions = newActions
        XCTAssertEqual(state.name, "newName")
        XCTAssertEqual(state.variables, "newVariables")
        XCTAssertEqual(state.actions, newActions)
        XCTAssertEqual(state.layout, layout)
        let newLayout = StateLayout(position: Point2D(x: 2, y: 2), dimensions: Point2D(x: 3, y: 3))
        state.layout = newLayout
        XCTAssertEqual(state.name, "newName")
        XCTAssertEqual(state.variables, "newVariables")
        XCTAssertEqual(state.actions, newActions)
        XCTAssertEqual(state.layout, newLayout)
    }

}
