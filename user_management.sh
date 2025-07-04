#!/bin/bash

LOGFILE="/var/log/user_management.log"

log_action() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1 by $(whoami)" >> "$LOGFILE"
}

if [ "$EUID" -ne 0 ]; then
  echo "⚠️ Please run as root"
  exit 1
fi

add_user() {
  read -p "Enter username to add: " username
  if id "$username" &>/dev/null; then
    echo "❌ User '$username' already exists."
  else
    useradd "$username"
    passwd "$username"
    echo "✅ User '$username' added."
    log_action "User '$username' added"
  fi
}

delete_user() {
  read -p "Enter username to delete: " username
  if id "$username" &>/dev/null; then
    userdel -r "$username"
    echo "✅ User '$username' deleted."
    log_action "User '$username' deleted"
  else
    echo "❌ User '$username' does not exist."
  fi
}

lock_user() {
  read -p "Enter username to lock: " username
  passwd -l "$username" && echo "🔒 User '$username' locked."
  log_action "User '$username' locked"
}

unlock_user() {
  read -p "Enter username to unlock: " username
  passwd -u "$username" && echo "🔓 User '$username' unlocked."
  log_action "User '$username' unlocked"
}

list_users() {
  echo "👤 Current non-system users:"
  awk -F: '$3 >= 1000 && $1 != "nobody" { print $1 }' /etc/passwd
  log_action "Listed users"
}

while true; do
  echo ""
  echo "=============================="
  echo "  🧑‍💻 User Management Menu"
  echo "=============================="
  echo "1. Add User"
  echo "2. Delete User"
  echo "3. Lock User"
  echo "4. Unlock User"
  echo "5. List Users"
  echo "6. Exit"
  echo "=============================="
  read -p "Choose an option [1-6]: " choice

  case "$choice" in
    1) add_user ;;
    2) delete_user ;;
    3) lock_user ;;
    4) unlock_user ;;
    5) list_users ;;
    6) echo "Exiting..."; break ;;
    *) echo "❌ Invalid option." ;;
  esac
done

