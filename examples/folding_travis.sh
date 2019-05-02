#!/bin/bash

set -e # Early exit if any command returns non-zero status code
set -v # Print executed lines

# This example shows installation of the latest version of GnuPG
# (currently 2.2).

###############
#    SETUP    #
###############

# The --sudo option is typically needed when installing to standard locations.
# Note that `sudo ./install_gpg_all …` is not the same—it would compile as
# root (not recommended).
if [[ `uname -s` == "Linux" ]]; then
	# Linux
	./install_gpg_all.sh --suite-version latest --sudo --ldconfig \
		--folding-style travis | tee ./output
else
	# Non-Linux
	./install_gpg_all.sh --suite-version latest --sudo \
		--folding-style travis | tee ./output
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

# Assert correct folding…
grep -G "travis_fold:" ./output  > ./folding
grep -G "libgpg-error" ./folding > ./folding-libgpg-error

# In Linux, the --ldconfig option is added, and that results with a slightly
# different output – section "component.libgpg-error.post-install.ldconfig"
# is added.
if [[ `uname -s` == "Linux" ]]; then
	# Linux
	diff --ignore-blank-lines ./folding-libgpg-error - <<-HERE_EXPECTATION
	travis_fold:start:component.libgpg-error
	travis_fold:start:component.libgpg-error.detect-latest
	travis_fold:end:component.libgpg-error.detect-latest
	travis_fold:start:component.libgpg-error.fetch
	travis_fold:end:component.libgpg-error.fetch
	travis_fold:start:component.libgpg-error.configure
	travis_fold:end:component.libgpg-error.configure
	travis_fold:start:component.libgpg-error.build
	travis_fold:end:component.libgpg-error.build
	travis_fold:start:component.libgpg-error.install
	travis_fold:end:component.libgpg-error.install
	travis_fold:start:component.libgpg-error.post-install.ldconfig
	travis_fold:end:component.libgpg-error.post-install.ldconfig
	travis_fold:end:component.libgpg-error
	HERE_EXPECTATION
else
	# Non-Linux
	diff --ignore-blank-lines ./folding-libgpg-error - <<-HERE_EXPECTATION
	travis_fold:start:component.libgpg-error
	travis_fold:start:component.libgpg-error.detect-latest
	travis_fold:end:component.libgpg-error.detect-latest
	travis_fold:start:component.libgpg-error.fetch
	travis_fold:end:component.libgpg-error.fetch
	travis_fold:start:component.libgpg-error.configure
	travis_fold:end:component.libgpg-error.configure
	travis_fold:start:component.libgpg-error.build
	travis_fold:end:component.libgpg-error.build
	travis_fold:start:component.libgpg-error.install
	travis_fold:end:component.libgpg-error.install
	travis_fold:end:component.libgpg-error
	HERE_EXPECTATION
fi

