#!/usr/bin/env bash

# Rofi Theme
theme="$HOME/.config/rofi/clipboard.rasi"
clear_opt="🗑 Clear History"

# Get selection from rofi
selected=$(echo -e "$clear_opt\n$(cliphist list)" | rofi -dmenu -theme "$theme")

case "$selected" in
    "$clear_opt")
        cliphist wipe
        notify-send "Clipboard" "History Cleared"
        ;;
    *)
        if [ -n "$selected" ]; then
            echo "$selected" | cliphist decode | wl-copy
            sleep 0.2
            wtype -M ctrl -k v -m ctrl
        fi
        ;;
esac
