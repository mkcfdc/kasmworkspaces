#!/usr/bin/env bash
set -ex

apt-get update
apt-get install -y sabnzbdplus jq openssl

mkdir -p $HOME/.sabnzbd

# Copy default config if it exists
if [ -f /dockerstartup/install/sabnzbd/sabnzbd.ini ]; then
    cp /dockerstartup/install/sabnzbd/sabnzbd.ini $HOME/.sabnzbd/sabnzbd.ini
fi

# Create desktop launcher (optional)
cat <<EOF > /usr/share/applications/sabnzbd.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=SABnzbd
Exec=exec brave-browser http://127.0.0.1:8080
Icon=sabnzbd
Terminal=false
Categories=Network;
EOF

cp /usr/share/applications/sabnzbd.desktop $HOME/Desktop/
chmod +x $HOME/Desktop/sabnzbd.desktop

chown -R 1000:0 $HOME