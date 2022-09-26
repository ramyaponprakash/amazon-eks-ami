#!/bin/bash

brew tap liamg/tfsec
brew install terraform-docs tflint tfsec checkov
brew install pre-commit gawk coreutils

# Enable pre-commit hook
pre-commit install