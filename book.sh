#!/bin/bash

set +o nounset

get_asset_version() {
	[ $# -ne 1 ] && return 1
	asset_version="$(grep -o -m 1 -P '(?<=assets_version = ")[^"]*' "$1/book.toml" || exit 1)"
}

populate_cache() {
	if ! type mdbook-admonish >/dev/null 2>&1; then
		echo "\
mdbook-admonish must be installed! See
https://github.com/tommilligan/mdbook-admonish" 1>&2
		exit 1
	fi

	[ $# -ne 1 ] && return 1

	local dir="$1"

	mkdir -p "$dir" || exit 1

	# Create a fake mdbook config file so that mdbook-admonish can install its files
	# to it.
	touch "${dir}/book.toml" || exit 1

	mdbook-admonish install "$dir" || exit 1

	if ! [ -f "${dir}/mdbook-admonish.css" ]; then
		echo "Couldn't generate ${dir}/mdbook-admonish.css!" 1>&2
		exit 1
	fi
}

additional_css() {
	[ $# -ne 1 ] && return 1
	local book_toml="$1"

	local line
	line="$(grep 'additional-css' "$book_toml")"

	case $? in
	0)
		additional_css_decl="$(echo "$line" | grep -Pom 1 '(?<=\[)[^]]*')"
		return 0
		;;
	1)
		additional_css_decl=""
		return 0
		;;
	*)
		exit 1
		;;
	esac
}

exec_mdbook() {
	[ $# -lt 2 ] && return 1
	local asset_version="$1"
	local finaldir="$2"
	shift 2

	local additional_css=""
	if [ -n "$additional_css_decl" ]; then
		additional_css="$additional_css_decl, "
	fi

	additional_css="${additional_css}\"${finaldir}/mdbook-admonish.css\""

	exec env MDBOOK_PREPROCESSOR__ADMONISH="{\"assets_version\": \"$asset_version\"}" \
		MDBOOK_OUTPUT__HTML__ADDITIONAL_CSS="[$additional_css]" \
		mdbook "$@"
}

usage="\
A wrapper for mdBook which handles mdbook-admonish.

$0 needs to generate some files. It puts them to <the directory the script
resides in>/cache/ by default.

You can change the base directory with -b <directory> (directory the script
resides in by default) and the cache subdirectory (cache/ by default) with -c
<directory relative to base directory>. The files are put into <base
directory>/<subdirectory>

Directories are created if they do not exist.

Usage:
  $0 [-b <directory>] [-c <directory>] mdbook commandline...
  $0 -h

Options:
  -h              Show this help message.
  -b=<directory>  Set base directory.
  -c=<directory>  Set cache directory.

Example usage:
  Build the book (calls \`mdbook build\` internally):
    $0 build
  Serve the book (calls \`mdbook serve\` internally):
    $0 serve
"

# I assume $0 is set and it's valid.
basedir="$(dirname "$0")"
cachedir="cache/"

while getopts hb:c: f; do
	case $f in
	h)
		printf %s "$usage"
		exit 0
		;;
	b)
		basedir="$OPTARG"
		;;
	c)
		cachedir="$OPTARG"
		;;
	*)
		printf %s "$usage"
		exit 1
		;;
	esac
done

shift $((OPTIND - 1))

finaldir="${basedir}/${cachedir}"

additional_css "${basedir}/book.toml" || exit 1

if [ -f "${finaldir}/mdbook-admonish.css" ]; then
	get_asset_version "$finaldir" || exit 1
	exec_mdbook "$asset_version" "$finaldir" "$@" || exit 1
else
	populate_cache "$finaldir" || exit 1
	get_asset_version "$finaldir" || exit 1
	exec_mdbook "$asset_version" "$finaldir" "$@" || exit 1
fi
