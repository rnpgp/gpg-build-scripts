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
	echo "usage: $__progname [-t <TEMP_BUILD_DIR>] [-i <GPG_VERSION>] [-d]"
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
	echo "  - TEMP_BUILD_DIR"
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

	while getopts ":t:idh" o; do
		case "${o}" in
		t)
			readonly local TEMP_BUILD_DIR=1
			;;
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

	[[ ! "$TEMP_BUILD_DIR" ]] && \
		TEMP_BUILD_DIR="$(mktemp -d)"

	DISTRO="$(detect_platform)"

	case $DISTRO in
		"CentOS Linux")
			echo "Installing CentOS yum dependencies"
			prequisites_yum
			;;
	esac

	case "$GPG_VERSION" in
		"2.2")
			./install_gpg_component.sh --component libgpg-error --version 1.31 --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component libgcrypt --version 1.8.2 --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component libassuan --version 2.5.1 --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component libksba --version 1.3.5 --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component npth --version 1.5 --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component pinentry --version 1.1.0 --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component gnupg --version 2.2.7 --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			;;
		"2.1")
			./install_gpg_component.sh --component libgpg-error --version 1.27 --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component libgcrypt --version 1.7.6 --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component libassuan --version 2.4.3 --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component libksba --version 1.3.5 --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component npth --version 1.2 --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component pinentry --version 0.9.5 --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component gnupg --version 2.1.20 --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			;;
		"latest")
			./install_gpg_component.sh --component libgpg-error --version latest --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component libgcrypt --version latest --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component libassuan --version latest --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component libksba --version latest --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component npth --version latest --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component pinentry --version latest --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component gnupg --version latest --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			;;
		"master")
			./install_gpg_component.sh --component libgpg-error --version master --git --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component libgcrypt --version master --git --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component libassuan --version master --git --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component libksba --version master --git --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component npth --version master --git --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component pinentry --version master --git --build-dir "$TEMP_BUILD_DIR" "${@:2}"
			./install_gpg_component.sh --component gnupg --version master --git --build-dir "$TEMP_BUILD_DIR" "${@:2}"
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
