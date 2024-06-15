#!/bin/bash

# Path to the public key
PUBLIC_KEY_PATH="$HOME/.ssh/encryption.pub"

# Check if the public key file exists
if [ ! -f "$PUBLIC_KEY_PATH" ]; then
  echo "Error: Public key file '$PUBLIC_KEY_PATH' not found."
  exit 1
fi

# Generate the MD5 hash of the public key
PUBLIC_KEY_HASH=$(openssl dgst -md5 "$PUBLIC_KEY_PATH" | awk '{print $2}')

# Save the hash to a file
# echo $PUBLIC_KEY_HASH > "$HOME/.ssh/encryption.pub.hash"
echo $PUBLIC_KEY_HASH > "$HOME/.ssh/encryption.pub.hash"
echo $PUBLIC_KEY_HASH 

echo "MD5 hash of the public key saved to '$HOME/.ssh/encryption.pub.hash'"
