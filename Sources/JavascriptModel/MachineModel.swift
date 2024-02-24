// MachineModel.swift
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

/// An abstract model for a single LLFSM.
public struct MachineModel: Equatable, Hashable, Codable, Sendable {

    /// The states within the machine.
    public var states: [StateModel]

    /// The external variables this machine has access too.
    public var externalVariables: String

    /// The variables local to this machine.
    public var machineVariables: String

    /// The includes required for this machine.
    public var includes: String

    /// The transitions between states in this machine.
    public var transitions: [TransitionModel]

    /// The name of the initial state.
    public var initialState: String

    /// The name of the suspended state. This property may be `nil` indicating that the machine has no
    /// suspended state.
    public var suspendedState: String?

    /// The clocks used in this machine. The first clock in the array represents the clock driving the
    /// machines execution.
    public var clocks: [ClockModel]

    /// Initialise this machine with it's stored properties.
    /// - Parameters:
    ///   - states: The states within the machine.
    ///   - externalVariables: The external variables this machine has access too.
    ///   - machineVariables: The variables local to this machine.
    ///   - includes: The includes required for this machine.
    ///   - transitions: The transitions between states in this machine.
    ///   - initialState: The name of the initial state.
    ///   - suspendedState: The name of the suspended state. This property may be `nil` indicating that the
    ///                     machine has no suspended state.
    ///   - clocks: The clocks used in the machine.
    /// - SeeAlso: ``StateModel``, ``Clock``.
    @inlinable
    public init(
        states: [StateModel],
        externalVariables: String,
        machineVariables: String,
        includes: String,
        transitions: [TransitionModel],
        initialState: String,
        suspendedState: String? = nil,
        clocks: [ClockModel]
    ) {
        self.states = states
        self.externalVariables = externalVariables
        self.machineVariables = machineVariables
        self.includes = includes
        self.transitions = transitions
        self.initialState = initialState
        self.suspendedState = suspendedState
        self.clocks = clocks
    }

}
