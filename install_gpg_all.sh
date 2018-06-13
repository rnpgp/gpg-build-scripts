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
		./install_gpg_component.sh libgpg-error 1.31 "${options}"
		./install_gpg_component.sh libgcrypt 1.8.2 "${options}"
		./install_gpg_component.sh libassuan 2.5.1 "${options}"
		./install_gpg_component.sh libksba 1.3.5 "${options}"
		./install_gpg_component.sh npth 1.5 "${options}"
		./install_gpg_component.sh pinentry 1.1.0 "${options}"
		./install_gpg_component.sh gnupg 2.2.7 "${options}"
		;;
	"2.1")
		./install_gpg_component.sh libgpg-error 1.27 "${options}"
		./install_gpg_component.sh libgcrypt 1.7.6 "${options}"
		./install_gpg_component.sh libassuan 2.4.3 "${options}"
		./install_gpg_component.sh libksba 1.3.5 "${options}"
		./install_gpg_component.sh npth 1.2 "${options}"
		./install_gpg_component.sh pinentry 0.9.5 "${options}"
		./install_gpg_component.sh gnupg 2.1.20 "${options}"
		;;
	"latest")
		./install_gpg_component.sh libgpg-error latest "${options}"
		./install_gpg_component.sh libgcrypt latest "${options}"
		./install_gpg_component.sh libassuan latest "${options}"
		./install_gpg_component.sh libksba latest "${options}"
		./install_gpg_component.sh npth latest "${options}"
		./install_gpg_component.sh pinentry latest "${options}"
		./install_gpg_component.sh gnupg latest "${options}"
		;;
	"master")
		./install_gpg_component.sh libgpg-error master --git "${options}"
		./install_gpg_component.sh libgcrypt master --git "${options}"
		./install_gpg_component.sh libassuan master --git "${options}"
		./install_gpg_component.sh libksba master --git "${options}"
		./install_gpg_component.sh npth master --git "${options}"
		./install_gpg_component.sh pinentry master --git "${options}"
		./install_gpg_component.sh gnupg master --git "${options}"
		;;
esac

echo "===="
echo "DONE"
echo "===="
