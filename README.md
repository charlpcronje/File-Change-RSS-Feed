# File Change RSS Feed

This project generates an RSS feed that tracks changes to files in the `/var/www/` directory. The feed is updated whenever a file is created, modified, or deleted, providing subscribers with real-time updates on the latest changes.

## Features

1. **Real-time Updates**: The RSS feed is updated instantly whenever a file change occurs in the `/var/www/` directory, ensuring that subscribers always have access to the most recent information.

2. **Detailed File Information**: Each item in the RSS feed includes the following details:
   - File name and path
   - Change event (create, modify, delete)
   - Timestamp of the change
   - Link to the changed file

3. **Easy Integration**: The RSS feed is generated in a standard XML format, making it easy to integrate with various RSS readers, feed aggregators, and other tools that support RSS.

4. **Customizable**: The script allows you to customize the number of items included in the feed by modifying the `MAX_ITEMS` variable. You can also adjust the paths and filenames to suit your specific requirements.

5. **Lightweight**: The script is written in Bash and uses standard Unix utilities, making it lightweight and efficient. It doesn't require any additional dependencies or complex setups.

6. **Compatibility**: The script is compatible with most Unix-based systems, including Linux and macOS, as long as the required utilities (`awk`, `sed`, `date`) are available.

## Why Use an RSS Feed?

An RSS feed is an excellent way to keep track of changes to files in a directory, especially in scenarios where multiple users or automated processes are involved. Here are a few reasons why using an RSS feed is beneficial:

1. **Centralized Monitoring**: Instead of manually checking the directory for changes, subscribers can simply subscribe to the RSS feed and receive updates in their preferred RSS reader. This centralized approach saves time and effort.

2. **Automation**: The RSS feed can be consumed by automated systems or scripts to trigger specific actions based on file changes. For example, you can set up a continuous integration or deployment pipeline that automatically builds and deploys your application whenever a particular file is modified.

3. **Auditing and Tracking**: The RSS feed provides a historical record of file changes, allowing you to audit and track modifications over time. This can be useful for troubleshooting, monitoring user activity, or maintaining a changelog.

4. **Notifications**: RSS readers often provide notification features, enabling subscribers to receive alerts whenever new items are added to the feed. This ensures that important file changes are not missed and allows for prompt action if necessary.

## Getting Started

To set up and use the File Change RSS Feed, follow these steps:

1. Clone this repository to your local machine.

2. Ensure that you have the necessary permissions to read the `/var/log/www_changes.log` file and write to the `/var/www/api/rss.webally.co.za/logs/` directory.

3. Open the `generate_rss_feed.sh` script in a text editor and modify the `LOG_FILE`, `RSS_FILE`, and `MAX_ITEMS` variables if needed.

4. Make the script executable by running the following command:
   ```
   chmod +x generate_rss_feed.sh
   ```

5. Set up a cron job or a similar scheduling mechanism to run the `generate_rss_feed.sh` script at your desired interval. For example, to run the script every minute, you can add the following line to your crontab:
   ```
   * * * * * /path/to/generate_rss_feed.sh
   ```

6. Subscribe to the generated RSS feed using your preferred RSS reader or tool. The feed URL will be `http://rss.webally.co.za/logs/rss_feed.xml`.

7. Monitor the RSS feed for updates and take appropriate actions based on the file changes.

## License

This project is open-source and available under the [MIT License](LICENSE). Feel free to modify and adapt the script to suit your needs.

## Contributing

Contributions are welcome! If you have any suggestions, improvements, or bug fixes, please open an issue or submit a pull request. Make sure to follow the existing code style and provide clear descriptions of your changes.

## Support

If you encounter any problems or have questions related to this project, please open an issue in the GitHub repository. We'll do our best to assist you.

Happy monitoring!