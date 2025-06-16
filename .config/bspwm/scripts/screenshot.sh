#!/usr/bin/env bash

# A screenshot script using scrot, rofi, and xclip.
#
# Default behavior: Save & Copy
# Interactive mode: Pass "--interactive" as an argument to get the action menu.
#                   (e.g., screenshot.sh --interactive)

# --- CONFIGURATION ---
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
FILENAME_FORMAT="%Y-%m-%d-%T-scrot.png" # Man page: man strftime

# --- SCRIPT LOGIC ---

# Ensure the screenshot directory exists.
mkdir -p "$SCREENSHOT_DIR"

# --- Helper Functions ---
notify_user() {
    # Sends a notification.
    if command -v dunstify &>/dev/null; then
        dunstify -u low "$1" "$2"
    else
        notify-send "$1" "$2"
    fi
}

# --- Main Functions ---

select_capture_mode() {
    # Nerd Fonts icons:  Area,  Window, 🖥 Fullscreen
    echo -e " Area\n Window\n🖥 Fullscreen" | rofi -dmenu -i -p "Screenshot"
}

select_action() {
    echo -e "📥 Save\n📋 Copy\n💾 Save & Copy" | rofi -dmenu -i -p "Action"
}

take_screenshot() {
    local capture_mode="$1"
    local tmp_file="/tmp/screenshot_$(date +%s).png"
    local scrot_cmd=""

    case "$capture_mode" in
        " Area")
            scrot_cmd="scrot --select --freeze"
            ;;
        " Window")
            scrot_cmd="scrot --focused --border --delay 1"
            ;;
        "🖥 Fullscreen")
            scrot_cmd="scrot"
            ;;
        *)
            notify_user "Screenshot" "Invalid mode selected. Aborting."
            exit 1
            ;;
    esac

    if $scrot_cmd "$tmp_file"; then
        echo "$tmp_file"
    else
        notify_user "Screenshot" "Screenshot cancelled."
        exit 1
    fi
}

perform_action() {
    local action="$1"
    local tmp_filepath="$2"
    local final_filepath="$SCREENSHOT_DIR/$(date +"$FILENAME_FORMAT")"

    # Handle the chosen action
    case "$action" in
        "📥 Save")
            mv "$tmp_filepath" "$final_filepath"
            notify_user "Screenshot Saved" "$final_filepath"
            ;;
        "📋 Copy")
            xclip -selection clipboard -t image/png -i "$tmp_filepath"
            rm "$tmp_filepath"
            notify_user "Screenshot Copied" "Image copied to clipboard."
            ;;
        "💾 Save & Copy")
            cp "$tmp_filepath" "$final_filepath"
            xclip -selection clipboard -t image/png -i "$tmp_filepath"
            rm "$tmp_filepath"
            notify_user "Screenshot Saved & Copied" "$final_filepath"
            ;;
        *)
            rm "$tmp_filepath"
            notify_user "Screenshot" "Invalid action. Aborting."
            ;;
    esac
}

# --- SCRIPT EXECUTION ---

# 1. Ask user what to capture
capture_mode=$(select_capture_mode)
[ -z "$capture_mode" ] && exit 0 # Exit if user cancelled Rofi

# 2. Take the screenshot
tmp_filepath=$(take_screenshot "$capture_mode")
[ ! -f "$tmp_filepath" ] && exit 1 # Exit if screenshot failed

# 3. Decide on the action: interactive or default
if [[ "$1" == "--interactive" ]]; then
    # If launched with --interactive, show the action menu
    action=$(select_action)
    [ -z "$action" ] && rm "$tmp_filepath" && exit 0 # Exit if user cancelled
else
    # Otherwise, use the default action
    action="💾 Save & Copy"
fi

# 4. Perform the selected or default action
perform_action "$action" "$tmp_filepath"