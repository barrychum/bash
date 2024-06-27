#!/bin/bash

# Check if the correct number of parameters is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_volume_name> <target_backup_file>"
    exit 1
fi

SOURCE_VOLUME=$1
shopt -s extglob nocasematch
TARGET_BACKUP_FILE="${2%%+(.tar.gz|.tar|.gz)}".tar.gz
shopt -u extglob nocasematch
file_path=$(dirname "$TARGET_BACKUP_FILE")
file_name=$(basename "$TARGET_BACKUP_FILE")

# TEMP_FILENAME="$(date +"%Y%m%d")_$(uuidgen | head -c 8).tar.gz"


# Check if the source volume exists
if ! docker volume inspect $SOURCE_VOLUME > /dev/null 2>&1; then
    echo "Source volume '$SOURCE_VOLUME' does not exist."
    exit 1
fi

# Check if the target backup file already exists
if [ -e $TARGET_BACKUP_FILE ]; then
    echo "Target backup file '$TARGET_BACKUP_FILE' already exists. Please choose a different name."
    exit 1
fi

# Create a backup of the Docker volume
docker run --rm -v $SOURCE_VOLUME:/volume -v ${file_path}:/backup alpine tar czf /backup/$file_name -C /volume .

# mv $TEMP_FILENAME $TARGET_BACKUP_FILE

echo "Volume '$SOURCE_VOLUME' has been successfully backed up to '$TARGET_BACKUP_FILE'."
