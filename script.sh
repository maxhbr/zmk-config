#!/usr/bin/env bash
set -euo pipefail

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
ROOT="$SCRIPTPATH"
CONFIG="$ROOT/config"
FIRMWARE="$ROOT/firmware"

help() {
    cat <<EOF
usage:
  $0 build \$BOARD \$SHIELD
  $0 build \$FILE
  $0 download
  $0 flash [--download|--build] \$FILE
EOF
}

wait_for_github_success() {
    gh run list --limit 1
    local conclusion="$(gh run list --limit 1 --json conclusion --jq '.[].conclusion')"
    echo "last action run: ${conclusion}"
    if [[ "$conclusion" == "" ]]; then
        sleep 10
        wait_for_github_success       
    elif [[ "$conclusion" != "success" ]]; then
        exit 1
    fi
    echo
}

github_download_firmware() {
    wait_for_github_success

    local date_dir="$FIRMWARE/$(date "+%F_%H-%M-%S")"
    mkdir -p "$date_dir"
    cd "$date_dir"
    gh run download --pattern firmware

    cd "$FIRMWARE"
    find "$(realpath --relative-to="$FIRMWARE" "$date_dir")" -type f |
        while read -r output; do
            local bn="$(basename "$output")"
            echo "get $bn"
            if [[ -f "$bn" ]]; then
                rm "$bn"
            fi
            ln -s "$output" "$bn"
        done

}

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

flash_firmware() {
    local label=XIAO-SENSE
    local dev=/dev/disk/by-label/"$label"
    local firmware="$1"
    if [[ -d "$firmware" ]]; then
        if [[ -f "$firmware/zephyr/zmk.uf2" ]]; then
            firmware="$firmware/zephyr/zmk.uf2"
        fi
    fi

    echo "waiting for $dev"
    while sleep 1; do
        if [[ -e "$dev" ]]; then
            sleep 1
            (
                set -x
                udisksctl mount -b "$dev"
                local mnt="$(findmnt -nr -o target -S "$dev")"
                cp "$firmware" "$mnt"
            )
            break
        fi
    done

}


if [[ $# -eq 0 ]]; then
    help
    exit 1
elif [[ "$1" == "init" ]]; then
    cd "$ROOT"
    west init -l ./config
    west update
    west zephyr-export
elif [[ "$1" == "update" ]]; then
    west update
elif [[ "$1" == "build" ]]; then
    shift
    if [[ $# -eq 2 ]]; then
        west_build "$1" "$2"
    elif [[ $# -eq 1 ]]; then
        west_build_from_file "$1"
    else
        exit 1
    fi
elif [[ "$1" == "download" ]]; then
    shift
    github_download_firmware
elif [[ "$1" == "flash" ]]; then
    shift
    if [[ "$1" == "--download" ]]; then
        shift
        github_download_firmware
    elif [[ "$1" == "--build" ]]; then
        shift
        west_build_from_file "$1"
    fi
    flash_firmware "$1"
else
    help
    exit 1
fi
