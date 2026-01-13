# Dotfiles
**English** | [Tiếng Việt](README_vi.md)

This is my personal linux configs

In order to install this, paste the following commands to terminal: 
```shell
git clone https://github.com/HighDelay/dotfiles/ && cd dotfiles && cp -rv .* ~/ ; rm -rf ~/.git
```
**Note:** Old BSPWM, Polybar, and SXHKD configs have been moved to `dotfiles/bspwm_backup/`.

## Hyprland Setup (Wayland)
If you are moving to Wayland/Hyprland, new configurations have been added:
* **WM:** hyprland (config in `.config/hypr/hyprland.conf`)
* **Bar:** waybar (config in `.config/waybar/`)
* **Shortcuts:** Mapped 1:1 from sxhkd to local hyprland config.
* **Dependencies:** `hyprland`, `waybar`, `swww` (wallpaper), `rofi-wayland` (or rofi), `grim` & `slurp` (screenshots), `wl-clipboard`, `swaynotificationcenter`.

```shell
yay -Sy hyprland hyprlock xdg-desktop-portal-hyprland waybar swww grim slurp wl-clipboard wtype cliphist rofi-wayland swaync htop cozette-otb ipa-fonts noto-fonts zsh fastfetch thunar thunar-volman thunar-archive-plugin polkit hyprpolkitagent dbus gnome-keyring tumbler ffmpegthumbnailer gvfs nwg-look cmus mpd mpc rmpc kitty lsp-plugins easyeffects pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack
```

To start Hyprland, usually just run `start-hyprland` from TTY or select it in your display manager.

## GTK themes, icons, and cursors to match the config
* **Icon:** [Papirus Cyan](https://www.pling.com/p/1166289/)
* **Theme:** [Graphite Dark Gtk](https://www.gnome-look.org/p/1598493)
* **Cursor:** [Future Dark Cursors](https://www.gnome-look.org/p/1457884)

### Screenshots
![1](/screenshots/1.png)
![2](/screenshots/2.png)
![3](/screenshots/3.png)
![4](/screenshots/4.png)
![5](/screenshots/5.png)
![6](/screenshots/6.png)
