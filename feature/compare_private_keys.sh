#!/bin/bash

# Path to the public key hash file
PUBLIC_KEY_HASH_PATH="$HOME/.ssh/encryption.pub.hash"

# Check if the public key hash file exists
if [ ! -f "$PUBLIC_KEY_HASH_PATH" ]; then
  echo "Error: Public key hash file '$PUBLIC_KEY_HASH_PATH' not found. Run the generate_public_key_hash.sh script first."
  exit 1
fi

# Read the stored public key hash
STORED_PUBLIC_KEY_HASH=$(cat "$PUBLIC_KEY_HASH_PATH")

# Directory containing private keys
PRIVATE_KEY_DIR="$HOME/.ssh"

# Check if the private key directory exists
if [ ! -d "$PRIVATE_KEY_DIR" ]; then
  echo "Error: Private key directory '$PRIVATE_KEY_DIR' not found."
  exit 1
fi

# Iterate through all private key files in the directory
for PRIVATE_KEY_FILE in "$PRIVATE_KEY_DIR"/*.key; do
  # Check if the file exists to handle no match case
  if [ ! -f "$PRIVATE_KEY_FILE" ]; then
    continue
  fi

  # Generate the public key from the private key using openssl
  PUBLIC_KEY=$(openssl rsa -pubout -in "$PRIVATE_KEY_FILE" 2>/dev/null)

  # Check if openssl succeeded
  if [ $? -ne 0 ]; then
    echo "Error generating public key from private key '$PRIVATE_KEY_FILE'."
    continue
  fi

  # Generate the MD5 hash of the public key
  PUBLIC_KEY_HASH=$(echo "$PUBLIC_KEY" | openssl dgst -md5)

  # Compare the public key hash with the stored public key hash
  if [ "$PUBLIC_KEY_HASH" == "$STORED_PUBLIC_KEY_HASH" ]; then
    echo "Match found: '$PRIVATE_KEY_FILE'"
    exit 0
  fi
done

echo "No matching private key found."
