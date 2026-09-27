# Dotfiles
**English** | [Tiếng Việt](README_vi.md)

This is my personal linux configs

On Arch Linux or an Arch-based distribution, run these commands as your normal user (not root):
```shell
git clone https://github.com/HighDelay/dotfiles/
cd dotfiles
bash install.sh --dry-run
bash install.sh
```

The installer uses `yay` or `paru` to install the dependencies and perform a full system upgrade. If neither helper is available, it installs `git` and `base-devel` with `sudo pacman`, then builds `yay` using its [documented installation procedure](https://github.com/Jguer/yay#installation). Package-manager and AUR prompts remain interactive; `sudo` must already be configured.

It copies the configs into `~/.config`, installs the bundled fonts, wallpaper and EasyEffects output preset, makes the Rofi scripts executable, and creates `~/Pictures` for screenshots. The checkout can live anywhere. These configs require the default `~/.config` and `~/.local/share` locations.

Changed files are backed up under `~/.local/state/dotfiles/backups/<unique-dir>/files/`, with an installation record for uninstalling. Identical files are left alone. The installer excludes the old BSPWM configs, X11 startup files, system files in `etc/`, and personal music database/playback state.

```shell
bash install.sh --configs-only   # Copy files without installing packages
bash install.sh --packages-only  # Install packages without copying files
bash install.sh --help
```

Before starting Hyprland, review the NVIDIA environment settings in `.config/hypr/hyprland.conf` and `.config/hypr/hyprland.lua`; comment them out if you do not use NVIDIA. Install the themes below separately. Changing your login shell, configuring GPU drivers, enabling services and TTY autostart remain manual steps.

## Uninstall

From the cloned repository, run:

```shell
bash uninstall.sh --dry-run
bash uninstall.sh
```

This undoes the most recent recorded installation: it removes files installed by that run and restores their previous versions. Files edited afterward are preserved and reported. To finish uninstalling those files, save your edits elsewhere, remove the reported files, then rerun the uninstaller. Original backups are retained for manual recovery.

If you installed multiple times, run the uninstaller again to undo the next older record. You can select a specific record with `bash uninstall.sh --backup /path/printed/by/installer`; undo records newest first. Packages and directories are kept, since they may be used by other applications. The uninstaller can only undo installations made by this script. Log out after uninstalling to apply the changes.

**Note:** Old BSPWM, Polybar, and SXHKD configs have been moved to `dotfiles/bspwm_backup/`.

## Hyprland Setup (Wayland)
If you are moving to Wayland/Hyprland, new configurations have been added:
* **WM:** hyprland (config in `.config/hypr/hyprland.conf`)
* **Bar:** waybar (config in `.config/waybar/`)
* **Shortcuts:** Mapped 1:1 from sxhkd to local hyprland config.
* **Dependencies:** `hyprland`, `waybar`, `awww` (wallpaper), `rofi-wayland` (or rofi), `grim` & `slurp` (screenshots), `wl-clipboard`, `swaynotificationcenter`.

The full dependency list is maintained in [`packages.txt`](packages.txt), which the installer reads directly. It includes the original README packages plus `libnotify`, `pavucontrol`, `wireplumber`, `alsa-utils`, `qt5ct`, and `fontconfig` for commands/settings used by the configs and installer. Edit that file to customize your installation.

To start Hyprland, usually just run `start-hyprland` from TTY or select it in your display manager.

Autostart Hyprland when logging in from TTY:
```shell
## .zprofile file
if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
  start-hyprland
fi
```

## GTK themes, icons, and cursors to match the config
* **Icon:** [Papirus Red](https://www.pling.com/p/1166289/)
* **Theme:** [Graphite Dark Gtk](https://www.gnome-look.org/p/1598493)
* **Cursor:** [Future Dark Cursors](https://www.gnome-look.org/p/1457884)

### Screenshots
![1](/screenshots/1.png)
![2](/screenshots/2.png)
![3](/screenshots/3.png)
![4](/screenshots/4.png)
![5](/screenshots/5.png)
![6](/screenshots/6.png)
