// Generate.swift
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

import ArgumentParser
import Foundation
import JavascriptModel
import VHDLMachines
import VHDLMachineTransformations

@main
struct Generate: ParsableCommand {

    @Flag(help: "Regenerate the Javascript model.")
    var exportModel = false

    @Argument(help: "The path to the machine folder.", completion: .directory)
    var path: String

    @inlinable var decoder: JSONDecoder {
        JSONDecoder()
    }

    @inlinable var encoder: JSONEncoder { JSONEncoder() }

    @inlinable var pathURL: URL {
        URL(fileURLWithPath: path, isDirectory: true)
    }

    @inlinable var machine: Data {
        get throws {
            try Data(contentsOf: machinePath)
        }
    }

    @inlinable var model: Data {
        get throws {
            try Data(contentsOf: modelPath)
        }
    }

    @inlinable var machinePath: URL {
        pathURL.appendingPathComponent("machine.json", isDirectory: false)
    }

    @inlinable var modelPath: URL {
        pathURL.appendingPathComponent("model.json", isDirectory: false)
    }

    mutating func run() throws {
        guard exportModel else {
            try createMachine()
            return
        }
        try createModel()
    }

    func createMachine() throws {
        let model = try decoder.decode(MachineModel.self, from: model)
        guard let machine = Machine(model: model) else {
            fputs("Cannot create valid machine from model.", stderr)
            return
        }
        let data = try encoder.encode(machine)
        try data.write(to: machinePath)
    }

    func createModel() throws {
        let machine = try decoder.decode(Machine.self, from: machine)
        let oldModel = try decoder.decode(MachineModel.self, from: model)
        let stateLayouts = oldModel.states.map(\.layout)
        let transitionLayouts = oldModel.transitions.map(\.layout)
        guard let newModel = MachineModel(
            machine: machine, stateLayouts: stateLayouts, transitionLayouts: transitionLayouts
        ) else {
            fputs("Cannot create valid model from machine.", stderr)
            return
        }
        let newData = try encoder.encode(newModel)
        try newData.write(to: modelPath)
    }

}
