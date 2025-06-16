#!/usr/bin/env bash

# A bspwm-friendly screenshot script using scrot, rofi, and xclip.

# --- CONFIGURATION ---
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
FILENAME_FORMAT="%Y-%m-%d-%T-scrot.png" # Man page: man strftime

# --- SCRIPT LOGIC ---

# Ensure the screenshot directory exists.
mkdir -p "$SCREENSHOT_DIR"

# --- Helper Functions ---
notify_user() {
    # Sends a notification. Uses dunstify if available, otherwise notify-send.
    # Usage: notify_user "Title" "Message"
    if command -v dunstify &>/dev/null; then
        dunstify -u low "$1" "$2"
    else
        notify-send "$1" "$2"
    fi
}

# --- Main Functions ---

# Use Rofi to select the capture mode.
select_capture_mode() {
    # The -i makes matching case-insensitive.
    # The -p flag sets the prompt text.
    # Nerd Fonts icons are used for flair:  Area,  Window, 🖥 Fullscreen
    echo -e " Area\n Window\n🖥 Fullscreen" | rofi -dmenu -i -p "Screenshot"
}

# Use Rofi to select the action after capturing.
select_action() {
    echo -e "📥 Save\n📋 Copy\n💾 Save & Copy" | rofi -dmenu -i -p "Action"
}

# Take the screenshot and save it to a temporary file.
take_screenshot() {
    local capture_mode="$1"
    local tmp_file="/tmp/screenshot_$(date +%s).png"
    local scrot_cmd=""

    case "$capture_mode" in
        " Area")
            # -s for select, -f to use the window name for the file (we override),
            # -b to include the window border.
            scrot_cmd="scrot --select --freeze"
            ;;
        " Window")
            # -u for focused window, -b for border
            scrot_cmd="scrot --focused --border --delay 1" # Delay helps with tooltips disappearing
            ;;
        "🖥 Fullscreen")
            scrot_cmd="scrot"
            ;;
        *)
            notify_user "Screenshot" "Invalid mode selected. Aborting."
            exit 1
            ;;
    esac

    # Execute scrot and check if the user cancelled (e.g., by pressing Esc).
    if $scrot_cmd "$tmp_file"; then
        echo "$tmp_file"
    else
        # Scrot returns a non-zero exit code if cancelled.
        notify_user "Screenshot" "Screenshot cancelled."
        exit 1
    fi
}

# --- SCRIPT EXECUTION ---

# 1. Ask user what to capture
capture_mode=$(select_capture_mode)
[ -z "$capture_mode" ] && exit 0 # Exit if user cancelled Rofi

# 2. Take the screenshot
tmp_filepath=$(take_screenshot "$capture_mode")
[ ! -f "$tmp_filepath" ] && exit 1 # Exit if screenshot failed for some reason

# 3. Ask user what to do with the screenshot
action=$(select_action)
[ -z "$action" ] && rm "$tmp_filepath" && exit 0 # Exit if user cancelled, clean up temp file

# 4. Perform the selected action
final_filepath="$SCREENSHOT_DIR/$(date +"$FILENAME_FORMAT")"

case "$action" in
    "📥 Save")
        mv "$tmp_filepath" "$final_filepath"
        notify_user "Screenshot Saved" "$final_filepath"
        ;;
    "📋 Copy")
        # Copy image data to clipboard
        xclip -selection clipboard -t image/png -i "$tmp_filepath"
        rm "$tmp_filepath" # Clean up temp file
        notify_user "Screenshot Copied" "Image copied to clipboard."
        ;;
    "💾 Save & Copy")
        # Copy file to final destination AND copy image data to clipboard
        cp "$tmp_filepath" "$final_filepath"
        xclip -selection clipboard -t image/png -i "$tmp_filepath"
        rm "$tmp_filepath"
        notify_user "Screenshot Saved & Copied" "$final_filepath"
        ;;
    *)
        rm "$tmp_filepath" # Clean up on invalid action
        notify_user "Screenshot" "Invalid action. Aborting."
        ;;
esac