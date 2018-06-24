#!/bin/bash

# Popular combinations of GPG software versions.
#
# For v2.2: https://gist.github.com/vt0r/a2f8c0bcb1400131ff51
# For v2.1: https://gist.github.com/mattrude/3883a3801613b048d45b
#
# USAGE:
#   ./install_gpg_all.sh <version> [<options>]
#
# EXAMPLE
#   ./install_gpg_all.sh 2.2

set -e

case "$1" in
	"2.2")
		./install_gpg_component.sh --component libgpg-error --version 1.31 "${@:2}"
		./install_gpg_component.sh --component libgcrypt --version 1.8.2 "${@:2}"
		./install_gpg_component.sh --component libassuan --version 2.5.1 "${@:2}"
		./install_gpg_component.sh --component libksba --version 1.3.5 "${@:2}"
		./install_gpg_component.sh --component npth --version 1.5 "${@:2}"
		./install_gpg_component.sh --component pinentry --version 1.1.0 "${@:2}"
		./install_gpg_component.sh --component gnupg --version 2.2.7 "${@:2}"
		;;
	"2.1")
		./install_gpg_component.sh --component libgpg-error --version 1.27 "${@:2}"
		./install_gpg_component.sh --component libgcrypt --version 1.7.6 "${@:2}"
		./install_gpg_component.sh --component libassuan --version 2.4.3 "${@:2}"
		./install_gpg_component.sh --component libksba --version 1.3.5 "${@:2}"
		./install_gpg_component.sh --component npth --version 1.2 "${@:2}"
		./install_gpg_component.sh --component pinentry --version 0.9.5 "${@:2}"
		./install_gpg_component.sh --component gnupg --version 2.1.20 "${@:2}"
		;;
	"latest")
		./install_gpg_component.sh --component libgpg-error --version latest "${@:2}"
		./install_gpg_component.sh --component libgcrypt --version latest "${@:2}"
		./install_gpg_component.sh --component libassuan --version latest "${@:2}"
		./install_gpg_component.sh --component libksba --version latest "${@:2}"
		./install_gpg_component.sh --component npth --version latest "${@:2}"
		./install_gpg_component.sh --component pinentry --version latest "${@:2}"
		./install_gpg_component.sh --component gnupg --version latest "${@:2}"
		;;
	"master")
		./install_gpg_component.sh --component libgpg-error --version master --git "${@:2}"
		./install_gpg_component.sh --component libgcrypt --version master --git "${@:2}"
		./install_gpg_component.sh --component libassuan --version master --git "${@:2}"
		./install_gpg_component.sh --component libksba --version master --git "${@:2}"
		./install_gpg_component.sh --component npth --version master --git "${@:2}"
		./install_gpg_component.sh --component pinentry --version master --git "${@:2}"
		./install_gpg_component.sh --component gnupg --version master --git "${@:2}"
		;;
esac

cat <<DONE
----------------
|     DONE     |
----------------
DONE
