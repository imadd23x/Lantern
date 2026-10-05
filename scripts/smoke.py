"""Exercise the compiled hook's real stdin/stdout/socket contract without running an agent."""
from __future__ import annotations

import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import tempfile
import threading
import time


def main() -> None:
    relay = Path(sys.argv[1]).resolve()
    assert relay.is_file(), "Build Lantern.app first"
    with tempfile.TemporaryDirectory(prefix="lantern-smoke-", dir="/private/tmp") as folder:
        env = dict(os.environ, LANTERN_RUNTIME_DIR=folder)
        payload = {"hook_event_name": "PermissionRequest", "session_id": "synthetic-session",
                   "cwd": folder, "tool_name": "Bash", "tool_input": {"command": "echo synthetic-only"}}

        def invoke(data: object, provider: str = "codex") -> subprocess.CompletedProcess[str]:
            return subprocess.run([str(relay), "--provider", provider], input=json.dumps(data),
                                  text=True, capture_output=True, env=env, timeout=5, check=True)

        started = time.monotonic()
        assert invoke(payload).stdout == "", "No app must mean no decision"
        assert time.monotonic() - started < 1, "Absent app must not block"
        assert invoke({}).stdout == "", "Malformed hooks must not allow"

        for provider in ("codex", "claude"):
            for decision in ("allow", "deny", "delegate"):
                endpoint = Path(folder) / "lantern.sock"
                with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as server:
                    server.bind(str(endpoint))
                    server.listen()
                    events: list[dict[str, object]] = []
                    failures: list[BaseException] = []

                    def respond() -> None:
                        try:
                            server.settimeout(3)
                            connection, _ = server.accept()
                            with connection:
                                connection.settimeout(3)
                                event = json.loads(connection.makefile("rb").readline())
                                events.append(event)
                                connection.sendall((json.dumps(decision) + "\n").encode())
                        except BaseException as error:
                            failures.append(error)

                    worker = threading.Thread(target=respond)
                    worker.start()
                    result = invoke(payload, provider)
                    worker.join(timeout=4)
                    assert not worker.is_alive() and not failures, failures
                    assert events[0]["provider"] == provider
                    assert events[0]["sessionID"] == "synthetic-session"
                    if decision == "delegate":
                        assert result.stdout == ""
                    else:
                        output = json.loads(result.stdout)["hookSpecificOutput"]
                        assert output["hookEventName"] == "PermissionRequest"
                        assert output["decision"]["behavior"] == decision
                endpoint.unlink()
        print("PASS: absent app, malformed input, and Allow/Deny/Delegate for both packaged agent adapters.")


if __name__ == "__main__":
    main()
