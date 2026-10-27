#!/usr/bin/env bash
set -Eeuo pipefail
umask 022

REPO_URL="${REPO_URL:-https://github.com/shenbourne/1Panel-Appstore.git}"
BRANCH="${BRANCH:-main}"
LOCAL_APPS_DIR="${LOCAL_APPS_DIR:-/opt/1panel/resource/apps/local}"
STATE_DIR="${STATE_DIR:-/opt/1panel-third-party/shenbourne}"
SOURCE_DIR="${SOURCE_DIR:-}"

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }
for tool in flock cp mkdir mktemp realpath diff find date; do
    command -v "$tool" >/dev/null || die "Missing dependency: $tool"
done
[[ "$LOCAL_APPS_DIR" = /* && "$STATE_DIR" = /* ]] || die "Use absolute paths"
mkdir -p "$LOCAL_APPS_DIR" "$STATE_DIR"
LOCAL_APPS_DIR="$(realpath "$LOCAL_APPS_DIR")"
STATE_DIR="$(realpath "$STATE_DIR")"
[[ "$LOCAL_APPS_DIR" != / && "$STATE_DIR" != / ]] || die "Refusing filesystem root"
case "$STATE_DIR/" in "$LOCAL_APPS_DIR/"*) die "STATE_DIR must be outside LOCAL_APPS_DIR";; esac
exec 9>"$STATE_DIR/sync.lock"
flock -n 9 || die "Another sync is running"

if [[ -z "$SOURCE_DIR" ]]; then
    command -v git >/dev/null || die "Missing dependency: git (or set SOURCE_DIR)"
    if [[ ! -d "$STATE_DIR/repository/.git" ]]; then
        git clone --depth 1 --branch "$BRANCH" -- "$REPO_URL" "$STATE_DIR/repository"
    else
        [[ "$(git -C "$STATE_DIR/repository" remote get-url origin)" = "$REPO_URL" ]] ||
            die "Cached repository origin differs from REPO_URL"
        git -C "$STATE_DIR/repository" fetch --depth 1 origin "$BRANCH"
        git -C "$STATE_DIR/repository" checkout --detach FETCH_HEAD
    fi
    SOURCE_DIR="$STATE_DIR/repository"
fi
SOURCE_DIR="$(realpath "$SOURCE_DIR")"
[[ -f "$SOURCE_DIR/apps.txt" ]] || die "Missing apps.txt"
APP_SOURCE="$SOURCE_DIR/apps"
[[ -d "$APP_SOURCE" && ! -L "$APP_SOURCE" ]] || die "Missing or linked apps directory"
apps=()
while IFS= read -r app || [[ -n "$app" ]]; do
    [[ -z "$app" || "$app" = \#* ]] && continue
    [[ "$app" =~ ^[a-z0-9][a-z0-9-]*$ ]] || die "Invalid app key: $app"
    [[ -d "$APP_SOURCE/$app" && ! -L "$APP_SOURCE/$app" ]] || die "Invalid source: $app"
    [[ ! -L "$LOCAL_APPS_DIR/$app" ]] || die "Target is a symlink: $app"
    [[ ! -e "$LOCAL_APPS_DIR/$app" || -d "$LOCAL_APPS_DIR/$app" ]] || die "Target is not a directory: $app"
    for required in data.yml logo.png README.md; do
        [[ -f "$APP_SOURCE/$app/$required" ]] || die "Missing $app/$required"
    done
    # Templates must not link to files outside the downloaded repository.
    [[ -z "$(find "$APP_SOURCE/$app" -type l -print -quit)" ]] || die "Source contains symlinks: $app"
    found_version=false
    for version in "$APP_SOURCE/$app"/*/; do
        [[ -d "$version" ]] || continue
        [[ -f "${version}data.yml" && -f "${version}docker-compose.yml" ]] ||
            die "Incomplete version: $version"
        found_version=true
    done
    "$found_version" || die "No versions: $app"
    apps+=("$app")
done < "$SOURCE_DIR/apps.txt"
[[ ${#apps[@]} -gt 0 ]] || die "Empty catalog"
backup=""
for app in "${apps[@]}"; do
    if [[ -d "$LOCAL_APPS_DIR/$app" ]] && diff -qr "$APP_SOURCE/$app" "$LOCAL_APPS_DIR/$app" >/dev/null; then
        printf 'Unchanged: %s\n' "$app"
        continue
    fi
    if [[ -e "$LOCAL_APPS_DIR/$app" ]]; then
        if [[ -z "$backup" ]]; then
            mkdir -p "$STATE_DIR/backups"
            backup="$(mktemp -d "$STATE_DIR/backups/$(date +%Y%m%d-%H%M%S)-XXXXXX")"
        fi
        cp -a -- "$LOCAL_APPS_DIR/$app" "$backup/$app"
    fi
    # Merge template files; never delete other stores or installed application data.
    mkdir -p "$LOCAL_APPS_DIR/$app"
    cp -a -- "$APP_SOURCE/$app/." "$LOCAL_APPS_DIR/$app/"
    printf 'Synced: %s\n' "$app"
done
[[ -z "$backup" ]] || printf 'Backup: %s\n' "$backup"
printf 'Templates ready: %s\nRefresh local apps in the 1Panel app store.\n' "$LOCAL_APPS_DIR"
