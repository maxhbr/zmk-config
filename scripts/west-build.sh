#!/usr/bin/env bash

set -euo pipefail

BOARD=seeeduino_xiao_ble
SHIELD=mykeeb_v7a2_left

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ROOT="$SCRIPTPATH/.."
CONFIG="$ROOT/config"
BUILD_DIR="${ROOT}-${SHIELD}"
cd "$ROOT"
west-arm build \
    -p auto \
    -d "${BUILD_DIR}" \
    -s "$ROOT/zmk/app" \
    -b "$BOARD" \
    -- \
    -DZMK_CONFIG="$CONFIG" \
    -DSHIELD="$SHIELD" \
    -DBOARD_ROOT="$CONFIG"

# mkdir -p build/artifacts
if [ -f "${BUILD_DIR}"/zephyr/zmk.uf2 ]; then
    cp "${BUILD_DIR}"/zephyr/zmk.uf2 "${SHIELD}-${BOARD}.uf2"
fi
