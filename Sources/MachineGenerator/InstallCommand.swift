// InstallCommand.swift
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

import ArgumentParser
import Foundation

/// A command that installs generated files into a specified directory.
struct InstallCommand: ParsableCommand {

    /// The configuration of this command.
    static var configuration = CommandConfiguration(
        commandName: "install",
        abstract: "Install the VHDL files into a specified directory."
    )

    /// The path to the machine to install.
    @OptionGroup var path: PathArgument

    /// Whether `installPath` is a vivado project directory.
    @Flag(help: "Specifies that the install path is a vivado project directory.")
    var vivado = false

    /// That path to the install location.
    @Argument(help: "The directory to install the generated files into.", completion: .directory)
    var installPath: String

    /// A `URL` of the `installPath`.
    @inlinable var installURL: URL {
        URL(fileURLWithPath: installPath, isDirectory: true)
    }

    /// The main entry point for this command.
    /// - Throws: ``GenerationError``.
    @inlinable
    func run() throws {
        let folder = try self.path.pathURL.lastPathComponent.lowercased()
        guard folder.hasSuffix(".machine") || folder.hasSuffix(".arrangement") else {
            throw GenerationError.invalidMachine(message: "The path provided is not a machine.")
        }
        let manager = FileManager.default
        var isDirectory: ObjCBool = false
        guard
            manager.fileExists(atPath: self.path.path, isDirectory: &isDirectory), isDirectory.boolValue
        else {
            throw GenerationError.invalidMachine(message: "The path provided is not a valid machine.")
        }
        isDirectory = false
        guard manager.fileExists(atPath: installPath, isDirectory: &isDirectory), isDirectory.boolValue else {
            throw GenerationError.invalidInput(message: "The install directory is incorrect.")
        }
        isDirectory = false
        guard
            manager.fileExists(atPath: try self.path.buildFolder.path, isDirectory: &isDirectory),
            isDirectory.boolValue
        else {
            throw GenerationError.invalidGeneration(
                message: "The build folder does not exist. Have you generated the VHDL files?"
            )
        }
        let vhdlFiles = try manager.contentsOfDirectory(
            at: self.path.vhdlFolder, includingPropertiesForKeys: nil
        )
        guard vhdlFiles.allSatisfy({ $0.lastPathComponent.hasSuffix(".vhd") }) else {
            throw GenerationError.invalidGeneration(
                message: "The build folder is corrupted! Please regenerate the VHDL files."
            )
        }
        guard !vivado else {
            try self.installVivado(files: vhdlFiles, manager: manager)
            return
        }
        try self.installLocal(files: vhdlFiles, manager: manager, installLocation: self.installURL)
    }

    /// Install files into a local location on the file system.
    /// - Parameters:
    ///   - files: The files to copy into the new location.
    ///   - manager: The manager to perform the copy operation.
    ///   - installLocation: The new location of the files.
    /// - Throws: ``GenerationError``.
    @inlinable
    func installLocal(files: [URL], manager: FileManager, installLocation: URL) throws {
        try files.forEach {
            try manager.copyItem(
                at: $0, to: installLocation.appendingPathComponent(
                    $0.lastPathComponent, isDirectory: $0.hasDirectoryPath
                )
            )
        }
    }

    /// Install files into a vivado project. This function assumed the files are VHDL files with the `.vhd`
    /// extension. The files will be copied into `<vivado_project>.srcs/sources_1/new`. This function assumes
    /// that the `installURL` property contains the location of the vivado project.
    /// - Parameters:
    ///   - files: The files to copy into the vivado project.
    ///   - manager: The manager to perform the copy.
    /// - Throws: ``GenerationError``.
    @inlinable
    func installVivado(files: [URL], manager: FileManager) throws {
        let installURL = self.installURL
        let projectFiles = try manager.contentsOfDirectory(at: installURL, includingPropertiesForKeys: nil)
        guard let projectNameURL = projectFiles.first(
            where: { !$0.hasDirectoryPath && $0.lastPathComponent.hasSuffix(".xpr") }
        ) else {
            throw GenerationError.invalidInput(
                message: "The install directory is not a valid vivado project."
            )
        }
        let projectName = String(projectNameURL.lastPathComponent.dropLast(4))
        let installLocation = installURL.appendingPathComponent(
            "\(projectName).srcs/sources_1/new", isDirectory: true
        )
        var isDirectory: ObjCBool = false
        guard
            manager.fileExists(atPath: installLocation.path, isDirectory: &isDirectory), isDirectory.boolValue
        else {
            throw GenerationError.invalidInput(message: "The vivado project is not set up correctly.")
        }
        try self.installLocal(files: files, manager: manager, installLocation: installLocation)
    }

}
