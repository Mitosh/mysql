

#!/bin/bash


# Define MySQL root credentials
root_user="root"
read -s -p "Enter MySQL root password: " root_password
echo

# Define the configuration file path
config_file="/etc/mysql/mysql.conf.d/mysqld.cnf"

# Define the sed commands with variables
sed_commands=(
  's/^# port.*/port            = 3306/'
  's/^bind-address.*/bind-address            = 0.0.0.0/'
  's/^mysqlx-bind-address.*/mysqlx-bind-address            = 0.0.0.0/'
  's/^# server-id.*/server-id               = 1/'
  's/^# log_bin.*/log_bin                 = \/var\/log\/mysql\/mysql-bin.log/'
)

# Loop through the sed commands and build the sed command string
sed_command=""
for command in "${sed_commands[@]}"; do
  sed_command+=" -e '${command}'"
done

# Use eval to execute the sed command with sudo
eval "sudo sed -i${sed_command} ${config_file}"


# Create admin user in the system
sudo adduser admin
sudo passwd admin
sudo usermod -aG sudo admin
sudo mkdir /home/admin
sudo chown admin:admin /home/admin

# Create admin user in the mysql
admin_user="admin"
read -s -p "Enter password for the admin user: " admin_password
echo

# Create the admin user and grant privileges
sudo mysql -u $root_user -p $root_password <<EOF
CREATE USER '$admin_user'@'%' IDENTIFIED BY '$admin_password';
GRANT ALL PRIVILEGES ON *.* TO '$admin_user'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

echo "Admin user '$admin_user' created with remote access."

# Restart MySQL service
sudo service mysql restart

echo "MySQL service restarted."
