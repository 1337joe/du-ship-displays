#!/bin/sh

# stop for error if test returns non-0 exit code
set -e

# code coverage display on jenkins expects files to be referenced from project root
cd "$(dirname "$0")/.."

# clear out old results
rm -rf tests/results
mkdir -p tests/results/
mkdir -p tests/results/images

for test in tests/**/Test*.lua
do
    testName=`basename $test`
    lua -lluacov ${test} $@ -n tests/results/${testName}.xml
done
