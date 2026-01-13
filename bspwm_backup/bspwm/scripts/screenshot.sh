#!/usr/bin/env bash

# This script takes a screenshot using scrot and copies it to the clipboard.
# It can capture the full screen, a selected area, or the active window.
#
# Usage:
#   screenshot.sh full      # Captures the entire screen.
#   screenshot.sh select    # Allows you to select an area.
#   screenshot.sh active    # Captures the currently focused window.

# Directory where screenshots will be saved
SAVE_DIR=~/Pictures/Screenshots
mkdir -p "$SAVE_DIR" # Ensure the directory exists

# Filename with a timestamp
FILENAME="$SAVE_DIR/$(date +'%Y-%m-%d_%H-%M-%S_screenshot.png')"

# Scrot options
# --select: allows selecting a window or rectangle
# --focused: captures the currently focused window
# --freeze: freezes the screen when selecting to capture tooltips or menus
# --quiet: suppress scrot's command-line output
OPTIONS=""
NOTIFICATION_MESSAGE=""

# Determine capture mode from the first argument
case "$1" in
    full)
        # No extra options needed for fullscreen
        NOTIFICATION_MESSAGE="Fullscreen capture copied to clipboard."
        ;;
    select)
        OPTIONS="$OPTIONS --select --freeze"
        NOTIFICATION_MESSAGE="Selection capture copied to clipboard."
        ;;
    active)
        OPTIONS="$OPTIONS --focused"
        NOTIFICATION_MESSAGE="Active window capture copied to clipboard."
        ;;
    *)
        echo "Usage: $0 {full|select|active}"
        exit 1
        ;;
esac

# Take the screenshot.
# The 'if' statement checks if scrot was successful (e.g., not cancelled by Esc).
if scrot $OPTIONS "$FILENAME"; then
    # Copy the image to the clipboard
    xclip -selection clipboard -t image/png -i "$FILENAME"

    # Send a desktop notification
    notify-send "Screenshot Taken" "$NOTIFICATION_MESSAGE"
else
    # Notify if the action was cancelled
    notify-send "Screenshot" "Action cancelled."
fi
