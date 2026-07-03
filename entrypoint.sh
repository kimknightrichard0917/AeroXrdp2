#!/bin/bash

# Configuration: Change these or set as Environment Variables in Railway
USER_NAME=${USER_NAME:-"admin"}
USER_PASSWORD=${USER_PASSWORD:-"railway123"}

# 1. Create User
if ! id "$USER_NAME" &>/dev/null; then
    useradd -m -s /bin/bash "$USER_NAME"
    echo "$USER_NAME:$USER_PASSWORD" | chpasswd
    echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
fi

# 2. Fix Railway Shared Memory & Cleanup
rm -rf /var/run/xrdp/*
mkdir -p /var/run/xrdp
chown xrdp:xrdp /var/run/xrdp

# 3. Optimization: Disable XFCE heavy graphics for the user
sudo -u "$USER_NAME" mkdir -p /home/"$USER_NAME"/.config/xfce4/xfconf/xfce-perchannel-xml
cat <<EOF > /home/"$USER_NAME"/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="use_compositing" type="bool" value="false"/>
  </property>
</channel>
EOF

# 4. Start Services
/usr/sbin/xrdp-sesman --nodaemon &
/usr/sbin/xrdp --nodaemon
