# idle

The interface definition language compiler for [Rose](https://github.com/blancolioni/rose). It parses `.idl` files into an abstract syntax tree, and generates Ada packages from the tree for a target, using [Syn](https://github.com/blancolioni/syn).

The language is described in the IDL chapter of the Rose book (`doc/rose-book/idl.adoc` in the Rose repository).

## Status

idle replaces Rose's original IDL compiler (see #1), and Rose builds with it.

- **Interfaces:** the whole language: parents, procedures and functions with parameter modes and interface types, constants, and range, derived and enumeration types. The kernel target generates `Rose.Interfaces.<Name>`, with its endpoint ids, and its client and server packages.
- **Endpoint ids** are derived from the source (#3). An `Endpoint_Id` aspect pins one.
- **User target** (#39, #40). The same packages, with the same names and encoding, for programs built with Rose's userland run-time system. An interface becomes an Ada interface type, `<Name>_Object`, in `Rose.Interfaces.<Name>`. The client type implements it, and raises `Rose.Interfaces.Objects.Invocation_Error` when a call fails. The server package declares `<Name>_Interface`, which a program implements and attaches an object of with `Attach` or `Publish`; one type can implement several. Each object type declares `<Name>_Cap`, the object's cap for the interface, which a client implements and a served object implements with its server package's `Cap_Of`. An interface argument is an object of the interface, and an interface result is one too, built in place as a client (#44). A client gets its caps on its first call. A string result is a `String`, and an `out` or `in out` string a `Rose.Texts.Text` (#45). An interface that is a `Resource` (Rose ADR 0010) has clients whose `Close` calls `Release`, and on the user target a server that frees a released object's slot (#50). A command has the same units as for the kernel target (#43), but takes an interface argument as an object, and an `out` string as a `Rose.Command_Line.Text`. See "User-mode target" in the IDL chapter of the Rose book.
- **Commands, packages and roles** (#2, Rose ADR 0002). For a command, the kernel target generates the procedure spec the author implements, a main that receives the shell's launch invocation and calls it, and the command's metadata, in the `.rose_command` section of the executable. For an IDL package, it generates a package of its details. A role generates nothing; it is part of the commands that inherit it. Arguments can be `Boolean`, `Natural`, `Positive`, `String`, `String_List` or an interface.
- **Modes, rights and transactions** (#55, Rose ADR 0012). A command argument is `in` or `out`, never `in out`: the mode is only the direction, and an `out` interface is a cap the command returns. What a command can do with an interface argument is its type. An interface with the `Versioned` aspect, and any interface that inherits from one, has objects the shell can version and commit, and a command is a transaction over its `Versioned` arguments unless it has the `Live` aspect. The metadata marks those arguments `versioned` and a live command `live`.

## Usage

```sh
idle --target kernel -I interfaces -o generated timer.idl
idle --target user -o generated-user stream_writer.idl
idle --check interfaces/*.idl
```

- `--target TARGET` chooses the code generator: `kernel`, the default, for kernel-level code and servers built with Rose's kernel run-time system, or `user`, for programs built with its userland run-time system. A program uses one target or the other, never both, since both generate packages with the same names.
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

`tests/run.sh` parses a snapshot of Rose's interfaces (`tests/rose/`), compares generated packages, and the units generated for the commands in `tests/commands/`, with `tests/expected/`, and the user target's packages and units for commands with `tests/expected-user/`; checks the diagnostics for the files in `tests/errors/` and the other error directories, and compiles every expected Ada file with `-gnatyabcefhiklmnoprst -gnaty3 -gnatwe`.
