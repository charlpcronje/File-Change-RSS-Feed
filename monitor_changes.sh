#!/bin/bash
# monitor_changes.sh

# Define the log file
LOG_FILE="/var/log/www_changes.log"

# Run inotifywait to monitor changes, excluding specified directories
inotifywait -m -r -e modify,create,delete --format '%T %w %f %e' --timefmt '%Y-%m-%dT%H:%M:%S' \
    --exclude '(\.history|\.vscode|\.git|node_modules|logs|vendor)' /var/www/ >> $LOG_FILE
