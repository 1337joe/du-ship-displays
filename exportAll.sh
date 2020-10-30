#!/bin/sh

cd "$(dirname "$0")"

targetDirectory=templateExports

# clear out old exports
rm -rf $targetDirectory
mkdir -p $targetDirectory

for template in **/*.json
do
    templateName=`basename $template`
    ../du-bundler/bundleTemplate.lua $template $targetDirectory/$templateName
done
