#!/bin/bash

# Check if input file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <file-to-decrypt>"
  exit 1
fi

# Define the input and output files
ENCRYPTED_BUNDLE=$1
DECRYPTED_FILE="${ENCRYPTED_BUNDLE%.bundle}.zip"

# Prompt for the private key password
read -sp "Enter the private key password: " PRIVATE_KEY_PASSWORD
echo

# Extract the encrypted symmetric key (first 256 bytes) and the encrypted file
ENC_SYM_KEY=$(head -c 256 "$ENCRYPTED_BUNDLE" | xxd -p -c 256)
tail -c +257 "$ENCRYPTED_BUNDLE" > "${DECRYPTED_FILE}.enc"

# Decrypt the symmetric key using the private key with pkeyutl
SYM_KEY=$(echo "$ENC_SYM_KEY" | xxd -r -p | openssl pkeyutl -decrypt -inkey private_key.pem -passin pass:"$PRIVATE_KEY_PASSWORD")

# Decrypt the file using the symmetric key with pbkdf2
openssl enc -d -aes-256-cbc -pbkdf2 -in "${DECRYPTED_FILE}.enc" -out "$DECRYPTED_FILE" -pass pass:"$SYM_KEY"

# Unzip the decrypted file
# unzip -q "$DECRYPTED_FILE" -d "${DECRYPTED_FILE%.zip}"
unzip -n "$DECRYPTED_FILE" -d .

# Clean up
rm "${DECRYPTED_FILE}.enc" "$DECRYPTED_FILE"

