#!/usr/bin/env bash

set -euo pipefail

DIR="$(readlink -f "$(dirname "$0")")/firmware"
cd "$DIR"

date_dir="$(date "+%F_%H-%M-%S")"
mkdir -p "$DIR/$date_dir"
cd "$DIR/$date_dir"
gh run download --pattern firmware

cd "$DIR"
find "$date_dir" -type f |
    while read output; do
        bn="$(basename "$output")"
        if [[ -f "$bn" ]]; then
            rm "$bn"
        fi
        ln -s "$output" "$bn"
    done