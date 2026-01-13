# Dotfiles
[English](README.md) | **Tiếng Việt**

Đây là Linux configs cá nhân của mình.

Để cài đặt, dán các lệnh sau vào terminal:
```shell
git clone https://github.com/HighDelay/dotfiles/ && cd dotfiles && cp -rv .* ~/ ; rm -rf ~/.git
```
**Lưu ý:** Configs cũ cho BSPWM, Polybar và SXHKD đã được chuyển sang thư mục `dotfiles/bspwm_backup/`.

## Thiết lập Hyprland (Wayland)
Nếu bạn chuyển sang Wayland/Hyprland, các configs mới đã được thêm vào:
* **WM (Quản lý cửa sổ):** hyprland (config trong `.config/hypr/hyprland.conf`)
* **Thanh trạng thái:** waybar (config trong `.config/waybar/`)
* **Phím tắt:** Được map 1:1 từ sxhkd sang config hyprland.
* **Các phụ thuộc:** `hyprland`, `waybar`, `swww` (hình nền), `rofi-wayland` (hoặc rofi), `grim` & `slurp` (chụp màn hình), `wl-clipboard`, `swaynotificationcenter`.

```shell
yay -Sy hyprland hyprlock xdg-desktop-portal-hyprland waybar swww grim slurp wl-clipboard wtype cliphist rofi-wayland swaync htop cozette-otb ipa-fonts noto-fonts zsh fastfetch thunar thunar-volman thunar-archive-plugin polkit hyprpolkitagent dbus gnome-keyring tumbler ffmpegthumbnailer gvfs nwg-look cmus mpd mpc rmpc kitty lsp-plugins easyeffects pipewire pipewire-audio pipewire-alsa pipewire-pulse pipewire-jack
```

Để khởi động Hyprland, thường chỉ cần chạy `start-hyprland` từ TTY hoặc chọn nó trong display manager của bạn.
## GTK themes, icons, và cursors để phù hợp với configs
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

