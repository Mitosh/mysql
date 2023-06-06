#!/bin/bash

# Source MySQL server details
source_host="192.168.1.172"
admin_user="admin"
read -s -p "Enter the password for the admin user: " admin_password
echo

# Target MySQL server details
target_host="192.168.1.67"
admin_user="admin"
read -s -p "Enter the password for the admin user: " admin_password
echo

# Prompt for "repl" user password
read -s -p "Enter the password for the 'repl' user: " repl_password
echo

# Check if repl user exists, create if not
mysql -h $source_host -u $admin_user -p$admin_password -e "SELECT 1" 2>/dev/null
if [ $? -ne 0 ]; then
    mysql -h $source_host -u $admin_user -p$admin_password -e "CREATE USER 'repl'@'%' IDENTIFIED WITH mysql_native_password BY '$repl_password'; GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%'; FLUSH PRIVILEGES;"
fi

# Check if target user exists, create if not
mysql -h $target_host -u $admin_user -p$admin_password -e "SELECT 1" 2>/dev/null
if [ $? -ne 0 ]; then
    mysql -h $target_host -u $admin_user -p$admin_password -e "CREATE USER 'repl'@'%' IDENTIFIED WITH mysql_native_password BY '$repl_password'; GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%'; FLUSH PRIVILEGES;"
fi

# Retrieve source server's binary log file and position'
source_log_file=$(mysql -h $source_host -u $admin_user -p$admin_password -e "SHOW MASTER STATUS\G" | awk '/File:/ {print $2}')
source_log_pos=$(mysql -h $source_host -u $admin_user -p$admin_password -e "SHOW MASTER STATUS\G" | awk '/Position:/ {print $2}')

# Stop replication on the target server
mysql -h $target_host -u $admin_user -p$admin_password -e "STOP SLAVE;"

# Configure replication on the target server
mysql -h $target_host -u $admin_user -p$admin_password -e "CHANGE MASTER TO MASTER_HOST='$source_host', MASTER_USER='repl', MASTER_PASSWORD='$repl_password', MASTER_LOG_FILE='$source_log_file', MASTER_LOG_POS=$source_log_pos;"

# Start replication on the target server
mysql -h $target_host -u $admin_user -p$admin_password -e "START SLAVE;"

# Check replication status on the target server
mysql -h $target_host -u $admin_user -p$admin_password -e "SHOW SLAVE STATUS\G"
