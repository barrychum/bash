#!/bin/bash

# Check if input file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <file-to-decrypt>"
  exit 1
fi

# Define the input and output files
ENCRYPTED_BUNDLE=$1
DECRYPTED_FILE="${ENCRYPTED_BUNDLE%.bundle}.zip"

# Extract the encrypted symmetric key (first 256 bytes) and the encrypted file
ENC_SYM_KEY=$(head -c 256 "$ENCRYPTED_BUNDLE" | xxd -p -c 256)
tail -c +257 "$ENCRYPTED_BUNDLE" >"${DECRYPTED_FILE}.enc"

# Path to the private key
PRIVATE_KEY_PATH="$HOME/.ssh/encryption.key"

# Check if the private key file is password protected
if openssl pkey -in $PRIVATE_KEY_PATH -noout -passin pass: 2>/dev/null; then
  echo "The private key is not password protected."

  # Prompt for the private key password
  read -sp "Enter the private key password: " PRIVATE_KEY_PASSWORD
  echo

  # Decrypt the symmetric key using the private key with pkeyutl
  SYM_KEY=$(echo "$ENC_SYM_KEY" | xxd -r -p | openssl pkeyutl -decrypt -inkey $PRIVATE_KEY_PATH -passin pass:"$PRIVATE_KEY_PASSWORD")
else
  echo "The private key is password protected."

  # Decrypt the symmetric key using the private key with pkeyutl
  SYM_KEY=$(echo "$ENC_SYM_KEY" | xxd -r -p | openssl pkeyutl -decrypt -inkey $PRIVATE_KEY_PATH)
fi

# Check if the decryption of the symmetric key was successful
if [ -z "$SYM_KEY" ]; then
  echo "Failed to retrieve symmetric key."
  exit 1
fi

# Decrypt the file using the symmetric key with pbkdf2
openssl enc -d -aes-256-cbc -pbkdf2 -in "${DECRYPTED_FILE}.enc" -out "$DECRYPTED_FILE" -pass pass:"$SYM_KEY"

# Unzip the decrypted file
# unzip -q "$DECRYPTED_FILE" -d "${DECRYPTED_FILE%.zip}"
unzip -n "$DECRYPTED_FILE" -d .

# Clean up
rm "${DECRYPTED_FILE}.enc" "$DECRYPTED_FILE"
