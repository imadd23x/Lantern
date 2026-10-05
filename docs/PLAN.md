# Lantern — personal agent companion

## Scope and acceptance

For Imad's Codex desktop and Claude Code in VS Code, on macOS 15+.
Native SwiftUI/AppKit app, original lantern character, local Unix socket and compiled hook relay.
No API keys, inference, telemetry, external integrations, or account login.

1. Each `(provider, sessionID)` has independent status, project, activity, and pending requests.
2. Concurrent requests stay queued. Only a deliberate click sends allow/deny for that request.
3. Timeout, disconnect, quit, and "Answer in agent" send no approval; the original agent retains its normal approval flow.
4. Configuration preview validates all existing hook shapes, preserves unrelated handlers/settings,
   rejects changes since preview, creates a verified exclusive backup, and writes atomically.
5. Menu bar access and a screen-aware panel work with and without a notch. Reduced motion is supported.
6. Swift 6 build, domain/config tests, real socket/relay integration checks, packaged app launch, and visual inspection pass.

## Architecture

- `LanternCore`: typed wire events, session reducer, hook normalization, transactional configuration editing.
- `LanternTransport`: bounded owner-only Unix socket messaging. No network listener.
- `LanternHook`: stdin hook adapter; short timeout for telemetry, bounded wait for PermissionRequest.
- `LanternApp`: main-actor observable model, request routing, panel/UI, connection setup, app launch links.
- `Tests`: behavior, configuration preservation, and real transport checks. No paid turns in tests.

Event protocol is versioned. Requests have per-connection IDs and provider/session identity.
No persistent always-allow control. Unknown events and malformed inputs cannot produce an allow.
Socket payload and concurrency limits bound memory/thread use. Session history is memory-only and bounded.

## Ordered implementation

1. Domain/normalization and failing behavior tests; make them pass.
2. Safe configuration transactions and owner-only transport/relay; test real I/O and concurrency.
3. Native panel, original character, session cards, explicit approvals, setup and recoverable quit.
4. Build/package scripts, CI, README/architecture/source notes, app runtime verification and release evidence.

## Assumptions / risks

- Codex hooks are stable/enabled in this machine's bundled CLI; desktop host delivery still needs user trust and a new session.
- No shared app-server control socket was present. Hooks are the integration; do not depend on private databases or undocumented desktop IPC.
- Hook execution/config policy may be managed by either agent. Surface that limitation; never bypass trust or approval policy.
- Claude Code's VS Code extension must load user hooks; prove its live path after activation.
- A hook has a bounded lifetime. Expired/disconnected cards must become unusable immediately.
- macOS may have screen/menu bar/full screen positioning differences. Follow screen changes and provide menu bar fallback.

## Rollout / rollback

Build to `outputs/Lantern.app` without installing it or changing agent config. Launch with isolated
runtime directories for verification. Setup only changes config after the user accepts an exact preview.
Restart/new agent sessions and Codex hook trust are explicit activation steps.
"Remove hooks" removes only Lantern handlers, preserving later unrelated edits and making a backup.
Quit closes pending connections with no decision. Rollback does not require reverting an entire settings file.

## Sources inspected, 2026-10-05

- Coucou at `7314790a814d48e57d7a732d1a317e5583149adf`: HookServer, IslandStateMachine, IslandWindowController, licenses.
- https://learn.chatgpt.com/docs/hooks — discovery, trust, supported events, PermissionRequest allow/deny contract.
- https://learn.chatgpt.com/docs/app-server — metadata reads and approval protocol; shared socket probe unavailable.
- https://code.claude.com/docs/en/hooks — PermissionRequest decisions and lifecycle hook schema.
- Installed Codex `--help`, `features list` (`hooks stable true`), generated protocol schema.

This is an independently implemented app. Coucou's branded character, artwork, sounds and media are not copied.
