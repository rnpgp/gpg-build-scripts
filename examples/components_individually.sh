#!/bin/bash

set -e # Early exit if any command returns non-zero status code
set -v # Print executed lines

# This example shows how to install GnuPG components individually
# with the `install_gpg_component.sh` script.  This approach allows for
# maximum flexibility, for instance picking specific software versions
# (also mixing stable releases with Git checkouts), or passing different
# options to ./configure script of each component.
#
# However, approach explained in `configure_options` and `install_prefix`
# examples is simpler, and satisfies typical needs.

###############
#    SETUP    #
###############

# The install_gpg_component.sh script requires passing a --build-dir option.
BUILD_DIR="${TRAVIS_BUILD_DIR}/b"

# Install specific versions of some components.  Disable documentation for
# libgpg-error, and enable it (default) for other components.
# In order to satisfy dependencies, components should be installed
# in a specific order.
./install_gpg_component.sh --component libgpg-error --version latest \
  --build-dir "${BUILD_DIR}" --sudo \
  --configure-opts "--disable-doc"
./install_gpg_component.sh --component libgcrypt --version latest \
  --build-dir "${BUILD_DIR}" --sudo
./install_gpg_component.sh --component libassuan --version latest \
  --build-dir "${BUILD_DIR}" --sudo
./install_gpg_component.sh --component libksba --version latest \
  --build-dir "${BUILD_DIR}" --sudo
./install_gpg_component.sh --component npth --version latest \
  --build-dir "${BUILD_DIR}" --sudo
./install_gpg_component.sh --component pinentry --version 1.1.0 \
  --build-dir "${BUILD_DIR}" --sudo
./install_gpg_component.sh --component gnupg --version 2.2.10 \
  --build-dir "${BUILD_DIR}" --sudo \
  --configure-opts "--enable-gpg-sha256 --disable-gpg-sha512 --enable-doc"

###############
#    TESTS    #
###############

# Assert path to executable…
[[ $(which gpg) == "/usr/local/bin/gpg" ]]

# Assert that executable actually works…
gpg --version

# Assert executable version…
gpg --version | head -n 1 | cut -d" " -f 3 | grep -xF "2.2.10"

# Assert configured algorithms (enabled SHA256 and disabled SHA512)…
gpg --version | grep -i "SHA256"
[[ ! $(gpg --version | grep -i "SHA512") ]]

# Assert disabled docs for libgpg-error, and enabled for other packages…
[[   -f "/usr/local/share/man/man1/gpg.1" ]]
[[ ! -f "/usr/local/share/man/man1/gpg-error-config.1" ]]
