#!/usr/bin/env bash
set -Eeuo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
scratch="$(mktemp -d)"
export LOCAL_APPS_DIR="$scratch/local"
export STATE_DIR="$scratch/state"
export SOURCE_DIR="$root"
mkdir -p "$LOCAL_APPS_DIR/magpie" "$LOCAL_APPS_DIR/other-store"
printf 'original\n' > "$LOCAL_APPS_DIR/magpie/custom.txt"
printf 'keep\n' > "$LOCAL_APPS_DIR/other-store/keep.txt"
bash "$root/scripts/sync.sh"
cmp "$root/magpie/data.yml" "$LOCAL_APPS_DIR/magpie/data.yml"
test "$(cat "$LOCAL_APPS_DIR/other-store/keep.txt")" = keep
test "$(cat "$LOCAL_APPS_DIR/magpie/custom.txt")" = original
test "$(find "$STATE_DIR/backups" -name custom.txt | wc -l)" -eq 1
# Check idempotence on a template without local extra files.
bash "$root/scripts/sync.sh" > "$scratch/second.log"
grep -q 'Unchanged: clash-meta' "$scratch/second.log"
export LOCAL_APPS_DIR="$scratch/rejected"
mkdir -p "$LOCAL_APPS_DIR"
ln -s "$scratch/local/magpie" "$LOCAL_APPS_DIR/magpie"
if bash "$root/scripts/sync.sh" > "$scratch/rejected.log" 2>&1; then
    echo "Symlink target was incorrectly accepted" >&2
    exit 1
fi
grep -q 'Target is a symlink' "$scratch/rejected.log"
test ! -e "$LOCAL_APPS_DIR/clash-meta"
echo "PASS: sync, backup, preservation, repeat execution and symlink rejection"
