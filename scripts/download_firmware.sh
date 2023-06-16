#!/usr/bin/env bash
set -euo pipefail

SCRIPT="$(readlink -f "$0")"
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
DIR="${SCRIPTPATH}/../firmware"
mkdir -p "$DIR"
cd "$DIR"

gh run list --limit 1
conclusion="$(gh run list --limit 1 --json conclusion --jq '.[].conclusion')"
echo "last action run: ${conclusion}"
if [[ "$conclusion" == "" ]]; then
    sleep 10
    exec "$SCRIPT"
elif [[ "$conclusion" != "success" ]]; then
    exit 1
fi
echo

date_dir="$(date "+%F_%H-%M-%S")"
mkdir -p "$DIR/$date_dir"
cd "$DIR/$date_dir"
gh run download --pattern firmware

cd "$DIR"
find "$date_dir" -type f |
    while read -r output; do
        bn="$(basename "$output")"
        echo "get $bn"
        if [[ -f "$bn" ]]; then
            rm "$bn"
        fi
        ln -s "$output" "$bn"
    done
