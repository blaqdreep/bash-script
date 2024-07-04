Automating User and Group Management on Ubuntu: A Practical Guide
Introduction
Managing user accounts and group assignments efficiently is crucial for system administrators. In this article, we'll explore how to automate these tasks using a Bash script on Ubuntu. This script ensures users are created, assigned to specified groups, and their actions logged securely.

Script Overview
The provided Bash script reads user and group information from a text file, creates groups if they don't exist, creates users if they are new, assigns users to groups, and logs all actions for traceability.

Prerequisites
Ensure you have the following set up:

Ubuntu machine for execution.
Basic understanding of Bash scripting.
Script Implementation
Step 1: Reading text File
The script begins by reading a text file containing usernames and associated groups. Each line is parsed to extract usernames and group memberships.

Step 2: Group Management
For each group specified:

Checks if the group exists using getent group.
Creates the group if it doesn't exist using sudo groupadd.
Step 3: User Management
For each user specified:

Checks if the user exists using id.
Creates the user if they don't exist using sudo useradd.
Sets a random password securely using /dev/urandom and sudo chpasswd.
Logs user creation and password securely.
Step 4: Adding Users to Groups
Users are added to specified groups using sudo usermod, ensuring they have appropriate access permissions.

Step 5: Logging
All actions are logged to /var/log/user_management.log for audit purposes, including group creation, user creation and password setting.

Step 6: Secure Password Storage
Passwords are stored securely in /var/secure/user_passwords.txt, accessible only to the file owner (root), ensuring sensitive information remains protected.

you can find the bash script for the automation in https://github.com/blaqdreep/bash-script.git 

Conclusion
Automating user and group management using this script enhances system administration efficiency and ensures consistent user access across environments. By adhering to best practices in logging and security, administrators can maintain robust system integrity.

Learn More
To learn more about opportunities like the HNG Internship program and related resources for enhancing your skills, visit: https://hng.tech/internship 
