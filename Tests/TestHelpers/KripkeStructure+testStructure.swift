// KripkeStructure+testStructure.swift
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
import VHDLKripkeStructures
import VHDLParsing

// swiftlint:disable file_length

/// Add constant kripke structures.
extension KripkeStructure {

    /// The ping pong kripke structure.
    public static let pingPongStructure: KripkeStructure = {
        let decoder = JSONDecoder()
        // swiftlint:disable:next force_unwrapping
        return (try? decoder.decode(KripkeStructure.self, from: KripkeStructure.raw.data(using: .utf8)!))!
    }()

    /// The raw JSON string for the ping pong kripke structure.
    static let raw = """
    {
    "edges" : [
        {
        "currentState" : "Initial",
        "executeOnEntry" : true,
        "nextState" : "SendPing",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'0'",
            "ping",
            "'0'",
            "pong",
            "'0'"
        ],
        "type" : {
            "write" : {

            }
        }
        },
        [
        {
            "cost" : {
            "energy" : {
                "coefficient" : 0,
                "exponent" : 0
            },
            "time" : {
                "coefficient" : 0,
                "exponent" : 0
            }
            },
            "target" : {
            "currentState" : "SendPing",
            "executeOnEntry" : true,
            "nextState" : "SendPing",
            "properties" : [
                "PingMachine_ping",
                "'0'",
                "PingMachine_pong",
                "'0'",
                "ping",
                "'0'",
                "pong",
                "'0'"
            ],
            "type" : {
                "read" : {

                }
            }
            }
        }
        ],
        {
        "currentState" : "WaitForPong",
        "executeOnEntry" : true,
        "nextState" : "WaitForPong",
        "properties" : [
            "PingMachine_ping",
            "'1'",
            "PingMachine_pong",
            "'1'",
            "ping",
            "'1'",
            "pong",
            "'1'"
        ],
        "type" : {
            "read" : {

            }
        }
        },
        [
        {
            "cost" : {
            "energy" : {
                "coefficient" : 0,
                "exponent" : 0
            },
            "time" : {
                "coefficient" : 1,
                "exponent" : -6
            }
            },
            "target" : {
            "currentState" : "WaitForPong",
            "executeOnEntry" : true,
            "nextState" : "SendPing",
            "properties" : [
                "PingMachine_ping",
                "'0'",
                "PingMachine_pong",
                "'1'",
                "ping",
                "'0'",
                "pong",
                "'1'"
            ],
            "type" : {
                "write" : {

                }
            }
            }
        }
        ],
        {
        "currentState" : "WaitForPong",
        "executeOnEntry" : true,
        "nextState" : "SendPing",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'1'",
            "ping",
            "'0'",
            "pong",
            "'1'"
        ],
        "type" : {
            "write" : {

            }
        }
        },
        [
        {
            "cost" : {
            "energy" : {
                "coefficient" : 0,
                "exponent" : 0
            },
            "time" : {
                "coefficient" : 0,
                "exponent" : 0
            }
            },
            "target" : {
            "currentState" : "SendPing",
            "executeOnEntry" : true,
            "nextState" : "SendPing",
            "properties" : [
                "PingMachine_ping",
                "'0'",
                "PingMachine_pong",
                "'1'",
                "ping",
                "'0'",
                "pong",
                "'1'"
            ],
            "type" : {
                "read" : {

                }
            }
            }
        }
        ],
        {
        "currentState" : "SendPing",
        "executeOnEntry" : true,
        "nextState" : "WaitForPong",
        "properties" : [
            "PingMachine_ping",
            "'1'",
            "PingMachine_pong",
            "'1'",
            "ping",
            "'1'",
            "pong",
            "'1'"
        ],
        "type" : {
            "write" : {

            }
        }
        },
        [
        {
            "cost" : {
            "energy" : {
                "coefficient" : 0,
                "exponent" : 0
            },
            "time" : {
                "coefficient" : 0,
                "exponent" : 0
            }
            },
            "target" : {
            "currentState" : "WaitForPong",
            "executeOnEntry" : true,
            "nextState" : "WaitForPong",
            "properties" : [
                "PingMachine_ping",
                "'1'",
                "PingMachine_pong",
                "'0'",
                "ping",
                "'1'",
                "pong",
                "'0'"
            ],
            "type" : {
                "read" : {

                }
            }
            }
        },
        {
            "cost" : {
            "energy" : {
                "coefficient" : 0,
                "exponent" : 0
            },
            "time" : {
                "coefficient" : 0,
                "exponent" : 0
            }
            },
            "target" : {
            "currentState" : "WaitForPong",
            "executeOnEntry" : true,
            "nextState" : "WaitForPong",
            "properties" : [
                "PingMachine_ping",
                "'1'",
                "PingMachine_pong",
                "'1'",
                "ping",
                "'1'",
                "pong",
                "'1'"
            ],
            "type" : {
                "read" : {

                }
            }
            }
        }
        ],
        {
        "currentState" : "WaitForPong",
        "executeOnEntry" : false,
        "nextState" : "WaitForPong",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'0'",
            "ping",
            "'0'",
            "pong",
            "'0'"
        ],
        "type" : {
            "write" : {

            }
        }
        },
        [
        {
            "cost" : {
            "energy" : {
                "coefficient" : 0,
                "exponent" : 0
            },
            "time" : {
                "coefficient" : 0,
                "exponent" : 0
            }
            },
            "target" : {
            "currentState" : "WaitForPong",
            "executeOnEntry" : false,
            "nextState" : "WaitForPong",
            "properties" : [
                "PingMachine_ping",
                "'0'",
                "PingMachine_pong",
                "'0'",
                "ping",
                "'0'",
                "pong",
                "'0'"
            ],
            "type" : {
                "read" : {

                }
            }
            }
        },
        {
            "cost" : {
            "energy" : {
                "coefficient" : 0,
                "exponent" : 0
            },
            "time" : {
                "coefficient" : 0,
                "exponent" : 0
            }
            },
            "target" : {
            "currentState" : "WaitForPong",
            "executeOnEntry" : false,
            "nextState" : "WaitForPong",
            "properties" : [
                "PingMachine_ping",
                "'0'",
                "PingMachine_pong",
                "'1'",
                "ping",
                "'0'",
                "pong",
                "'1'"
            ],
            "type" : {
                "read" : {

                }
            }
            }
        }
        ],
        {
        "currentState" : "WaitForPong",
        "executeOnEntry" : true,
        "nextState" : "WaitForPong",
        "properties" : [
            "PingMachine_ping",
            "'1'",
            "PingMachine_pong",
            "'0'",
            "ping",
            "'1'",
            "pong",
            "'0'"
        ],
        "type" : {
            "read" : {

            }
        }
        },
        [
        {
            "cost" : {
            "energy" : {
                "coefficient" : 0,
                "exponent" : 0
            },
            "time" : {
                "coefficient" : 1,
                "exponent" : -6
            }
            },
            "target" : {
            "currentState" : "WaitForPong",
            "executeOnEntry" : false,
            "nextState" : "WaitForPong",
            "properties" : [
                "PingMachine_ping",
                "'0'",
                "PingMachine_pong",
                "'0'",
                "ping",
                "'0'",
                "pong",
                "'0'"
            ],
            "type" : {
                "write" : {

                }
            }
            }
        }
        ],
        {
        "currentState" : "SendPing",
        "executeOnEntry" : true,
        "nextState" : "WaitForPong",
        "properties" : [
            "PingMachine_ping",
            "'1'",
            "PingMachine_pong",
            "'0'",
            "ping",
            "'1'",
            "pong",
            "'0'"
        ],
        "type" : {
            "write" : {

            }
        }
        },
        [
        {
            "cost" : {
            "energy" : {
                "coefficient" : 0,
                "exponent" : 0
            },
            "time" : {
                "coefficient" : 0,
                "exponent" : 0
            }
            },
            "target" : {
            "currentState" : "WaitForPong",
            "executeOnEntry" : true,
            "nextState" : "WaitForPong",
            "properties" : [
                "PingMachine_ping",
                "'1'",
                "PingMachine_pong",
                "'0'",
                "ping",
                "'1'",
                "pong",
                "'0'"
            ],
            "type" : {
                "read" : {

                }
            }
            }
        },
        {
            "cost" : {
            "energy" : {
                "coefficient" : 0,
                "exponent" : 0
            },
            "time" : {
                "coefficient" : 0,
                "exponent" : 0
            }
            },
            "target" : {
            "currentState" : "WaitForPong",
            "executeOnEntry" : true,
            "nextState" : "WaitForPong",
            "properties" : [
                "PingMachine_ping",
                "'1'",
                "PingMachine_pong",
                "'1'",
                "ping",
                "'1'",
                "pong",
                "'1'"
            ],
            "type" : {
                "read" : {

                }
            }
            }
        }
        ],
        {
        "currentState" : "SendPing",
        "executeOnEntry" : true,
        "nextState" : "SendPing",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'1'",
            "ping",
            "'0'",
            "pong",
            "'1'"
        ],
        "type" : {
            "read" : {

            }
        }
        },
        [
        {
            "cost" : {
            "energy" : {
                "coefficient" : 0,
                "exponent" : 0
            },
            "time" : {
                "coefficient" : 1,
                "exponent" : -6
            }
            },
            "target" : {
            "currentState" : "SendPing",
            "executeOnEntry" : true,
            "nextState" : "WaitForPong",
            "properties" : [
                "PingMachine_ping",
                "'1'",
                "PingMachine_pong",
                "'1'",
                "ping",
                "'1'",
                "pong",
                "'1'"
            ],
            "type" : {
                "write" : {

                }
            }
            }
        }
        ],
        {
        "currentState" : "SendPing",
        "executeOnEntry" : true,
        "nextState" : "SendPing",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'0'",
            "ping",
            "'0'",
            "pong",
            "'0'"
        ],
        "type" : {
            "read" : {

            }
        }
        },
        [
        {
            "cost" : {
            "energy" : {
                "coefficient" : 0,
                "exponent" : 0
            },
            "time" : {
                "coefficient" : 1,
                "exponent" : -6
            }
            },
            "target" : {
            "currentState" : "SendPing",
            "executeOnEntry" : true,
            "nextState" : "WaitForPong",
            "properties" : [
                "PingMachine_ping",
                "'1'",
                "PingMachine_pong",
                "'0'",
                "ping",
                "'1'",
                "pong",
                "'0'"
            ],
            "type" : {
                "write" : {

                }
            }
            }
        }
        ],
        {
        "currentState" : "Initial",
        "executeOnEntry" : true,
        "nextState" : "Initial",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'0'",
            "ping",
            "'0'",
            "pong",
            "'0'"
        ],
        "type" : {
            "read" : {

            }
        }
        },
        [
        {
            "cost" : {
            "energy" : {
                "coefficient" : 0,
                "exponent" : 0
            },
            "time" : {
                "coefficient" : 1,
                "exponent" : -6
            }
            },
            "target" : {
            "currentState" : "Initial",
            "executeOnEntry" : true,
            "nextState" : "SendPing",
            "properties" : [
                "PingMachine_ping",
                "'0'",
                "PingMachine_pong",
                "'0'",
                "ping",
                "'0'",
                "pong",
                "'0'"
            ],
            "type" : {
                "write" : {

                }
            }
            }
        }
        ]
    ],
    "initialStates" : [
        {
        "currentState" : "Initial",
        "executeOnEntry" : true,
        "nextState" : "Initial",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'0'",
            "ping",
            "'0'",
            "pong",
            "'0'"
        ],
        "type" : {
            "read" : {

            }
        }
        }
    ],
    "nodes" : [
        {
        "currentState" : "WaitForPong",
        "executeOnEntry" : false,
        "nextState" : "WaitForPong",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'0'",
            "ping",
            "'0'",
            "pong",
            "'0'"
        ],
        "type" : {
            "write" : {

            }
        }
        },
        {
        "currentState" : "WaitForPong",
        "executeOnEntry" : true,
        "nextState" : "WaitForPong",
        "properties" : [
            "PingMachine_ping",
            "'1'",
            "PingMachine_pong",
            "'1'",
            "ping",
            "'1'",
            "pong",
            "'1'"
        ],
        "type" : {
            "read" : {

            }
        }
        },
        {
        "currentState" : "SendPing",
        "executeOnEntry" : true,
        "nextState" : "SendPing",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'0'",
            "ping",
            "'0'",
            "pong",
            "'0'"
        ],
        "type" : {
            "read" : {

            }
        }
        },
        {
        "currentState" : "WaitForPong",
        "executeOnEntry" : true,
        "nextState" : "SendPing",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'1'",
            "ping",
            "'0'",
            "pong",
            "'1'"
        ],
        "type" : {
            "write" : {

            }
        }
        },
        {
        "currentState" : "Initial",
        "executeOnEntry" : true,
        "nextState" : "Initial",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'0'",
            "ping",
            "'0'",
            "pong",
            "'0'"
        ],
        "type" : {
            "read" : {

            }
        }
        },
        {
        "currentState" : "SendPing",
        "executeOnEntry" : true,
        "nextState" : "WaitForPong",
        "properties" : [
            "PingMachine_ping",
            "'1'",
            "PingMachine_pong",
            "'1'",
            "ping",
            "'1'",
            "pong",
            "'1'"
        ],
        "type" : {
            "write" : {

            }
        }
        },
        {
        "currentState" : "SendPing",
        "executeOnEntry" : true,
        "nextState" : "WaitForPong",
        "properties" : [
            "PingMachine_ping",
            "'1'",
            "PingMachine_pong",
            "'0'",
            "ping",
            "'1'",
            "pong",
            "'0'"
        ],
        "type" : {
            "write" : {

            }
        }
        },
        {
        "currentState" : "WaitForPong",
        "executeOnEntry" : true,
        "nextState" : "WaitForPong",
        "properties" : [
            "PingMachine_ping",
            "'1'",
            "PingMachine_pong",
            "'0'",
            "ping",
            "'1'",
            "pong",
            "'0'"
        ],
        "type" : {
            "read" : {

            }
        }
        },
        {
        "currentState" : "Initial",
        "executeOnEntry" : true,
        "nextState" : "SendPing",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'0'",
            "ping",
            "'0'",
            "pong",
            "'0'"
        ],
        "type" : {
            "write" : {

            }
        }
        },
        {
        "currentState" : "WaitForPong",
        "executeOnEntry" : false,
        "nextState" : "WaitForPong",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'0'",
            "ping",
            "'0'",
            "pong",
            "'0'"
        ],
        "type" : {
            "read" : {

            }
        }
        },
        {
        "currentState" : "SendPing",
        "executeOnEntry" : true,
        "nextState" : "SendPing",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'1'",
            "ping",
            "'0'",
            "pong",
            "'1'"
        ],
        "type" : {
            "read" : {

            }
        }
        },
        {
        "currentState" : "WaitForPong",
        "executeOnEntry" : false,
        "nextState" : "WaitForPong",
        "properties" : [
            "PingMachine_ping",
            "'0'",
            "PingMachine_pong",
            "'1'",
            "ping",
            "'0'",
            "pong",
            "'1'"
        ],
        "type" : {
            "read" : {

            }
        }
        }
    ]
    }
    """

}

// swiftlint:enable file_length
