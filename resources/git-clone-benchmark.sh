#!/usr/bin/env bash

# Output of this script is compatible with `column`. Run
## script.sh | column -t -s $'\t'
# to format the output.

set -eu

TIMEFORMAT='%lR'

function error_out() {
	echo -e "\nCouldn't clone! Command '$command' failed:" 1>&2
	cat "$LOG" 1>&2
	rm -r "$DIR"
	exit 1
}

DIR="$(mktemp --tmpdir -d xbps-src-tutorial-clone-benchmark.XXXXXXXXXX || exit 1)"
LOG="$DIR/log"

# shellcheck disable=SC2064
trap "cd / && rm -r $DIR; exit 1" SIGINT SIGTERM SIGQUIT

cd "$DIR"

function execute_command() {
	[ $# -ne 2 ] && exit 1
	local name="$1" command="$2"
	echo -ne "$name\t"
	TIME="$({ time $command > "$LOG" 2>&1; } 2>&1)" || error_out
	echo -e "time $TIME\tspace $(du -sh "$DIR/void-packages" | grep -o "^\S*")"
	rm -rf "$DIR/void-packages"
}

execute_command "shallow clone" "git clone --depth=1 git@github.com:void-linux/void-packages.git"
execute_command "treeless clone" "git clone --filter=tree:0 git@github.com:void-linux/void-packages.git"
execute_command "full clone" "git clone git@github.com:void-linux/void-packages.git"
execute_command "blobless clone" "git clone --filter=blob:none git@github.com:void-linux/void-packages.git"

rm -r "$DIR"
