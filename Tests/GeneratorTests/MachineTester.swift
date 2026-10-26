// MachineTester.swift
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
import TestHelpers
import VHDLKripkeStructures
import VHDLMachines
import Testing
import Foundation

/// A super class for mutating Machine0 on the file system.
class MachineTester {

    let packageScope: String = UUID().uuidString

    /// A JSON encoder.
    let encoder = JSONEncoder()

    /// A JSON decoder.
    let decoder = JSONDecoder()

    /// A `FileManager`.
    let manager = FileManager.default

    /// A path to Machine0.
    var pathRaw: String {
        String(packagePath) + "/Tests/GeneratorTests/machines/\(packageScope)/Machine0.machine"
    }

    /// A URL to the package root.
    private let packagePath = FileManager.default.currentDirectoryPath

    /// The path to the package root.
    private var packageRootPath: URL {
        URL(fileURLWithPath: String(packagePath), isDirectory: true)
    }

    /// The path to the machines folder.
    private var machinesFolder: URL {
        packageRootPath.appendingPathComponent("Tests/GeneratorTests/machines", isDirectory: true)
    }

    /// The path to Machine0.
    var machine0Path: URL {
        machineScope.appendingPathComponent("Machine0.machine", isDirectory: true)
    }

    var machineScope: URL {
        machinesFolder.appendingPathComponent(packageScope, isDirectory: true)
    }

    /// The path to the machines json file.
    var jsonFile: URL {
        machine0Path.appendingPathComponent("machine.json", isDirectory: false)
    }

    /// The path to the machines model file.
    var modelFile: URL {
        machine0Path.appendingPathComponent("model.json", isDirectory: false)
    }

    /// The path to the build folder.
    var buildFolder: URL {
        machine0Path.appendingPathComponent("build", isDirectory: true)
    }

    /// The path to the `Arragnement1` folder.
    var arrangement1Folder: URL {
        machineScope.appendingPathComponent("Arrangement1.arrangement", isDirectory: true)
    }

    /// The path to the `PingMachine` folder.
    var pingMachineFolder: URL {
        machineScope.appendingPathComponent("PingMachine.machine", isDirectory: true)
    }

    /// The build folder in the ping machine.
    var pingMachineBuildFolder: URL {
        pingMachineFolder.appendingPathComponent("build", isDirectory: true)
    }

    /// The path to the `PingMachine` kripke structure (`output.json`).
    var pingMachineKripkeStructure: URL {
        pingMachineFolder.appendingPathComponent("output.json", isDirectory: false)
    }

    /// Create test machines before every test.
    init() {
        let createDir: ()? =
            try? manager
            .createDirectory(at: machine0Path, withIntermediateDirectories: true)
        let machine = Machine.machine0
        let pingMachine = MachineModel.pingMachine
        guard
            createDir != nil,
            let data = try? encoder.encode(machine),
            let pingData = try? encoder.encode(pingMachine),
            let arrangementData = try? encoder.encode(
                ArrangementModel.pingArrangement(path: self.pingMachineFolder)
            ),
            let modelData = try? encoder.encode(MachineModel.machine0),
            let structureData = try? encoder.encode(KripkeStructure.pingPongStructure)
        else {
            Issue.record("Failed to create machine!")
            return
        }
        try? self.manager.createDirectory(at: self.pingMachineFolder, withIntermediateDirectories: true)
        try? pingData.write(to: pingMachineFolder.appendingPathComponent("model.json", isDirectory: false))
        try? structureData.write(to: pingMachineKripkeStructure)
        try? self.manager.createDirectory(at: arrangement1Folder, withIntermediateDirectories: true)
        try? arrangementData.write(
            to: arrangement1Folder.appendingPathComponent("model.json", isDirectory: false)
        )
        let result: ()? = try? data.write(to: jsonFile)
        #expect(result != nil)
        let modelResult: ()? = try? modelData.write(to: modelFile)
        #expect(modelResult != nil)
    }

    /// Remove test machines after every test.
    deinit {
        let result: ()? = try? FileManager.default.removeItem(at: machineScope)
        try? self.manager.removeItem(at: machine0Path)
        try? self.manager.removeItem(at: arrangement1Folder)
        try? self.manager.removeItem(at: pingMachineFolder)
        #expect(result != nil)
    }

}
