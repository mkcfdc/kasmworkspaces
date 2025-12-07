#!/usr/bin/env bash
set -ex

apt-get update
apt-get install -y software-properties-common
add-apt-repository -y ppa:jcfp/nobetas
apt-get update

# Install SABnzbd and themes
apt-get install -y \
    jq \
    sabnzbdplus \
    sabnzbdplus-theme-classic \
    sabnzbdplus-theme-mobile

# Config directory for default profile (before switch to kasm-user)
mkdir -p $HOME/.sabnzbd

# Copy your sabnzbd.ini if present
if [ -f /dockerstartup/install/sabnzbd/sabnzbd.ini ]; then
    cp /dockerstartup/install/sabnzbd/sabnzbd.ini \
       $HOME/.sabnzbd/sabnzbd.ini
fi

# Create a simple desktop launcher
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

# Cleanup
chown -R 1000:0 $HOME

if [ -z ${SKIP_CLEAN+x} ]; then
  apt-get autoclean
  rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/*
fi
