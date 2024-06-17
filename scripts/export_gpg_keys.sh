#!/bin/bash

# Define the .env file location
ENV_FILE=".env"

# Function to read a specific variable from the .env file
get_env_var() {
    local var_name="$1"
    local value="${!var_name}"
    if [ -z "$value" ]; then
        value=$(grep "^${var_name}=" "$ENV_FILE" | cut -d '=' -f2-)
    fi 
    echo "$value"
}

# Read GPG_PASSPHRASE from the .env file
GPG_PASSPHRASE=$(get_env_var "GPG_PASSPHRASE")

# Check if the GPG_PASSPHRASE environment variable is set
if [ -z "$GPG_PASSPHRASE" ]; then
    echo "GPG_PASSPHRASE environment variable is not set."
    echo "Check if you see error during export"
    GPG_PASSPHRASE=""
fi

# Directory to store the exported keys
OUTPUT_DIR="./gpg_keys_backup"

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Ensure GPG agent is running
gpg-connect-agent /bye

# Export all private keys
gpg --list-secret-keys --with-colons | grep '^sec' | cut -d':' -f5 | while read -r KEY_ID; do
    echo "Exporting private key for KEY_ID: $KEY_ID"
    
    # Get the real name associated with the key (excluding email)
    REAL_NAME=$(gpg --list-secret-keys --with-colons "$KEY_ID" | grep '^uid' | cut -d':' -f10 | head -n 1 | sed 's/ <.*>//' | tr ' ' '_')
    
    # Export the private key using the passphrase from the environment variable
    echo "$GPG_PASSPHRASE" | gpg --batch --yes --pinentry-mode loopback --passphrase-fd 0 --output "$OUTPUT_DIR/private_key_${REAL_NAME}_$KEY_ID.asc" --armor --export-secret-keys "$KEY_ID"
done

echo "All private keys have been exported to $OUTPUT_DIR"
