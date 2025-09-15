#!/bin/bash
set -euo pipefail

usage() {
    echo "Usage: $0 <sd|uefi|mender> [MENDER_TENANT_TOKEN]"
    echo "  sd      : Build SD card image"
    echo "  uefi    : Build UEFI image (requires MENDER_TENANT_TOKEN)"
    echo "  mender  : Build Mender artifact (requires MENDER_TENANT_TOKEN)"
    exit 1
}

if [[ $# -lt 1 ]]; then
    usage
fi

# Remove AppArmor restriction (Ubuntu 24.04) 
# see: https://lists.yoctoproject.org/g/yocto/topic/workaround_for_uid_map_error/106192359
if command -v apparmor_parser &>/dev/null && [[ -f /etc/apparmor.d/unprivileged_userns ]]; then
    echo 0 > /proc/sys/kernel/apparmor_restrict_unprivileged_userns
fi

# Setup Python virtual environment if not already present
VENV_DIR="virtual_env"
if [[ ! -d "$VENV_DIR" ]]; then
    python3 -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"
pip install --upgrade pip
pip install -r requirements.txt

MODE="$1"
TOKEN="${2:-}" # Optional second argument

case "$MODE" in
    sd)
        kas build yml/beagleplay-ti-sd.yml
        ;;
    uefi)
        if [[ -z "$TOKEN" ]]; then
            echo "Error: MENDER_TENANT_TOKEN required for uefi build."
            usage
        fi
        sed -i "s/MENDER_TENANT_TOKEN_SLUG/$TOKEN/g" yml/beagleplay-ti-mender.yml
        kas build yml/beagleplay-ti-uefi.yml
        ;;
    mender)
        if [[ -z "$TOKEN" ]]; then
            echo "Error: MENDER_TENANT_TOKEN required for mender build."
            usage
        fi
        UUID_VAL="$(uuidgen)"
        sed -i "s/UUID_SLUG/$UUID_VAL/g" yml/beagleplay-ti-mender.yml
        sed -i "s/MENDER_TENANT_TOKEN_SLUG/$TOKEN/g" yml/beagleplay-ti-mender.yml
        kas build yml/beagleplay-ti-mender.yml
        ;;
    *)
        usage
        ;;
esac
