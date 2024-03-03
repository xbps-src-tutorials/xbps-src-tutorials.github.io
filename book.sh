#!/bin/sh

set +o errexit +o nounset

get_asset_version() {
	[ $# -ne 1 ] && return 1
	asset_version="$(grep -o -m 1 -P '(?<=assets_version = ")[^"]*' "$1/book.toml")"
}

populate_cache() {
	if ! type mdbook-admonish > /dev/null 2>&1; then
		echo "\
mdbook-admonish must be installed! See
https://github.com/tommilligan/mdbook-admonish" 1>&2
		exit 1
	fi

	[ $# -ne 1 ] && return 1

	dir="$1"

	mkdir -p "$dir"

	# Create a fake mdbook config file so that mdbook-admonish can install its files
	# to it.
	touch "${dir}/book.toml"

	mdbook-admonish install "$dir"

	if ! [ -f "${dir}/mdbook-admonish.css" ]; then
		echo "Couldn't generate ${dir}/mdbook-admonish.css!" 1>&2
		exit 1
	fi
}

exec_mdbook() {
	[ $# -lt 2 ] && return 1
	asset_version="$1"
	finaldir="$2"
	shift 2
	exec env MDBOOK_PREPROCESSOR__ADMONISH="{\"assets_version\": \"$asset_version\"}"\
	 MDBOOK_OUTPUT__HTML__ADDITIONAL_CSS="[\"${finaldir}/mdbook-admonish.css\"]"\
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
basedir="$(dirname $0)"
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

if [ -f "${finaldir}/mdbook-admonish.css" ]; then
	get_asset_version "$finaldir"
	exec_mdbook "$asset_version" "$finaldir" "$@"
else
	populate_cache "$finaldir"
	get_asset_version "$finaldir"
	exec_mdbook "$asset_version" "$finaldir" "$@"
fi
