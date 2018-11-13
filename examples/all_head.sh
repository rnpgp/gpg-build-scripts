#!/bin/bash

set -e # Early exit if any command returns non-zero status code
set -v # Print executed lines

# This example shows installation of the current master of GnuPG from Git
# repository.

###############
#    SETUP    #
###############

# The --sudo option is typically needed when installing to standard locations.
# Note that `sudo ./install_gpg_all …` is not the same—it would compile as
# root (not recommended), and won't trigger post-install steps (including
# ldconfig).
./install_gpg_all.sh --suite-version master --sudo

###############
#    TESTS    #
###############

# Assert path to executable…
[[ $(which gpg) == "/usr/local/bin/gpg" ]]

# Assert that executable actually works…
gpg --version

# Assert executable version…
gpg --version | head -n 1 | cut -d" " -f 3 | grep -xE "2\.2\.[0-9]+"
