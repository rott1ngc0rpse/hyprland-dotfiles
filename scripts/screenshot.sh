#!/bin/bash

output_dir="$HOME/Pictures/Screenshots"
mkdir -p "$output_dir"
filename="$output_dir/screenshot_$(date +%Y%m%d_%H%M%S).png"

take_screenshot() {
    local mode="$1"
    local temp_file=$(mktemp)

    case "$mode" in
        "area")
            grim -g "$(slurp)" "$temp_file"
            ;;
        "full")
            grim "$temp_file"
            ;;
        *)
            echo "Invalid mode. Use 'area' or 'full'."
            exit 1
            ;;
    esac

    # Check if the temporary file is empty (screenshot was cancelled)
    if [ -s "$temp_file" ]; then
        mv "$temp_file" "$filename"
        # Play sound (replace with your preferred sound file)
        paplay /usr/share/sounds/freedesktop/stereo/camera-shutter.oga
        # Send notification with image preview
        notify-send -i "$filename" "Screenshot taken" "Saved as $filename"
    else
        rm "$temp_file"
        notify-send "Screenshot cancelled"
    fi
}

take_screenshot "$1"
