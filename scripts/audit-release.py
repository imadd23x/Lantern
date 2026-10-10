"""Reject accidental local data in a built app. Does not scan account/auth files."""
from __future__ import annotations

from pathlib import Path
import sys


def audit(app: Path) -> None:
    for path in app.rglob("*"):
        assert not path.is_symlink(), f"Unexpected bundle link: {path.relative_to(app)}"
        if not path.is_file():
            continue
        relative = path.relative_to(app)
        assert path.name not in {"settings.json", "hooks.json", ".env", "auth.json", "credentials.json"}, f"Local configuration in bundle: {relative}"
        if relative.parts[:2] == ("Contents", "MacOS"):
            data = path.read_bytes()
            assert b"/Users/" not in data, f"Personal home path embedded in {relative}"
            assert b"Documents/Codex" not in data, f"Personal source path embedded in {relative}"
    print("PASS: packaged executables have no personal home/source paths; no local agent settings bundled.")


if __name__ == "__main__":
    audit(Path(sys.argv[1]))
