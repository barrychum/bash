#!/bin/bash

# Check if input file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <file-to-encrypt>"
  exit 1
fi

# Define the input and output files
INPUT_FILE=$1
ZIP_FILE="${INPUT_FILE}.zip"
ENCRYPTED_FILE="${ZIP_FILE}.enc"

# Path to the public key
PUBLIC_KEY_PATH="$HOME/.ssh/encryption.pub"

# Zip the input file
zip -q $ZIP_FILE $INPUT_FILE

# Generate a symmetric key
SYM_KEY=$(openssl rand -base64 32)

# Encrypt the file using the symmetric key (AES) with pbkdf2
openssl enc -aes-256-cbc -salt -pbkdf2 -in $ZIP_FILE -out $ENCRYPTED_FILE -pass pass:$SYM_KEY

# Encrypt the symmetric key using the public key with pkeyutl
ENC_SYM_KEY=$(echo -n $SYM_KEY | openssl pkeyutl -encrypt -pubin -inkey $PUBLIC_KEY_PATH | xxd -p)

# Combine the encrypted symmetric key and the encrypted file
cat <(echo "$ENC_SYM_KEY" | xxd -r -p) $ENCRYPTED_FILE > "${INPUT_FILE}.bundle"
# {
#  echo "$ENC_SYM_KEY" | xxd -r -p
#  cat $ENCRYPTED_FILE
# } > "${INPUT_FILE}.bundle"

# Clean up
rm $ZIP_FILE $ENCRYPTED_FILE

echo "File has been encrypted and stored as ${INPUT_FILE}.bundle"
