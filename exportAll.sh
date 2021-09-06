#!/bin/sh

cd "$(dirname "$0")"

targetDirectory=exportedTemplates

# clear out old exports
rm -rf $targetDirectory
mkdir -p $targetDirectory

for template in src/**/*.json
do
    templateName=`basename $template`
    du-bundler $template $targetDirectory/$templateName
done
