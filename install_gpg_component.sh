#!/usr/bin/env bash
#
# shellcheck disable=SC2155

######################
# ARGUMENTS HANDLING #
######################

print_help ()
{
	cat <<HELP
USAGE

	install_gpg_component.sh <options>

DESCRIPTION

	Installs a single component of GnuPG suite.

EXAMPLES

	# Installing latest version of libgpg-error
	install_gpg_component.sh --component-name libgpg-error --component-version latest

	# Installing latest version of libgpg-error with sudo
	install_gpg_component.sh --component-name libgpg-error --component-version latest --sudo

	# Installing latest git revision of libgpg-error
	install_gpg_component.sh --component-name libgpg-error --component-git-ref master

	# Passing options to ./configure script
	install_gpg_component.sh --component-name libgpg-error --component-version latest --configure-opts "--disable-doc"

OPTIONS

	Basic options:

	--component-name COMPONENT
		Component to install.  This option is mandatory.

	--component-version VERSION
		Component version to install (use "latest" for the latest release),
		or git ref (branch, tag, commit hash etc.) when used with "--component-git-ref"
		option (typically "master").

		Either --component-version or --component-git-ref is mandatory.

	--component-git-ref REF
		Fetch source code from git repository instead of downloading release,
		use branch or tag name specified by REF argument (typically "master").

		Either --component-version or --component-git-ref is mandatory.

	Build options:

	--build-dir DIR
		Directory in which the compilation will happen.  Content may be
		overwritten during build.  Directory will be created if non-existent.
		If not set, a temporary directory will be created.

	--configure-opts OPTS
		Options to be passed to "./configure" script.

	--[no-]ldconfig
		Whether to run 'ldconfig' after component is installed.

		You probably want to turn it on when installing GnuPG on GNU+Linux
		system.  It ensures that a correct library path is written to
		"/etc/ld.so.conf.d/gpg-from_build_scripts.conf", and then runs
		"ldconfig".  Library path is obtained from Makefile which has been
		produced by "configure" script, therefore any options passed to
		configure script via --configure-opts will be honoured (e.g. --prefix).

		You may want to keep it off if you prefer to rely on LD_LIBRARY_PATH
		environment variable instead, or if you need to customize 'ldconfig'
		setup any further.

		You definitely want not to enable it on systems which do not use
		'ldconfig', e.g. MacOS.

		This option requires that current user can execute 'ldconfig', and that
		configuration file "/etc/ld.so.conf.d/gpg-from_build_scripts.conf" is
		writtable for current user.  Note that 'sudo' will be used if --sudo
		option is enabled as well.

		By default this option is off.

	--[no-]force-autogen
		Whether to do './autogen.sh', regardless of whether 'configure' exists.

		By default this option is off.

	--[no-]sudo
		Whether to do 'sudo make install', or just 'make install', and whether
		to update ldconfig configuration. Note that the ldconfig update is
		currently hardcoded to '/usr/local/lib' and so will not honor
		'--prefix' configure options changes. Consider 'LD_LIBRARY_PATH' in
		these cases. By default it is off.

	--[no-]verify
		Whether to verify signatures of tarballs with GnuPG distribution or not.
		By default it is off.

		This option requires that gpg is already in $PATH at build time.

		This option is incompatible with --component-git-ref.

	--[no-]trace
		Whether to turn on Bash option \`set -x\` in Bash, after displaying
		build configs.
		By default it is off.

	--[no-]verbose
		Whether to pass VERBOSE=1 to 'make' and 'make install'.
		By default it is off.

	Help:

	--help, -h
		Displays this message

HELP
}

set_default_options()
{
	_arg_build_dir=
	_arg_configure_opts=
	_arg_ldconfig="off"
	_arg_sudo="off"
	_arg_verify="off"
	_arg_verbose=()
	_arg_trace="off"
	_arg_force_autogen="off"
	_arg_git="off"
	_arg_color="off"
}

parse_cli_arguments()
{
	while test $# -gt 0
	do
		case "$1" in
			--component-name)
				_arg_component="$2"
				shift
				shift
				;;
			--component-version)
				_arg_version="$2"
				_arg_git="off"
				shift
				shift
				;;
			--component-git-ref)
				_arg_version="$2"
				_arg_git="on"
				shift
				shift
				;;
			--build-dir)
				_arg_build_dir="$2"
				shift
				shift
				;;
			--configure-opts)
				_arg_configure_opts="$2"
				shift
				shift
				;;
			--force-autogen)
				_arg_force_autogen="on"
				shift
				;;
			--no-force-autogen)
				_arg_force_autogen="off"
				shift
				;;
			--ldconfig)
				_arg_ldconfig="on"
				shift
				;;
			--no-ldconfig)
				_arg_ldconfig="off"
				shift
				;;
			--sudo)
				_arg_sudo="on"
				shift
				;;
			--no-sudo)
				_arg_sudo="off"
				shift
				;;
			--verify)
				_arg_verify="on"
				shift
				;;
			--no-verify)
				_arg_verify="off"
				shift
				;;
			--verbose)
				_arg_verbose=("VERBOSE=1")
				shift
				;;
			--no-verbose)
				_arg_verbose=()
				shift
				;;
			--trace)
				_arg_trace="on"
				shift
				;;
			--no-trace)
				_arg_trace="off"
				shift
				;;
			-h|--help)
				print_help
				exit 0
				;;
			*)
				echo "Unrecognized option: $1, exiting."
				exit 1
		esac
	done
}

######################
#      BUILDING      #
######################

set_important_configure_options()
{
	if [[ ${_arg_git} == "on" ]]; then
		_arg_configure_opts="--enable-maintainer-mode ${_arg_configure_opts}"
	fi
}

ensure_options_compatibility()
{
	if [[ ${_arg_git} == "on" ]] && [[ ${_arg_verify} = "on" ]]; then
		cat <<ECHO
ERROR --verify option cannot be used together with --component-git-ref.
ECHO
		exit 255
	fi
}

display_config()
{
	cat <<CONFIG
component: "${_arg_component}"
version: "${_arg_version}"
git: "${_arg_git}"
ld_config: "${_arg_ldconfig}"
sudo: "${_arg_sudo}"
verify: "${_arg_verify}"
verbose: "${_arg_verbose[*]}"
trace: "${_arg_trace}"
build_dir: "${_arg_build_dir:-"<temporary directory>"}"
configure_options: "${_arg_configure_opts}"

CONFIG
}

# Assigns the most recent
# version of component ${_arg_component} to ${_arg_version} variable.
determine_latest_version()
{
	determine_latest_version_by_swdb || \
	determine_latest_version_by_scraping

	if [[ -z "${_arg_version}" ]]; then
		>&2 echo "Warning: Could not determine version for ${_arg_component}."
		return 1
	fi
}

# Consults https://versions.gnupg.org/swdb.lst and assigns the most recent
# version of component ${_arg_component} to ${_arg_version} variable.
determine_latest_version_by_swdb()
{
	>&2 echo "Determining latest version by scraping https://versions.gnupg.org/swdb.lst"

	local _component_underscored="${_arg_component:?}"
	_component_underscored="${_component_underscored//-/_}"
	_arg_version=$(curl -s "https://versions.gnupg.org/swdb.lst" |
		grep "_ver" |
		grep -v "w32" |
		sort --reverse |
		grep "${_component_underscored}" |
		head -n 1 |
		cut -d " " -f 2)

	# shellcheck disable=SC2181
	if [[ $? != 0 ]]; then
		>&2 echo "Warning: There were issues accessing https://versions.gnupg.org/swdb.lst"
		return 1
	fi

	echo "The latest version of ${_arg_component} is '${_arg_version}'."
}

# Consults https://www.gnupg.org/ftp and assigns the most recent
# version of component ${_arg_component} to ${_arg_version} variable.
determine_latest_version_by_scraping()
{
	>&2 echo "Determining latest version by scraping https://www.gnupg.org/ftp/gcrypt/${_arg_component}/"

	# Using <<<".." to work around "Curl (23) Failed writing body" issue.
	# See: https://stackoverflow.com/questions/16703647/why-does-curl-return-error-23-failed-writing-body
	_arg_version=$(<<<"$(curl -s "https://www.gnupg.org/ftp/gcrypt/${_arg_component}/")" \
		sed '/tr/!d; /tar/!d; /'"${_arg_component:?}"'/!d; s/.tar.*$//; s/.*'"${_arg_component}"'-//; /tr/d; q'
		)

	# shellcheck disable=SC2181
	if [[ $? != 0 ]]; then
		>&2 echo "Warning: There were issues accessing https://www.gnupg.org/ftp/gcrypt/${_arg_component}/"
		return 1
	fi

	echo "The latest version of ${_arg_component} is '${_arg_version}'."
}

create_temporary_build_dir()
{
	readonly _temporary_build_dir="$(mktemp -d -t "gpg-build.XXXXXXXX")"
	trap remove_temporary_build_dir EXIT
	echo "Building in temporary directory '${_temporary_build_dir}'."
	_arg_build_dir=${_temporary_build_dir}
}

remove_temporary_build_dir()
{
	rm -rf "${_temporary_build_dir}"
}

fetch_source()
{
	if [[ "${_arg_git}" = "on" ]]; then
		fetch_from_git
	else
		fetch_release
	fi
}

fetch_release()
{
	local _tarball_file_name="${_arg_component}-${_arg_version}.tar.bz2"
	local _tarball_url="https://gnupg.org/ftp/gcrypt/${_arg_component}/${_tarball_file_name}"
	local _signature_url="${_tarball_url}.sig"
	curl "${_tarball_url}" --remote-name --retry 5
	if [[ "${_arg_verify}" = "on" ]]; then
		curl "${_signature_url}" --remote-name --retry 5
		verify_tarball_signature "${_tarball_file_name}"
	fi
	tar -xjf "${_tarball_file_name}"
	rm "${_tarball_file_name}"
	set_component_build_dir "${_arg_component}-${_arg_version}"
}

fetch_from_git()
{
	local _git_url="git://git.gnupg.org/${_arg_component}"
	set_component_build_dir "${_arg_component}-git-${_arg_version}"

	if [[ ! -d "${_component_build_dir}" ]]; then
		git clone "${_git_url}" "${_component_build_dir}"
		pushd "${_component_build_dir}"
		git checkout "${_arg_version}"
		popd
	else
		pushd "${_component_build_dir}"
		git fetch # need to fetch prior checkout, ref may be nonexistent locally
		git checkout "${_arg_version}"
		git pull # in case of outdated local branch
		popd
	fi
}

verify_tarball_signature()
{
	local _tarball_file_name=$1
	local _signature_file_name="${_tarball_file_name}.sig"
	gpg --verify "${_signature_file_name}" "${_tarball_file_name}"
}

patch_sources() {
	# For older libgpg-error versions e.g. 1.32 vs newer gawk versions e.g. 5
	#
	# See: https://github.com/openwrt/packages/commit/77587bedaeb1eb7f304a380dcc931537fce195b8
	if [[ "${_arg_component}" = libgpg-error ]]; then
		for file in src/{Makefile.{in,am},mkstrtable.awk}; do
			if [[ -f "${file}" ]]; then
				sed -i'' \
					-e "s/\bnamespace\b/varerrno/g" "${file}"
			fi
		done
	fi

	# For gpgme in CentOS 7
	# # XXX: This does not seem to work.
	# if [[ "${_arg_component}" = gpgme ]]; then
	# 	local file=configure.ac
	# 	# XXX: debug
	# 	echo "checking if file ${file} exists..." >&2
	# 	if [[ -f "${file}" ]]
	# 	then
	# 		echo
	# 		echo "File ${file} exists, patching." >&2
	# 		echo "Before patch:" >&2
	# 		grep -5 AC_PROG_CC_STDC "${file}" || :

	# 		sed -i'' \
	# 			-e 's/^AC_PROG_CC$/AC_PROG_CC\nAC_PROG_CC_STDC/g' "${file}"

	# 		echo
	# 		echo "After patch (AC_PROG_CC_STDC):" >&2
	# 		grep -5 AC_PROG_CC_STDC "${file}" || :
	# 		echo
	# 	fi
	# fi

	# For older gnupg versions (specific version uncertain)
	# XXX: Fixing this "iobuf defined multiple times" issue opens a can of
	# worms.  Disabling for now.
	# if [[ "${_arg_component}" = gnupg ]]; then
	# 	patch -s -p0 < "${__progdir}"/patches/gnupg-common-iobuf-c.patch common/iobuf.c || :
	# 	patch -s -p0 < "${__progdir}"/patches/gnupg-common-iobuf-h.patch common/iobuf.h || :
	# fi
}

build_and_install()
{
	local _sudo=""
	[[ "${_arg_sudo}" = "on" ]] && _sudo=sudo

	pushd "${_component_build_dir}"

	patch_sources

	if [[ ! -f configure ]] || [[ "${_arg_force_autogen}" = "on" ]]; then
		./autogen.sh
	fi
	# shellcheck disable=SC2086
	./configure ${_arg_configure_opts}
	make "${_arg_verbose[@]}" > /dev/null
	${_sudo} make install "${_arg_verbose[@]}" > /dev/null
	popd
}

post_install()
{
	if [[ "${_arg_ldconfig}" = "on" ]]; then
		post_install_ldconfig
	fi
}

post_install_ldconfig()
{
	local _ld_so_conf_file="/etc/ld.so.conf.d/gpg-from_build_scripts.conf"
	local _libpath=$(detect_libpath)

	local _sudo=""
	[[ "${_arg_sudo}" = "on" ]] && _sudo=sudo

	${_sudo} tee "${_ld_so_conf_file}"<<<"${_libpath}"
	${_sudo} ldconfig -v
}

set_component_build_dir()
{
	_component_build_dir=$1
}

# Returns actual libpath determined by ./configure script, typically
# "/usr/local/lib".  Requires that Makefile for given component already exists.
#
# See: https://stackoverflow.com/a/55770976/304175
#
# Note that pushd/popd output must be suprressed, otherwise it will be captured
# in calling function and treated as part of this function's return value.
detect_libpath()
{
	pushd "${_component_build_dir}" > /dev/null
	make -f - display-libdir<<'HEREMAKEFILE'
include Makefile

display-%:
	@echo "$($*)"
HEREMAKEFILE

	popd > /dev/null #$_component_build_dir
}

######################
#    PRETTY OUTPUT   #
######################

header()
{
	echo ""
	echo ""
	echo "=== $1 ==="
	echo ""
	echo ""
}

######################
#   ERROR HANDLING   #
######################

readonly __progname="$(basename "$0")"
# shellcheck disable=SC2034
readonly __progdir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

errx() {
	echo -e "$__progname: $*" >&2
	exit 1
}

######################
#        MAIN        #
######################

set -eo pipefail # Early exit if any command returns non-zero status code

set_default_options
parse_cli_arguments "$@"
ensure_options_compatibility
set_important_configure_options

header "Installing ${_arg_component} / ${_arg_version}"

display_config

if [[ "${_arg_trace}" = on ]]; then
	set -x # From now, print every command to STDOUT
fi

if [[ "${_arg_version}" =~ ^latest ]]; then
	determine_latest_version
fi

if [[ -z "${_arg_build_dir}" ]]; then
	create_temporary_build_dir
else
	mkdir -p "${_arg_build_dir}"
fi

pushd "${_arg_build_dir}"
fetch_source
build_and_install
post_install
popd # _arg_build_dir
