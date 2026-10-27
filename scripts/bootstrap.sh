#!/usr/bin/env bash
set -euo pipefail

# 1Panel 安装在其他位置时，修改下行冒号后的默认路径。
export LOCAL_APPS_DIR="${LOCAL_APPS_DIR:-/opt/1panel/resource/apps/local}"

# 默认直连；需要加速时，将下行改为 export DOWNLOAD_PROXY="https://ghfast.top/"
export DOWNLOAD_PROXY="${DOWNLOAD_PROXY:-}"

url="https://github.com/shenbourne/1Panel-Appstore/raw/refs/heads/main/scripts/install.sh"
if [[ -n "$DOWNLOAD_PROXY" ]]; then
  [[ "$DOWNLOAD_PROXY" = https://* ]] || { echo "DOWNLOAD_PROXY must use HTTPS" >&2; exit 1; }
  url="${DOWNLOAD_PROXY%/}/$url"
fi

script="$(mktemp)"
trap 'rm -f -- "$script"' EXIT

curl --fail --location --http1.1 --retry 2 --retry-all-errors --retry-delay 2 \
  --connect-timeout 20 --max-time 180 --proto '=https' --proto-redir '=https' --output "$script" "$url"

test -s "$script"
bash -n "$script"
bash "$script"
