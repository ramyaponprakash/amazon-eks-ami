#!/bin/bash

if ! command -v terraform-docs &> /dev/null
then
  brew install terraform-docs
else
  echo "The cli 'terraform-docs' already exist, skip installing"
fi

for module in ./modules/*/ ; do
    echo "generating doc for $module"
    terraform-docs markdown table --output-file README.md --output-mode inject $module
done
