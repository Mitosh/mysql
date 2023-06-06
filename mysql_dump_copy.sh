#!/bin/bash

# Source MySQL database details
source_host="192.168.1.172"
source_user="admin"
read -s -p "Enter the password for the source user: " source_password
echo

# Target server details
target_host="192.168.1.67"
target_user="admin"
read -s -p "Enter the password for the target user: " target_password
echo

# Dump all databases
dump_filename="database_dump.sql"
dump_command="mysqldump -h $source_host -u $source_user -p'$source_password' --all-databases > $dump_filename"
eval "$dump_command"

# Transfer the dump file to the target server
transfer_command="scp $dump_filename $target_user@$target_host:~"
eval "$transfer_command"

# Get the list of database names from the dump file
database_names=$(grep "CREATE DATABASE" $dump_filename | awk -F'`' '{print $2}')

# Import each database on the target server
for database_name in $database_names; do
    # Create the target database if it doesn't exist'
    create_database_command="mysql -h $target_host -u $target_user -p'$target_password' -e 'CREATE DATABASE IF NOT EXISTS $database_name;'"
    eval "$create_database_command"

    # Import the dump file for the current database
    import_command="mysql -h $target_host -u $target_user -p'$target_password' $database_name < $dump_filename"
    eval "$import_command"
done

# Clean up the dump file
cleanup_command="rm $dump_filename"
eval "$cleanup_command"

echo "Database transfer and import completed successfully!"
