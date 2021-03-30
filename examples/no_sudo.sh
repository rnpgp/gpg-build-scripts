#!/bin/bash

set -e # Early exit if any command returns non-zero status code
set -v # Print executed lines

###############
#    SETUP    #
###############

# This example shows how to install GnuPG to a non-standard location
# (overriding both --prefix, and --exec-prefix )

GPG_PREFIX="${TRAVIS_BUILD_DIR:-$(mktemp -d)}/opt/gpg-all"

GPG_CONFIGURE_OPTS="--prefix=${GPG_PREFIX} \
	--with-libgpg-error-prefix=${GPG_PREFIX} \
	--with-libassuan-prefix=${GPG_PREFIX} \
	--with-libgpg-error-prefix=${GPG_PREFIX} \
	--with-libgcrypt-prefix=${GPG_PREFIX} \
	--with-libassuan-prefix=${GPG_PREFIX} \
	--with-ksba-prefix=${GPG_PREFIX} \
	--with-npth-prefix=${GPG_PREFIX}"

export LD_RUN_PATH="${GPG_PREFIX}/lib:${LD_RUN_PATH}"

# Configure script looks for executables like gpg-error-config in locations
# provided with $PATH and $GPG_PREFIX, hence we must enhance $PATH.
export PATH="${GPG_PREFIX}/bin:${PATH}"

mkdir -p ${GPG_PREFIX}

./install_gpg_all.sh --suite-version latest --no-sudo \
	--configure-opts "${GPG_CONFIGURE_OPTS}" "$@"

###############
#    TESTS    #
###############

# Assert that sudo is not available in current environment
# (You may need to comment it out when running on your local machine)…
sudo --non-interactive true || SUDO_UNAVAILABLE=1
[[ ${SUDO_UNAVAILABLE} -eq 1 ]]

# Assert path to executable…
[[ $(command -v gpg) == "${GPG_PREFIX}/bin/gpg" ]]

# Assert that executable actually works…
gpg --version

# Assert executable version…
gpg --version | head -n 1 | cut -d" " -f 3 | grep -xE "2\.2\.[0-9]+"

# Assert manual entry location…
[[ -f "${GPG_PREFIX}/share/man/man1/gpg.1" ]]
[[ -f "${GPG_PREFIX}/share/man/man1/gpgsm.1" ]]
[[ -f "${GPG_PREFIX}/share/man/man7/gnupg.7" ]]
