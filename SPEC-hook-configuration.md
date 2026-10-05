# Spec: hook-configuration

Inherits commands, style and boundaries from `SPEC.md`.

Provider coverage follows the documented event set: Claude adds Notification, tool failure
and turn failure; Codex adds Interrupt and does not register unsupported notification events.

Objective: connect either agent without losing settings or unrelated hook handlers.
Interface: `preview(original, provider, relayPath, remove)` returns before/after bytes;
`ConfigurationTransaction.apply` returns verified backup URL or throws without replacing the target.
Validate all hook group shapes; mark only Lantern-owned commands. Shell-quote executable paths.
Optimistic exact-byte concurrency guard + advisory writer lock, exclusive owner-only verified backup,
same-directory atomic rename. Refuse symlink targets. Removal preserves unrelated later edits.
Config gets no writes until user accepts its preview. Codex trust is never altered.
Tests: preservation, shared groups, malformed config, idempotency, shell quoting, stale preview, exact backup.
Verify: `bash scripts/swift.sh test --filter Configuration` in temporary directories only.

0.1.4 adds read-only installation inspection: every expected Lantern event must point to this app's
exact relay command; partial installations, other app paths and disabled Claude hooks cannot count
as installed. Reuse the existing bounded, symlink-refusing reader. Installation does not prove trust
or live delivery. The Connections sheet and empty session state share this information and paths.
