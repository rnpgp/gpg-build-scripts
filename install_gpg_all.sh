#!/usr/bin/env bash
#

######################
# ARGUMENTS HANDLING #
######################

print_help ()
{
	cat <<HELP
USAGE

	install_gpg_all.sh <options> <component options>

DESCRIPTION

	Installs a whole GnuPG suite.

	All arguments which are not recognized by this script are forwarded to
	install_gpg_component.sh script (<component options>).  They must be
	specified after <options> (if any).

EXAMPLES

	# Installing latest version of all GnuPG software
	install_gpg_component.sh --suite-version latest

	# Installing GnuPG 2.1
	install_gpg_component.sh --suite-version 2.1

	# Passing options to install_gpg_component.sh scripts
	install_gpg_component.sh --suite-version latest --sudo

OPTIONS

	--suite-version VERSION

		Defines which version of GnuPG components should be installed.  Default
		is "latest".

		Following values for VERSION are supported:

		"2.2"
			GnuPG 2.2, and matching dependencies.

		"2.1"
			GnuPG 2.1, and matching dependencies.

		"latest"
			Latest version of GnuPG, and its dependecies.  Prefer "latest"
			over "2.2".

		"master"
			Install all GnuPG components from Git master branch.

	--help, -h
		Displays this message.

HELP
}

set_default_options()
{
	_arg_suite="latest"
	_arr_component_options=()
}

parse_cli_arguments()
{
	while test $# -gt 0
	do
		case "$1" in
			--suite-version)
				_arg_suite="$2"
				shift
				shift
				;;
			-h|--help)
				print_help
				exit 0
				;;
			*)
				_arr_component_options=("${@}")
				break
		esac
	done
}

######################
#      BUILDING      #
######################

set_compiler_and_linker_flags()
{
	case "${_arg_suite}" in
		"2.1")
			# Newer versions of g++ tend to complain about how GnuPG 2.1 uses C++ unions.
			# In order to prevent build failures, following has to be set.
			export CXXFLAGS="${CXXFLAGS} -std=c++11"
			;;
	esac
}

install_suite()
{
	case "${_arg_suite}" in
		"2.2")
			./install_gpg_component.sh --component-name libgpg-error --component-version 1.32 "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name libgcrypt --component-version 1.8.3 "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name libassuan --component-version 2.5.1 "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name libksba --component-version 1.3.5 "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name npth --component-version 1.6 "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name pinentry --component-version 1.1.0 "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name gnupg --component-version 2.2.10 "${_arr_component_options[@]}"
			;;
		"2.1")
			./install_gpg_component.sh --component-name libgpg-error --component-version 1.27 "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name libgcrypt --component-version 1.7.6 "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name libassuan --component-version 2.4.3 "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name libksba --component-version 1.3.5 "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name npth --component-version 1.2 "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name pinentry --component-version 0.9.5 "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name gnupg --component-version 2.1.20 "${_arr_component_options[@]}"
			;;
		"latest")
			./install_gpg_component.sh --component-name libgpg-error --component-version latest "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name libgcrypt --component-version latest "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name libassuan --component-version latest "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name libksba --component-version latest "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name npth --component-version latest "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name pinentry --component-version latest "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name gnupg --component-version latest "${_arr_component_options[@]}"
			;;
		"master")
			./install_gpg_component.sh --component-name libgpg-error --component-git-ref master "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name libgcrypt --component-git-ref master "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name libassuan --component-git-ref master "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name libksba --component-git-ref master "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name npth --component-git-ref master "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name pinentry --component-git-ref master "${_arr_component_options[@]}"
			./install_gpg_component.sh --component-name gnupg --component-git-ref master "${_arr_component_options[@]}"
			;;
	esac

	cat <<DONE
+-------------------+
| INSTALL COMPLETE! |
+-------------------+
DONE
}

######################
#   ERROR HANDLING   #
######################

readonly __progname="$(basename "$0")"

errx() {
	echo -e "$__progname: $*" >&2
	exit 1
}

######################
#        MAIN        #
######################

set -e # Early exit if any command returns non-zero status code

set_default_options
parse_cli_arguments "$@"
set_compiler_and_linker_flags
install_suite

exit 0
