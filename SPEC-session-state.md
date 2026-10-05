# Spec: session-state

Inherits commands, style and boundaries from `SPEC.md`.

Objective: normalize Codex/Claude lifecycle input and maintain independent `(provider, sessionID)` state.
Interface: `HookNormalizer.normalize`, `AgentEvent.validate`, `SessionState.apply/resolve/expire`.
Unknown events return no event; malformed/oversized input throws. `resolve` is single-use and time-bounded.
State is memory-only, maximum 100 sessions except sessions with pending approvals; at most 32 connected clients.
Queue retains every concurrent request; terminal lifecycle events clear only that session's requests.
Tests: independent sessions, queue order, duplicate/expired decisions, exact proposal display, malformed hooks.
Verify: `bash scripts/swift.sh test --filter LanternCoreTests`.
