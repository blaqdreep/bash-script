Automating User and Group Management on Ubuntu: A Practical Guide
Introduction
A Bash script is a file containing a sequence of commands executed on a Bash shell, enabling automation of tasks. This article demonstrates how to use a Bash script to dynamically create users and groups by reading from a CSV file. A CSV (Comma Separated Values) file contains data separated by commas or other delimiters, and is often used for data exchange.

In Linux systems, multiple users can access the same machine, making efficient user and group management crucial for system administrators. This guide shows how to automate these tasks using a Bash script, ensuring users are created, assigned to specified groups, and their actions logged securely.

Objective
The main objective is to create users in a Linux system using a simple Bash script, assigning them to groups, and generating random passwords.

Bash Script Overview
The script reads user and group information from a CSV file, creates groups if they don't exist, creates users if they are new, assigns users to groups, and logs all actions for traceability.

Prerequisites
Ubuntu machine for execution.
Basic understanding of Bash scripting.
Script Implementation
Step 1: Reading the CSV File
The script begins by reading a CSV file containing usernames and associated groups. The script throws an error and exits if no input is provided.

```bash
CSV_FILE="$1"

# Check if the file exists
if [[ ! -f "$CSV_FILE" ]]; then
    echo "File not found!"
    exit 1
fi 
```
Step 2: Creating a Directory and File to Store Users
After reading the file, we create a directory and file to store the usernames and passwords of any new users created, accessible only to the file owner.

```bash
PASSWD_DIR="/var/secure"
PASSWD_FILE="user_passwords.csv"

if [ ! -d "$PASSWD_DIR" ]; then
    sudo mkdir -p "$PASSWD_DIR"
    sudo touch "$PASSWD_DIR/$PASSWD_FILE"
    sudo chmod 600 "$PASSWD_DIR/$PASSWD_FILE"
fi
```
Step 3: Group Management
For each group specified, the script checks if the group exists and creates it if it doesn't.

```bash
# Function to trim white spaces
trim() {
  echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

# Ensure log file exists and is writable
LOG_FILE="/var/log/user_management.log"
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
  ```
Step 4: User Management
For each user specified, the script checks if the user exists, creates the user if they don't, assigns a random password, and logs the actions.

```bash
# Check if the user exists, if not, create it and add to all groups
  if ! id "$username" > /dev/null 2>&1; then
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Creating user: $username" | sudo tee -a "$LOG_FILE"
    sudo useradd -m "$username"

    # Set a random password for the user
    password=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12)
    echo "$username:$password" | sudo chpasswd

    echo "$(date '+%Y-%m-%d %H:%M:%S'): Password for $username set and stored securely." | sudo tee -a "$LOG_FILE"
    echo "$username,$password" | sudo tee -a "$PASSWD_DIR/$PASSWD_FILE"
  else
    echo "$(date '+%Y-%m-%d %H:%M:%S'): User $username already exists." | sudo tee -a "$LOG_FILE"
  fi 
  ```
Step 5: Adding Users to Groups
Users are added to specified groups using sudo usermod, ensuring they have appropriate access permissions.

```bash
  # Add the user to each group (if the user was already created)
  for group in "${group_array[@]}"; do
    echo "$(date '+%Y-%m-%d %H:%M:%S'): Adding user $username to group: $group" | sudo tee -a "$LOG_FILE"
    sudo usermod -a -G "$group" "$username"
  done

done < "$CSV_FILE"

echo "All users and groups have been processed."
```

Running the Script
To run the script, follow these steps:

Ensure you are running on a Linux system with root privileges or use the sudo command.
Save the script to a file, for example, user_management.sh.
Create a sample CSV file users.csv with the following content:

```bash
mary;developer,sys-admin
paul;sys-admin
peter;operations
```
Execute the script as shown below (add sudo if you are not a root user):
```bash
sudo bash user_management.sh users.csv
```
After running the script, new users will be created, and their details will be stored in /var/secure/user_passwords.csv. All actions will be logged in /var/log/user_management.log.

Conclusion
Automating user and group management using this script enhances system administration efficiency and ensures consistent user access across environments. By adhering to best practices in logging and security, administrators can maintain robust system integrity.

Learn More
To learn more about opportunities like the HNG Internship program and related resources for enhancing your skills, visit: [HNG Internship](https://hng.tech/internship)


