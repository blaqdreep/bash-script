#!/bin/bash

# Path to the CSV file passed as argument
CSV_FILE="$1"

# Log file path
LOG_FILE="/var/log/user_management.log"

# Function to trim white spaces
trim() {
  echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Ensure log file exists and is writable
sudo touch "$LOG_FILE"
sudo chmod 644 "$LOG_FILE"

# Read the CSV file line by line
while IFS=';' read -r username groups; do
  # Trim white spaces from the username and groups
  username=$(trim "$username")
  groups=$(trim "$groups")

  # Split the groups field into an array, ignoring white spaces
  IFS=',' read -r -a group_array <<< "$(echo "$groups" | tr -d '[:space:]')"

  # Create each group if it doesn't exist
  for group in "${group_array[@]}"; do
    group=$(trim "$group")
    if ! getent group "$group" > /dev/null 2>&1; then
      echo "$(date '+%Y-%m-%d %H:%M:%S'): Creating group: $group" | sudo tee -a "$LOG_FILE"
      sudo groupadd "$group"
    else
      echo "$(date '+%Y-%m-%d %H:%M:%S'): Group $group already exists." | sudo tee -a "$LOG_FILE"
    fi
  done

  # Check if the user exists, if not, create it and add to all groups
  if ! id "$username" > /dev/null 2>&1; then
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Creating user: $username" | sudo tee -a "$LOG_FILE"
    sudo useradd -m "$username"

    # Set a random password for the user
    password=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)
    echo "$username:$password" | sudo chpasswd

    echo "$(date '+%Y-%m-%d %H:%M:%S'): Password for $username set and stored securely." | sudo tee -a "$LOG_FILE"
    echo "$username,$password" | sudo tee -a "/var/secure/user_passwords.txt"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S'): User $username already exists." | sudo tee -a "$LOG_FILE"
  fi

  # Add the user to each group (if the user was already created)
  for group in "${group_array[@]}"; do
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Adding user $username to group: $group" | sudo tee -a "$LOG_FILE"
    sudo usermod -a -G "$group" "$username"
  done

done < "$CSV_FILE"

echo "All users and groups have been processed."

