# rss_generator.py
from feedgen.feed import FeedGenerator
from datetime import datetime
import os

RSS_FILE = "/var/www/rss_feed.xml"

# Initialize the RSS feed
def initialize_rss_feed():
    fg = FeedGenerator()
    fg.title('Project File Changes')
    fg.link(href='http://rss.webally.co.za')
    fg.description('Tracks changes in project files')
    return fg

# Load or create the RSS feed
def load_or_create_rss_feed():
    if os.path.exists(RSS_FILE):
        return FeedGenerator.load(RSS_FILE)
    else:
        return initialize_rss_feed()

# Add new entry to the RSS feed
def add_rss_entry(file_path, event_type):
    fg = load_or_create_rss_feed()

    entry = fg.add_entry()
    entry.title(f"File {file_path} {event_type}")
    entry.link(href=f"http://rss.webally.co.za/{file_path}")
    entry.description(f"File {file_path} was {event_type} at {datetime.now().isoformat()}")
    entry.pubDate(datetime.now().isoformat())

    # Save the RSS feed
    fg.rss_file(RSS_FILE)
