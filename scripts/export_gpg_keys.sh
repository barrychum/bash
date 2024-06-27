#!/bin/bash

batch_mode=false
for arg in "$@"; do
    if [[ "$arg" == "-batch" ]]; then
        batch_mode=true
        break # Exit the loop after finding "-batch"
    fi
done
batch_mode=true

# Directory to store the exported keys
OUTPUT_DIR="$HOME/backups/bk_gpg"

# Read GPG_PASSPHRASE from the KeyVault
if command -v get-keyvalue.sh &>/dev/null; then
    GPG_PASSPHRASE=$(get-keyvalue.sh "GPG_PASSPHRASE")
fi

# Check if the GPG_PASSPHRASE environment variable is set
if [ -z "$GPG_PASSPHRASE" ]; then
    if [! $batch_mode]; then
        echo "GPG_PASSPHRASE environment variable is not set."
        echo "Check if you see error during export"
    fi
    GPG_PASSPHRASE=""
fi

# Create the output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Ensure GPG agent is running
gpg-connect-agent /bye

TAR_GZ="$OUTPUT_DIR/gpg_privkeys.tar"

# Export all private keys, grep 5th column as KEY_ID
gpg --list-secret-keys --with-colons | grep '^sec' | cut -d':' -f5 | while read -r KEY_ID; do
  REAL_NAME=$(gpg --list-secret-keys --with-colons "$KEY_ID" |
      grep '^uid' | cut -d':' -f10 | head -n 1 |
      sed 's/ <.*>//' | sed 's/(.*)//' | tr ' ' '_')

  FILE_NAME="gpg_privkey_${REAL_NAME}_${KEY_ID: -8}.asc"
  FILE_NAME=${FILE_NAME//__/_}  # This replaces all "__" with "_"  

  FILE2="$OUTPUT_DIR/$FILE_NAME"

  # Export key directly to file with filename
  echo "$GPG_PASSPHRASE" | gpg --batch --yes --pinentry-mode loopback --passphrase-fd 0 \
      --output "$FILE2" --armor --export-secret-keys "$KEY_ID"

  # Add the created file to archive
  tar --append --file="$TAR_GZ" --directory="$OUTPUT_DIR" "$FILE_NAME"
  rm "$FILE2"
done

unset GPG_PASSPHRASE

gzip -f "$TAR_GZ"

echo "All private keys have been exported to"
echo "$TAR_GZ.gz"
