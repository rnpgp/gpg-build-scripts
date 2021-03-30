#!/bin/bash

set -e # Early exit if any command returns non-zero status code
set -v # Print executed lines

# This example shows how to install GnuPG Made Easy (GPGME) API.

###############
#    SETUP    #
###############

# The --sudo option is typically needed when installing to standard locations.
# Note that `sudo ./install_gpg_all …` is not the same—it would compile as
# root (not recommended).
./install_gpg_all.sh \
	--suite-version latest --sudo --ldconfig "$@"
./install_gpg_component.sh \
	--component-name gpgme --component-version latest --sudo --ldconfig "$@"

###############
#    TESTS    #
###############

# Assert path to executables…
[[ $(command -v gpg) == "/usr/local/bin/gpg" ]]
[[ $(command -v gpgme-config) == "/usr/local/bin/gpgme-config" ]]

# Assert that executables actually works…
gpg --version
gpgme-config --version

# Assert executable version…
gpgme-config --version | head -n 1 | cut -d" " -f 3 | grep -xE "1\.[0-9]+\.[0-9]+"

# Assert GPGME prefix…
[[ $(gpgme-config --prefix) == "/usr/local" ]]

# Assert the presence of dynamic library…
[[ -f /usr/local/lib/libgpgme.so ]]
