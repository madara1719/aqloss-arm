#!/usr/bin/env bash
# ARM64 (aarch64) AppImage packager for Aqloss.
#
# Adapted from upstream's .github/scripts/package-appimage.sh
# (https://github.com/nokarin-dev/Aqloss), which only builds x86_64.
# This version targets the arm64 Flutter Linux bundle and uses the
# aarch64 build of appimagetool. Must be run on an aarch64 host (the
# resulting AppDir bundles the natively-built Rust/Flutter binaries and
# is not cross-compiled).
#
# Run from the root of the Aqloss checkout (the working tree that
# contains `assets/`, `linux/`, and `build/`).
set -euo pipefail

OUTPUT="${1:-Aqloss-linux-arm64.AppImage}"
BUNDLE="${BUNDLE:-build/linux/arm64/release/bundle}"

if [ ! -d "${BUNDLE}" ]; then
  echo "Flutter Linux bundle not found: ${BUNDLE}" >&2
  echo "Did 'flutter build linux --release' run on an aarch64 host?" >&2
  exit 1
fi

HOST_ARCH="$(uname -m)"
if [ "${HOST_ARCH}" != "aarch64" ] && [ "${HOST_ARCH}" != "arm64" ]; then
  echo "Warning: host arch is '${HOST_ARCH}', expected aarch64/arm64." >&2
  echo "The AppImage will only run correctly on the arch it was built on." >&2
fi

APPIMAGETOOL_VERSION="${APPIMAGETOOL_VERSION:-1.9.1}"
APPIMAGETOOL_URL="https://github.com/AppImage/appimagetool/releases/download/${APPIMAGETOOL_VERSION}/appimagetool-aarch64.AppImage"

if ! command -v wget >/dev/null 2>&1; then
  echo "wget is required to download appimagetool" >&2
  exit 1
fi

wget -q "${APPIMAGETOOL_URL}" -O /tmp/appimagetool.AppImage
chmod +x /tmp/appimagetool.AppImage
(
  cd /tmp
  # appimagetool AppImages need FUSE to run directly; extracting and
  # calling AppRun avoids depending on FUSE being available on the
  # GitHub Actions runner.
  ./appimagetool.AppImage --appimage-extract >/dev/null
)
APPIMAGETOOL="/tmp/squashfs-root/AppRun"
if [ ! -x "${APPIMAGETOOL}" ]; then
  echo "Failed to extract appimagetool from ${APPIMAGETOOL_URL}" >&2
  exit 1
fi

rm -rf AppDir
mkdir -p AppDir/app AppDir/usr/share/icons/hicolor/256x256/apps \
  AppDir/usr/share/mime/packages

cp -r "${BUNDLE}/." AppDir/app/

if [ -f assets/icons/icon_256.png ]; then
  cp assets/icons/icon_256.png \
    AppDir/usr/share/icons/hicolor/256x256/apps/xyz.nokarin.aqloss.png
  cp assets/icons/icon_256.png AppDir/xyz.nokarin.aqloss.png
else
  printf 'PNG' > AppDir/xyz.nokarin.aqloss.png
fi

cp linux/xyz.nokarin.aqloss.desktop AppDir/xyz.nokarin.aqloss.desktop
cp linux/xyz.nokarin.aqloss.xml AppDir/usr/share/mime/packages/xyz.nokarin.aqloss.xml

cat > AppDir/AppRun <<'EOF'
#!/bin/sh
APPDIR="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$APPDIR/app/lib:$LD_LIBRARY_PATH"
EXE_NAME=$(find "$APPDIR/app" -maxdepth 1 -type f ! -name "*.so" ! -name "*.desktop" | xargs -I{} basename {} | head -1)
[ -z "$EXE_NAME" ] && echo "Aqloss: executable not found" >&2 && exit 1
cd "$APPDIR/app"
exec "./$EXE_NAME" "$@"
EOF
chmod +x AppDir/AppRun

ARCH=aarch64 "${APPIMAGETOOL}" --no-appstream AppDir "${OUTPUT}"
chmod +x "${OUTPUT}"
echo "Built ${OUTPUT} ($(du -h "${OUTPUT}" | cut -f1))"
