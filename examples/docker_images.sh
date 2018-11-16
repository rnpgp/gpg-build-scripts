#!/bin/bash

set -e # Early exit if any command returns non-zero status code
set -v # Print executed lines

# This example shows how to use GnuPG Docker image.

###############
#    SETUP    #
###############

docker build -t gnupg:latest --build-arg GNUPG_VERSION=latest .
docker build -t gnupg:2.2    --build-arg GNUPG_VERSION=2.2 .
docker build -t gnupg:2.1    --build-arg GNUPG_VERSION=2.1 .

###############
#    TESTS    #
###############

# Assert installed versions…
# (All images are configured to have GnuPG executable at /usr/local/bin/gpg)
docker run -i gnupg:latest gpg --version | head -n 1 | cut -d" " -f 3 | grep -xE "2\.2\.[0-9]+"
docker run -i gnupg:2.2    gpg --version | head -n 1 | cut -d" " -f 3 | grep -xE "2\.2\.[0-9]+"
docker run -i gnupg:2.1    gpg --version | head -n 1 | cut -d" " -f 3 | grep -xE "2\.1\.[0-9]+"

# Assert that it works (is capable of clearsigning files)…
docker run -i gnupg:latest /bin/bash > signed.out <<-SH
	gpg --gen-key --batch <<-KEY_PARAMS
		%no-protection
		Key-Type: RSA
		Key-Usage: sign, cert
		Key-Length: 2048
		Subkey-Type: RSA
		Subkey-Length: 2048
		Subkey-Usage: encrypt
		Name-Real: Some User
		Name-Email: user@example.test
		Name-Comment: Without passphrase
		Expire-Date: 0
	KEY_PARAMS

	echo "it is very important" > ~/important.txt

	gpg --clearsign ~/important.txt

	cat ~/important.txt.asc
SH

grep signed.out -xe "-----BEGIN PGP SIGNED MESSAGE-----"
grep signed.out -xe "it is very important"
