#!/usr/bin/env bash
set -ex

INI_PATH="/home/kasm-user/.sabnzbd/sabnzbd.ini"

# Patch launch config if present
LAUNCH_CONF="/tmp/launch_selections.json"

if [ -f "$LAUNCH_CONF" ]; then
  sab_host=$(jq -r '.sab_host // empty' "$LAUNCH_CONF")
  sab_user=$(jq -r '.sab_user // empty' "$LAUNCH_CONF")
  sab_password=$(jq -r '.sab_password // empty' "$LAUNCH_CONF")

  if [ -n "$sab_host" ]; then
    sed -i "s|__SERVER_HOST__|$sab_host|g" "$INI_PATH"
  fi

  if [ -n "$sab_user" ]; then
    sed -i "s|__SERVER_USER__|$sab_user|g" "$INI_PATH"
  fi

  if [ -n "$sab_password" ]; then
    sed -i "s|__SERVER_PASSWORD__|$sab_password|g" "$INI_PATH"
  fi

  if grep -q "__API_KEY__" "$INI_PATH"; then
    API_KEY=$(openssl rand -hex 32)
    sed -i "s|__API_KEY__|$API_KEY|g" "$INI_PATH"
  fi

  if grep -q "__NZB_KEY__" "$INI_PATH"; then
    NZB_KEY=$(openssl rand -hex 32)
    sed -i "s|__NZB_KEY__|$NZB_KEY|g" "$INI_PATH"
  fi
fi

/usr/bin/filter_ready
/usr/bin/desktop_ready

# Start SABnzbd in background
/usr/bin/sabnzbdplus --config-file "$INI_PATH" --browser 0 &

sleep 5 # let SABnzbd start

# Launch Brave in app mode pointing to SABnzbd
exec brave-browser --start-maximized http://127.0.0.1:8080