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
import JavascriptModel
@testable import MachineGenerator
import VHDLMachines
import XCTest

/// Test class for ``Generate``.
final class GeneratorTests: XCTestCase {

    /// A JSON encoder.
    let encoder = JSONEncoder()

    /// A URL to the package root.
    let packagePath = URL(fileURLWithPath: #file).pathComponents.prefix { $0 != "Tests" }
        .joined(separator: "/")
        .dropFirst()

    /// The path to the package root.
    var packageRootPath: URL {
        URL(fileURLWithPath: String(packagePath), isDirectory: true)
    }

    /// The path to the machines folder.
    var machinesFolder: URL {
        packageRootPath.appendingPathComponent("Tests/MachineGeneratorTests/machines", isDirectory: true)
    }

    /// The path to Machine0.
    var machine0Path: URL {
        machinesFolder.appendingPathComponent("Machine0.machine", isDirectory: true)
    }

    /// The path to the machines json file.
    var jsonFile: URL {
        machine0Path.appendingPathComponent("machine.json", isDirectory: false)
    }

    /// The path to the machines model file.
    var modelFile: URL {
        machine0Path.appendingPathComponent("model.json", isDirectory: false)
    }

    /// Create test machines before every test.
    override func setUp() {
        let createDir: ()? = try? FileManager.default
            .createDirectory(at: machine0Path, withIntermediateDirectories: true)
        guard
            createDir != nil,
            let machine = Machine(machine0LocatedInFolder: machinesFolder),
            let data = try? encoder.encode(machine),
            let modelData = try? encoder.encode(MachineModel.machine0)
        else {
            XCTFail("Failed to create machine!")
            return
        }
        let result: ()? = try? data.write(to: jsonFile)
        XCTAssertNotNil(result)
        let modelResult: ()? = try? modelData.write(to: modelFile)
        XCTAssertNotNil(modelResult)
    }

    /// Remove test machines before every test.
    override func tearDown() {
        let result: ()? = try? FileManager.default.removeItem(at: machine0Path)
        XCTAssertNotNil(result)
    }

    /// Test the setters set the correct values.
    func testSetters() {
        var generator = Generate(exportModel: false, path: "")
        generator.exportModel = true
        XCTAssertTrue(generator.exportModel)
        XCTAssertTrue(generator.path.isEmpty)
        generator.path = "/tmp/Machine0.machine"
        XCTAssertTrue(generator.exportModel)
        XCTAssertEqual(generator.path, "/tmp/Machine0.machine")
    }

    /// Test computed properties function correctly.
    func testComputedProperties() throws {
        let pathRaw = String(packagePath) + "/Tests/MachineGeneratorTests/machines/Machine0.machine"
        let generator = Generate(exportModel: false, path: pathRaw)
        XCTAssertEqual(generator.pathURL, machine0Path)
        XCTAssertEqual(try generator.machine, try Data(contentsOf: jsonFile))
        XCTAssertEqual(try generator.model, try Data(contentsOf: modelFile))
        XCTAssertEqual(generator.machinePath, jsonFile)
        XCTAssertEqual(generator.modelPath, modelFile)
    }

}

/// Add initialiser for testing `Generate`.
extension Generate {

    /// Iniialise from stored properties.
    init(exportModel: Bool, path: String) {
        self.init()
        self.exportModel = exportModel
        self.path = path
    }

}
