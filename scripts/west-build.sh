#!/usr/bin/env bash
set -euo pipefail

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ROOT="$SCRIPTPATH/.."
CONFIG="$ROOT/config"
OUT="$ROOT/firmware"

west_build() {
    local BOARD="$1"
    local SHIELD="$2"

    local BUILD_DIR="${ROOT}/${SHIELD}-${BOARD}-build"

    cd "$ROOT"
    (set -x;
     west-arm build \
        -p auto \
        -d "${BUILD_DIR}" \
        -s "$ROOT/zmk/app" \
        -b "$BOARD" \
        -- \
        -DZMK_CONFIG="$CONFIG" \
        -DSHIELD="$SHIELD" \
        -DBOARD_ROOT="$CONFIG"
    )

    # mkdir -p "$OUT"
    # if [[ -f "${BUILD_DIR}"/zephyr/zmk.uf2 ]]; then
    #     local OUT_UF2="$OUT/${SHIELD}-${BOARD}-zmk.uf2"
    #     if [[ -f "$OUT_UF2" ]]; then
    #             rm "$OUT_UF2"
    #     fi
    #     ln -s "${BUILD_DIR}"/zephyr/zmk.uf2 "$OUT_UF2"
    # fi
}

west_build_from_file() {
    local path="$1"
    local bn="$(basename "$path")"
    IFS=- read shield board the_rest <<< "$bn"
    west_build "$board" "$shield"
}

if [[ $# -eq 2 ]]; then
    west_build "$1" "$2"
elif [[ $# -eq 1 ]]; then
    west_build_from_file "$1"
else
    exit 1
fi


