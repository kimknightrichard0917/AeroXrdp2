#!/bin/bash

# Set Root Password
echo "root:root" | chpasswd

# 1. Fix Permissions & Shared Memory
rm -rf /var/run/xrdp/*
mkdir -p /var/run/xrdp
chown xrdp:xrdp /var/run/xrdp

# 2. Create Desktop Shortcuts for Browsers in Root folder
mkdir -p /root/Desktop

# Firefox Shortcut
cat <<EOF > /root/Desktop/firefox.desktop
[Desktop Entry]
Name=Firefox
Exec=firefox-esr
Icon=firefox-esr
Type=Application
EOF

# Chrome Shortcut
cat <<EOF > /root/Desktop/chrome.desktop
[Desktop Entry]
Name=Chrome
Exec=/usr/local/bin/chrome
Icon=chromium
Type=Application
EOF

chmod +x /root/Desktop/*.desktop

# 3. Optimization: Disable XFCE heavy graphics for Root
mkdir -p /root/.config/xfce4/xfconf/xfce-perchannel-xml
cat <<EOF > /root/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfwm4" version="1.0">
  <property name="general" type="empty">
    <property name="use_compositing" type="bool" value="false"/>
  </property>
</channel>
EOF

# 4. Start XRDP Services
/usr/sbin/xrdp-sesman --nodaemon &
/usr/sbin/xrdp --nodaemon
