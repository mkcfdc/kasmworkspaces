#!/usr/bin/env bash
set -ex

START_COMMAND="/usr/bin/sabnzbdplus --config-file /home/kasm-user/.sabnzbd/sabnzbd.ini --browser 0"
PGREP="sabnzbdplus"
INI_PATH="/home/kasm-user/.sabnzbd/sabnzbd.ini"
LAUNCH_CONF="/tmp/launch_selections.json"

DEFAULT_ARGS=""
ARGS=${APP_ARGS:-$DEFAULT_ARGS}

process_launch_config() {
    if [ ! -f "$LAUNCH_CONF" ]; then
        echo "No launch selections file found."
        return
    fi

    sab_host=$(jq -r '.sab_host // empty' "$LAUNCH_CONF")
    sab_user=$(jq -r '.sab_user // empty' "$LAUNCH_CONF")
    sab_password=$(jq -r '.sab_password // empty' "$LAUNCH_CONF")

    # Only patch if values exist
    if [ -n "$sab_host" ]; then
        sed -i "s|__SERVER_HOST__|$sab_host|g" "$INI_PATH"
    fi
    if [ -n "$sab_user" ]; then
        sed -i "s|__SERVER_USER__|$sab_user|g" "$INI_PATH"
    fi
    if [ -n "$sab_password" ]; then
        sed -i "s|__SERVER_PASSWORD__|$sab_password|g" "$INI_PATH"
    fi

    # Generate SAB-specific keys if still placeholders
    if grep -q "__API_KEY__" "$INI_PATH"; then
        sed -i "s|__API_KEY__|$(uuidgen)|g" "$INI_PATH"
    fi
    if grep -q "__NZB_KEY__" "$INI_PATH"; then
        sed -i "s|__NZB_KEY__|$(uuidgen)|g" "$INI_PATH"
    fi
}

kasm_startup() {
    # Patch config file before startup
    process_launch_config

    echo "Starting SABnzbd loop"
    set +x
    while true; do
        if ! pgrep -x "$PGREP" >/dev/null; then
            /usr/bin/filter_ready
            /usr/bin/desktop_ready
            $START_COMMAND $ARGS
        fi
        sleep 1
    done
    set -x
}

kasm_exec() {
    process_launch_config
    /usr/bin/filter_ready
    /usr/bin/desktop_ready
    $START_COMMAND $ARGS
}

# Same parameter parsing as other Kasm images
options=$(getopt -o ga -l go,assign -n "$0" -- "$@") || exit
eval set -- "$options"
while [[ $1 != -- ]]; do
    case $1 in
        -g|--go) GO='true'; shift;;
        -a|--assign) ASSIGN='true'; shift;;
    esac
done
shift

if [[ -n "$GO" || -n "$ASSIGN" ]]; then
    kasm_exec
else
    kasm_startup
fi
