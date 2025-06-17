# Dotfiles
This is my personal linux configs

In order to install this, paste the following commands to terminal: 
```
git clone https://github.com/HighDelay/dotfiles/ && cd dotfiles && cp -rv .* ~/ ; rm -rf ~/.git
```
To set wallpaper, use feh: 
```
feh --bg-fill /path/to/your/wallpaper
```
**Make sure that you have installed all of the required dependencies**

## Dependencies

* **WM:** bspwm
* **Bar:** polybar
* **Shortcuts:** sxhkd (check .config/sxhkd/sxhkdrc for kb shortcuts, Win + enter to open the terminal)
* **Launcher - Powermenu:** rofi
* **Screenshot**: scrot (Win/Super+shift+S to capture on selection, PrintScr to capture the entire screen, Ctrl+PrintScr to capture active windows)
* **Compositor:** picom
* **Notification Daemon:** dunst
* **Terminal:** urxvt, urxvt-perls (for kb shortcuts)
* **Sysmon:** htop
* **Sysfetch:** fastfetch
* **Wallpaper:** feh
* **Fonts:** cozette-otb, ipa-fonts
* **Shell:** zsh (ohmyzsh, zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions, powerlevel10k)
* **Lockscreen:** betterlockscreen

```
yay -Sy bspwm polybar rofi scrot sxhkd picom dunst rxvt-unicode urxvt-perls htop feh cozette-otb ipa-fonts noto-fonts zsh betterlockscreen fastfetch thunar thunar-volman thunar-archive-plugin polkit polkit-gnome dbus gnome-keyring tumbler ffmpegthumbnailer gvfs lxappearance-gtk3 xorg-server xorg-xinit xorg-xsetroot xclip
```

## GTK themes, icons, and cursors to match the config
* **Icon:** [Papirus grey](https://www.pling.com/p/1166289/)
* **Theme:** [Graphite dark gtk](https://www.gnome-look.org/p/1598493)
* **Cursor:** [Future dark cursors](https://www.gnome-look.org/p/1457884)

### Screenshots
![1](/screenshots/1.png)
![2](/screenshots/2.png)
