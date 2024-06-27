#!/bin/bash

# Check if the correct number of parameters is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_volume_name> <target_volume_name>"
    exit 1
fi

SOURCE_VOLUME=$1
TARGET_VOLUME=$2

# Check if the source volume exists
if ! docker volume inspect $SOURCE_VOLUME > /dev/null 2>&1; then
    echo "Source volume '$SOURCE_VOLUME' does not exist."
    exit 1
fi

# Check if the target volume already exists
if docker volume inspect $TARGET_VOLUME > /dev/null 2>&1; then
    echo "Target volume '$TARGET_VOLUME' already exists. Please choose a different name."
    exit 1
fi

# Create the target volume
docker volume create $TARGET_VOLUME

# Duplicate the volume
docker run --rm -v $SOURCE_VOLUME:/from -v $TARGET_VOLUME:/to alpine ash -c "cd /from && cp -a . /to"

# Calculate the size of the source volume
VOLUME_SIZE=$(docker run --rm -v $SOURCE_VOLUME:/volume alpine sh -c "du -sb /volume | cut -f1")

echo "Volume '$SOURCE_VOLUME' has been successfully duplicated to '$TARGET_VOLUME'."
echo "The size of the volume is $VOLUME_SIZE bytes."
