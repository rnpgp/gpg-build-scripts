#!/bin/bash

set -e # Early exit if any command returns non-zero status code
set -v # Print executed lines

# This example shows how to verify downloade GnuPG distribution prior installing
# it.  Note that this feature requires that some version of GnuPG (possibly
# an old one) is installed in advance.

###############
#    SETUP    #
###############

# Firstly, public keys which will be used for GnuPG distribution verification
# must be imported.  For security reasons, you need to do it yourself.
#
# A public key block with current keys can be found on this page:
# https://www.gnupg.org/signature_key.html
#
# Then, keys can be imported by executing something of:
# $ gpg --import FILE_WITH_KEY_BLOCK
#
# For more about importing keys (and trusting them) in G

# The --sudo option is typically needed when installing to standard locations.
# Note that `sudo ./install_gpg_all …` is not the same—it would compile as
# root (not recommended), and won't trigger post-install steps (including
# ldconfig).
./install_gpg_all.sh --suite-version 2.2 --sudo --verify 2>&1 | tee ./output

###############
#    TESTS    #
###############

# Assert path to executable…
[[ $(which gpg) == "/usr/local/bin/gpg" ]]

# Assert that executable actually works…
gpg --version

# Assert executable version…
gpg --version | head -n 1 | cut -d" " -f 3 | grep -xE "2\.2\.[0-9]+"

# Assert that verification has happened…
grep -F "gpg: Good signature from" ./output | tee ./good_signatures
[[ `wc -l < ./good_signatures` -gt 6 ]]
