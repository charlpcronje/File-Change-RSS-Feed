#!/bin/bash

# setup_rss_feed.sh
# Directory to store RSS feed and setup script
TARGET_DIR="/var/www/api/rss.webally.co.za"

# Create the target directory if it doesn't exist
sudo mkdir -p $TARGET_DIR

# Install inotify-tools using dnf
sudo dnf install -y inotify-tools

# Create the log file directory and log file
sudo mkdir -p /var/log
sudo touch /var/log/www_changes.log
sudo chmod 666 /var/log/www_changes.log

# Create the monitoring script
cat << 'EOF' | sudo tee /usr/local/bin/monitor_changes.sh
#!/bin/bash
inotifywait -m -r -e modify,create,delete --format '%T %w %f %e' --timefmt '%Y-%m-%dT%H:%M:%S' /var/www/ >> /var/log/www_changes.log
EOF

# Make the monitoring script executable
sudo chmod +x /usr/local/bin/monitor_changes.sh

# Create the RSS feed generation script in the target directory
cat << 'EOF' | sudo tee $TARGET_DIR/generate_rss_feed.sh
#!/bin/bash

LOG_FILE="/var/log/www_changes.log"
RSS_FILE="$TARGET_DIR/logs/rss_feed.xml"

echo "<?xml version='1.0' encoding='UTF-8' ?>" > $RSS_FILE
echo "<rss version='2.0'>" >> $RSS_FILE
echo "<channel>" >> $RSS_FILE
echo "<title>File Changes in /var/www/</title>" >> $RSS_FILE
echo "<link>http://rss.webally.co.za/logs/rss_feed.xml</link>" >> $RSS_FILE
echo "<description>Recent changes to files in /var/www/</description>" >> $RSS_FILE
echo "<lastBuildDate>$(date -R)</lastBuildDate>" >> $RSS_FILE

tail -n 50 $LOG_FILE | while read -r line; do
    DATE=$(echo $line | awk '{print $1}')
    TIME=$(echo $line | awk '{print $2}')
    PATH=$(echo $line | awk '{print $3}')
    FILE=$(echo $line | awk '{print $4}')
    EVENT=$(echo $line | awk '{print $5}')

    echo "<item>" >> $RSS_FILE
    echo "<title>$EVENT: $FILE</title>" >> $RSS_FILE
    echo "<link>http://rss.webally.co.za/$PATH$FILE</link>" >> $RSS_FILE
    echo "<pubDate>${DATE}T${TIME}</pubDate>" >> $RSS_FILE
    echo "<guid>http://rss.webally.co.za/$PATH$FILE</guid>" >> $RSS_FILE
    echo "</item>" >> $RSS_FILE
done

echo "</channel>" >> $RSS_FILE
echo "</rss>" >> $RSS_FILE
EOF

# Make the RSS feed generation script executable
sudo chmod +x $TARGET_DIR/generate_rss_feed.sh

# Create a systemd service for the monitoring script
cat << 'EOF' | sudo tee /etc/systemd/system/monitor_changes.service
[Unit]
Description=Monitor file changes in /var/www

[Service]
ExecStart=/usr/local/bin/monitor_changes.sh

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable monitor_changes.service
sudo systemctl start monitor_changes.service

# Set up a cron job to run the RSS feed generation script every 10 minutes
(crontab -l ; echo "*/10 * * * * $TARGET_DIR/generate_rss_feed.sh") | crontab -

# Confirm the location and execution of the script
echo "Setup complete. The RSS feed will be generated and updated every 10 minutes in $TARGET_DIR."
