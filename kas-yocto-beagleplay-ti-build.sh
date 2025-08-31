#!/bin/bash

# To build on Ubuntu 24.04
sudo apparmor_parser -R /etc/apparmor.d/unprivileged_userns

# Install python requirements
python -m venv .
source ./bin/activate
pip install -r requirements.txt

if [ "$1" == "sd"]; then
    kas build yml/beagleplay-ti-sd.yml
fi

if [ "$1" == "uefi"]; then
    kas build yml/beagleplay-ti-uefi.yml
fi

if ["$1" == "mender"]; then
    # Generate a UUID for the Mender artifact name
    sed -i "s/UUID_SLUG/$(uuidgen)/g" yml/beagleplay-ti-mender.yml
    # Swap Mender token from argument
    sed -i "s/MENDER_TENANT_TOKEN_SLUG/$2/g" yml/beagleplay-ti-mender.yml
    # Build with Mender
    kas build yml/beagleplay-ti-mender.yml
fi
