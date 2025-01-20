# LLFSMGenerate
[![Swift Coverage Test](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/cov.yml/badge.svg)](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/cov.yml)
[![Swift Lint](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/swiftlint.yml)
[![Linux CI](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/ci-linux.yml/badge.svg)](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/ci-linux.yml)
[![MacOS CI](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/ci-macOS.yml/badge.svg)](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/ci-macOS.yml)
[![Windows CI](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/ci-windows.yml/badge.svg)](https://github.com/CPSLabGU/LLFSMGenerate/actions/workflows/ci-windows.yml)

`llfsmgenerate` is a command-line utility for transforming and compiling LLFSM formats that use the `VHDL`
Hardware Description Language.
This program allows the transformation between [VHDL LLFSMs](https://github.com/mipalgu/VHDLMachines) and
other standard Javascript models, such as the [VHDL LLFSM editor](https://github.com/CPSLabGU/editor) that utilises *React*.
In addition to this support, the program can generate the relative `vhd` files for standard execution and
formal verification via Kripke structure generation.

## Requirements and Supported Platforms

- Swift 5.10 or later (See [Installing Swift](#installing-swift)).
- macOS 14 (Sonoma) or later.
- Linux (Ubuntu 20.04 or later).
- Windows 11.
- Windows Server Edition 2022.

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

The `llfsmgenerate` binary allows the transformation of LLFSM models that contain VHDL code within their
state actions. Most LLFSMs are created using an editor that places an easily parsable format within the
LLFSM directory. This format is very easy to parse using Javascript, however, it does not provide type
information that is extremely useful in formal verification and code generation. To generate VHDL code for a
given LLFSM, we need to first convert it from the Javascript-like format into the format that our
[code generator](https://github.com/mipalgu/VHDLMachines) understands. This is done by using the command:

```shell
llfsmgenerate model <path_to_LLFSM_folder>
```

> [!IMPORTANT]
> Please make sure the LLFSM path contains a `.machine` extension.

This command creates the type-aware model that our
[code generator](https://github.com/mipalgu/VHDLMachines) interprets.

Once this model is generated, we can then create the VHDL source files by using:

```shell
llfsmgenerate vhdl <path_to_LLFSM_folder>
```

This command creates the `.vhd` files located in `<path_to_LLFSM_folder>/build/vhdl`. We can also create
the Kripke structure generator that creates graph structures for formal verification.

```shell
llfsmgenerate vhdl --include-kripke-structure <path_to_LLFSM_folder>
```

We may now copy our vhdl files into a directory that we can utilise for HDL projects. We have provided
a command called `install` to make this simpler.

```shell
llfsmgenerate install <path_to_LLFSM_folder> <path_to_install_location>
```

You may also specify a vivado project location by passing the `--vivado` flag.

```shell
llfsmgenerate install <path_to_LLFSM_folder> --vivado <path_to_vivado_project_directory>
```

Please see the *help* section of the binary for a complete list of parameters and sub-commands.
```shell
OVERVIEW: A utility for performing operations on LLFSM formats.

USAGE: llfsmgenerate <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  model                   A utility for converting LLFSM formats.
  vhdl                    A utility for generating VHDL source files from LLFSM definitions.
  clean                   Clean the generated source files from the machine.
  install                 Install the VHDL files into a specified directory.
  graph                   Generate a graphviz file (.dot) for the entire kripke structure.

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
swiftenv install 6.0
```

The full instructions are provided in the
[swiftenv documentation](https://swiftenv.fuller.li/en/latest/installation.html).

### MacOS

Make sure you install the latest version of XCode through your App store or
[developer website](https://developer.apple.com/xcode/).

### Windows

The full instructions for installing swift may be found on the [swift website](https://www.swift.org/install/windows/).
