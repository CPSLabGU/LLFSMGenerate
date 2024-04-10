// ArrangementTests.swift
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
import TestHelpers
import VHDLMachines
@testable import VHDLMachineTransformations
import VHDLParsing
import XCTest

/// Test class for `Arrangement` extensions.
final class ArrangementTests: TransformationsFileTester {

    /// A model of the arrangement.
    lazy var model = ArrangementModel.pingArrangement(path: self.pingMachineDirectory)

    /// Initialise the model before every test.
    override func setUp() {
        super.setUp()
        model = ArrangementModel.pingArrangement(path: self.pingMachineDirectory)
    }

    /// Test that the arrangement is created correctly from the model.
    func testArrangementCreation() {
        XCTAssertEqual(Arrangement(model: model), .pingArrangement)
    }

    /// Test the arrangement is still created using relative paths.
    func testArrangementCreationWithRelativePath() throws {
        let subdir = self.machinesDirectory.appendingPathComponent("subdir", isDirectory: true)
        let pingURL = subdir.appendingPathComponent("PingMachine.machine", isDirectory: true)
        try self.manager.createDirectory(at: pingURL, withIntermediateDirectories: true)
        let modelURL = pingURL.appendingPathComponent("model.json", isDirectory: false)
        let data = try encoder.encode(Machine.pingMachine)
        try data.write(to: modelURL)
        model.machines[0].path = "subdir/PingMachine.machine"
        XCTAssertEqual(Arrangement(model: model), .pingArrangement)
    }

    /// Test that the init returns nil for invalid machine references.
    func testInvalidMachineReferences() throws {
        let oldRef = model.machines[0]
        model.machines += [model.machines[0]]
        XCTAssertNil(Arrangement(model: model))
        model.machines = [oldRef]
        XCTAssertNotNil(Arrangement(model: model))
        var ref = oldRef
        ref.path = String(ref.path.dropLast(8))
        model.machines = [ref]
        XCTAssertNil(Arrangement(model: model))
        model.machines = [oldRef]
        XCTAssertNotNil(Arrangement(model: model))
        var invalidMapping = oldRef
        invalidMapping.mappings[0] = JavascriptModel.VariableMapping(
            source: "invalid name!", destination: "clk"
        )
        model.machines = [invalidMapping]
        XCTAssertNil(Arrangement(model: model))
        model.machines = [oldRef]
        XCTAssertNotNil(Arrangement(model: model))
        try self.manager.removeItem(
            at: self.pingMachineDirectory.appendingPathComponent("model.json", isDirectory: false)
        )
        XCTAssertNil(Arrangement(model: model))
    }

    /// Test that the init returns nil for invalid variables.
    func testInitReturnsNilForInvalidVariables() {
        let oldModel = model
        model.externalVariables += "\nsignal invalid_data!: in std_logic;"
        XCTAssertNil(Arrangement(model: model))
        model = oldModel
        XCTAssertNotNil(Arrangement(model: model))
        model.globalVariables += "\nsignal invalid_data!: in std_logic;"
        XCTAssertNil(Arrangement(model: model))
        model = oldModel
        XCTAssertNotNil(Arrangement(model: model))
        model.clocks += [ClockModel(name: "clk2", frequency: "invalid")]
        XCTAssertNil(Arrangement(model: model))
        model = oldModel
        XCTAssertNotNil(Arrangement(model: model))
        model.globalMappings += [
            JavascriptModel.VariableMapping(source: "invalid signal!", destination: "ping")
        ]
        XCTAssertNil(Arrangement(model: model))
    }

}
