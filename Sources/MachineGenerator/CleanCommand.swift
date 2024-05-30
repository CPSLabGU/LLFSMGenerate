// CleanCommand.swift
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

/// A command that cleans all generated files.
struct CleanCommand: ParsableCommand {

    /// The command configuration.
    static var configuration = CommandConfiguration(
        commandName: "clean",
        abstract: "Clean the generated source files from the machine."
    )

    /// A flag that specifies that only the build folder must be removed.
    @Flag(help: "Only clean the build folder.")
    var cleanBuildFolder = false

    /// A path to the machine to clean.
    @OptionGroup var options: PathArgument

    /// Clean the generated files from the machine.
    /// - Throws: ``GenerationError``.
    @inlinable
    mutating func run() throws {
        let manager = FileManager.default
        guard !cleanBuildFolder else {
            try cleanBuildFolder(manager: manager)
            return
        }
        try cleanBuildFolder(manager: manager)
        guard !(try options.pathURL.lastPathComponent.lowercased().hasSuffix(".arrangement")) else {
            _ = try? manager.removeItem(
                at: options.pathURL.appendingPathComponent("arrangement.json", isDirectory: false)
            )
            return
        }
        try cleanMachine(manager: manager)
    }

    /// Clean the build folder.
    /// - Parameter manager: A manager to use.
    /// - Throws: ``GenerationError.invalidExportation`` if the build folder is a file.
    @inlinable
    func cleanBuildFolder(manager: FileManager) throws {
        var isDirectory: ObjCBool = false
        guard manager.fileExists(atPath: try options.buildFolder.path, isDirectory: &isDirectory) else {
            return
        }
        guard isDirectory.boolValue else {
            throw GenerationError.invalidExportation(message: "Found a file at the build folders location.")
        }
        try manager.removeItem(at: options.buildFolder)
    }

    /// Cleans the machine file.
    /// - Parameter manager: A manager to use.
    /// - Throws: ``GenerationError.invalidExportation`` if the machine file is a directory.
    @inlinable
    func cleanMachine(manager: FileManager) throws {
        var isDirectory: ObjCBool = true
        guard manager.fileExists(atPath: try options.machine.path, isDirectory: &isDirectory) else {
            return
        }
        guard !isDirectory.boolValue else {
            throw GenerationError.invalidExportation(
                message: "Found a directory at the machine files location."
            )
        }
        try manager.removeItem(at: options.machine)
    }

}
