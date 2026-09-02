# Aqloss — ARM64 AppImage builder (unofficial)

Builds and publishes an **aarch64 (ARM64) AppImage** of [Aqloss](https://github.com/nokarin-dev/Aqloss), a Flutter + Rust lossless music player that upstream currently ships only as x86_64 on Linux.

This is a third-party CI wrapper, not affiliated with the Aqloss author. It doesn't fork or modify the app — it checks out the upstream source at a given tag and compiles it as-is.  

Obviusly i don't made aqloss, all credits go to [nokarin](https://www.nokarin.xyz/)

## How it works

`.github/workflows/build-arm-appimage.yml`:

1. **Resolves a tag** — either the latest upstream GitHub release, or one you pass in manually.
2. **Skips if already built** — checks whether a release for that tag already exists in this repo.
3. **Builds natively on ARM64** — using GitHub's `ubuntu-24.04-arm` hosted runner, so both the Flutter UI and the Rust audio engine (via `flutter_rust_bridge`/cargokit) are compiled directly for aarch64. No cross-compilation toolchain is involved.
4. **Packages the AppImage** — `scripts/package-appimage-arm.sh` mirrors upstream's own `package-appimage.sh`, pointed at the `arm64` Flutter bundle and the `aarch64` build of `appimagetool`.
5. **Publishes a release** in this repo tagged `arm64-<upstream-tag>` (e.g. `arm64-v0.3.1`) with the `.AppImage` attached.

Runs on a schedule (checks every few hours) and can also be triggered manually from the Actions tab, optionally targeting a specific upstream tag.

## Using it

1. Push this repository to GitHub (public repos get free `ubuntu-24.04-arm` runner minutes; private repos need a paid ARM runner or a self-hosted arm64 runner — swap `runs-on` in the workflow if so).
2. Run the **Build ARM64 AppImage** workflow once manually (Actions tab → *Run workflow*), or wait for the schedule.
3. Grab the `.AppImage` from this repo's **Releases** page.
4. `chmod +x Aqloss-linux-arm64.AppImage && ./Aqloss-linux-arm64.AppImage`

## Caveats

- **Untested by upstream.** Upstream explicitly only tests Windows/Linux(x64)/Android; ARM64 Linux is outside that. If Aqloss's Rust dependencies (audio backends, codecs) have any platform quirks, they'd show up here first. Please file build issues in *this* repo, not upstream, unless you've confirmed it's an app bug.
- **No code signing / no GPG.** Like upstream's own AppImage, this one isn't signed. Verify the source (this repo's workflow file) if that matters to you.
- **GPLv3.** Aqloss is GPLv3-licensed; this repo only adds build automation and links back to the unmodified upstream source, per the license.
- Desktop (GTK-based) ARM devices only — this is **not** an Android build (upstream already ships `Aqloss-android-arm64.apk` for that).

## Repo layout

```
.github/workflows/build-arm-appimage.yml   # the CI pipeline described above
scripts/package-appimage-arm.sh            # AppImage packaging, adapted for aarch64
```
