#!/bin/bash

# Path to the key file
KEY_FILE=$1

# Check if the file exists
if [ ! -f "$KEY_FILE" ]; then
  echo "Key file does not exist."
  exit 1
fi

# Function to check if an RSA private key is password protected
is_password_protected() {
  if openssl rsa -in $1 -noout -passin pass: 2>/dev/null; then
    echo "The RSA private key is not password protected."
  else
    echo "The RSA private key is password protected."
  fi
}

# Determine the key type
KEY_TYPE=$(openssl pkey -in $KEY_FILE -noout -text -passin pass: 2>&1)

if echo "$KEY_TYPE" | grep -q 'RSA PRIVATE KEY'; then
  echo "The key is an RSA private key."
  is_password_protected $KEY_FILE
elif echo "$KEY_TYPE" | grep -q 'PUBLIC KEY'; then
  if echo "$KEY_TYPE" | grep -q 'RSA'; then
    echo "The key is an RSA public key."
  elif echo "$KEY_TYPE" | grep -q 'ED25519'; then
    echo "The key is an Ed25519 public key."
  else
    echo "Unknown public key type."
  fi
elif echo "$KEY_TYPE" | grep -q 'ED25519 PRIVATE KEY'; then
  echo "The key is an Ed25519 private key. Ed25519 keys do not support password protection."
else
  echo "Unknown key type or unsupported format."
fi
