#!/bin/bash

# Check if input file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <file-to-decrypt>"
  exit 1
fi

# Define the input and output files
ENCRYPTED_BUNDLE=$1
RANDOM_SUFFIX=$(uuidgen | tr -d '-')
DECRYPTED_FILE="${ENCRYPTED_BUNDLE%.bundle}.zip.${RANDOM_SUFFIX}"
ENCRYPTED_FILE="${ENCRYPTED_BUNDLE%.bundle}.enc.${RANDOM_SUFFIX}"

# Path to the private key
PRIVATE_KEY_PATH="$HOME/.ssh/encryption.key"

if [ ! -f "$ENCRYPTED_BUNDLE" ]; then
  echo "Error: Input file '$ENCRYPTED_BUNDLE' not found."
  exit 1
fi
if [ ! -f "$PRIVATE_KEY_PATH" ]; then
  echo "Error: Private key file '$PRIVATE_KEY_PATH' not found."
  exit 1
fi

# Extract the encrypted symmetric key (first 256 bytes)
ENC_SYM_KEY=$(head -c 256 "$ENCRYPTED_BUNDLE" | xxd -p -c 256)

# Check if the private key file is password protected
if openssl pkey -in $PRIVATE_KEY_PATH -noout -passin pass: 2>&1 | grep -q "unable to load"; then
  echo "The private key is password protected."
fi

# Decrypt the symmetric key using the private key with pkeyutl
# openssl will prompt for password if private key is password protected
SYM_KEY=$(echo "$ENC_SYM_KEY" | xxd -r -p | openssl pkeyutl -decrypt -inkey $PRIVATE_KEY_PATH 2>&1)
if [ $? -ne 0 ]; then
  echo "Error: OpenSSL command failed. Failed to retrieve symmetric key."
  exit 1
fi

# Extract the encrypted file
tail -c +257 "$ENCRYPTED_BUNDLE" >"$ENCRYPTED_FILE"

# Decrypt the file using the symmetric key with pbkdf2
openssl enc -d -aes-256-cbc -pbkdf2 -in "$ENCRYPTED_FILE" -out "$DECRYPTED_FILE" -pass pass:"$SYM_KEY"

# Unzip the decrypted file
# unzip -n "$DECRYPTED_FILE" -d .
output=$(unzip -n "$DECRYPTED_FILE" -d . | grep "inflating")

# Check if the output contains the word "inflating"
if echo "$output" | grep -q "inflating"; then
  echo $output
else
  echo "File already exists. Unzip operation aborted."
fi

# Clean up
rm "$ENCRYPTED_FILE" "$DECRYPTED_FILE"
