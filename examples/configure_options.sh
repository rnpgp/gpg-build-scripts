#!/bin/bash

set -e # Early exit if any command returns non-zero status code
set -v # Print executed lines

# This example shows how to pass options to ./configure script.

###############
#    SETUP    #
###############

# Note that configure options must be passed as a single argument.
# Also, --enable-pinentry-curses is only relevant to Pinentry component,
# --enable-gpg-sha256 and --disable-gpg-sha512 are relevant to GnuPG component,
# whereas --disable-doc is relevant for all components.  This is okay, however
# warnings will be printed.
./install_gpg_all.sh --suite-version latest --sudo --ldconfig \
	--configure-opts "--disable-doc --enable-pinentry-curses \
	--enable-gpg-sha256 --disable-gpg-sha512"

###############
#    TESTS    #
###############

# Assert path to executable…
command -v gpg | grep -e "${GPG_PREFIX}/bin/gpg"

# Assert that executable actually works…
gpg --version

# Assert executable version…
gpg --version | head -n 1 | cut -d" " -f 3 | grep -xE "2\.2\.[0-9]+"

# Assert that manual entry has not been installed…
[[ ! -f "/usr/local/share/man/man1/gpg.1" ]]
[[ ! -f "/usr/local/share/man/man1/gpgsm.1" ]]
[[ ! -f "/usr/local/share/man/man7/gnupg.7" ]]

# Assert configured algorithms (enabled SHA256 and disabled SHA512)…
gpg --version | grep -i "SHA256"
[[ ! $(gpg --version | grep -i "SHA512") ]]
