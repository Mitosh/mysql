
#!/bin/bash

# Create admin user
sudo adduser admin

# Set password for the user
sudo passwd admin <<EOF
rty
rty
EOF

# Grant sudo privileges
sudo usermod -aG sudo admin

# Enable SSH access (optional)
#sudo systemctl enable ssh

# Create home directory
sudo mkdir /home/admin
sudo chown admin:admin /home/admin
