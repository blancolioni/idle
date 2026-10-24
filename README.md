# idle

The interface definition language compiler for [Rose](https://github.com/blancolioni/rose). It parses `.idl` files into an abstract syntax tree, and generates Ada packages from the tree for a target, using [Syn](https://github.com/blancolioni/syn).

The language is described in the IDL chapter of the Rose book (`doc/rose-book/idl.adoc` in the Rose repository).

## Status

idle replaces Rose's original IDL compiler (see #1), and Rose builds with it.

- **Interfaces:** the whole language: parents, procedures and functions with parameter modes and interface types, constants, and range, derived and enumeration types. The kernel target generates `Rose.Interfaces.<Name>`, with its endpoint ids, and its client and server packages.
- **Endpoint ids** are derived from the source (#3). An `Endpoint_Id` aspect pins one.
- **Commands, packages and roles** (#2, Rose ADR 0002). For a command, the kernel target generates the procedure spec the author implements, a main that receives the shell's launch invocation and calls it, and the command's metadata, in the `.rose_command` section of the executable. For an IDL package, it generates a package of its details. A role generates nothing; it is part of the commands that inherit it. Arguments can be `Boolean`, `Natural`, `Positive`, `String` or `String_List`, all of mode `in`, and roles can hold only the standard streams, for now.

## Usage

```sh
idle --target kernel -I interfaces -o generated timer.idl
idle --check interfaces/*.idl
```

- `--target TARGET` chooses the code generator. `kernel`, the default, is the only target so far.
- `-o DIRECTORY` is where generated files are written (default: the current directory).
- `-I DIRECTORY` adds a directory in which to look for the declarations a file names, after the file's own directory.
- `--syntax-only` parses the files and reports errors, without generating anything.
- `--check` checks the files together, without generating anything: file names, endpoint ids that clash, and parents and types that are not found.
- `--list-endpoints` lists the endpoint ids of the interfaces, with the canonical forms they are derived from.

## Building and testing

idle depends on Syn, pinned to a checkout in `../syn`.

```sh
make          # build (alr build)
make test     # build, then run tests/run.sh
```

`tests/run.sh` parses a snapshot of Rose's interfaces (`tests/rose/`), compares generated packages, and the units generated for the commands in `tests/commands/`, with `tests/expected/`, checks the diagnostics for the files in `tests/errors/` and the other error directories, and compiles every expected Ada file with `-gnatyabcefhiklmnoprst -gnaty3 -gnatwe`.
