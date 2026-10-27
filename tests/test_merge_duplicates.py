import importlib.util
from pathlib import Path
import tempfile
import unittest

SPEC = importlib.util.spec_from_file_location(
    "merge_duplicates", Path(__file__).resolve().parents[1] / "scripts/merge-duplicates.py"
)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class MergeTests(unittest.TestCase):
    def test_preview_merge_backup_and_conflicts(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            local, source, backup = root / "local", root / "source", root / "backups"
            source.mkdir()
            (source / "apps.txt").write_text("magpie\n", encoding="utf-8")
            compose = b"services:\n  app:\n    image: example:1\n"
            for name in ("magpie", "other-magpie", "different", "conflict", "extra-version"):
                app = local / name
                (app / "latest").mkdir(parents=True)
                (app / "data.yml").write_text(f"key: {name}\n")
                (app / "latest/docker-compose.yml").write_bytes(compose)
                (app / "latest/data.yml").write_text("form: same\n")
            (local / "other-magpie/latest/docker-compose.yml").write_bytes(
                compose.replace(b"\n", b"\r\n")
            )
            (local / "other-magpie/custom.txt").write_text("preserved")
            (local / "different/latest/docker-compose.yml").write_bytes(
                compose.replace(b"example:1", b"example:2")
            )
            (local / "conflict/latest/data.yml").write_text("form: different\n")
            (local / "extra-version/old").mkdir()
            (local / "extra-version/old/docker-compose.yml").write_bytes(compose)
            self.assertEqual(MODULE.merge(local, source, backup), 1)
            self.assertTrue((local / "other-magpie").exists())
            self.assertFalse(backup.exists())
            self.assertEqual(MODULE.merge(local, source, backup, True), 1)
            self.assertFalse((local / "other-magpie").exists())
            self.assertEqual((local / "magpie/custom.txt").read_text(), "preserved")
            self.assertEqual((local / "magpie/data.yml").read_text(), "key: magpie\n")
            saved = next(backup.iterdir())
            self.assertTrue((saved / "magpie/data.yml").is_file())
            self.assertTrue((saved / "other-magpie/data.yml").is_file())
            self.assertTrue((local / "conflict").exists())
            self.assertTrue((local / "different").exists())
            self.assertTrue((local / "extra-version").exists())
            self.assertEqual(MODULE.merge(local, source, backup, True), 0)


if __name__ == "__main__":
    unittest.main()
