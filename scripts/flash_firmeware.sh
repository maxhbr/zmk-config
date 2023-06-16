#!/usr/bin/env bash
set -euo pipefail

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"

if [[ "$1" == "--download" ]]; then
    shift
    "$SCRIPTPATH/download_firmware.sh"
elif [[ "$1" == "--build" ]]; then
    shift
    "$SCRIPTPATH/west-build.sh" "$1"
fi

label=XIAO-SENSE
dev=/dev/disk/by-label/"$label"
firmware="$1"
if [[ -d "$firmware" ]]; then
    if [[ -f "$firmware/zephyr/zmk.uf2" ]]; then
        firmware="$firmware/zephyr/zmk.uf2"
    fi
fi

echo "waiting for $dev"
while sleep 1; do
    if [[ -e "$dev" ]]; then
        set -x
        sleep 1
        udisksctl mount -b "$dev"
        mnt="$(findmnt -nr -o target -S "$dev")"
        cp "$firmware" "$mnt"
        break
    fi
done
