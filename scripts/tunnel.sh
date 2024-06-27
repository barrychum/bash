#!/bin/bash

# Read GPG_PASSPHRASE from the KeyVault
# https://github.com/barrychum/keyvault
if command -v get-keyvalue.sh &>/dev/null; then
    CLOUDFLARE_TUNNEL_TOKEN=$(get-keyvalue.sh "CLOUDFLARE_TUNNEL_TOKEN")
fi

# Define available actions
ACTIONS="start stop status"

# Check if at least one argument is provided
if [[ -z "$1" ]]; then
  echo "No action specified. Please choose one of the following:"
  echo "${ACTIONS[@]}"
  echo -e "\n"
  exit 1
fi

# Get the first argument (action)
action="$1"

# Check if action is valid
if [[ ! ($ACTIONS =~ $action) ]]; then
  echo "Invalid action: '$action'"
  echo "Available actions: ${ACTIONS}"
  echo -e "\n"
  exit 1
fi

# Function to check if cloudflared is running
is_cloudflared_running() {
  pgrep -x "cloudflared" >/dev/null 2>&1
}

# Get the token from the environment variable
# token can be found from install and run a connector
# in cloudflare tunnels setting
TOKEN="$CLOUDFLARE_TUNNEL_TOKEN"

echo -e "\n"

# Check if TOKEN is set
if [[ "$action" == "start" && -z "$TOKEN" ]]; then
  echo "CLOUDFLARE_TUNNEL_TOKEN is required for the start action."
  echo -e "\n"
  exit 1
fi

# Execute action based on argument
case $action in
start)
  if is_cloudflared_running; then
    echo "Tunnel is already running"
  else
    echo "Starting tunnel..."
    cloudflared service install "$TOKEN"
  fi
  ;;
stop)
  if is_cloudflared_running; then
    echo "Stopping tunnel..."
    cloudflared service uninstall
  else
    echo "Tunnel is not running"
  fi
  ;;
status)
  if is_cloudflared_running; then
    echo "Tunnel is running."
  else
    echo "Tunnel is not running."
  fi
  ;;
esac
echo -e "\n"
