#!/bin/bash

set -e # Early exit if any command returns non-zero status code
set -v # Print executed lines

# This example shows how to use the --build-dir option.
#
# By default, the install script creates a temporary directory in which
# the whole build happens.  However, sometimes you may want to use a specific
# directory instead.  Typical reasons are caching the source code, or keeping
# the build which has failed for inspection.

###############
#    SETUP    #
###############

BUILD_DIR="${TRAVIS_BUILD_DIR}/b"

mkdir -p ${BUILD_DIR}

# The --sudo option is typically needed when installing to standard locations.
# Note that `sudo ./install_gpg_all …` is not the same—it would compile as
# root (not recommended).
#
# The --ldconfig option is typically needed on GNU+Linux systems.  It causes
# `ldconfig` to be run right after installing each component in order to
# reconfigure dynamic linker run-time bindings, in other words to make the
# installed shared libraries working correctly.  This option should not be
# enabled on systems which do not feature `ldconfig`.
if [[ `uname -s` == "Linux" ]]; then
	# Linux
	./install_gpg_all.sh --suite-version 2.2 --sudo --ldconfig \
		--build-dir ${BUILD_DIR}
else
	# Non-Linux
	./install_gpg_all.sh --suite-version 2.2 --sudo \
		--build-dir ${BUILD_DIR}
fi

###############
#    TESTS    #
###############

# Assert path to executable…
[[ $(which gpg) == "/usr/local/bin/gpg" ]]

# Assert that executable actually works…
gpg --version

# Assert executable version…
gpg --version | head -n 1 | cut -d" " -f 3 | grep -xE "2\.2\.[0-9]+"

# Assert that ${BUILD_DIR} is now full of files (cause build had happened
# there)…
pushd ${BUILD_DIR}
ls -d libgpg-error-*
ls -d gnupg-*
[[ -f "$(ls | grep "libgpg-error-")/Makefile" ]]
[[ -f "$(ls | grep "gnupg-")/Makefile" ]]
popd
