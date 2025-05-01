#!/bin/bash

# Configuration
output_dir="$HOME/Pictures/Screenshots"
mkdir -p "$output_dir"
filename="$output_dir/screenshot_$(date +%Y%m%d_%H%M%S).png"
sound_path="/usr/share/sounds/freedesktop/stereo/camera-shutter.oga"

# Dependency Check
required_cmds=(grim slurp notify-send mktemp)
for cmd in "${required_cmds[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        notify-send "❌ Screenshot Error" "Missing command: $cmd"
        exit 1
    fi
done

# Environment Check
if [ -z "$WAYLAND_DISPLAY" ]; then
    notify-send "❌ Screenshot Error" "Not in a Wayland session."
    exit 1
fi

# Screenshot Function
take_screenshot() {
    local mode="$1"
    local temp_file
    temp_file=$(mktemp) || {
        notify-send "❌ Screenshot Error" "Failed to create temp file."
        exit 1
    }

    case "$mode" in
        "area")
            grim -g "$(slurp)" "$temp_file"
            ;;
        "full")
            grim "$temp_file"
            ;;
        *)
            notify-send "❌ Screenshot Error" "Invalid mode: $mode"
            exit 1
            ;;
    esac

    # If screenshot was taken
    if [ -s "$temp_file" ]; then
        mv "$temp_file" "$filename"

        #  Sound feedback
        if [ -x "$(command -v paplay)" ] && [ -f "$sound_path" ]; then
            paplay "$sound_path" &> /dev/null
        fi

        notify-send -i "$filename" "📸 Screenshot taken" "Saved as $filename"
    else
        rm -f "$temp_file"
        notify-send "❌ Screenshot cancelled"
    fi
}

# Prevent multiple instances.
(
    flock -n 9 || {
        notify-send "⚠️ Screenshot already in progress"
        exit 1
    }

    take_screenshot "$1"

) 9>/tmp/screenshot.lock
