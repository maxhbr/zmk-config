#!/usr/bin/env bash
set -euo pipefail

label=XIAO-SENSE
dev=/dev/disk/by-label/"$label"
firmware="$1"

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
