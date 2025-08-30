# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in this repository or in any of the KAS/Yocto configuration files (such as [`yml/beagleplay-ti-uefi.yml`](yml/beagleplay-ti-uefi.yml), [`yml/beagleplay-ti-sd.yml`](yml/beagleplay-ti-sd.yml), [`yml/mender-base.yml`](yml/mender-base.yml), or [`yml/mender-full.yml`](yml/mender-full.yml)), please report it by opening a GitHub issue or by contacting the maintainer directly.

- Issues can be reported at: https://github.com/jim-wyatt/beagleplay-kas-config/issues
- For sensitive disclosures, email the maintainer listed in the [README.md](README.md).

Please include as much detail as possible, including:
- A description of the vulnerability and its impact
- Steps to reproduce (if applicable)
- Affected configuration files or scripts

You can expect a response within 7 days. If the vulnerability is confirmed, we will coordinate a fix and notify users via the repository.

## Dependencies

This project relies on upstream Yocto layers and Python dependencies listed in [`requirements.txt`](requirements.txt). For vulnerabilities in those dependencies, please also report issues to the respective upstream projects.

## Responsible Disclosure

We ask that you give us an opportunity to address the issue before disclosing it publicly. We are committed to maintaining the security of this project and its users.