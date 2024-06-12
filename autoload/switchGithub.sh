#!/bin/bash

# Define the abc function
switch_github() {
  # Path to the hosts.yml file
  local HOSTS_FILE="$HOME/.config/gh/hosts.yml"

  # Function to list all users
  list_users() {
    awk '/users:/{flag=1; next} /user:/{flag=0} flag' "$HOSTS_FILE" | tr -d ' ' | tr -d ':'
  }

  # Function to get the current active user
  get_active_user() {
    awk '/user:/{print $2}' "$HOSTS_FILE" | tr -d ' '
  }

  # Function to switch user
  switch_user() {
    local username=$1
    echo "Switching to user: $username"
    gh auth switch -u "$username"
  }

  # List all users and store in an array
  local users=()
  while IFS= read -r user; do
    users+=("$user")
  done < <(list_users)

  # Display available users
  echo "Available users:"
  local i=1
  for user in "${users[@]}"; do
    echo "$i. $user"
    i=$((i + 1))
  done

  # Get current active user
  local current_user=$(get_active_user)
  echo "Current active user: $current_user"

  # Prompt user to select a user by number
  echo -n "Enter the number corresponding to the GitHub account to switch to: "
  read user_number

  # Validate the input and switch to the selected user
  if [[ $user_number -gt 0 && $user_number -le ${#users[@]} ]]; then
    local selected_user=${users[$((user_number-1))]}
    switch_user "$selected_user"
  else
    echo "Invalid selection. Please enter a valid number."
    return 1
  fi

  echo "Switch successful."
}


if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    replaceAll "$@"
fi
