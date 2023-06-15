#!/usr/bin/env bash

set -euo pipefail

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ROOT="$SCRIPTPATH/.."
CONFIG="$ROOT/config"
OUT="$ROOT/firmware"

west_build() {
    local BOARD="$1"
    local SHIELD="$2"

    local BUILD_DIR="${ROOT}/build-${SHIELD}"

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

    mkdir -p "$OUT"
    if [[ -f "${BUILD_DIR}"/zephyr/zmk.uf2 ]]; then
        local OUT_UF2="$OUT/${SHIELD}_${BOARD}-zmk.uf2"
        if [[ -f "$OUT_UF2" ]]; then
                rm "$OUT_UF2"
        fi
        ln -s "${BUILD_DIR}"/zephyr/zmk.uf2 "$OUT_UF2"
    fi
}

BOARD=seeeduino_xiao_ble
SHIELD=mykeeb_v7a2_left

west_build "$BOARD" "$SHIELD"