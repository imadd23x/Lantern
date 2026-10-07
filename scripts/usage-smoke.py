#!/usr/bin/env python3
"""Offline executable checks; all input, environment and sockets belong to this fixture."""
from __future__ import annotations
import base64
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import tempfile
import threading


def snapshot(command: str | None) -> str:
    record: dict[str, object] = {"present": command is not None}
    if command is not None:
        record["value"] = {"type": "command", "command": command}
    return base64.b64encode(json.dumps(record).encode()).decode()


def main(relay: Path) -> None:
    with tempfile.TemporaryDirectory(prefix="lantern-usage-", dir="/private/tmp") as temporary:
        root = Path(temporary)
        env = dict(os.environ, LANTERN_RUNTIME_DIR=str(root), LANTERN_USAGE_FIXTURE="preserved")
        command = "printf '%s\\n' \"$LANTERN_USAGE_FIXTURE\" \"$PWD\"; cat; printf 'fixture stderr\\n' >&2; exit 7"

        def run(payload: bytes, previous: str | None = command) -> subprocess.CompletedProcess[bytes]:
            return subprocess.run([str(relay), "--provider", "claude", "--usage", "--previous-status-line", snapshot(previous)],
                                  input=payload, capture_output=True, env=env, cwd=root, timeout=5)

        valid = json.dumps({"rate_limits": {"five_hour": {"used_percentage": 42, "resets_at": 5000}},
                            "session_id": "private fixture", "prompt": "must not be forwarded"}).encode()
        for payload in [valid, b"invalid JSON", b"x" * 600_000]:
            result = run(payload)
            assert result.returncode == 7, result.returncode
            assert result.stdout == b"preserved\n" + str(root).encode() + b"\n" + payload
            assert result.stderr == b"fixture stderr\n", result.stderr
        early = run(b"x" * 600_000, "printf early; exit 7")
        assert (early.returncode, early.stdout, early.stderr) == (7, b"early", b"")
        assert run(valid, None).stdout == b""

        listener = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        listener.bind(str(root / "lantern.sock")); listener.listen(1); listener.settimeout(3)
        received: list[dict[str, object]] = []
        errors: list[Exception] = []

        def receive() -> None:
            try:
                connection, _ = listener.accept()
                with connection:
                    connection.settimeout(2)
                    data = bytearray()
                    while b"\n" not in data:
                        chunk = connection.recv(8192)
                        if not chunk:
                            break
                        data.extend(chunk)
                    received.append(json.loads(data))
                    connection.sendall(b'"allow"\n')  # An unexpected ack must never print a grant.
            except Exception as error:
                errors.append(error)

        worker = threading.Thread(target=receive)
        worker.start()
        result = run(valid, None)
        worker.join(4); listener.close()
        assert not worker.is_alive() and not errors, errors
        assert (result.returncode, result.stdout, result.stderr) == (0, b"", b"")
        assert len(received) == 1 and set(received[0]) == {"type", "version", "snapshot"}
        assert received[0]["type"] == "claude_usage" and received[0]["version"] == 1
        assert received[0]["snapshot"] == {"fiveHour": {"usedPercentage": 42, "resetsAt": 5000}}
        print("Usage relay: prior stdin/stdout/stderr/env/cwd/exit preserved; bounded payload; private quota-only wire; no approval output.")


if __name__ == "__main__":
    main(Path(sys.argv[1]).resolve())
