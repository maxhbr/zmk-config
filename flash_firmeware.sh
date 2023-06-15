#!/usr/bin/env bash
set -euo pipefail

if [[ "$1" == "--download" ]]; then
    shift
    ./download_firmware.sh
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
