"""Compiled relay regression checks. No agent, commands or inference are run."""
from __future__ import annotations

import json
import os
from pathlib import Path
import select
import signal
import socket
import subprocess
import sys
import tempfile
import time


PARENT = """
import json, os, subprocess, sys, time
child = subprocess.Popen(sys.argv[1:], stdin=subprocess.PIPE)
child.stdin.write(os.environ['LANTERN_TEST_PAYLOAD'].encode())
child.stdin.close()
print(child.pid, flush=True)
time.sleep(30)
"""


def read_line(stream, timeout: float = 3) -> bytes:
    deadline = time.monotonic() + timeout
    data = b""
    while time.monotonic() < deadline:
        ready, _, _ = select.select([stream], [], [], max(0, deadline - time.monotonic()))
        assert ready, "Relay did not finish within the bounded check"
        byte = os.read(stream.fileno(), 1)
        if not byte or byte == b"\n":
            return data
        data += byte
    raise AssertionError("Relay output exceeded the deadline")


def main() -> None:
    relay = Path(sys.argv[1]).resolve()
    assert relay.is_file()
    with tempfile.TemporaryDirectory(prefix="lantern-lifetime-", dir="/private/tmp") as folder:
        env = dict(os.environ, LANTERN_RUNTIME_DIR=folder)
        payload = {"hook_event_name": "PermissionRequest", "session_id": "same-session",
                   "cwd": folder, "tool_name": "Read", "tool_input": {"file_path": "sample-A"}}
        env["LANTERN_TEST_PAYLOAD"] = json.dumps(payload)
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as server:
            server.bind(str(Path(folder) / "lantern.sock"))
            server.listen()
            server.settimeout(3)
            parent = subprocess.Popen([sys.executable, "-c", PARENT, str(relay), "--provider", "claude"],
                                      env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=0)
            child_pid = None
            sibling = None
            try:
                child_pid = int(read_line(parent.stdout))
                connection_a, _ = server.accept()
                with connection_a:
                    connection_a.settimeout(3)
                    assert json.loads(connection_a.makefile("rb").readline())["summary"] == "Read"
                    payload["tool_input"]["file_path"] = "sample-B"
                    sibling = subprocess.Popen([str(relay), "--provider", "claude"], env=env,
                                               stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                    sibling.stdin.write(json.dumps(payload).encode()); sibling.stdin.close()
                    connection_b, _ = server.accept()
                    with connection_b:
                        connection_b.settimeout(3)
                        assert json.loads(connection_b.makefile("rb").readline())["sessionID"] == "same-session"
                        # Several receive slices must not be mistaken for EOF.
                        time.sleep(0.25)
                        assert sibling.poll() is None
                        parent.terminate(); parent.wait(timeout=3)
                        started = time.monotonic()
                        connection_a.settimeout(1.5)
                        assert connection_a.recv(1) == b"", "Orphaned relay retained its approval socket"
                        assert time.monotonic() - started < 1.5
                        assert read_line(parent.stdout) == b"", "Cancelled relay printed a decision"
                        assert sibling.poll() is None, "Cancelling A also cancelled B in the same session"
                        # Preserve an incomplete JSON response across cancellation polling slices.
                        connection_b.sendall(b'"al')
                        time.sleep(0.25)
                        assert sibling.poll() is None
                        connection_b.sendall(b'low"\n')
                        output = json.loads(read_line(sibling.stdout))
                        assert output["hookSpecificOutput"]["decision"]["behavior"] == "allow"
                        sibling.wait(timeout=3)
                        assert sibling.returncode == 0
            finally:
                if parent.poll() is None:
                    parent.terminate(); parent.wait(timeout=3)
                if sibling is not None and sibling.poll() is None:
                    sibling.terminate(); sibling.wait(timeout=3)
                if child_pid is not None:
                    try:
                        os.kill(child_pid, signal.SIGTERM)
                    except ProcessLookupError:
                        pass
    check_stalled_send(relay)
    print("PASS: orphan closes only its relay during receive/send; live sibling and partial replies survive polling.")


def check_stalled_send(relay: Path) -> None:
    with tempfile.TemporaryDirectory(prefix="lantern-stalled-", dir="/private/tmp") as folder:
        payload = {"hook_event_name": "PermissionRequest", "session_id": "stalled-send",
                   "tool_name": "Read", "tool_input": {"file_path": "x" * 180_000}}
        env = dict(os.environ, LANTERN_RUNTIME_DIR=folder, LANTERN_TEST_PAYLOAD=json.dumps(payload))
        with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as server:
            server.setsockopt(socket.SOL_SOCKET, socket.SO_RCVBUF, 1024)
            server.bind(str(Path(folder) / "lantern.sock")); server.listen(); server.settimeout(3)
            parent = subprocess.Popen([sys.executable, "-c", PARENT, str(relay), "--provider", "claude"],
                                      env=env, stdout=subprocess.PIPE, stderr=subprocess.PIPE, bufsize=0)
            child_pid = None
            try:
                child_pid = int(read_line(parent.stdout))
                connection, _ = server.accept()
                with connection:
                    time.sleep(0.25) # Deliberately do not read the proposal before cancelling.
                    parent.terminate(); parent.wait(timeout=3)
                    # The child must exit without the server having to consume its send buffer.
                    assert read_line(parent.stdout, timeout=1.5) == b"", "Stalled send retained orphaned relay"
                    connection.settimeout(1)
                    while connection.recv(8192):
                        pass
            finally:
                if parent.poll() is None:
                    parent.terminate(); parent.wait(timeout=3)
                if child_pid is not None:
                    try:
                        os.kill(child_pid, signal.SIGTERM)
                    except ProcessLookupError:
                        pass


if __name__ == "__main__":
    main()
