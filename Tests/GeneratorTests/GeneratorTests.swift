// GeneratorTests.swift
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
@testable import GeneratorCommands
import JavascriptModel
import VHDLMachines
import XCTest

/// Test class for ``Generate``.
final class GeneratorTests: MachineTester {

    // /// Test the setters set the correct values.
    // func testSetters() {
    //     var generator = Generate(exportModel: false, path: "")
    //     generator.exportModel = true
    //     XCTAssertTrue(generator.exportModel)
    //     XCTAssertTrue(generator.path.isEmpty)
    //     generator.options.path = "/tmp/Machine0.machine"
    //     XCTAssertTrue(generator.exportModel)
    //     XCTAssertEqual(generator.path, "/tmp/Machine0.machine")
    // }

    /// Test computed properties function correctly.
    func testComputedProperties() throws {
        let generator = Generate(exportModel: false, path: pathRaw)
        XCTAssertEqual(generator.pathURL, machine0Path)
        let machineContents = try Data(contentsOf: jsonFile)
        XCTAssertFalse(machineContents.isEmpty)
        XCTAssertEqual(try generator.machine, machineContents)
        let modelContents = try Data(contentsOf: modelFile)
        XCTAssertFalse(modelContents.isEmpty)
        XCTAssertEqual(try generator.model, modelContents)
        XCTAssertEqual(generator.machinePath, jsonFile)
        XCTAssertEqual(generator.modelPath, modelFile)
    }

    /// Test the `createMachine` function correctly translates the model.
    func testCreateMachine() throws {
        let oldData = try Data(contentsOf: jsonFile)
        XCTAssertFalse(oldData.isEmpty)
        try "Invalid data".write(to: jsonFile, atomically: true, encoding: .utf8)
        let generator = Generate(exportModel: false, path: pathRaw)
        try generator.createMachine()
        let newData = try generator.machine
        let newMachine = try decoder.decode(Machine.self, from: newData)
        let oldMachine = try decoder.decode(Machine.self, from: oldData)
        XCTAssertEqual(newMachine, oldMachine)
    }

    /// Test that the createMachine function throws the correct error for an invalid model.
    func testCreateMachineThrows() throws {
        var model = MachineModel.machine0
        model.externalVariables = "invalid data"
        let data = try encoder.encode(model)
        try data.write(to: modelFile)
        let generator = Generate(exportModel: false, path: pathRaw)
        XCTAssertThrowsError(try generator.createMachine()) {
            guard let error = $0 as? GenerationError else {
                XCTFail("Error is not of type GenerationError.")
                return
            }
            XCTAssertEqual(error, .invalidGeneration(message: "Cannot create valid machine from model."))
        }
    }

    /// Test that the model is created correctly.
    func testCreateModel() throws {
        let oldData = try Data(contentsOf: modelFile)
        XCTAssertFalse(oldData.isEmpty)
        let oldModel = try decoder.decode(MachineModel.self, from: oldData)
        var invalidModel = oldModel
        invalidModel.externalVariables = "Invalid data"
        let invalidData = try encoder.encode(invalidModel)
        try invalidData.write(to: modelFile)
        let generator = Generate(exportModel: true, path: pathRaw)
        try generator.createModel()
        let newData = try generator.model
        let newModel = try decoder.decode(MachineModel.self, from: newData)
        XCTAssertEqual(newModel, oldModel)
    }

    /// Test that the `createModel` method throws the correct error for an invalid state layout.
    func testCreateModelDetectsInvalidStateLayouts() throws {
        let oldData = try Data(contentsOf: modelFile)
        let oldModel = try decoder.decode(MachineModel.self, from: oldData)
        var invalidModel = oldModel
        invalidModel.states = [oldModel.states[0]]
        let invalidData = try encoder.encode(invalidModel)
        try invalidData.write(to: modelFile)
        let generator = Generate(exportModel: true, path: pathRaw)
        XCTAssertThrowsError(try generator.createModel()) {
            guard let error = $0 as? GenerationError else {
                XCTFail("Error is not of type GenerationError.")
                return
            }
            XCTAssertEqual(
                error,
                .invalidLayout(
                    message: """
                    Found incorrect number of state layouts.
                    Machine: 2
                    Model: 1
                    """
                )
            )
        }
    }

    /// Test that `createModel` detects an invalid number of transition layouts.
    func testCreateModelDetectsInvalidTransitionLayouts() throws {
        let oldData = try Data(contentsOf: modelFile)
        let oldModel = try decoder.decode(MachineModel.self, from: oldData)
        var invalidModel = oldModel
        invalidModel.transitions = []
        let invalidData = try encoder.encode(invalidModel)
        try invalidData.write(to: modelFile)
        let generator = Generate(exportModel: true, path: pathRaw)
        XCTAssertThrowsError(try generator.createModel()) {
            guard let error = $0 as? GenerationError else {
                XCTFail("Error is not of type GenerationError.")
                return
            }
            XCTAssertEqual(
                error,
                .invalidLayout(
                    message: """
                    Found incorrect number of transition layouts.
                    Machine: 1
                    Model: 0
                    """
                )
            )
        }
    }

    /// Test that `run` correctly generates model.
    func testRunGeneratesModel() throws {
        let oldData = try Data(contentsOf: modelFile)
        let oldModel = try decoder.decode(MachineModel.self, from: oldData)
        var invalidModel = oldModel
        invalidModel.externalVariables = "Invalid data"
        let invalidData = try encoder.encode(invalidModel)
        try invalidData.write(to: modelFile)
        Generate.main(["--export-model", pathRaw])
        let newData = try Data(contentsOf: modelFile)
        let newModel = try decoder.decode(MachineModel.self, from: newData)
        XCTAssertEqual(newModel, oldModel)
    }

    /// Test that the `run` method generates the machine correctly.
    func testRunGeneratesMachine() throws {
        let oldData = try Data(contentsOf: jsonFile)
        let oldMachine = try decoder.decode(Machine.self, from: oldData)
        try "Invalid data".write(to: jsonFile, atomically: true, encoding: .utf8)
        Generate.main([pathRaw])
        let newData = try Data(contentsOf: jsonFile)
        let newMachine = try decoder.decode(Machine.self, from: newData)
        XCTAssertEqual(newMachine, oldMachine)
    }

    /// Test that the arrangement is created correctly.
    func testArrangementCreation() throws {
        Generate.main([self.arrangement1Folder.path])
        guard let data = self.manager.contents(
            atPath: self.arrangement1Folder.appendingPathComponent(
                "arrangement.json", isDirectory: false
            ).path
        ) else {
            XCTFail("Failed to read file.")
            return
        }
        let arrangement = try self.decoder.decode(Arrangement.self, from: data)
        XCTAssertEqual(arrangement, .pingArrangement)
    }

    /// Test that arrangement creation throws the correct error when arrangement generation fails.
    func testArrangementCreationThrowsCorrectErrorWhenFails() throws {
        let modelPath = self.arrangement1Folder.appendingPathComponent("model.json", isDirectory: false)
        try self.manager.removeItem(at: modelPath)
        let model = ArrangementModel.pingArrangement(path: self.arrangement1Folder)
        let data = try self.encoder.encode(model)
        try data.write(to: modelPath)
        var command = try Generate.parse([self.arrangement1Folder.path])
        XCTAssertThrowsError(try command.run()) {
            guard let error = $0 as? GenerationError else {
                XCTFail("Error is not of type GenerationError.")
                return
            }
            XCTAssertEqual(
                error,
                .invalidGeneration(message: "Cannot create valid arrangement from model.")
            )
        }
    }

}

/// Add initialiser for testing `Generate`.
extension Generate {

    /// Iniialise from stored properties.
    init(exportModel: Bool, path: String) {
        let command: Generate
        // swiftlint:disable force_try force_cast
        if exportModel {
            command = (try! Generate.parseAsRoot(["--export-model", path])) as! Generate
        } else {
            command = (try! Generate.parseAsRoot([path])) as! Generate
        }
        // swiftlint:enable force_try force_cast
        self = command
    }

}
