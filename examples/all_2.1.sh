#!/bin/bash

set -e # Early exit if any command returns non-zero status code
set -v # Print executed lines

# This example shows GnuPG 2.1 installation.

###############
#    SETUP    #
###############

# The --sudo option is typically needed when installing to standard locations.
# Note that `sudo ./install_gpg_all …` is not the same—it would compile as
# root (not recommended).
#
# The --ldconfig option is typically needed on GNU+Linux systems.  It causes
# `ldconfig` to be run right after installing each component in order to
# reconfigure dynamic linker run-time bindings, in other words to make the
# installed shared libraries working correctly.  This option should not be
# enabled on systems which do not feature `ldconfig`.
./install_gpg_all.sh --suite-version 2.1 --sudo --ldconfig

###############
#    TESTS    #
###############

# Assert path to executable…
# (By default, GnuPG 2.1 executable is named "gpg2".  This is changed in 2.2.
# Pass "--enable-gpg2-is-gpg" to configure script if you want executable to
# be named "gpg").
[[ $(command -v gpg2) == "/usr/local/bin/gpg2" ]]

# Assert that executable actually works…
gpg2 --version

# Assert executable version…
gpg2 --version | head -n 1 | cut -d" " -f 3 | grep -xE "2\.1\.[0-9]+"
