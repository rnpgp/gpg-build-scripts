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
# must be imported.  For security reasons, you need to do it yourself.  See
# "Verifying authenticity of tarballs" in README for more information.

# The --sudo option is typically needed when installing to standard locations.
# Note that `sudo ./install_gpg_all …` is not the same—it would compile as
# root (not recommended).
#
# The --ldconfig option is typically needed on GNU+Linux systems.  It causes
# `ldconfig` to be run right after installing each component in order to
# reconfigure dynamic linker run-time bindings, in other words to make the
# installed shared libraries working correctly.  This option should not be
# enabled on systems which do not feature `ldconfig`.
./install_gpg_all.sh --suite-version 2.2 --sudo --ldconfig --verify 2>&1 | \
	tee ./output

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
