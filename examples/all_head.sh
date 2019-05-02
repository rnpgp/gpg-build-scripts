#!/bin/bash

set -e # Early exit if any command returns non-zero status code
set -v # Print executed lines

# This example shows installation of the current master of GnuPG from Git
# repository.

###############
#    SETUP    #
###############

# When building from Git, some other packages are required to be installed.
if [[ ( "${TRAVIS}" = "true" ) && ( "${TRAVIS_OS_NAME}" = "linux" ) ]]; then
	sudo apt-get update
	sudo apt-get install -y texinfo
fi

# The --sudo option is typically needed when installing to standard locations.
# Note that `sudo ./install_gpg_all …` is not the same—it would compile as
# root (not recommended).
#
# The --ldconfig option is typically needed on GNU+Linux systems.  It causes
# `ldconfig` to be run right after installing each component in order to
# reconfigure dynamic linker run-time bindings, in other words to make the
# installed shared libraries working correctly.  This option should not be
# enabled on systems which do not feature `ldconfig`.
#
# --disable-doc option for ./configure script isn't required, but may save
# you much headache.  Building documentation involves plenty of additional
# packages, which may require manual tweaks (e.g. non-standard ImageMagick's
# policies for building PDFs).
#
# --disable-pinentry-qt for ./configure script prevents from building of
# Qt Pinentry.  Although dependecies seem to be present in Travis CI enviromnent
# by default, build fails for some reason.  Fixing it for unstable Pinentry
# version is out of the scope of this example.
./install_gpg_all.sh --suite-version master --sudo --ldconfig \
	--configure-opts "--disable-doc --disable-pinentry-qt"

###############
#    TESTS    #
###############

# Assert path to executable…
[[ $(which gpg) == "/usr/local/bin/gpg" ]]

# Assert that executable actually works…
gpg --version

# Assert executable version…
gpg --version | grep "THIS IS A DEVELOPMENT VERSION"
