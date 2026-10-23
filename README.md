# idle

The interface definition language compiler for [Rose](https://github.com/blancolioni/rose). It parses `.idl` files into an abstract syntax tree, and generates Ada packages from the tree for a target, using [Syn](https://github.com/blancolioni/syn).

The language is described in the IDL chapter of the Rose book (`doc/rose-book/idl.adoc` in the Rose repository).

## Status

This is the first version, which replaces the current compiler step by step (see #1).

- **Parsing:** the whole current language — interfaces with parents, procedures and functions with parameter modes and interface types, constants, and range, derived and enumeration types. All of Rose's interfaces parse.
- **Kernel target:** generates the `Rose.Interfaces.<Name>` package, holding the interface's endpoint ids, for interfaces without parents, types or constants. Others are reported as not yet supported. Client and server packages are not generated yet.
- **Endpoint ids** are read from an existing `interfaces.txt`, such as Rose's, which idle never writes. Ids derived from the source (#3) will replace it.

## Usage

```sh
idle --endpoints interfaces.txt -o generated timer.idl
idle --syntax-only *.idl
```

## Building and testing

idle depends on Syn, pinned to a checkout in `../syn`.

```sh
make          # build (alr build)
make test     # build, then run tests/run.sh
```

`tests/run.sh` parses a snapshot of Rose's interfaces (`tests/rose/`), compares generated packages with `tests/expected/`, checks the diagnostics for the files in `tests/errors/`, and compiles every expected Ada file with `-gnatyabcefhiklmnoprst -gnaty3 -gnatwe`.
