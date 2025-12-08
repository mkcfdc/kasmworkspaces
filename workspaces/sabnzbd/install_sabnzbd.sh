#!/usr/bin/env bash
set -ex

apt-get update
apt-get install -y sabnzbdplus jq openssl python3 python3-pip

# Install webDav for easy streaming
pip3 install wsgidav

mkdir -p $HOME/.sabnzbd

# Copy default config if it exists
if [ -f /dockerstartup/install/sabnzbd/sabnzbd.ini ]; then
    cp /dockerstartup/install/sabnzbd/sabnzbd.ini $HOME/.sabnzbd/sabnzbd.ini
fi

cp /usr/share/applications/sabnzbd.desktop $HOME/Desktop/
chmod +x $HOME/Desktop/sabnzbd.desktop

chown -R 1000:0 $HOME