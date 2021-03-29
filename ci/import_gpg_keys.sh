#!/usr/bin/env bash

# This is only for use in CI.
#
# Public keys which will be used for GnuPG distribution verification
# must be imported.  For security reasons, you need to do it yourself.  See
# "Verifying authenticity of tarballs" in README for more information.
#
# This is only for use in CI.

if [[ "${CI:-}" = "true" ]]
then
	gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 249B39D24F25E3B6 2071B08A33BD3F06 BCEF7E294B092E28 528897B826403ADA
else
	>&2 echo "Error: Not in CI environment.  Only use this script if you are really sure what you're doing.  Aborting."
	exit 1
fi
