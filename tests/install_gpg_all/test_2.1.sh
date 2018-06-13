#!/bin/bash

set -e # Early exit if any command returns non-zero status code
set -x # Print every command to STDOUT

./install_gpg_all 2.1

gpg --version | head -n 1 | grep gpg | grep 2.1.
