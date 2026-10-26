"""Validate the local catalog against the 1Panel application package structure."""
import re
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]


def load(path):
    return yaml.safe_load(path.read_text(encoding="utf-8-sig"))


def validate():
    bootstrap = (ROOT / "scripts/bootstrap.sh").read_text(encoding="utf-8")
    readme = (ROOT / "README.md").read_text(encoding="utf-8")
    assert f"```bash\n{bootstrap}```" in readme, "README bootstrap differs from scripts/bootstrap.sh"
    for target in re.findall(r'(?:href|src)="([^"]+)"', readme):
        if not target.startswith(("https://", "#")):
            assert (ROOT / target).is_file(), target
    catalog = load(ROOT / "data.yaml")["additionalProperties"]
    tags = {tag["key"] for tag in catalog["tags"]}
    apps = (ROOT / "apps.txt").read_text(encoding="utf-8").splitlines()
    assert len(apps) == len(set(apps)), "Duplicate catalog entries"
    actual = {p.name for p in (ROOT / "apps").iterdir() if p.is_dir()}
    assert set(apps) == actual, "apps.txt must match apps/"
    versions_checked = 0
    for app in apps:
        assert re.fullmatch(r"[a-z0-9][a-z0-9-]*", app), app
        base = ROOT / "apps" / app
        for name in ("data.yml", "logo.png", "README.md", "README_en.md"):
            assert (base / name).is_file(), f"{app}/{name}"
        assert (base / "logo.png").read_bytes().startswith(b"\x89PNG\r\n\x1a\n"), app
        meta = load(base / "data.yml")["additionalProperties"]
        assert meta["key"] == app
        assert meta["name"] and set(meta["tags"]) <= tags, app
        assert meta["type"] in ("tool", "website", "runtime"), app
        assert meta["description"]["en"] and meta["description"]["zh"], app
        for key in ("website", "github", "document"):
            assert meta[key].startswith("https://"), (app, key)
        versions = [p for p in base.iterdir() if p.is_dir()]
        assert versions, app
        for version in versions:
            assert not version.name.startswith("v"), version
            fields = load(version / "data.yml")["additionalProperties"]["formFields"]
            assert isinstance(fields, list), version
            keys = [field["envKey"] for field in fields]
            assert len(keys) == len(set(keys)), version
            for field in fields:
                assert field["label"]["en"] and field["label"]["zh"], (version, field)
                if field["envKey"].startswith("PANEL_APP_PORT"):
                    assert field["type"] == "number" and field["rule"] == "paramPort"
            compose_path = version / "docker-compose.yml"
            compose = load(compose_path)
            assert compose["services"], version
            for service in compose["services"].values():
                assert service["image"], version
                assert service.get("labels", {}).get("createdBy") == "Apps", version
            variables = set(re.findall(r"\$\{([A-Za-z_][A-Za-z0-9_]*)", compose_path.read_text(encoding="utf-8")))
            assert variables <= set(keys) | {"CONTAINER_NAME"}, (version, variables - set(keys))
            versions_checked += 1
        for path in base.rglob("*"):
            assert not path.is_symlink(), path
            if path.suffix in (".yml", ".yaml"):
                load(path)
    print(f"PASS: {len(apps)} apps, {versions_checked} versions; metadata, forms, Compose and variables")


if __name__ == "__main__":
    validate()
