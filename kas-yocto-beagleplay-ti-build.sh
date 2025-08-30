#!/bin/bash

# To build on Ubuntu 24.04
sudo apparmor_parser -R /etc/apparmor.d/unprivileged_userns

# Install python requirements
python -m venv .
. ./bin/activate
pip install -r requirements.txt

# Check if the script is running in GitHub Actions
if [ "$GITHUB_ACTIONS" == "true" ]; then
    # Swap Mender token from argument
    sed -i "s/MENDER_TENANT_TOKEN_SLUG/$1/g" yml/beagleplay-ti-uefi.yml
fi

# Generate a UUID for the Mender artifact name
sed -i "s/UUID_SLUG/$(uuidgen)/g" yml/beagleplay-ti-uefi.yml

# Build
kas build yml/beagleplay-ti-uefi.yml
