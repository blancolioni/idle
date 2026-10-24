#!/bin/sh
# idle's tests. Run from anywhere; uses ../bin/idle.
#
#  1. Parse every interface in rose/, a snapshot of Rose's interfaces/.
#  2. Generate the kernel-target packages for each interface in
#     generated.txt, and compare them with expected/. Each line names
#     DIRECTORY/INTERFACE, whose endpoint ids are in
#     DIRECTORY/interfaces.txt: rose/ for Rose's interfaces, parents/ for
#     a small hierarchy.
#  3. Run idle on each file in errors/ and compare its diagnostics with
#     the .txt file of the same name; and the same for the kernel target
#     with the cases in kernel-errors/, and for --check with Rose's build
#     list (rose-build.txt) and the cases in check-errors/.
#  4. Compile every expected Ada file with GNAT's style checks, as strict
#     as Rose's build.

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
  dir=${entry%/*}
  name=${entry#*/}
  if ! $idle --target kernel --endpoints "$dir/interfaces.txt" -o output \
         "$entry.idl"; then
    fail "kernel target for $entry"
    continue
  fi
  for file in "rose-interfaces-$name.ads" \
              "rose-interfaces-$name-client.ads" \
              "rose-interfaces-$name-client.adb" \
              "rose-interfaces-$name-server.ads" \
              "rose-interfaces-$name-server.adb"; do
    if diff -u "expected/$file" "output/$file"; then
      pass "$file"
    else
      fail "$file"
    fi
  done
done < generated.txt

# An unknown target is rejected, naming the targets there are.

if $idle --target nonesuch --endpoints rose/interfaces.txt -o output \
     rose/timer.idl 2> output/target.txt; then
  fail "unknown target (expected failure)"
elif grep -q "unknown target nonesuch; the targets are kernel" \
       output/target.txt; then
  pass "unknown target"
else
  fail "unknown target (message)"
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

for name in orphan loop_a twice bounds typo; do
  file="kernel-errors/$name.idl"
  if $idle --target kernel --endpoints kernel-errors/interfaces.txt        -o output "$file" 2> output/diagnostics.txt; then
    fail "$file (expected errors)"
  elif diff -u "kernel-errors/$name.txt" output/diagnostics.txt; then
    pass "$file"
  else
    fail "$file"
  fi
done

# Checking interfaces together. Rose's build gives only warnings, for the
# files it does not compile. Each case in check-errors/ but extra.idl has
# an error.

if $idle --check --endpoints rose/interfaces.txt      $(sed 's|^|rose/|; s|$|.idl|' rose-build.txt) 2> output/check.txt    && diff -u rose-build.expected output/check.txt; then
  pass "check of Rose's build"
else
  fail "check of Rose's build"
fi

if $idle --check --endpoints check-errors/interfaces.txt      check-errors/misnamed.idl check-errors/typo.idl check-errors/first.idl      check-errors/second.idl check-errors/both.idl check-errors/no_id.idl      2> output/check.txt; then
  fail "check errors (expected errors)"
elif diff -u check-errors/expected.txt output/check.txt; then
  pass "check errors"
else
  fail "check errors"
fi

# 4. Style of expected output

work=$(mktemp -d) || exit 1
trap 'rm -rf "$work"' EXIT
for file in expected/*.ad[sb]; do
  if (cd "$work" && gcc -c -gnats -gnat2022 -gnatyabcefhiklmnoprst -gnaty3 \
        -gnatwe "$OLDPWD/$file"); then
    pass "style of $file"
  else
    fail "style of $file"
  fi
done

exit $status
