This repository contains no Aqloss source code or assets. It only
contains build automation (a GitHub Actions workflow and a shell
script) that checks out the unmodified upstream source of Aqloss at
build time and compiles it for aarch64.

Aqloss itself is Copyright © 2025-2026 nokarin-dev, licensed under the
GNU General Public License v3.0. See:
https://github.com/nokarin-dev/Aqloss/blob/main/LICENSE

The build/packaging scripts in this repo are adapted from Aqloss's own
`.github/scripts/package-appimage.sh` and `.github/actions/setup-aqloss`,
also under the upstream project's license terms.
