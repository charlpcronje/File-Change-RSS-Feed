# monitor_projects.py
import os
import fnmatch
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import time
import json
from gitignore_parser import parse_gitignore
from rss_generator import add_rss_entry  # Updated to use feedgen

BASE_DIR = '/var/www/'

class ChangeHandler(FileSystemEventHandler):
    def __init__(self, ignore_patterns):
        super().__init__()
        self.ignore_patterns = ignore_patterns

    def on_modified(self, event):
        self.process_event(event)

    def on_created(self, event):
        self.process_event(event)

    def process_event(self, event):
        if event.is_directory or any(fnmatch.fnmatch(event.src_path, pattern) for pattern in self.ignore_patterns):
            return

        # Log changes and add to RSS feed
        print(f"File {event.src_path} has been {event.event_type}")
        add_rss_entry(event.src_path, event.event_type)

def is_valid_project(project_path):
    return os.path.exists(os.path.join(project_path, 'rss.json'))

def get_ignore_patterns(project_path):
    """Parse the .gitignore file and return ignore patterns."""
    gitignore_path = os.path.join(project_path, '.gitignore')
    if os.path.exists(gitignore_path):
        with open(gitignore_path) as f:
            ignore_patterns = parse_gitignore(f)
            return [ignore_patterns]
    return []

def monitor_projects():
    observer = Observer()

    for category in os.listdir(BASE_DIR):
        category_path = os.path.join(BASE_DIR, category)
        
        if os.path.isdir(category_path):
            for project in os.listdir(category_path):
                project_path = os.path.join(category_path, project)

                if os.path.isdir(project_path) and is_valid_project(project_path):
                    ignore_patterns = get_ignore_patterns(project_path)
                    print(f"Monitoring: {project_path} (excluding patterns: {ignore_patterns})")
                    
                    event_handler = ChangeHandler(ignore_patterns)
                    observer.schedule(event_handler, project_path, recursive=True)

    observer.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()

    observer.join()

if __name__ == "__main__":
    monitor_projects()
