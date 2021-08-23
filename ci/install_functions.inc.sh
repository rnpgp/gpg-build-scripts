#!/usr/bin/env bash

set -euo pipefail

: "${MAKE:=make}"
: "${MAKE_PARALLEL:=2}"
: "${SUDO:=command}"

: "${LOCAL_BUILDS:=$GITHUB_WORKSPACE/builds}"

case "$OSTYPE" in
	darwin*)
		: "${PREFIX:=/usr/local}"
		;;
	*)
		: "${PREFIX:=/usr}"
esac

if [[ "${GPG_VERSION:-}" = 2.3.* || "${SCRIPT}" = all_head ]]; then
	: "${MINIMUM_AUTOMAKE_VERSION:=1.16.3}"
	: "${MINIMUM_BISON_VERSION:=3.0}"
	: "${MINIMUM_GETTEXT_VERSION:=0.19.3}"
else
	: "${MINIMUM_AUTOMAKE_VERSION:=1.16.1}"
	: "${MINIMUM_BISON_VERSION:=2.0}"
	: "${MINIMUM_GETTEXT_VERSION:=0.18.3}"
fi
: "${RECOMMENDED_AUTOMAKE_VERSION:=1.16.4}"
: "${RECOMMENDED_BISON_VERSION:=3.7}"
: "${RECOMMENDED_GETTEXT_VERSION:=0.21}"

# Print out crucial variables for debugging.
debug_env() {
	>&2 echo "${FUNCNAME[1]:+${FUNCNAME[1]}()}"

	for i in \
		MAKE \
		MAKE_PARALLEL \
		SUDO \
		LOCAL_BUILDS \
		SCRIPT \
		PATH \
		; do
			>&2 echo "${i}=\"${!i}\""
		done
}

# Make sure gettext is at least 0.19.3+ as required by libgpg-error
# If not, build gettext from source.
ensure_gettext() {
	local gettext_version
	gettext_version=$({
		command -v gettext >/dev/null && command gettext --version
	} | head -n1 | cut -f4 -d' ')

	ensure_version \
		gettext \
		"${MINIMUM_GETTEXT_VERSION}" \
		"${gettext_version}"
}

build_and_install_gettext() {
	build_and_install \
		gettext \
		gettext.tar.xz \
		https://ftp.gnu.org/gnu/gettext/gettext-${RECOMMENDED_GETTEXT_VERSION}.tar.xz
}

ensure_version() {
	local bin_name="${1:?Missing bin name}"; shift
	local min_version="${1:?Missing min_version}"; shift

	local installed_version="${1:?Missing installed version}"

	local need_to_rebuild=

	if ! is_version_at_least "${bin_name}" "${min_version}" echo "${installed_version}"; then
		>&2 echo "${bin_name} version lower than ${min_version}."
		need_to_rebuild=1
	fi

	if [[ "${need_to_rebuild}" != 1 ]]; then
		>&2 echo "${bin_name} rebuild is NOT needed."
		return
	fi

	>&2 echo "${bin_name} rebuild is needed."

	pushd "$(mktemp -d)" || return 1

	build_and_install_"${bin_name}"

	command -v "${bin_name}"

	popd
}


# Make sure automake is at least 1.16.3+ as required by GnuPG 2.3.
# If not, build automake from source.
ensure_automake() {
	local automake_version
	automake_version=$({
		command -v automake >/dev/null && command automake --version
	} | head -n1 | cut -f4 -d' ')

	ensure_version \
		automake \
		"${MINIMUM_AUTOMAKE_VERSION}" \
		"${automake_version}"
}

build_and_install_automake() {
	build_and_install \
		automake \
		automake.tar.xz \
		https://ftp.gnu.org/gnu/automake/automake-${RECOMMENDED_AUTOMAKE_VERSION}.tar.xz
}

# Make sure bison is at least 3+ as required by libska 1.6.1+
# If not, build bison from source.
ensure_bison() {
	local bison_version
	bison_version=$({
		command -v bison >/dev/null && command bison --version
	} | head -n1 | cut -f4 -d' ')

	ensure_version \
		bison \
		"${MINIMUM_BISON_VERSION}" \
		"${bison_version}"
}

build_and_install_bison() {
	build_and_install \
		bison \
		bison.tar.xz \
		https://ftp.gnu.org/gnu/bison/bison-${RECOMMENDED_BISON_VERSION}.tar.xz
}

build_and_install() {
	local package_name="${1:?Missing package name}"; shift
	local package_filename="${1:?Missing package filename}"; shift
	local package_download_source="${1:?Missing package download_source}"; shift

	debug_env

	local build_dir=${LOCAL_BUILDS}/${package_name}
	mkdir -p "${build_dir}"
	pushd "${build_dir}"
	curl -L -o "${package_filename}" "${package_download_source}"
	tar -xf "${package_filename}" --strip 1
	./configure --enable-optimizations --prefix="${PREFIX}" && ${MAKE} -j"${MAKE_PARALLEL}" && ${SUDO} ${MAKE} install
	popd
}


is_version_at_least() {
	local bin_name="${1:?Missing bin name}"; shift
	local version_constraint="${1:?Missing version constraint}"; shift
	local need_to_build=0

	if ! command -v "${bin_name}"; then
		>&2 echo "Warning: ${bin_name} not installed."
		need_to_build=1
	fi

	local installed_version installed_version_major installed_version_minor #version_patch
	installed_version="$("$@")"

  # shellcheck disable=SC2181
  if [[ $? -ne 0 ]]; then
	  need_to_build=1
  else
	  installed_version_major="${installed_version%%.*}"
	  installed_version_minor="${installed_version#*.}"
	  installed_version_minor="${installed_version_minor%%.*}"
	  installed_version_minor="${installed_version_minor:-0}"
	  installed_version_patch="${installed_version#${installed_version_major}.}"
	  installed_version_patch="${installed_version_patch#${installed_version_minor}}"
	  installed_version_patch="${installed_version_patch#.}"
	  installed_version_patch="${installed_version_patch%%.*}"
	  installed_version_patch="${installed_version_patch:-0}"

	  local need_version_major
	  need_version_major="${version_constraint%%.*}"
	  need_version_minor="${version_constraint#*.}"
	  need_version_minor="${need_version_minor%%.*}"
	  need_version_minor="${need_version_minor:-0}"
	  need_version_patch="${version_constraint##*.}"
	  need_version_patch="${version_constraint#${need_version_major}.}"
	  need_version_patch="${need_version_patch#${need_version_minor}}"
	  need_version_patch="${need_version_patch#.}"
	  need_version_patch="${need_version_patch%%.*}"
	  need_version_patch="${need_version_patch:-0}"

	  >&2 echo "
	  -> installed_version_major=${installed_version_major}
	  -> installed_version_minor=${installed_version_minor}
	  -> installed_version_patch=${installed_version_patch}
	  -> need_version_major=${need_version_major}
	  -> need_version_minor=${need_version_minor}
	  -> need_version_patch=${need_version_patch}"

	# Naive semver comparison
	if [[ "${installed_version_major}" -lt "${need_version_major}" ]] || \
		[[ "${installed_version_major}" = "${need_version_major}" && "${installed_version_minor}" -lt "${need_version_minor}" ]] || \
		[[ "${installed_version_major}.${installed_version_minor}" = "${need_version_major}.${need_version_minor}" && "${installed_version_patch}" -lt "${need_version_patch}" ]]; then
			need_to_build=1
	fi
  fi

  if [[ 1 = "${need_to_build}" ]]; then
	  >&2 echo "Warning: Need to build ${bin_name} since version constraint ${version_constraint} not met."
  else
	  >&2 echo "No need to build ${bin_name} since version constraint ${version_constraint} is met."
  fi

  return "${need_to_build}"
}
