[![Build SD Image](https://github.com/jim-wyatt/beagleplay-kas-config/actions/workflows/build_sd.yml/badge.svg)](https://github.com/jim-wyatt/beagleplay-kas-config/actions/workflows/build_sd.yml)[![Build UEFI Image](https://github.com/jim-wyatt/beagleplay-kas-config/actions/workflows/build_uefi.yml/badge.svg)](https://github.com/jim-wyatt/beagleplay-kas-config/actions/workflows/build_uefi.yml)[![Build Mender Image](https://github.com/jim-wyatt/beagleplay-kas-config/actions/workflows/build_mender.yml/badge.svg)](https://github.com/jim-wyatt/beagleplay-kas-config/actions/workflows/build_mender.yml)

[![Automatic Dependency Submission](https://github.com/jim-wyatt/beagleplay-kas-config/actions/workflows/dependency-graph/auto-submission/badge.svg)](https://github.com/jim-wyatt/beagleplay-kas-config/actions/workflows/dependency-graph/auto-submission)[![CodeQL](https://github.com/jim-wyatt/beagleplay-kas-config/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/jim-wyatt/beagleplay-kas-config/actions/workflows/github-code-scanning/codeql)[![Dependabot Updates](https://github.com/jim-wyatt/beagleplay-kas-config/actions/workflows/dependabot/dependabot-updates/badge.svg)](https://github.com/jim-wyatt/beagleplay-kas-config/actions/workflows/dependabot/dependabot-updates)

# BeaglePlay KAS Yocto Build Configuration

This repository provides configuration files and scripts to build custom Linux images for the BeaglePlay board using the Yocto Project and KAS. It integrates support for Mender OTA updates, TI-specific layers, and ARM architecture, enabling robust and reproducible builds for embedded development.

## Table of Contents
- [Overview](#overview)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration Files](#configuration-files)
- [Customizing the Build](#customizing-the-build)
- [References](#references)

## Overview
This project leverages [KAS](https://kas.readthedocs.io/) to simplify and automate Yocto builds for the BeaglePlay board. It provides ready-to-use YAML configuration files for different build targets, including UEFI and SD card images, and integrates Mender for over-the-air updates.

## Repository Structure
- `kas-yocto-beagleplay-ti-build.sh` – Helper script to set up the build environment and run a KAS build.
- `requirements.txt` – Python dependencies for KAS and related tooling.
- `beagleplay-ti-uefi.yml` – KAS config for building a UEFI image with Mender support.
- `beagleplay-ti-sd.yml` – KAS config for building an SD card image.
- `beagleplay-ti-mender.yml` – KAS config for building a Mender release.
- `mender-base.yml`, `mender-full.yml` – Base and full Mender integration layers.
- `arm.yml` – ARM architecture meta-layer configuration.
- `ti.yml` – Texas Instruments meta-layer configuration.

## Prerequisites
- Ubuntu 24.04 (recommended)
- Python 3.8+
- [KAS](https://kas.readthedocs.io/en/latest/) (installed via `requirements.txt`)
- Git
- Internet access to fetch Yocto layers
- A sizeable build machine, test machine has 32 cores / 32GB memory

## Quick Start

1. **Install Yocto dependencies:**
   ```bash
   sudo apt-get install build-essential chrpath cpio debianutils diffstat file gawk gcc git iputils-ping libacl1 liblz4-tool locales python-is-python3 python3 python3-git python3-jinja2 python3-pexpect python3-pip python3-subunit python3-venv socat texinfo unzip wget xz-utils zstd
   ```

2. **Clone the repository:**
   ```bash
   git clone https://github.com/jim-wyatt/beagleplay-kas-config.git
   cd beagleplay-kas-config
   ```

## Bootstrapping BeaglePlay with an SD Card (beagleplay-ti-sd.yml)

1. **Build the SD card image:**
   ```bash
   ./kas-yocto-beagleplay-ti-build.sh sd
   ```
   The resulting SD card image (e.g., `core-image-full-cmdline-beagleplay-ti.sdimg`) will be found in `build/deploy-ti/images/beagleplay-ti/`.

2. **Write the image to an SD card:**
   Insert an SD card (at least 8GB recommended) and identify its device node (e.g., `/dev/sdX`).
   ```bash
   sudo dd if=build/deploy-ti/images/beagleplay-ti/core-image-full-cmdline-beagleplay-ti.sdimg of=/dev/sdX bs=4M status=progress conv=fsync
   sync
   ```
   **Warning:** Double-check the device node to avoid overwriting your system disk.

3. **Boot the BeaglePlay from SD card:**
   - Insert the SD card into the BeaglePlay.
   - Hold the BOOT button (if required) and power on the board.
   - The board will boot from the SD card, allowing you to access and configure the system.

## Build, Copy, and Flash the UEFI Image (beagleplay-ti-uefi.yml)

1. **Build the UEFI image: (on build machine)**
   ```bash
   ./kas-yocto-beagleplay-ti-build.sh uefi
   ```
   The UEFI image (e.g., `core-image-full-cmdline-beagleplay-ti.uefiimg`) will be in `build/deploy-ti/images/beagleplay-ti/`.

2. **Copy the image to the BeaglePlay:**
   - Use `scp` or a USB drive to transfer the image to the running BeaglePlay (booted from SD card).
   - Example using `scp`:
     ```bash
     scp build/deploy-ti/images/beagleplay-ti/core-image-full-cmdline-beagleplay-ti.uefiimg <user>@<beagleplay-ip>:/tmp/
     ```

3. **Flash the image to eMMC:**
   - On the BeaglePlay, use `dd` to write the image to the internal eMMC. For Mender images, you may use the Mender client or a custom script.
   - Example (for raw image):
     ```bash
     sudo dd if=/tmp/core-image-full-cmdline-beagleplay-ti.uefiimg of=/dev/mmcblk0 bs=4M status=progress conv=fsync
     sync
     ```
   - Power off, remove the SD card, and reboot. The board should now boot from the internal eMMC with the UEFI image.


**Note:** Adjust image filenames and device nodes as needed for your setup. Always back up important data before flashing.

## Deploying Mender Images (beagleplay-ti-mender.yml)

Once you have bootstrapped your BeaglePlay by booting from an SD card and written a UEFI image to the eMMC, your device is ready to receive and deploy Mender images for over-the-air updates.

1. **Build a Mender image:**
   On your build machine, run:
   ```bash
   ./kas-yocto-beagleplay-ti-build.sh mender
   ```
   The resulting Mender artifact (e.g., `core-image-full-cmdline-beagleplay-ti.mender`) will be found in `build/deploy-ti/images/beagleplay-ti/`.

2. **Upload the Mender artifact:**
   - Log in to your Mender server (e.g., https://hosted.mender.io/).
   - Go to the Releases section and upload the `.mender` file as a new release.

3. **Deploy the update:**
   - Approve the deployment to your BeaglePlay device(s) from the Mender UI.
   - The device will download and install the update on its next check-in.

**Tip:** Make sure your device is connected to the network and enrolled with your Mender server. The Mender client on the device will handle the update process automatically.

## Configuration Files
- **beagleplay-ti-mender.yml**: Builds a Mender Release for BeaglePlay. The generated image can be uploaded to a Mender server for deployment. Includes:
  - `mender-full.yml`, `arm.yml`, `ti.yml`
  - Custom `local_conf_header` for Mender settings
- **beagleplay-ti-uefi.yml**: Builds a UEFI image for BeaglePlay with Mender OTA support. The generated image is written to the internal eMMC on the Beagleplay. Includes:
  - `mender-full.yml`, `arm.yml`, `ti.yml`
  - Custom `local_conf_header` for image settings
- **beagleplay-ti-sd.yml**: Builds an SD card image. The generated images can be written to an SD card and it suitable for bootstrapping a system. Includes:
  - `mender-full.yml`, `arm.yml`, `ti.yml`
  - Custom `local_conf_header` for SD card specifics
- **mender-base.yml**: Base Yocto and Mender layer definitions
- **mender-full.yml**: Extends `mender-base.yml` with full Mender integration
- **arm.yml**: Adds meta-arm layers for ARM architecture
- **ti.yml**: Adds meta-ti layers for TI SoCs

## Customizing the Build
- **Change Target Image:** Edit the `target` field in the YAML config (e.g., `core-image-full-cmdline`, `core-image-minimal`).
- **Add/Remove Layers:** Modify the `repos` and `layers` sections in the YAML files.
- **Mender Settings:** Update the `local_conf_header` in the YAML files for custom Mender server URLs, tokens, or storage devices.
- **Additional Packages:** Use `EXTRA_IMAGE_FEATURES` and `CORE_IMAGE_EXTRA_INSTALL` in the YAML to add packages.

## References
- [Yocto Project Documentation](https://docs.yoctoproject.org/)
- [KAS Documentation](https://kas.readthedocs.io/)
- [Mender Documentation](https://docs.mender.io/)
- [BeaglePlay Board](https://beagleboard.org/play)

---

*Maintained by Jim Wyatt. Contributions welcome!*
