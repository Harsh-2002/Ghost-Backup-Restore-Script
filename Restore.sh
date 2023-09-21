#!/bin/bash


# Database credentials
DB_USER="root"
DB_NAME="bitnami_ghost"
S3_BUCKET="firstfinger1"
S3_FOLDER="MySQL"

# List objects in the S3 folder and get the latest backup file
LATEST_MYSQL_BACKUP=$(aws s3 ls "s3://$S3_BUCKET/$S3_FOLDER/" | sort | tail -n 1 | awk '{print $4}')

# Check if a backup file was found
if [ -n "$LATEST_MYSQL_BACKUP" ]; then
    # Download the latest MySQL backup from S3 and restore it
    aws s3 cp "s3://$S3_BUCKET/$S3_FOLDER/$LATEST_MYSQL_BACKUP" - | mysql -u $DB_USER -p $DB_NAME

    # Check if the MySQL restore was successful
    if [ $? -eq 0 ]; then
        echo "MySQL restore completed successfully."
    else
        echo "Error: MySQL restore failed."
    fi
else
    echo "Error: No MySQL backup found in S3."
fi

#Content Folder Restore

sudo /opt/bitnami/ctlscript.sh stop ghost

# Directory to be restored
SOURCE_DIR="/opt/bitnami/ghost/content/"
S3_CONTENT_FOLDER="Content"

# List objects in the S3 Content folder and get the latest backup file
LATEST_CONTENT_BACKUP=$(aws s3 ls "s3://$S3_BUCKET/$S3_CONTENT_FOLDER/" | sort | tail -n 1 | awk '{print $4}')

# Check if a backup file was found
if [ -n "$LATEST_CONTENT_BACKUP" ]; then
    # Download the latest directory backup from S3
    aws s3 cp "s3://$S3_BUCKET/$S3_CONTENT_FOLDER/$LATEST_CONTENT_BACKUP" "/tmp/$LATEST_CONTENT_BACKUP"

    # Check if the download was successful
    if [ $? -eq 0 ]; then
        # Remove the existing content directory
        sudo rm -rf "$SOURCE_DIR"

        # Unzip the downloaded backup to replace the content directory
        sudo unzip -q "/tmp/$LATEST_CONTENT_BACKUP" -d "$SOURCE_DIR"

        # Clean up temporary files and directories
        rm "/tmp/$LATEST_CONTENT_BACKUP"

        echo "Directory restore completed successfully."

        # Array of folder names
        folders=("apps" "data" "files" "images" "logs" "media" "public" "settings" "themes")

        # Loop through each folder and execute the commands
        for folder in "${folders[@]}"; do
            sudo chown -R ghost:ghost "$SOURCE_DIR$folder"
            sudo chmod -R 755 "$SOURCE_DIR$folder"
            sudo chown ghost:bitnami "$SOURCE_DIR$folder"
        done

        echo "Ownership and permissions set for specific folders and Starting Ghost."
          sudo /opt/bitnami/ctlscript.sh start ghost
    else
        echo "Error: Directory download failed."
    fi
else
    echo "Error: No directory backup found in S3."
fi
