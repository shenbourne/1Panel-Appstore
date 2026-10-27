#!/usr/bin/env bash
set -euo pipefail

# 自定义 1Panel 安装位置时修改此路径。
export LOCAL_APPS_DIR="/opt/1panel/resource/apps/local"
# 可替换为其他加速地址；留空则直连。
export DOWNLOAD_PROXY="https://ghfast.top/"

script_url="${DOWNLOAD_PROXY:+${DOWNLOAD_PROXY%/}/}https://github.com/shenbourne/1Panel-Appstore/raw/refs/heads/main/scripts/download.sh"
script="$(curl -fsSL --connect-timeout 20 --max-time 180 "$script_url")"
test -n "$script"
bash -n <<< "$script"
bash -c "$script"
