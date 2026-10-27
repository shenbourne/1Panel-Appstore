#!/usr/bin/env bash
set -Eeuo pipefail
umask 022
STORE_DIR="${STORE_DIR:-/opt/1panel-third-party/shenbourne}"
LOCAL_APPS_DIR="${LOCAL_APPS_DIR:-/opt/1panel/resource/apps/local}"
# Optional prefix, for example https://ghfast.top/ (third-party service).
DOWNLOAD_PROXY="${DOWNLOAD_PROXY:-}"
for tool in curl tar flock mktemp realpath mkdir rm sleep grep; do
    command -v "$tool" >/dev/null || { echo "Missing dependency: $tool" >&2; exit 1; }
done
[[ "$STORE_DIR" = /* && "$LOCAL_APPS_DIR" = /* ]] || { echo "Use absolute paths" >&2; exit 1; }
mkdir -p "$STORE_DIR"
STORE_DIR="$(realpath "$STORE_DIR")"
[[ "$STORE_DIR" != / ]] || { echo "Refusing filesystem root" >&2; exit 1; }
exec 8>"$STORE_DIR/download.lock"
flock -n 8 || { echo "Another download is running" >&2; exit 1; }
work="$(mktemp -d "$STORE_DIR/download-XXXXXXXX")"
trap 'rm -rf -- "$work"' EXIT
urls=(
    "https://codeload.github.com/shenbourne/1Panel-Appstore/tar.gz/refs/heads/main"
    "https://github.com/shenbourne/1Panel-Appstore/archive/refs/heads/main.tar.gz"
)
if [[ -n "$DOWNLOAD_PROXY" ]]; then
    [[ "$DOWNLOAD_PROXY" = https://* ]] || { echo "DOWNLOAD_PROXY must use HTTPS" >&2; exit 1; }
    urls=("${DOWNLOAD_PROXY%/}/${urls[1]}")
fi
downloaded=false
for url in "${urls[@]}"; do
    for attempt in 1 2 3; do
        echo "Downloading catalog (attempt $attempt/3)"
        if curl --fail --location --http1.1 --connect-timeout 20 --max-time 180 \
            --proto '=https' --proto-redir '=https' \
            --output "$work/catalog.tar.gz" "$url" &&
            tar -tzf "$work/catalog.tar.gz" > "$work/entries"; then
            downloaded=true
            break 2
        fi
        echo "Download failed; retrying or trying next endpoint" >&2
        sleep 2
    done
done
"$downloaded" || { echo "Download failed. Check connectivity or set DOWNLOAD_PROXY; templates unchanged." >&2; exit 1; }
# Only extract the expected GitHub archive root and regular files/directories.
if grep -Ev '^1Panel-Appstore-main(/|$)' "$work/entries" ||
    grep -Eq '(^|/)\.\.(/|$)' "$work/entries" ||
    tar -tvzf "$work/catalog.tar.gz" | grep -E '^[^d-]' > /dev/null; then
    echo "Unexpected archive entries; templates unchanged." >&2
    exit 1
fi
mkdir "$work/source"
tar -xzf "$work/catalog.tar.gz" --strip-components=1 --no-same-owner -C "$work/source"
[[ -f "$work/source/scripts/sync.sh" && -s "$work/source/apps.txt" && -d "$work/source/apps" ]] ||
    { echo "Incomplete archive; templates unchanged." >&2; exit 1; }
LOCAL_APPS_DIR="$LOCAL_APPS_DIR" STATE_DIR="$STORE_DIR" SOURCE_DIR="$work/source" \
    bash "$work/source/scripts/sync.sh"
