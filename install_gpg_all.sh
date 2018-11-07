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

readonly __progname=$(basename $0)

errx() {
	echo -e "$__progname: $@" >&2
	exit 1
}

usage() {
	echo "usage: $__progname [-i <GPG_VERSION>] [-d]"
	echo ""
	echo "  Options:"
	echo "  -d for dry run, not building GPG components."
	echo "  -i to select the GPG version to install [major.minor], defaults to `latest`."
	echo "      - `latest`: latest version of GnuPG."
	echo "      - `x.y`: specific version x.y of GnuPG, e.g. `2.2`."
	echo "      - `master`: build from GnuPG git master branch."
	echo "  -h to display this message"
	echo ""
	echo "  Arguments can also be set via environment variables: "
	echo "  - GPG_VERSION"
	exit 1
}

prequisites_yum() {
	yum install -y bzip2 gcc make sudo
}

detect_platform() {
	# Determine OS platform
	DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d \")
	echo "$DISTRO"
}

main() {

	while getopts ":idh" o; do
		case "${o}" in
		i)
			readonly local GPG_VERSION=${OPTARG}
			;;
		d)
			readonly local DRYRUN=1
			;;
		h)
			usage
			;;
		*)
			usage
			;;
		esac
	done

	if [ "x$GPG_VERSION" == "x" ]; then
		GPG_VERSION="latest"
	fi

	DISTRO="$(detect_platform)"

	case $DISTRO in
		"CentOS Linux")
			echo "Installing CentOS yum dependencies"
			prequisites_yum
			;;
	esac

	case "$GPG_VERSION" in
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
+-------------------+
| INSTALL COMPLETE! |
+-------------------+
DONE

}

main "$@"

exit 0
