#!/usr/bin/env bash
set -euo pipefail

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
CONFIG="$SCRIPTPATH/.."
cd "$CONFIG"
west init -l ./config
west update
west zephyr-export
