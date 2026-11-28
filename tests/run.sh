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
#     expected-user/, and the commands in user-commands/ too, whose
#     arguments the kernel target cannot have. Running idle again over the same output leaves the
#     files it would write unchanged alone, timestamps and all (#129).
#  3. Run idle on each file in errors/ and compare its diagnostics with
#     the .txt file of the same name; and the same for the kernel target
#     with the cases in kernel-errors/, and for --check with Rose's build
#     list (rose-build.txt) and the cases in check-errors/, for commands
#     with the cases in command-errors/, and for what the user target
#     does not support yet with user-errors/. A command in user-commands/
#     is an error for the kernel target.
#     Then interfaces in groups (Rose ADR 0034), from groups/, for both
#     targets, with expected-groups/. Then the host target (#133), with
#     host-backings.txt, the commands in commands/ that it can build and
#     those in host-commands/, and expected-host/; and what it refuses,
#     in host-errors/.
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
elif grep -q "unknown target nonesuch; the targets are kernel, user, host" \
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
rose-core-show_metadata.ads rose-core-touch.ads rose-core-touch_main.adb
rose-core-touch_metadata.ads rose-core-probe.ads
rose-core-probe_main.adb rose-core-probe_metadata.ads
rose-core-replace.ads rose-core-replace_main.adb
rose-core-replace_metadata.ads
rose-interfaces-journal.ads rose-interfaces-journal-client.ads
rose-interfaces-journal-client.adb
rose-interfaces-journal-client-conversions.ads
rose-interfaces-journal-client-conversions.adb
rose-interfaces-journal-server.ads rose-interfaces-journal-server.adb"
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
  package_body=
  # Only an interface with records has a package body (idle#113).
  if [ -f "expected-user/rose-interfaces-$name.adb" ] \
     || [ -f "output/user/rose-interfaces-$name.adb" ]; then
    package_body="rose-interfaces-$name.adb"
  fi
  for file in "rose-interfaces-$name.ads" $package_body \
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
rose-core-show_metadata.ads rose-core-touch.ads rose-core-touch_main.adb
rose-core-touch_metadata.ads rose-core-replace.ads
rose-core-replace_main.adb rose-core-replace_metadata.ads
rose-core-echo_client.ads rose-core-echo_client.adb
rose-core-head_client.ads rose-core-head_client.adb
rose-core-copy_client.ads rose-core-copy_client.adb
rose-core-serve_client.ads rose-core-serve_client.adb
rose-core-show_client.ads rose-core-show_client.adb
rose-core-touch_client.ads rose-core-touch_client.adb
rose-core-replace_client.ads rose-core-replace_client.adb
rose-core-edit.ads rose-core-edit_main.adb rose-core-edit_metadata.ads
rose-core-edit_client.ads rose-core-edit_client.adb"
if $idle --target user -I commands -I rose -o output/user \
     commands/rose-core.idl commands/rose-core-echo.idl \
     commands/rose-core-head.idl commands/rose-core-copy.idl \
     commands/rose-core-serve.idl commands/rose-core-show.idl \
     commands/rose-core-touch.idl commands/rose-core-replace.idl \
     user-commands/rose-core-edit.idl; then
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

# --command-client writes only the client of a command (#103), for a
# program that launches it, and the package of details it is a child of.
# It needs the user target.

rm -rf output/client && mkdir output/client
if $idle --target user --command-client -I commands -I rose \
     -o output/client commands/rose-core.idl commands/rose-core-replace.idl
then
  generated=$(ls output/client | LC_ALL=C sort | tr '\n' ' ')
  if [ "$generated" = \
       "rose-core-replace_client.adb rose-core-replace_client.ads rose-core.ads " ]
  then
    pass "--command-client writes only the client"
  else
    fail "--command-client writes only the client: $generated"
  fi
  for file in rose-core-replace_client.ads rose-core-replace_client.adb; do
    if diff -u "expected-user/$file" "output/client/$file"; then
      pass "client $file"
    else
      fail "client $file"
    fi
  done
else
  fail "--command-client"
fi

if $idle --command-client -I commands -I rose -o output/client \
     commands/rose-core-replace.idl 2> output/diagnostics.txt
then
  fail "--command-client without --target user"
else
  pass "--command-client without --target user"
fi

# The host target (#133), for a command built for the host's own Ada
# run-time, to test it without Rose. An interface has only its package,
# the same as the user target's, with no client or server, since a host
# program has no caps.

rm -rf output/host && mkdir output/host
if $idle --target host -o output/host rose/stream_reader.idl rose/timer.idl
then
  for file in rose-interfaces-stream_reader.ads rose-interfaces-timer.ads; do
    if diff -u "expected-user/$file" "output/host/$file"; then
      pass "host $file"
    else
      fail "host $file"
    fi
  done
  generated=$(ls output/host | LC_ALL=C sort | tr '\n' ' ')
  if [ "$generated" = \
       "rose-interfaces-stream_reader.ads rose-interfaces-timer.ads " ]
  then
    pass "host target writes no client or server"
  else
    fail "host target writes no client or server: $generated"
  fi
else
  fail "host target for interfaces"
fi

# A command's spec is the user target's, its metadata has no linker
# section, and its main is built on Rose.Command_Line.Host, opening the
# host backing of each interface argument and role member.

host_commands="rose-core.ads rose-core-echo.ads rose-core-echo_main.adb
rose-core-echo_metadata.ads rose-core-head.ads rose-core-head_main.adb
rose-core-head_metadata.ads rose-core-touch.ads rose-core-touch_main.adb
rose-core-touch_metadata.ads rose-core-scan.ads rose-core-scan_main.adb
rose-core-scan_metadata.ads"
mkdir output/host/commands
if $idle --target host --host-backings host-backings.txt -I commands -I rose \
     -o output/host/commands commands/rose-core.idl \
     commands/rose-core-echo.idl commands/rose-core-head.idl \
     commands/rose-core-touch.idl host-commands/rose-core-scan.idl; then
  for file in $host_commands; do
    if diff -u "expected-host/$file" "output/host/commands/$file"; then
      pass "host $file"
    else
      fail "host $file"
    fi
  done
  if [ "$(ls output/host/commands)" = "$(ls expected-host)" ]; then
    pass "files generated for the host target"
  else
    fail "files generated for the host target"
  fi
else
  fail "host target for commands"
fi

# What the host target refuses: servers, replaceable commands, system
# caps, out arguments, and interfaces with no backing. Nothing is
# written for a command it refuses.

mkdir output/host/errors
if $idle --target host --host-backings host-backings.txt -I commands \
     -I rose -o output/host/errors commands/rose-core-show.idl \
     commands/rose-core-copy.idl commands/rose-core-serve.idl \
     commands/rose-core-replace.idl 2> output/diagnostics.txt; then
  fail "host target errors (expected errors)"
elif diff -u host-errors/expected.txt output/diagnostics.txt \
     && [ -z "$(ls output/host/errors)" ]; then
  pass "host target errors"
else
  fail "host target errors"
fi

# Without a backings file, no interface has a backing; the file's own
# errors; and --host-backings needs --target host.

if $idle --target host -I commands -I rose -o output/host/errors \
     commands/rose-core-touch.idl 2> output/diagnostics.txt; then
  fail "host target without backings (expected errors)"
elif diff -u host-errors/no-backings.txt output/diagnostics.txt; then
  pass "host target without backings"
else
  fail "host target without backings"
fi

if $idle --target host --host-backings host-errors/bad-backings.txt \
     -I commands -I rose -o output/host/errors commands/rose-core-echo.idl \
     2> output/diagnostics.txt; then
  fail "host backings errors (expected errors)"
elif diff -u host-errors/bad-backings.expected output/diagnostics.txt; then
  pass "host backings errors"
else
  fail "host backings errors"
fi

if $idle --target user --host-backings host-backings.txt -o output/host \
     rose/timer.idl 2> output/diagnostics.txt; then
  fail "--host-backings without --target host"
elif grep -q "idle: --host-backings needs --target host" \
       output/diagnostics.txt; then
  pass "--host-backings without --target host"
else
  fail "--host-backings without --target host (message)"
fi

# Interfaces in groups (Rose ADR 0034): an interface whose parent is in
# another group, references across groups, a role in a group, and a
# command whose role and argument are in groups. Each group's package is
# generated with its interfaces, for both targets. The expected files are
# in expected-groups/kernel and expected-groups/user. Checking the
# interfaces warns that the command beside them is not compiled.

rm -rf output/groups && mkdir -p output/groups/kernel output/groups/user
for target in kernel user; do
  for name in common-named measures-counter; do
    $idle --target $target -I groups -o output/groups/$target \
      groups/$name.idl || fail "$target target for groups/$name"
  done
  $idle --target $target -I groups -I commands -I rose \
    -o output/groups/$target commands/rose-core.idl \
    groups/rose-core-tally.idl || fail "$target target for groups/tally"
  for file in $(ls expected-groups/$target); do
    if diff -u "expected-groups/$target/$file" \
         "output/groups/$target/$file"; then
      pass "groups $target $file"
    else
      fail "groups $target $file"
    fi
  done
  if [ "$(ls output/groups/$target)" = "$(ls expected-groups/$target)" ]
  then
    pass "files generated for groups, $target target"
  else
    fail "files generated for groups, $target target"
  fi
done

if $idle --list-endpoints groups/common-named.idl \
     groups/measures-counter.idl > output/groups/endpoints.txt \
   && diff -u expected-groups/endpoints.txt output/groups/endpoints.txt
then
  pass "endpoint ids of interfaces in groups"
else
  fail "endpoint ids of interfaces in groups"
fi

if $idle --check groups/common-named.idl groups/measures-counter.idl \
     groups/measures-counter_service.idl groups/measures-standard_input.idl \
     2> output/groups/check.txt \
   && diff -u expected-groups/check.txt output/groups/check.txt; then
  pass "check of interfaces in groups"
else
  fail "check of interfaces in groups"
fi

# Running idle again over its own output leaves files whose text is
# unchanged alone, timestamps and all, so that a build does not recompile
# them; a file whose text differs is rewritten (#129). Both targets, and
# a command, since they all write through Syn.

for target in kernel user; do
  dir=output/again-$target
  rm -rf "$dir" && mkdir "$dir"
  run () {
    $idle --target "$target" -I commands -I rose -o "$dir"       rose/timer.idl commands/rose-core-echo.idl
  }
  if ! run; then
    fail "$target target, run once"
    continue
  fi
  ls -l --full-time "$dir" > "$dir.before"
  # Timestamps may only have a resolution of a second.
  sleep 2
  if run && ls -l --full-time "$dir" > "$dir.after"      && diff -u "$dir.before" "$dir.after"; then
    pass "$target target, run again: unchanged files keep their timestamps"
  else
    fail "$target target, run again: unchanged files keep their timestamps"
  fi
  file=$dir/rose-interfaces-timer.ads
  cp "$file" "$dir.timer"
  echo "--  stale" >> "$file"
  if run && cmp -s "$dir.timer" "$file"; then
    pass "$target target, run again: a changed file is rewritten"
  else
    fail "$target target, run again: a changed file is rewritten"
  fi
done

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

for name in orphan loop_a twice bounds typo clash cap_array buffers caps words \
            records; do
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

if $idle --target kernel -I commands -I rose -o output      command-errors/rose-core-bad.idl command-errors/nowhere-thing.idl      command-errors/bad_role.idl command-errors/bad_category.idl command-errors/rose-core-modes.idl      command-errors/rose-core-unserved.idl      command-errors/rose-core-lists.idl      command-errors/rose-core.idl 2> output/diagnostics.txt; then
  fail "command errors (expected errors)"
elif diff -u command-errors/expected.txt output/diagnostics.txt; then
  pass "command errors"
else
  fail "command errors"
fi

# A list of interfaces needs the user target (Rose ADR 0012, section 6),
# since the command tests which one it was given.

if $idle --target kernel -I commands -I rose -o output \
     user-commands/rose-core-edit.idl 2> output/diagnostics.txt; then
  fail "a list of interfaces on the kernel target (expected errors)"
elif diff -u user-commands/kernel-expected.txt output/diagnostics.txt; then
  pass "a list of interfaces on the kernel target"
else
  fail "a list of interfaces on the kernel target"
fi

# What the user target cannot generate: a type with the name of the
# object type, a subprogram with the name of a cap function, and records
# that break the rules (idle#113).

if $idle --target user -I commands -I rose -o output \
     user-errors/clash.idl user-errors/cap_name.idl user-errors/records.idl \
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
for file in expected/*.ad[sb] expected-user/*.ad[sb] expected-host/*.ad[sb] \
            expected-groups/*/*.ad[sb]; do
  if (cd "$work" && gcc -c -gnats -gnat2022 -gnatyabcefhiklmnoprst -gnaty3 \
        -gnatwe "$OLDPWD/$file"); then
    pass "style of $file"
  else
    fail "style of $file"
  fi
done

# 5. Against Rose

# The style check reads the files, but it doesn't look up what they name.
# If ROSE is a Rose checkout whose two run-time systems are built, compile
# the expected files of the interfaces listed in semantic.txt against its
# real specs, for both targets, and look the names up (-gnatc: no code).
# This is how a missing "use type", or a name that Rose.Interfaces hides,
# shows up (idle#68, idle#70), and with warnings as errors, as Rose's own
# build has them, a "use type" that has no effect (idle#72). Run it with:
#
#   ROSE=$HOME/git/rose tests/run.sh

if [ -z "${ROSE:-}" ]; then
  echo "SKIP semantic check against Rose (set ROSE to a built Rose checkout)"
else
  src=$ROSE/src
  common="-I$src/base -I$src/library/capabilities -I$src/library/rose
          -I$src/library/kernelapi/system-calls
          -I$src/library/kernelapi/arch/i686"
  kernel="$common -I$src/library/kernelapi/system-calls-boot
          -I$ROSE/rts/kernel/build/i686/adainclude"
  user="$common -I$ROSE/rts/user/src/adainclude
        -I$src/library/kernelapi/system-calls-user
        -I$ROSE/rts/user/build/interfaces
        -I$ROSE/rts/user/build/i686-rose/adainclude"
  while read -r name; do
    [ -n "$name" ] || continue
    for target in kernel user; do
      if [ $target = kernel ]; then dir=expected; flags=$kernel
      else dir=expected-user; flags=$user; fi
      for file in "$dir/rose-interfaces-$name.ads" \
                  "$dir/rose-interfaces-$name-client.ads" \
                  "$dir/rose-interfaces-$name-client.adb" \
                  "$dir/rose-interfaces-$name-server.ads" \
                  "$dir/rose-interfaces-$name-server.adb"; do
        # shellcheck disable=SC2086
        if (cd "$work" && gcc -c -gnatc -gnat2012 -gnatwae -m32 -nostdinc -nostdlib \
              -I"$OLDPWD/$dir" $flags "$OLDPWD/$file"); then
          pass "rose $target $(basename "$file")"
        else
          fail "rose $target $(basename "$file")"
        fi
      done
    done
  done < semantic.txt

  # Records, which only the user target has (idle#113), with the package
  # body that holds their codecs.
  for file in expected-user/rose-interfaces-listing*.ad[sb]; do
    # shellcheck disable=SC2086
    if (cd "$work" && gcc -c -gnatc -gnat2012 -gnatwae -m32 -nostdinc \
          -nostdlib -I"$OLDPWD/expected-user" $user "$OLDPWD/$file"); then
      pass "rose user $(basename "$file")"
    else
      fail "rose user $(basename "$file")"
    fi
  done

  # The interfaces in groups, and their groups' packages.
  for target in kernel user; do
    if [ $target = kernel ]; then flags=$kernel; else flags=$user; fi
    dir=expected-groups/$target
    for file in "$dir"/rose-interfaces-*.ad[sb]; do
      # shellcheck disable=SC2086
      if (cd "$work" && gcc -c -gnatc -gnat2012 -gnatwae -m32 -nostdinc \
            -nostdlib -I"$OLDPWD/$dir" $flags "$OLDPWD/$file"); then
        pass "rose groups $target $(basename "$file")"
      else
        fail "rose groups $target $(basename "$file")"
      fi
    done
  done
fi

exit $status
