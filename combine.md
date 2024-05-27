# File Change RSS Feed
This project generates an RSS feed that tracks changes to files in the `/var/www/` directory. The feed is updated whenever a file is created, modified, or deleted, providing subscribers with real-time updates on the latest changes.

## setup_rss_feed.sh
```bash
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
```

## monitor_changes.sh
This script also excludes some folders from being monitored
```bash
#!/bin/bash
# monitor_changes.sh

# Define the log file
LOG_FILE="/var/log/www_changes.log"

# Run inotifywait to monitor changes, excluding specified directories
inotifywait -m -r -e modify,create,delete --format '%T %w %f %e' --timefmt '%Y-%m-%dT%H:%M:%S' \
    --exclude '(\.history|\.vscode|\.git|node_modules|logs|vendor)' /var/www/ >> $LOG_FILE
```

## generate_rss_feed.sh
This file generates the xml for the feed but there are a few bugs look at the output below this file
```bash
#!/bin/bash
# generate_rss_feed.sh
LOG_FILE="`/var/log/www_changes.log`"
RSS_FILE="/var/www/api/rss.webally.co.za/logs/rss_feed.xml"
MAX_ITEMS=50

echo "<?xml version='1.0' encoding='UTF-8' ?>" > $RSS_FILE
echo "<rss version='2.0'>" >> $RSS_FILE
echo "<channel>" >> $RSS_FILE
echo "<title>File Changes in /var/www/</title>" >> $RSS_FILE
echo "<link>http://rss.webally.co.za/logs/rss_feed.xml</link>" >> $RSS_FILE
echo "<description>Recent changes to files in /var/www/</description>" >> $RSS_FILE
echo "<lastBuildDate>$(/usr/bin/date -R)</lastBuildDate>" >> $RSS_FILE

# Get the most recent $MAX_ITEMS log entries
tail -n $MAX_ITEMS $LOG_FILE | while read -r line; do
    DATE=$(/usr/bin/echo $line | /usr/bin/awk -F'T' '{print $1}')
    TIME=$(/usr/bin/echo $line | /usr/bin/awk -F'T' '{print $2}' | /usr/bin/awk '{print $1}')
    PATH=$(/usr/bin/echo $line | /usr/bin/awk '{print $3}')
    FILE=$(/usr/bin/echo $line | /usr/bin/awk '{print $4}')
    EVENT=$(/usr/bin/echo $line | /usr/bin/awk '{print $5}')

    # Replace commas with spaces in the EVENT variable using awk
    EVENT=$(/usr/bin/echo $EVENT | /usr/bin/awk '{gsub(/,/, " "); print}')

    # Convert the date and time to RFC-822 format
    PUBDATE=$(/usr/bin/date -R -d "$DATE $TIME")

    echo "<item>" >> $RSS_FILE
    echo "<title>$FILE: $EVENT</title>" >> $RSS_FILE
    echo "<link>http://rss.webally.co.za$PATH$FILE</link>" >> $RSS_FILE
    echo "<pubDate>$PUBDATE</pubDate>" >> $RSS_FILE
    echo "<guid>http://rss.webally.co.za$PATH$FILE</guid>" >> $RSS_FILE
    echo "</item>" >> $RSS_FILE
done

echo "</channel>" >> $RSS_FILE
echo "</rss>" >> $RSS_FILE
```

RSS Feed XML Output:
```xml
<item>
<title>MODIFY: </title>
<link>http://rss.webally.co.zaREADME.mdMODIFY</link>
<pubDate>Mon, 27 May 2024 13:06:06 +0200</pubDate>
<guid>http://rss.webally.co.zaREADME.mdMODIFY</guid>
</item>
<item>
<title>MODIFY: </title>
<link>http://rss.webally.co.zaREADME.mdMODIFY</link>
<pubDate>Mon, 27 May 2024 13:06:12 +0200</pubDate>
<guid>http://rss.webally.co.zaREADME.mdMODIFY</guid>
</item>
<item>
<title>MODIFY: </title>
<link>http://rss.webally.co.zaREADME.mdMODIFY</link>
<pubDate>Mon, 27 May 2024 13:06:12 +0200</pubDate>
<guid>http://rss.webally.co.zaREADME.mdMODIFY</guid>
</item>
<item>
<title>MODIFY: </title>
<link>http://rss.webally.co.zaREADME.mdMODIFY</link>
<pubDate>Mon, 27 May 2024 13:06:14 +0200</pubDate>
<guid>http://rss.webally.co.zaREADME.mdMODIFY</guid>
</item>
<item>
<title>MODIFY: </title>
<link>http://rss.webally.co.zaREADME.mdMODIFY</link>
<pubDate>Mon, 27 May 2024 13:06:14 +0200</pubDate>
<guid>http://rss.webally.co.zaREADME.mdMODIFY</guid>
</item>
<item>
<title>MODIFY: </title>
<link>http://rss.webally.co.zastyling.mdMODIFY</link>
<pubDate>Mon, 27 May 2024 13:06:16 +0200</pubDate>
<guid>http://rss.webally.co.zastyling.mdMODIFY</guid>
</item>
<item>
<title>MODIFY: </title>
<link>http://rss.webally.co.zastyling.mdMODIFY</link>
<pubDate>Mon, 27 May 2024 13:06:16 +0200</pubDate>
<guid>http://rss.webally.co.zastyling.mdMODIFY</guid>
</item>
</channel>
</rss>
```