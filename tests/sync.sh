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
cmp "$root/apps/magpie/data.yml" "$LOCAL_APPS_DIR/magpie/data.yml"
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

# Exercise the downloader without network access by replacing curl with a fixture.
mkdir -p "$scratch/archive/1panel-appstore-main" "$scratch/bin"
cp -a "$root/apps" "$root/scripts" "$root/apps.txt" "$root/data.yaml" "$scratch/archive/1panel-appstore-main/"
tar -czf "$scratch/catalog.tar.gz" -C "$scratch/archive" 1panel-appstore-main
cat > "$scratch/bin/curl" <<'SH'
#!/usr/bin/env bash
set -e
while [[ $# -gt 0 ]]; do
    if [[ "$1" = --output ]]; then
        cp "$TEST_ARCHIVE" "$2"
        exit
    fi
    shift
done
exit 1
SH
chmod +x "$scratch/bin/curl"
PATH="$scratch/bin:$PATH" TEST_ARCHIVE="$scratch/catalog.tar.gz" \
    STORE_DIR="$scratch/installer-state" LOCAL_APPS_DIR="$scratch/installer-local" \
    bash "$root/scripts/install.sh"
cmp "$root/apps/magpie/data.yml" "$scratch/installer-local/magpie/data.yml"

# A failed bootstrap transfer must retry; total failure must never execute a script.
cat > "$scratch/bin/curl" <<'SH'
#!/usr/bin/env bash
set -e
count=0
[[ ! -f "$TEST_COUNT" ]] || count="$(cat "$TEST_COUNT")"
count=$((count + 1))
echo "$count" > "$TEST_COUNT"
[[ "${TEST_FAIL_ALL:-}" != 1 && "$count" -gt 1 ]] || exit 56
while [[ $# -gt 0 ]]; do
    if [[ "$1" = --output ]]; then
        printf '#!/usr/bin/env bash\nprintf ok > "$TEST_MARKER"\n' > "$2"
        exit
    fi
    shift
done
exit 1
SH
printf '#!/usr/bin/env bash\nexit 0\n' > "$scratch/bin/sleep"
chmod +x "$scratch/bin/sleep"
PATH="$scratch/bin:$PATH" TEST_COUNT="$scratch/count" TEST_MARKER="$scratch/marker" \
    bash "$root/scripts/bootstrap.sh"
test "$(cat "$scratch/count")" -eq 2
test "$(cat "$scratch/marker")" = ok
if PATH="$scratch/bin:$PATH" TEST_COUNT="$scratch/fail-count" TEST_MARKER="$scratch/must-not-run" \
    TEST_FAIL_ALL=1 bash "$root/scripts/bootstrap.sh"; then
    echo "Bootstrap incorrectly accepted a failed download" >&2
    exit 1
fi
test ! -e "$scratch/must-not-run"
test "$(cat "$scratch/fail-count")" -eq 6
echo "PASS: bootstrap retry/failure, archive download, sync, backup and preservation"
