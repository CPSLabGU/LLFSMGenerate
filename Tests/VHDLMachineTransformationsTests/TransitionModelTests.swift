// TransitionModelTests.swift
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

/// Test class for ``TransitionModel`` extensions.
final class TransitionModelTests: XCTestCase {

    /// A transition to convert.
    let transition = Transition(
        condition: .conditional(condition: .literal(value: true)), source: 0, target: 1
    )

    /// The layout of the transition.
    let layout = TransitionLayout(path: BezierPath(
        source: Point2D(x: 0, y: 0),
        target: Point2D(x: 1, y: 1),
        control0: Point2D(x: 2, y: 2),
        control1: Point2D(x: 3, y: 3)
    ))

    // swiftlint:disable force_unwrapping

    /// The states within the machine.
    let states = [
        State(name: VariableName(rawValue: "state1")!, actions: [:], signals: [], externalVariables: []),
        State(name: VariableName(rawValue: "state2")!, actions: [:], signals: [], externalVariables: [])
    ]

    // swiftlint:enable force_unwrapping

    /// Test the model is correctly created from the transition.
    func testInit() {
        let model = TransitionModel(transition: transition, between: states, layout: layout)
        XCTAssertEqual(model.source, "state1")
        XCTAssertEqual(model.target, "state2")
        XCTAssertEqual(model.condition, "true")
        XCTAssertEqual(model.layout, layout)
    }

}
