#!/bin/bash

# Popular combinations of GPG software versions.
#
# For v2.2: https://gist.github.com/vt0r/a2f8c0bcb1400131ff51
# For v2.1: https://gist.github.com/mattrude/3883a3801613b048d45b
#
# USAGE:
#   ./install_gpg_all <version> [<options>]
# EXAMPLE
#   ./install_gpg_all 2.2
set -e

version="$1"
shift
options="$@"

case "${version}" in
	"2.2")
		./install_gpg_component libgpg-error 1.31 "${options}"
		./install_gpg_component libgcrypt 1.8.2 "${options}"
		./install_gpg_component libassuan 2.5.1 "${options}"
		./install_gpg_component libksba 1.3.5 "${options}"
		./install_gpg_component npth 1.5 "${options}"
		./install_gpg_component pinentry 1.1.0 "${options}"
		./install_gpg_component gnupg 2.2.7 "${options}"
		;;
	"2.1")
		./install_gpg_component libgpg-error 1.27 "${options}"
		./install_gpg_component libgcrypt 1.7.6 "${options}"
		./install_gpg_component libassuan 2.4.3 "${options}"
		./install_gpg_component libksba 1.3.5 "${options}"
		./install_gpg_component npth 1.2 "${options}"
		./install_gpg_component pinentry 0.9.5 "${options}"
		./install_gpg_component gnupg 2.1.20 "${options}"
		;;
	"latest")
		./install_gpg_component libgpg-error latest "${options}"
		./install_gpg_component libgcrypt latest "${options}"
		./install_gpg_component libassuan latest "${options}"
		./install_gpg_component libksba latest "${options}"
		./install_gpg_component npth latest "${options}"
		./install_gpg_component pinentry latest "${options}"
		./install_gpg_component gnupg latest "${options}"
		;;
	"master")
		./install_gpg_component libgpg-error master --git "${options}"
		./install_gpg_component libgcrypt master --git "${options}"
		./install_gpg_component libassuan master --git "${options}"
		./install_gpg_component libksba master --git "${options}"
		./install_gpg_component npth master --git "${options}"
		./install_gpg_component pinentry master --git "${options}"
		./install_gpg_component gnupg master --git "${options}"
		;;
esac

echo "===="
echo "DONE"
echo "===="
