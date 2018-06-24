#!/usr/bin/env bash
#

######################
# ARGUMENTS HANDLING #
######################

print_help ()
{
	cat <<HELP
USAGE

	install_gpg_component.rb <options>

EXAMPLES

	# Installing latest version of libgpg-error
	install_gpg_component.rb --component libgpg-error --version latest

	# Installing latest version of libgpg-error with sudo
	install_gpg_component.rb --component libgpg-error --version latest --sudo

	# Installing latest git revision of libgpg-error
	install_gpg_component.rb --component libgpg-error --version master --git

	# Passing options to ./configure script
	install_gpg_component.rb --component libgpg-error --version latest --configure-opts "--disable-doc --exec-prefix=/my/bin"

OPTIONS

	--component COMPONENT
		Component to install

	--version VERSION
		Component version to install (use "latest" for the latest release),
		or git ref (branch, tag, commit hash etc.) when used with "--git"
		option (typically "master").

	--[no-]git
		Fetch source code from git repository instead of downloading release,
		pass branch or tag name to --version argument.  By default it is off.

	--[no-]sudo
		Whether to do 'sudo make install', or just 'make install'.
		Doesn't affect post install steps, which may require sudo.  By default
		it is off.

	--configure-opts OPTS
		Options to be passed to "./configure" script.

	--build-dir DIR
		Directory in which the compilation will happen.  Content may be
		overwritten during build.  Directory will be created if non-existent.

	--folding-style STYLE
		If set, enables output folding.  STYLE defines the folding notation
		used.  Following STYLE values are recognized:

		"none"
			Disable folding.  This is default.

		"travis"
			Fold output for Travis CI builds.  See this example Travis job:
			https://api.travis-ci.org/v3/job/15440998/log.txt

	--help, -h
		Displays this message

HELP
}

set_default_options()
{
	_arg_build_dir=
	_arg_configure_opts=
	_arg_sudo="off"
	_arg_git="off"
	_arg_color="off"
	_arg_folding_style="none"
}

parse_cli_arguments()
{
	while test $# -gt 0
	do
		case "$1" in
			--component)
				_arg_component="$2"
				shift
				shift
				;;
			--version)
				_arg_version="$2"
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
			--sudo)
				_arg_sudo="on"
				shift
				;;
			--no-sudo)
				_arg_sudo="off"
				shift
				;;
			--git)
				_arg_git="on"
				shift
				;;
			--no-git)
				_arg_git="off"
				shift
				;;
			--folding-style)
				_arg_folding_style="$2"
				shift
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

display_config()
{
	cat <<CONFIG
component: "${_arg_component}"
version: "${_arg_version}"
git: "${_arg_git}"
sudo: "${_arg_sudo}"
build_dir: "${_arg_build_dir}"
configure_options: "${_arg_configure_opts}"

CONFIG
}

# Consults https://versions.gnupg.org/swdb.lst and assigns the most recent
# version of component ${_arg_component} to ${_arg_version} variable.
determine_latest_version()
{
	fold_start "component.${_arg_component}.detect-latest"
	local _component_underscored=`echo "${_arg_component}" | tr - _`
	_arg_version=`curl "https://versions.gnupg.org/swdb.lst" | grep "_ver" | grep -v "w32" | sort --reverse | grep "${_component_underscored}" | head -n 1 | cut -d " " -f 2`
	echo "The latest version of ${_arg_component} is ${_arg_version}."
	fold_end "component.${_arg_component}.fetch"
}

fetch_source()
{
	fold_start "component.${_arg_component}.fetch"
	if [[ "${_arg_git}" = "on" ]]; then
		fetch_from_git
	else
		fetch_release
	fi
	fold_end "component.${_arg_component}.fetch"
}

fetch_release()
{
	local _tarball_file_name="${_arg_component}-${_arg_version}.tar.bz2"
	local _tarball_url="https://gnupg.org/ftp/gcrypt/${_arg_component}/${_tarball_file_name}"
	curl ${_tarball_url} --remote-name --retry 5
	tar -xjf ${_tarball_file_name}
	rm ${_tarball_file_name}
	set_component_build_dir "${_arg_component}-${_arg_version}"
}

fetch_from_git()
{
	local _git_url="git://git.gnupg.org/${_arg_component}"
	set_component_build_dir "${_arg_component}-git-${_arg_version}"

	if [ ! -d "${_component_build_dir}" ]; then
		git clone ${_git_url} "${_component_build_dir}"
	else
		pushd "${_component_build_dir}"
		git fetch # need to fetch prior checkout, ref may be nonexistent locally
		popd
	fi

	pushd "${_component_build_dir}"
	git checkout ${_arg_version}
	git pull # in case of outdated local branch
	popd
}

build_and_install()
{
	pushd "${_component_build_dir}"
	if [ ! -f configure ]; then
		fold_start "component.${_arg_component}.autogen"
		./autogen.sh
		fold_end "component.${_arg_component}.autogen"
	fi
	fold_start "component.${_arg_component}.configure"
	./configure ${_arg_configure_opts}
	fold_end "component.${_arg_component}.configure"
	fold_start "component.${_arg_component}.build"
	make > /dev/null
	fold_end "component.${_arg_component}.build"
	fold_start "component.${_arg_component}.install"
	sudo make install > /dev/null
	fold_end "component.${_arg_component}.install"
	popd
}

set_component_build_dir()
{
	_component_build_dir=$1
}

header()
{
	echo ""
	echo ""
	echo "=== $1 ==="
	echo ""
	echo ""
}

######################
#    PRETTY OUTPUT   #
######################

fold_start()
{
	case "${_arg_folding_style}" in
		travis)
			echo "travis_fold:start:$1"
			;;
		*)
			;;
	esac
}

fold_end()
{
	case "${_arg_folding_style}" in
		travis)
			echo "travis_fold:end:$1"
			;;
		*)
			;;
	esac
}

######################
#        MAIN        #
######################

set -e # Early exit if any command returns non-zero status code

set_default_options
parse_cli_arguments "$@"

fold_start "component.${_arg_component}"

header "Installing ${_arg_component} / ${_arg_version}"

display_config

# set -x # From now, print every command to STDOUT

if [[ "${_arg_version}" =~ ^latest ]]; then
	determine_latest_version
fi

mkdir -p ${_arg_build_dir}
pushd ${_arg_build_dir}
fetch_source
build_and_install
popd # _arg_build_dir

if [[ "${_arg_component}" =~ ^gnupg ]]; then
	fold_start "component.${_arg_component}.post-install"
	sudo tee -a /etc/ld.so.conf.d/gpg2.conf <<<"/usr/local/lib"
	sudo ldconfig -v
	fold_end "component.${_arg_component}.post-install"
fi

fold_end "component.${_arg_component}"
