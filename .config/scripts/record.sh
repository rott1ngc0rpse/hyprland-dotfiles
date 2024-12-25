#!/bin/bash

# Define the output file path and the recording process name
output_dir="$HOME/Videos"
mkdir -p "$output_dir"  # Ensure the directory exists
timestamp=$(date +%Y-%m-%d_%H-%M-%S)
output_file="$output_dir/screen_recording_$timestamp.mp4"
pid_file="$HOME/.config/scripts/recording_pid.txt"

# Function to start the recording
start_recording() {
    if [ -f "$pid_file" ]; then
        # If a recording is already running, stop it before starting a new one
        pid=$(cat "$pid_file")
        if kill "$pid" 2>/dev/null; then
            echo "Existing recording stopped. Starting a new recording..."
            rm "$pid_file"  # Remove the old PID file
        else
            echo "Failed to stop the existing recording. Proceeding with new recording anyway."
        fi
    fi

    # Start the new recording
    echo "Recording started. Saving to $output_file"
    wf-recorder -f "$output_file" &
    echo $! > "$pid_file"  # Save the new process ID of the recording

    # Send notification using makoctl
    notify-send -i "Recording Started" "Your recording has started and is being saved to $output_file."
}

# Function to stop the recording
stop_recording() {
    if [ -f "$pid_file" ]; then
        pid=$(cat "$pid_file")
        if kill "$pid" 2>/dev/null; then
            echo "Recording stopped."
            rm "$pid_file"  # Remove the PID file after stopping
            
            # Send notification using makoctl
            notify-send "Recording Stopped" "Your recording has been saved to $output_file."
        else
            echo "Failed to stop the recording (maybe it's already stopped)."
        fi
    else
        echo "No active recording found."
    fi
}

# Check the argument passed to the script
case "$1" in
    start)
        start_recording
        ;;
    stop)
        stop_recording
        ;;
    *)
        echo "Usage: $0 {start|stop}"
        exit 1
        ;;
esac
