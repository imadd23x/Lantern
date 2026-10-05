# Spec: hook-connection

Inherits commands, style and boundaries from `SPEC.md`.

Objective: receive local events and return a decision only to the request's original hook connection.
Interface: server `start/stop/respond`, client `exchange`; typed `AgentEvent` and `HookDecision`.
Implementation hides file descriptors, framing, same-UID authentication, permission checks and lifecycle cleanup.
Owner-only directory/socket; refuse an occupied socket rather than unlink a live endpoint.
Maximum 256 KB message, 32 clients, read deadline 2 s, approval deadline 110 s; no-decision fallback on error.
Only PermissionRequest can produce decision JSON; fire-and-forget hooks produce no stdout.
Transport closes on app quit; cancel/disconnect is surfaced immediately to invalidate the card.
Tests: real exchange, concurrent responses, disconnect, oversized frame, occupied socket, absent app.
Verify: `bash scripts/swift.sh test`; `bash scripts/smoke.sh` with packaged relay.
