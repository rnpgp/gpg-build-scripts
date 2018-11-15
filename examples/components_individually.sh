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

BUILD_DIR="${TRAVIS_BUILD_DIR}/b"

# Install specific versions of some components.  Disable documentation for
# libgpg-error, and enable it (default) for other components.
# In order to satisfy dependencies, components should be installed
# in a specific order.
./install_gpg_component.sh --component-name libgpg-error --component-version latest --sudo \
  --configure-opts "--disable-doc"
./install_gpg_component.sh --component-name libgcrypt --component-version latest --sudo \
  --build-dir "${BUILD_DIR}"
./install_gpg_component.sh --component-name libassuan --component-version latest --sudo
./install_gpg_component.sh --component-name libksba --component-version latest --sudo
./install_gpg_component.sh --component-name npth --component-version latest --sudo
./install_gpg_component.sh --component-name pinentry --component-version 1.1.0 --sudo
./install_gpg_component.sh --component-name gnupg --component-version 2.2.10  --sudo \
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

# Assert that building the libgcrypt component has happened in a $BUILD_DIR,
# and no other component was built there…
pushd ${BUILD_DIR}
ls -d libgcrypt-*
[[ ! $(ls . | grep -v "libgcrypt-") ]]
[[ -f "$(ls | grep "libgcrypt-")/Makefile" ]]
popd
