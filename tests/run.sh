#!/bin/sh
# idle's tests. Run from anywhere; uses ../bin/idle.
#
#  1. Parse every interface in rose/, a snapshot of Rose's interfaces/.
#  2. Generate the kernel-target packages for each interface in
#     generated.txt, and compare them with expected/. Each line names
#     DIRECTORY/INTERFACE: rose/ for Rose's interfaces, parents/ for a
#     small hierarchy. Also list the endpoint ids of some interfaces,
#     and generate the units for the commands and packages in commands/.
#     Then the same for the user target, with generated-user.txt and
#     expected-user/.
#  3. Run idle on each file in errors/ and compare its diagnostics with
#     the .txt file of the same name; and the same for the kernel target
#     with the cases in kernel-errors/, and for --check with Rose's build
#     list (rose-build.txt) and the cases in check-errors/, for commands
#     with the cases in command-errors/, and for what the user target
#     does not support yet with user-errors/.
#  4. Compile every expected Ada file, of both targets, with GNAT's style
#     checks, as strict as Rose's build.

cd "$(dirname "$0")" || exit 1
idle=../bin/idle
status=0

pass () { echo "PASS $1"; }
fail () { echo "FAIL $1"; status=1; }

# 1. Syntax

if $idle --syntax-only rose/*.idl; then
  pass "syntax of $(ls rose/*.idl | wc -l) Rose interfaces"
else
  fail "syntax of Rose interfaces"
fi

# 2. Generated packages

rm -rf output && mkdir output
while read -r entry; do
  [ -n "$entry" ] || continue
  name=${entry#*/}
  if ! $idle --target kernel -o output "$entry.idl"; then
    fail "kernel target for $entry"
    continue
  fi
  conversions=
  for file in "rose-interfaces-$name-client-conversions.ads" \
              "rose-interfaces-$name-client-conversions.adb"; do
    # Only an interface with ancestors has conversions.
    if [ -f "expected/$file" ] || [ -f "output/$file" ]; then
      conversions="$conversions $file"
    fi
  done
  for file in "rose-interfaces-$name.ads" \
              "rose-interfaces-$name-client.ads" \
              "rose-interfaces-$name-client.adb" \
              "rose-interfaces-$name-server.ads" \
              "rose-interfaces-$name-server.adb" \
              $conversions; do
    if diff -u "expected/$file" "output/$file"; then
      pass "$file"
    else
      fail "$file"
    fi
  done
done < generated.txt

# Endpoint ids, with their canonical forms: a hierarchy with a pinned id,
# and Rose interfaces with declared types and interface results.

if $idle --list-endpoints parents/named.idl parents/counter.idl \
     rose/block_device.idl rose/directory.idl > output/endpoints.txt \
   && diff -u endpoints.expected output/endpoints.txt; then
  pass "endpoint ids"
else
  fail "endpoint ids"
fi

# An unknown target is rejected, naming the targets there are.

if $idle --target nonesuch -o output rose/timer.idl \
     2> output/target.txt; then
  fail "unknown target (expected failure)"
elif grep -q "unknown target nonesuch; the targets are kernel, user" \
       output/target.txt; then
  pass "unknown target"
else
  fail "unknown target (message)"
fi

# Commands and IDL packages, with the roles the commands inherit, which
# find the interfaces they name in rose/.

commands="rose-core.ads rose-core-echo.ads rose-core-echo_main.adb
rose-core-echo_metadata.ads rose-core-head.ads rose-core-head_main.adb
rose-core-head_metadata.ads rose-core-copy.ads rose-core-copy_main.adb
rose-core-copy_metadata.ads rose-core-serve.ads rose-core-serve_main.adb
rose-core-serve_metadata.ads rose-core-show.ads rose-core-show_main.adb
rose-core-show_metadata.ads"
rm -rf output/commands && mkdir output/commands
if $idle --target kernel -I rose -o output/commands commands/*.idl; then
  for file in $commands; do
    if diff -u "expected/$file" "output/commands/$file"; then
      pass "$file"
    else
      fail "$file"
    fi
  done
  if [ "$(ls output/commands)" = "$(printf '%s
' $commands | sort)" ]; then
    pass "files generated for commands"
  else
    fail "files generated for commands"
  fi
else
  fail "kernel target for commands"
fi

# The user target: the same packages, generated for programs built with
# Rose's userland run-time system.

rm -rf output/user && mkdir output/user
while read -r entry; do
  [ -n "$entry" ] || continue
  name=${entry#*/}
  if ! $idle --target user -o output/user "$entry.idl"; then
    fail "user target for $entry"
    continue
  fi
  for file in "rose-interfaces-$name.ads" \
              "rose-interfaces-$name-client.ads" \
              "rose-interfaces-$name-client.adb" \
              "rose-interfaces-$name-server.ads" \
              "rose-interfaces-$name-server.adb"; do
    if diff -u "expected-user/$file" "output/user/$file"; then
      pass "user $file"
    else
      fail "user $file"
    fi
  done
done < generated-user.txt

# Commands, whose units are the same as the kernel target's, but that a
# command takes an interface argument or role member as an object of the
# interface, and an out or in out string as a text.

user_commands="rose-core.ads rose-core-echo.ads rose-core-echo_main.adb
rose-core-echo_metadata.ads rose-core-head.ads rose-core-head_main.adb
rose-core-head_metadata.ads rose-core-copy.ads rose-core-copy_main.adb
rose-core-copy_metadata.ads rose-core-serve.ads rose-core-serve_main.adb
rose-core-serve_metadata.ads rose-core-show.ads rose-core-show_main.adb
rose-core-show_metadata.ads"
if $idle --target user -I commands -I rose -o output/user \
     commands/rose-core.idl commands/rose-core-echo.idl \
     commands/rose-core-head.idl commands/rose-core-copy.idl \
     commands/rose-core-serve.idl commands/rose-core-show.idl; then
  for file in $user_commands; do
    if diff -u "expected-user/$file" "output/user/$file"; then
      pass "user $file"
    else
      fail "user $file"
    fi
  done
else
  fail "user target for commands"
fi

if [ "$(ls output/user)" = "$(ls expected-user)" ]; then
  pass "files generated for the user target"
else
  fail "files generated for the user target"
fi

# 3. Diagnostics

for file in errors/*.idl; do
  expected="${file%.idl}.txt"
  if $idle --syntax-only "$file" 2> output/diagnostics.txt; then
    fail "$file (expected errors)"
  elif diff -u "$expected" output/diagnostics.txt; then
    pass "$file"
  else
    fail "$file"
  fi
done

# Interfaces that the kernel target rejects. The other files in
# kernel-errors/ are their parents.

for name in orphan loop_a twice bounds typo clash out_array; do
  file="kernel-errors/$name.idl"
  if $idle --target kernel -o output "$file" \
       2> output/diagnostics.txt; then
    fail "$file (expected errors)"
  elif diff -u "kernel-errors/$name.txt" output/diagnostics.txt; then
    pass "$file"
  else
    fail "$file"
  fi
done

# An interface that declares Release without being a Resource (Rose
# ADR 0010) gets a warning, and is still generated.

if $idle --target kernel -o output warnings/unreleased.idl \
     2> output/warnings.txt \
   && diff -u warnings/expected.txt output/warnings.txt; then
  pass "warning for Release without Resource"
else
  fail "warning for Release without Resource"
fi

# Checking interfaces together. Rose's build gives only warnings, for the
# files it does not compile. Each case in check-errors/ but extra.idl has
# an error or a warning.

if $idle --check $(sed 's|^|rose/|; s|$|.idl|' rose-build.txt) \
     2> output/check.txt \
   && diff -u rose-build.expected output/check.txt; then
  pass "check of Rose's build"
else
  fail "check of Rose's build"
fi

if $idle --check \
     check-errors/misnamed.idl check-errors/typo.idl check-errors/first.idl \
     check-errors/second.idl check-errors/both.idl check-errors/pinned.idl \
     2> output/check.txt; then
  fail "check errors (expected errors)"
elif diff -u check-errors/expected.txt output/check.txt; then
  pass "check errors"
else
  fail "check errors"
fi

# Commands, packages and roles that break the rules. Each command finds
# its package beside it, in command-errors/, and its roles in commands/.

if $idle --target kernel -I commands -I rose -o output      command-errors/rose-core-bad.idl command-errors/nowhere-thing.idl      command-errors/bad_role.idl command-errors/rose-core-modes.idl      command-errors/rose-core.idl 2> output/diagnostics.txt; then
  fail "command errors (expected errors)"
elif diff -u command-errors/expected.txt output/diagnostics.txt; then
  pass "command errors"
else
  fail "command errors"
fi

# What the user target cannot generate: a type with the name of the
# object type, and a subprogram with the name of a cap function.

if $idle --target user -I commands -I rose -o output \
     user-errors/clash.idl user-errors/cap_name.idl \
     2> output/diagnostics.txt; then
  fail "user target errors (expected errors)"
elif diff -u user-errors/expected.txt output/diagnostics.txt; then
  pass "user target errors"
else
  fail "user target errors"
fi

# 4. Style of expected output

work=$(mktemp -d) || exit 1
trap 'rm -rf "$work"' EXIT
for file in expected/*.ad[sb] expected-user/*.ad[sb]; do
  if (cd "$work" && gcc -c -gnats -gnat2022 -gnatyabcefhiklmnoprst -gnaty3 \
        -gnatwe "$OLDPWD/$file"); then
    pass "style of $file"
  else
    fail "style of $file"
  fi
done

exit $status
