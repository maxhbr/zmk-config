#!/usr/bin/env bash

set -euo pipefail

DIR="$HOME/ZMK"

if [[ -d "$DIR" ]]; then
    exit 1
fi

mkdir -p "$DIR"
cd "$DIR"
west init -m https://github.com/maxhbr/zmk-config
west update
west zephyr-export
