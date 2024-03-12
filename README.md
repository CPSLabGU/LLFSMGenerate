# VHDLMachineTransformations
[![Swift Coverage Test](https://github.com/Morgan2010/VHDLMachineTransformations/actions/workflows/cov.yml/badge.svg)](https://github.com/Morgan2010/VHDLMachineTransformations/actions/workflows/cov.yml)
[![Swift Lint](https://github.com/Morgan2010/VHDLMachineTransformations/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/Morgan2010/VHDLMachineTransformations/actions/workflows/swiftlint.yml)
[![Linux CI](https://github.com/Morgan2010/VHDLMachineTransformations/actions/workflows/ci-linux.yml/badge.svg)](https://github.com/Morgan2010/VHDLMachineTransformations/actions/workflows/ci-linux.yml)
[![MacOS CI](https://github.com/Morgan2010/VHDLMachineTransformations/actions/workflows/ci-macOS.yml/badge.svg)](https://github.com/Morgan2010/VHDLMachineTransformations/actions/workflows/ci-macOS.yml)

`llfsmgenerate` is a command-line utility for transforming and compiling LLFSM formats that use the `VHDL`
Hardware Description Language.
This program allows the transformation between [VHDL LLFSMs](https://github.com/mipalgu/VHDLMachines) and
other standard Javascript models, such as the [VHDL LLFSM editor](https://github.com/Morgan2010/editor) that
utilises *React*.
In addition to this support, the program can generate the relative `vhd` files for standard execution and
formal verification via Kripke structure generation.

## Requirements and Supported Platforms

- Swift 5.7 or later.
- macOS 13 (Ventura) or later.
- Linux (Ubuntu 20.04 or later).

## Usage
You may compile the binary by invoking a `swift build` within the package directory.

```shell
cd VHDLMachineTransformations
swift build -c release
```

After the compilation, you will find the binary at `.build/release/llfsmgenerate`. It is preferred that the
binary is installed within a location accessible by your `PATH` variable. For example, you may install the
program within `/usr/local/`:
```shell
install -m 0755 .build/release/llfsmgenerate /usr/local/bin
```

Please see the *help* section of the binary for a complete list of parameters and sub-commands.
```shell
llfsmgenerate --help
OVERVIEW: A utility for performing operations on LLFSM formats.

USAGE: llfsmgenerate <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  model                   A utility for converting LLFSM formats.
  vhdl                    A utility for generating VHDL source files from LLFSM definitions.

  See 'llfsmgenerate help <subcommand>' for detailed help.
```
