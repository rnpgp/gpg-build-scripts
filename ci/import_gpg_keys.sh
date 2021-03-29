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
	declare keyservers=(
		hkp://pool.sks-keyservers.net:80
		hkp://keyserver.ubuntu.com:80
	)

	# See: https://gnupg.org/signature_key.html
	declare keys=(
		249B39D24F25E3B6  # Werner Koch (dist sig)
		2071B08A33BD3F06  # NIIBE Yutaka (GnuPG Release Key) <gniibe 'at' fsij.org>
		BCEF7E294B092E28  # Andre Heinecke (Release Signing Key)
		528897B826403ADA  # Werner Koch (dist signing 2020)
		6F7F0F91D138FC7B  # Damien Goutte-Gattat (XXX: Not on the page listed above, but needed for pinentry 1.1.1)
		04376F3EE0856959  # David Shaw (GnuPG Release Signing Key) (XXX: Not on the page listed above, but needed for libgpg-error 1.32)
	)

	for keyserver in "${keyservers[@]}"; do
		gpg --keyserver "${keyserver}" --recv-keys "${keys[@]}" || \
			>&2 echo "Warning: There were issues receiving keys from ${keyserver}."
	done
else
	>&2 echo "Error: Not in CI environment.  Only use this script if you are really sure what you're doing.  Aborting."
	exit 1
fi
