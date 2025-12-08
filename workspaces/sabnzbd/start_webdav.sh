#!/usr/bin/env bash
DL_DIR="/home/kasm-user/Downloads"

wsgidav \
  --host=0.0.0.0 \
  --port=8090 \
  --root="$DL_DIR" \
  --auth=anonymous \
  &
