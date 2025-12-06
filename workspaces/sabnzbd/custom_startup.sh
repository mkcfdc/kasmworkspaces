#!/bin/bash
set -e

# Setup Config Directory
mkdir -p $HOME/.config/sabnzbd

# --- Auto-Config Logic ---
if [ ! -f "$HOME/.config/sabnzbd/sabnzbd.ini" ]; then
    echo "No config found. Applying template..."
    cp /etc/sabnzbd_template.ini $HOME/.config/sabnzbd/sabnzbd.ini

    if [ -f "/tmp/launch_selections.json" ]; then
        echo "Found launch config, reading secrets..."
        
        # Extract variables using jq (Use // empty to avoid nulls)
        SAB_HOST=$(jq -r '.sab_host // empty' /tmp/launch_selections.json)
        SAB_USER=$(jq -r '.sab_user // empty' /tmp/launch_selections.json)
        SAB_PASS=$(jq -r '.sab_password // empty' /tmp/launch_selections.json)

        # Inject Host
        if [ ! -z "$SAB_HOST" ]; then
            sed -i "s/__SERVER_HOST__/$SAB_HOST/g" $HOME/.config/sabnzbd/sabnzbd.ini
        fi

        # Inject User
        if [ ! -z "$SAB_USER" ]; then
            sed -i "s/__SERVER_USER__/$SAB_USER/g" $HOME/.config/sabnzbd/sabnzbd.ini
        fi

        # Inject Password
        if [ ! -z "$SAB_PASS" ]; then
            sed -i "s/__SERVER_PASSWORD__/$SAB_PASS/g" $HOME/.config/sabnzbd/sabnzbd.ini
        fi
    fi
fi
# -------------------------

# Start Sabnzbd
/usr/bin/sabnzbdplus --daemon --browser 0 --server 127.0.0.1:8080 --config-file $HOME/.config/sabnzbd &

sleep 5

# Launch Brave
/usr/bin/brave-browser --no-sandbox --start-maximized --disable-gpu --app=http://127.0.0.1:8080
