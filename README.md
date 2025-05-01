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
* **Launcher - Powermenu:** rofi
* **Screenshot**: scrot (Win + Print)
* **Compositor:** picom-pijulius-next-git
* **Notification Daemon:** dunst
* **Terminal:** urxvt, urxvt-perls (for kb shortcuts)
* **Sysmon:** htop
* **Sysfetch:** fastfetch
* **Wallpaper:** feh
* **Fonts:** cozette-otb, ipa-fonts
* **Shell:** zsh (ohmyzsh, zsh-autosuggestions, zsh-syntax-highlighting, zsh-completions, powerlevel10k)
* **Lockscreen:** betterlockscreen

## GTK themes, icons, and cursors to match the config
* **Icon:** [Papirus grey](https://www.pling.com/p/1166289/)
* **Theme:** [Graphite dark gtk](https://www.gnome-look.org/p/1598493)
* **Cursor:** [Future dark cursors](https://www.gnome-look.org/p/1457884)

```
yay -Sy bspwm polybar rofi scrot sxhkd picom-pijulius-next-git dunst rxvt-unicode urxvt-perls htop feh cozette-otb ipa-fonts noto-fonts zsh betterlockscreen fastfetch
```
### Screenshots
![1](/screenshots/1.png)
![2](/screenshots/2.png)
