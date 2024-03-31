# LLFSMGenerate
[![Swift Coverage Test](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/cov.yml/badge.svg)](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/cov.yml)
[![Swift Lint](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/swiftlint.yml)
[![Linux CI](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/ci-linux.yml/badge.svg)](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/ci-linux.yml)
[![MacOS CI](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/ci-macOS.yml/badge.svg)](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/ci-macOS.yml)

`llfsmgenerate` is a command-line utility for transforming and compiling LLFSM formats that use the `VHDL`
Hardware Description Language.
This program allows the transformation between [VHDL LLFSMs](https://github.com/mipalgu/VHDLMachines) and
other standard Javascript models, such as the [VHDL LLFSM editor](https://github.com/Morgan2010/editor)
(to be released soon) that utilises *React*.
In addition to this support, the program can generate the relative `vhd` files for standard execution and
formal verification via Kripke structure generation.

## Requirements and Supported Platforms

- Swift 5.7 or later (See [Installing Swift](#installing-swift)).
- macOS 13 (Ventura) or later.
- Linux (Ubuntu 20.04 or later).

## Usage
You may compile the binary by invoking a `swift build` within the package directory.

```shell
cd LLFSMGenerate
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
  clean                   Clean the generated source files from the machine.

  See 'llfsmgenerate help <subcommand>' for detailed help.
```

## Documentation

The latest documentation may be found on the
[documentation website](https://cpslabgu.github.io/LLFSMGenerate/).

## Installing Swift

You may verify your swift installation by performing `swift --version`. The minimum required version for
`llfsmgenerate` is `5.7`. To install swift, follow the instructions below for your operating system.

### Linux

We prefer that you use [swiftenv](https://github.com/kylef/swiftenv) to install swift on linux. To install
`swiftenv`, clone the repository in your home directory.

```shell
git clone https://github.com/kylef/swiftenv.git ~/.swiftenv
```

Then place the following in your `.bash_profile` (or equivalent if using a different shell). Please note,
some systems will require modifying your `.bashrc` instead of `.bash_profile`.

```shell
echo 'export SWIFTENV_ROOT="$HOME/.swiftenv"' >> ~/.bash_profile
echo 'export PATH="$SWIFTENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(swiftenv init -)"' >> ~/.bash_profile
```

You may now install swift via:

```shell
source ~/.bash_profile
swiftenv install 5.9
```

The full instructions are provided in the
[swiftenv documentation](https://swiftenv.fuller.li/en/latest/installation.html).

### MacOS

Make sure you install the latest version of XCode through your App store or
[developer website](https://developer.apple.com/xcode/).
