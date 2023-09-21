#!/bin/bash

# Database credentials

DB_USER="root"
DB_NAME="bitnami_ghost"

# S3 bucket information

S3_BUCKET="firstfinger"
S3_FOLDER="MySQL"

# Perform MySQL backup and directly upload it to S3

mysqldump -u $DB_USER -p $DB_NAME | aws s3 cp - "s3://$S3_BUCKET/$S3_FOLDER/backup-$(date +%Y-%m-%d-%H%M).sql"

# Check if the backup and transfer were successful

if [ $? -eq 0 ]; then
echo "MySQL backup and transfer to S3 completed successfully."
else
echo "Error: MySQL backup or transfer to S3 failed."
fi

# Directory to be backed up

SOURCE_DIR="/opt/bitnami/ghost/content/"

# S3 bucket information

S3_BUCKET="firstfinger"
S3_FOLDER="Content"

# Timestamp for the backup file

TIMESTAMP=$(date +%Y-%m-%d-%H%M)
BACKUP_FILENAME="backup-$TIMESTAMP.zip"

# Perform the backup and upload to S3

(cd "$SOURCE_DIR" && sudo zip -r - .) | aws s3 cp - "s3://$S3_BUCKET/$S3_FOLDER/$BACKUP_FILENAME"

# Check if the backup and transfer were successful

if [ $? -eq 0 ]; then
echo "Backup and transfer to S3 completed successfully."
else
echo "Error: Backup or transfer to S3 failed."
fi

#Back to home
cd

# File to be backed up

SOURCE_FILE="/opt/bitnami/ghost/config.production.json"

# S3 bucket information

S3_BUCKET="firstfinger"
S3_FOLDER="Config"

# Timestamp for the backup file

TIMESTAMP=$(date +%Y-%m-%d-%H%M)
BACKUP_FILENAME="config-backup-$TIMESTAMP.json"

# Perform the backup and upload to S3

aws s3 cp "$SOURCE_FILE" "s3://$S3_BUCKET/$S3_FOLDER/$BACKUP_FILENAME"

# Check if the backup and transfer were successful

if [ $? -eq 0 ]; then
echo "Backup and transfer to S3 completed successfully."
else
echo "Error: Backup or transfer to S3 failed."
fi
