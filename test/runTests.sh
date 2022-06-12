#!/bin/sh

# stop for error if test returns non-0 exit code
# set -e

# set return code for final result
exitCode=0

# code coverage display on jenkins expects files to be referenced from project root
cd "$(dirname "$0")/.."

# set lua path to include src directory
export LUA_PATH="src/?.lua;;$LUA_PATH"

# clear out old results
rm -rf test/results
mkdir -p test/results/
mkdir -p test/results/images

# Note: not whitespace-safe
for test in $(find . -name Test\*.lua)
do
    testName=`basename $test`
    lua -lluacov ${test} $@ -n test/results/${testName}.xml

    retVal=$?
    if [ $retVal -ne 0 ]; then
        exitCode=$retVal
    fi
done

exit $exitCode
