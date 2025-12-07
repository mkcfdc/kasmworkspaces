#!/usr/bin/env bash
set -ex

apt-get update
apt-get install -y software-properties-common wget gnupg2

# Install Brave
wget -qO - https://brave-browser-apt-release.s3.brave.com/brave-core.asc | apt-key add -
echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" > /etc/apt/sources.list.d/brave.list
apt-get update
apt-get install -y brave-browser

# Install SABnzbd and jq
add-apt-repository -y ppa:jcfp/nobetas
apt-get update
apt-get install -y sabnzbdplus jq

# Config directory for default profile
mkdir -p $HOME/.sabnzbd

# Copy sabnzbd.ini if present
if [ -f /dockerstartup/install/sabnzbd/sabnzbd.ini ]; then
    cp /dockerstartup/install/sabnzbd/sabnzbd.ini $HOME/.sabnzbd/sabnzbd.ini
fi

# Create a desktop launcher for reference
cat <<EOF > /usr/share/applications/sabnzbd.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=SABnzbd
Exec=/usr/bin/sabnzbdplus --browser 0
Icon=sabnzbd
Terminal=false
Categories=Network;
EOF

cp /usr/share/applications/sabnzbd.desktop $HOME/Desktop/
chmod +x $HOME/Desktop/sabnzbd.desktop

# Fix permissions
chown -R 1000:0 $HOME

# Cleanup
if [ -z ${SKIP_CLEAN+x} ]; then
    apt-get autoclean
    rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
fi
