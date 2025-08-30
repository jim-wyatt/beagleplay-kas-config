[![CI](https://github.com/jim-wyatt/beagleplay-kas-config/actions/workflows/build.yml/badge.svg)](https://github.com/jim-wyatt/beagleplay-kas-config/actions/workflows/build.yml)

# BeaglePlay KAS Yocto Build Configuration

This repository provides configuration files and scripts to build custom Linux images for the BeaglePlay board using the Yocto Project and KAS. It integrates support for Mender OTA updates, TI-specific layers, and ARM architecture, enabling robust and reproducible builds for embedded development.

# tldr;

Fork this repo. Create a Github Actions secret named "MENDER_TENANT_TOKEN" with your Mender Organization token from [here](https://hosted.mender.io/ui/settings/organization). Create a "self-hosted" Github Actions Runner per the [docs](https://docs.github.com/en/actions/concepts/runners/self-hosted-runners). Run "CI" Github Action. Flash resulting "uefiimg" artifact to your Beagleplay eMMC or upload the "mender" file as a release on the Mender web application. 

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

### 1. Install Yocto dependencies
```bash
sudo apt-get install build-essential chrpath cpio debianutils diffstat file gawk gcc git iputils-ping libacl1 liblz4-tool locales python-is-python3 python3 python3-git python3-jinja2 python3-pexpect python3-pip python3-subunit python3-venv socat texinfo unzip wget xz-utils zstd
```

### 2. Clone the repository
```bash
git clone https://github.com/jim-wyatt/beagleplay-kas-config.git
cd beagleplay-kas-config
```

---

## Bootstrapping BeaglePlay with an SD Card (beagleplay-ti-sd.yml)

1. **Build the SD card image:**
   ```bash
   kas build beagleplay-ti-sd.yml
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

---

## Build, Copy, and Flash the UEFI Image (beagleplay-ti-uefi.yml)

1. **Build the UEFI image: (on build machine)**
   ```bash
   kas build beagleplay-ti-uefi.yml
   ```
   The UEFI image (e.g., `core-image-full-cmdline-beagleplay-ti.uefiimg`) will be in `build/deploy-ti/images/beagleplay-ti/`.

2. **Copy the image to the BeaglePlay:**
   - Use `scp` or a USB drive to transfer the image to the running BeaglePlay (booted from SD card).
   - Example using `scp`:
     ```bash
     scp build/deploy-ti/images/beagleplay-ti/core-image-full-cmdline-beagleplay-ti.uefiimg <user>@<beagleplay-ip>:/tmp/
     ```

3. **Flash the image to eMMC:**
   - On the BeaglePlay, use the appropriate flashing tool (e.g., `mender`, `dd`, or a provided script) to write the image to the internal eMMC. For Mender images, you may use the Mender client or a custom script.
   - Example (for raw image):
     ```bash
     sudo dd if=/tmp/core-image-full-cmdline-beagleplay-ti.uefiimg of=/dev/mmcblk0 bs=4M status=progress conv=fsync
     sync
     ```
   - Power off, remove the SD card, and reboot. The board should now boot from the internal eMMC with the UEFI image.

**Note:** Adjust image filenames and device nodes as needed for your setup. Always back up important data before flashing.

## Configuration Files
- **beagleplay-ti-uefi.yml**: Builds a UEFI image for BeaglePlay with Mender OTA support. The generated image is written to the internal eMMC on the Beagleplay. Includes:
  - `mender-full.yml`, `arm.yml`, `ti.yml`
  - Custom `local_conf_header` for Mender and image settings
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
