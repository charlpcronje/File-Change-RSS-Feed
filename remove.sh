#!/bin/bash

# Cleanup script for the file monitoring system

# Stop and disable the monitoring service
echo "Stopping and disabling the monitoring service..."
sudo systemctl stop monitor_changes.service
sudo systemctl disable monitor_changes.service

# Remove the service file
echo "Removing the service file..."
sudo rm -f /etc/systemd/system/monitor_changes.service

# Reload systemd to apply changes
sudo systemctl daemon-reload

# Remove the cron job
echo "Removing the cron job..."
crontab -l | grep -v "/var/www/api/rss.webally.co.za/generate_rss_feed.sh" | crontab -

# Remove the scripts
echo "Removing scripts..."
sudo rm -f /usr/local/bin/monitor_changes.sh
sudo rm -f /var/www/api/rss.webally.co.za/generate_rss_feed.sh

# Clean up log files
echo "Cleaning up log files..."
sudo rm -f /var/log/www_changes.log

# Remove the RSS feed file
echo "Removing RSS feed file..."
sudo rm -f /var/www/api/rss.webally.co.za/logs/rss_feed.xml

# Remove the entire monitoring app directory
echo "Removing the entire monitoring app directory..."
sudo rm -rf /var/www/api/rss.webally.co.za

# Optionally, remove inotify-tools (uncomment if you want to remove it)
# echo "Removing inotify-tools..."
# sudo dnf remove -y inotify-tools

echo "Cleanup complete. The file monitoring system has been removed."

# Reminder to reboot or log out
echo "Please remember to reboot your system or log out and log back in to ensure all related processes are terminated."