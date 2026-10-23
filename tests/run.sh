#!/bin/sh
# idle's tests. Run from anywhere; uses ../bin/idle.
#
#  1. Parse every interface in rose/, a snapshot of Rose's interfaces/.
#  2. Generate the kernel-target package for each interface in
#     generated.txt, and compare it with expected/.
#  3. Run idle on each file in errors/ and compare its diagnostics with
#     the .txt file of the same name.
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
while read -r name; do
  [ -n "$name" ] || continue
  if $idle --endpoints rose/interfaces.txt -o output "rose/$name.idl" \
     && diff -u "expected/rose-interfaces-$name.ads" \
                "output/rose-interfaces-$name.ads"; then
    pass "rose-interfaces-$name.ads"
  else
    fail "rose-interfaces-$name.ads"
  fi
done < generated.txt

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
