#!/bin/bash

set -e # Early exit if any command returns non-zero status code
set -v # Print executed lines

###############
#    SETUP    #
###############

# This example shows how to install GnuPG to a non-standard location
# (overriding both --prefix, and --exec-prefix )

GPG_PREFIX="${TRAVIS_BUILD_DIR}/opt/gpg-all/universal"
EXEC_PREFIX="${TRAVIS_BUILD_DIR}/opt/gpg-all/arch"
MAN_DIR="${TRAVIS_BUILD_DIR}/opt/gpg-all/manual"

GPG_CONFIGURE_OPTS="--prefix=${GPG_PREFIX} \
	--exec-prefix=${EXEC_PREFIX} \
	--mandir=${MAN_DIR} \
	--with-libgpg-error-prefix=${EXEC_PREFIX} \
	--with-libassuan-prefix=${EXEC_PREFIX} \
	--with-libgpg-error-prefix=${EXEC_PREFIX} \
	--with-libgcrypt-prefix=${EXEC_PREFIX} \
	--with-libassuan-prefix=${EXEC_PREFIX} \
	--with-ksba-prefix=${EXEC_PREFIX} \
	--with-npth-prefix=${EXEC_PREFIX}"

# Configure script looks for executables like gpg-error-config in locations
# provided with $PATH and $GPG_PREFIX, hence we must enhance $PATH.
export PATH="${EXEC_PREFIX}/bin:${PATH}"

mkdir -p ${GPG_PREFIX} ${EXEC_PREFIX} ${MAN_DIR}

# The --ldconfig option is typically needed on GNU+Linux systems.  It causes
# `ldconfig` to be run right after installing each component in order to
# reconfigure dynamic linker run-time bindings, in other words to make the
# installed shared libraries working correctly.  This option should not be
# enabled on systems which do not feature `ldconfig`.  Note that despite using
# custom prefixes, a correct path to shared libraries will be obtained from
# the `./configure` script.
if [[ `uname -s` == "Linux" ]]; then
	# Linux
	./install_gpg_all.sh --suite-version latest --sudo --ldconfig \
		--configure-opts "${GPG_CONFIGURE_OPTS}"
else
	# Non-Linux
	./install_gpg_all.sh --suite-version latest --sudo \
		--configure-opts "${GPG_CONFIGURE_OPTS}"
fi

###############
#    TESTS    #
###############

# Assert path to executable…
[[ $(which gpg) == "${EXEC_PREFIX}/bin/gpg" ]]

# Assert that executable actually works…
gpg --version

# Assert executable version…
gpg --version | head -n 1 | cut -d" " -f 3 | grep -xE "2\.2\.[0-9]+"

# Assert manual entry location…
[[ -f "${MAN_DIR}/man1/gpg.1" ]]
[[ -f "${MAN_DIR}/man1/gpgsm.1" ]]
[[ -f "${MAN_DIR}/man7/gnupg.7" ]]
