# NikOS &nbsp; [![bluebuild build badge](https://github.com/nikokultalahti/nikos/actions/workflows/build.yml/badge.svg)](https://github.com/nikokultalahti/nikos/actions/workflows/build.yml)

NikOS is my personal desktop OS: [Fedora Silverblue](https://fedoraproject.org/atomic-desktops/silverblue/) 44, rebuilt every day with [BlueBuild](https://blue-build.org/) and published as a container image at `ghcr.io/nikokultalahti/nikos`.

It is an image-based system. The OS is built in CI, installed or updated as a whole, and rolled back by booting the previous deployment.

## How NikOS differs from Silverblue

**Removed from the image**
- GNOME Software, Help (Yelp), GNOME Tour, user docs, Parental Controls, remote desktop, file sharing (Rygel, user share), the GNOME Classic session, GNOME System Monitor and the Firefox RPM (Firefox is installed as a Flatpak instead).

**Added to the image**
- `chezmoi` and the Nextcloud desktop client.
- Visual Studio Code (official Microsoft build) with telemetry, feedback and automatic updates disabled (`files/system/etc/vscode/policy.json`); the Microsoft repo is enabled at build time only, so updates arrive with image rebuilds. `distrobox` is installed alongside it (`recipes/dev.yml`).
- udev rules for the ZSA Voyager keyboard, so Oryx and Keymapp can reach it (`files/system/usr/lib/udev/rules.d/50-zsa.rules`).
- [Homebrew](https://brew.sh/), updating itself and its packages daily, with its analytics turned off.
- JetBrainsMono Nerd Fonts
- Polkit Policy for Bitwarden biometric authentication (`files/system/usr/share/polkit-1/actions/com.bitwarden.Bitwarden.policy`)

**Codecs are not installed on the host, by design.** Every app comes from Flathub as a Flatpak and has all its dependencies, including codecs, baked in. The image ships no RPM Fusion repositories, no `ffmpeg` and no `mesa-va-drivers-freeworld`.

**Apps from Flathub**
- Fedora's Flatpak remote is not set up, so every Flatpak comes from Flathub. The image installs a default set on first boot; install anything else with Bazaar.
- **System-wide:** Bazaar (the app store), Firmware, Flatseal, Warehouse, Refine, Extension Manager, Ignition, Resources (system monitor), Archive Manager (FileRoller) and Firefox, plus the GNOME apps Silverblue's own installer would preinstall from Fedora's remote: Disk Usage Analyzer, Calculator, Calendar, Decibels, Contacts, Fonts, Text Editor, Image Viewer, Logs, Sushi (file previews), Papers and Showtime (video player).
- **Per user:** BudsLink (companion app for the Bluetooth Battery Meter GNOME extension), Emote, Gradia, Impression, Pika Backup, LibreOffice and Convey. These are installed in each user's home directory instead of system-wide.

**GNOME extensions**
- Installed at build time: Blur my Shell, AppIndicator and KStatusNotifierItem Support, Night Theme Switcher, Bluetooth Battery Meter, GSConnect and Caffeine.
- Removed: the extensions that ship with Silverblue's GNOME (Apps Menu, Background Logo, Launch New Instance, Places Status Indicator and Window List).

**Updates**
- Silverblue updates manually by default. NikOS runs `bootc upgrade` daily (`bootc-update.timer`); it downloads and stages the new image, and it takes effect on the next reboot.
- Flatpaks update daily too, with a system timer (`flatpak-system-update.timer`) and a per-user timer (`flatpak-user-update.timer`). GNOME Software, which normally does this, is removed.
- Homebrew updates itself and upgrades its packages daily.

**Smaller changes**
- `systemd-remount-fs.service` is masked. It fails on every boot on composefs roots, which is a known upstream issue.
- `/etc/os-release` says NikOS. `ID` is left as `fedora`.
- Images are signed with cosign.

The configuration is split by topic under `recipes/`: `gnome`, `packages`, `dev`, `homebrew`, `flatpaks`, `system` and `os-release`.

## Install

> [!WARNING]
> Image-based installs are a relatively new Fedora feature. Back up your data before installing, because the installer erases the disk you choose.

### Fresh install from an ISO

Generate an installer ISO from the published image (see the [BlueBuild guide](https://blue-build.org/how-to/generate-iso/)):

```bash
sudo bluebuild generate-iso --iso-name nikos.iso image ghcr.io/nikokultalahti/nikos:latest
```

ISOs are too large to host on GitHub, so this repository does not publish them. After the first boot, GNOME's setup creates your user, and the Flatpaks install in the background once you are online.

### From an existing Fedora Atomic installation

- First rebase to the unsigned image, to get the signing keys and policies installed:
  ```bash
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/nikokultalahti/nikos:latest
  ```
- Reboot, then rebase to the signed image:
  ```bash
  systemctl reboot
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/nikokultalahti/nikos:latest
  ```
- Reboot again to finish:
  ```bash
  systemctl reboot
  ```

The `latest` tag points to the newest build. Builds always use the Fedora version set in `recipes/recipe.yml`, so you won't be moved to the next major version by accident.

## Notes

- The ZSA web configurator (Oryx) needs a Chromium-based browser. None is preinstalled, so install one (for example Chromium) from Bazaar. Firefox has no WebHID support.

## Verification

Images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). To verify, download `cosign.pub` from this repository and run:

```bash
cosign verify --key cosign.pub ghcr.io/nikokultalahti/nikos
```
