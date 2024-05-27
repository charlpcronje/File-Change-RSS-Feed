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