#!/bin/sh

MDBOOK_CATPPUCCIN_VERSION="2.2.0"

set -o errexit -o nounset

get_asset_version() {
	[ $# -ne 1 ] && return 1
	asset_version="$(grep -o -m 1 -P '(?<=assets_version = ")[^"]*' "$1/book.toml")"
}

poppulate_cache_admonish() {
	[ $# -ne 1 ] && return 1
	cache_dir="$1"

	if ! type mdbook-admonish > /dev/null 2>&1; then
		echo "\
mdbook-admonish must be installed! See
https://github.com/tommilligan/mdbook-admonish" >&2
		exit 1
	fi

	# Create a fake mdbook config file so that mdbook-admonish can install its
	# files to it.
	touch "${cache_dir}/book.toml"

	mdbook-admonish install "$cache_dir"

	if ! [ -f "${cache_dir}/mdbook-admonish.css" ]; then
		echo "Couldn't generate ${cache_dir}/mdbook-admonish.css!" >&2
		exit 1
	fi
}

poppulate_cache_catppuccin_index() {
	[ $# -ne 3 ] && return 1

	base="$1"
	temporary_default_theme="$2"
	modified_theme="$3"

	# We take the default index.hbs and patch in our new themes.
	mkdir "$temporary_default_theme"
	mdbook init --theme --force --title "index.hbs mdbook book" --ignore none\
		"$temporary_default_theme"
	patch -d "$temporary_default_theme" -p1\
		< "${base}/theme/add-catppuccin-to-index.patch"

	mkdir "$modified_theme"

	# Move the only file we care about, index.hbs, somewhere else and leave the rest.
	mv "${temporary_default_theme}/theme/index.hbs" "${modified_theme}/index.hbs"
}

poppulate_cache_catppuccin_css() {
	[ $# -ne 1 ] && return 1

	cache_dir="$1"

	archive_base_path_that_will_be_stripped="mdBook-${MDBOOK_CATPPUCCIN_VERSION}/src/bin/assets"

	# --strip-components refers to the number of components in
	# archive_base_path_that_will_be_stripped
	curl -L "https://github.com/catppuccin/mdBook/archive/refs/tags/v${MDBOOK_CATPPUCCIN_VERSION}.tar.gz" |\
		tar -C "${cache_dir}" --strip-components=4 -xzf -\
			"${archive_base_path_that_will_be_stripped}/catppuccin-admonish.css"\
			"${archive_base_path_that_will_be_stripped}/catppuccin.css"
}

populate_cache() {
	[ $# -ne 4 ] && return 1

	dir="$1"
	base="$2"
	modified_theme="$3"
	enable_catppuccin="$4"

	mkdir -p "$dir" || true

	if ! [ -f "${dir}/mdbook-admonish.css" ]; then
		poppulate_cache_admonish "$dir"
	fi

	if [ -z "$enable_catppuccin" ]; then
		return
	fi

	if ! [ -f "${modified_theme}/index.hbs" ]; then
		poppulate_cache_catppuccin_index "$base" "${dir}/temporary-default-theme"\
			"$modified_theme"
	fi

	if ! { [ -f "${dir}/catppuccin-admonish.css" ] && [ -f "${dir}/catppuccin.css" ]; }; then
		poppulate_cache_catppuccin_css "$dir"
	fi

	# Try to do smart copy of all static theme files to the cached directory.
	# If it fails, try using a simpler cp cmdline (because the failure could have
	# been caused by using cp other than the one provided by GNU coreutils).
	cp --reflink=auto --update=older "${base}"/theme/* "$modified_theme" ||\
		cp "${base}"/theme/* "$modified_theme"
}

exec_mdbook() {
	[ $# -lt 3 ] && return 1
	asset_version="$1"
	cache_dir="$2"
	theme_dir="$3"
	shift 3

	# Accumulate all CSS files in cache_dir in JSON-ish format.
	additional_css=""
	for css_file in "${cache_dir}"/*.css; do
		if [ -z "$additional_css" ]; then
			additional_css="[\"$css_file\""
		else
			additional_css="${additional_css}, \"${css_file}\""
		fi
	done
	additional_css="${additional_css}]"

	if [ "$theme_dir" ]; then
		export MDBOOK_OUTPUT__HTML__THEME="$theme_dir"
	fi

	exec env MDBOOK_PREPROCESSOR__ADMONISH="{\"assets_version\": \"$asset_version\"}"\
		MDBOOK_OUTPUT__HTML__ADDITIONAL_CSS="$additional_css"\
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
  $0 [-b <directory>] [-c <directory>] [-e <true|false>] mdbook commandline...
  $0 -h

Options:
  -h              Show this help message.
  -b=<directory>  Set base directory.
  -c=<directory>  Set cache directory.
  -e=<true|false> Turn on extra themes. This will download mdbook-catppuccin
                  to cache. True by default.

Example usage:
  Build the book (calls \`mdbook build\` internally):
    $0 build
  Serve the book (calls \`mdbook serve\` internally):
    $0 serve
"

# I assume $0 is set and it's valid.
basedir="$(dirname "$0")"
cache_dir_component="cache/"
enable_catppuccin="1"

while getopts hb:c:e: f; do
	case $f in
	h)
		printf %s "$usage"
		exit 0
		;;
	b)
		basedir="$OPTARG"
		;;
	c)
		cache_dir_component="$OPTARG"
		;;
	e)
		case "$OPTARG" in
			true)
				enable_catppuccin="1"
				;;
			false)
				enable_catppuccin=""
				;;
			*)
				echo "Invalid argument to -e: ${OPTARG}" >&2
				exit 1
				;;
		esac
		;;
	*)
		printf %s "$usage"
		exit 1
		;;
	esac
done

shift $((OPTIND - 1))

finaldir="${basedir}/${cache_dir_component}"

if [ "$enable_catppuccin" ]; then
	cached_theme_dir="${finaldir}/theme"
else
	cached_theme_dir=""
fi

populate_cache "$finaldir" "$basedir" "$cached_theme_dir" "$enable_catppuccin"
get_asset_version "$finaldir"
exec_mdbook "$asset_version" "$finaldir" "$cached_theme_dir" "$@"
