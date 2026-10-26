#!/usr/bin/env bash
set -Eeuo pipefail
export STORE_DIR="${STORE_DIR:-/opt/1panel-third-party/shenbourne}"
export LOCAL_APPS_DIR="${LOCAL_APPS_DIR:-/opt/1panel/resource/apps/local}"
export DOWNLOAD_PROXY="${DOWNLOAD_PROXY:-}"

urls=(
  "https://raw.githubusercontent.com/shenbourne/1panel-appstore/main/scripts/install.sh"
  "https://github.com/shenbourne/1panel-appstore/raw/refs/heads/main/scripts/install.sh"
)
if [[ -n "$DOWNLOAD_PROXY" ]]; then
  [[ "$DOWNLOAD_PROXY" = https://* ]] || { echo "DOWNLOAD_PROXY must use HTTPS" >&2; exit 1; }
  urls=("${DOWNLOAD_PROXY%/}/${urls[1]}")
fi
script="$(mktemp)"
trap 'rm -f -- "$script"' EXIT
for url in "${urls[@]}"; do
  for attempt in 1 2 3; do
    if curl --fail --location --http1.1 --connect-timeout 20 --max-time 180 \
      --proto '=https' --proto-redir '=https' --output "$script" "$url" &&
      [[ -s "$script" ]] && bash -n "$script"; then
      bash "$script"
      exit 0
    fi
    echo "Bootstrap download failed (attempt $attempt/3)" >&2
    sleep 2
  done
done
echo "Cannot download installer. Check network or DOWNLOAD_PROXY; templates unchanged." >&2
exit 1
