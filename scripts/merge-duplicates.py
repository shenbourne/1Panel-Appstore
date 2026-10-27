#!/usr/bin/env python3
"""Preview or merge local app templates with identical Compose files."""

import argparse
import hashlib
from pathlib import Path
import shutil
import tempfile


ROOT_METADATA = {"data.yml", "README.md", "README_en.md", "logo.png"}


def files(root):
    entries = {}
    for path in root.rglob("*"):
        if path.is_symlink():
            raise ValueError(f"Symlink: {path}")
        if path.is_file():
            entries[path.relative_to(root)] = path
    return entries


def compose_signature(entries):
    # Keep version names: identical YAML in different versions need not be duplicates.
    return {
        str(rel.parent): hashlib.sha256(
            path.read_bytes().replace(b"\r\n", b"\n")
        ).hexdigest()
        for rel, path in entries.items()
        if len(rel.parts) == 2 and rel.name == "docker-compose.yml"
    }


def merge(local, source, state, apply=False):
    local, source, state = local.resolve(), source.resolve(), state.resolve()
    if local == Path(local.anchor) or state == local or local in state.parents:
        raise ValueError("Backup directory must be outside the local app directory")
    if not local.is_dir():
        raise ValueError(f"Missing local app directory: {local}")
    keys = (source / "apps.txt").read_text(encoding="utf-8").splitlines()
    keys = {key.strip() for key in keys if key.strip() and not key.startswith("#")}
    canonical = {}
    # Validate every candidate before changing any files.
    candidates = {}
    for directory in sorted(local.iterdir()):
        if directory.is_symlink():
            print(f"Skipped symlink: {directory.name}")
            continue
        if directory.is_dir() and (directory / "data.yml").is_file():
            entries = files(directory)
            signature = compose_signature(entries)
            if signature:
                candidates[directory.name] = (directory, entries, signature)
                if directory.name in keys:
                    canonical[directory.name] = candidates[directory.name]
    plans = []
    for name, (directory, entries, signature) in candidates.items():
        if name in keys:
            continue
        matches = [
            key for key, (_, _, expected) in canonical.items() if signature == expected
        ]
        if len(matches) != 1:
            if matches:
                print(f"Skipped ambiguous match: {name}")
            continue
        key = matches[0]
        target, target_files, _ = canonical[key]
        conflicts = [
            str(rel) for rel in entries.keys() & target_files.keys()
            if str(rel) not in ROOT_METADATA
            and rel.name != "docker-compose.yml"
            and entries[rel].read_bytes() != target_files[rel].read_bytes()
        ]
        # Also reject file/directory collisions, including between planned merges.
        for rel in entries:
            destination = target / rel
            if destination.is_dir() or any(
                parent in target_files or (target / parent).is_file()
                for parent in rel.parents if parent != Path(".")
            ) or any(rel in existing.parents for existing in target_files):
                conflicts.append(str(rel))
        if conflicts:
            print(f"Skipped conflicting files: {name}: {', '.join(sorted(conflicts))}")
            continue
        plans.append((directory, target, entries))
        # Reserve new files so another duplicate cannot silently overwrite them.
        for rel, path in entries.items():
            if rel not in target_files:
                target_files[rel] = path
    backup = None
    for directory, target, entries in plans:
        print(f"{'Merge' if apply else 'Would merge'}: {directory.name} -> {target.name}")
        if not apply:
            continue
        if backup is None:
            state.mkdir(parents=True, exist_ok=True)
            backup = Path(tempfile.mkdtemp(prefix="merge-", dir=state))
        if not (backup / target.name).exists():
            shutil.copytree(target, backup / target.name)
        shutil.copytree(directory, backup / directory.name)
        for rel, path in entries.items():
            destination = target / rel
            if not destination.exists():
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(path, destination)
        shutil.rmtree(directory)
    if backup:
        print(f"Backup: {backup}")
    print(f"{len(plans)} duplicate application(s); {'merged' if apply else 'preview only'}")
    return len(plans)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--local-apps-dir", type=Path,
                        default=Path("/opt/1panel/resource/apps/local"))
    parser.add_argument("--source-dir", type=Path,
                        default=Path(__file__).resolve().parent.parent)
    parser.add_argument("--backup-dir", type=Path,
                        default=Path("/opt/1panel-third-party/shenbourne/backups"))
    parser.add_argument("--apply", action="store_true", help="Back up and merge duplicates")
    args = parser.parse_args()
    merge(args.local_apps_dir, args.source_dir, args.backup_dir, args.apply)


if __name__ == "__main__":
    main()
