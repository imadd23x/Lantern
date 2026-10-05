# Verification evidence — Lantern 0.1.0

2026-10-05. Results below distinguish observed local behavior from live host activation.

## Observed checks

| Layer | Evidence | Result |
|---|---|---|
| Platform | macOS 27.0.1, Apple silicon, Swift 6.4 Command Line Tools | Native build supported |
| Domain/config/transport | `bash scripts/swift.sh test` | **20/20 passed** |
| Release app | `bash scripts/package.sh` | Release build, icon rendering and packaging passed |
| Delivered signature | `codesign --verify --deep --strict outputs/Lantern.app` | Passed |
| Archive | Extract ZIP in a temporary directory; strict/deep signature check; icon exists | Passed |
| Packaged relay | `bash scripts/smoke.sh` | Absent app/malformed input fallback plus Allow/Deny/Delegate for both agents passed |
| Native approvals | Two compiled relay processes → actual app → select Claude request 2/Deny → Codex request 1/Allow once | Correct identities and exact documented JSON returned; no proposed command executed |
| Native setup | App environment redirected both config targets to `/private/tmp/lantern-ui-verification` | Preview/current comparison, backup, connect and removal passed |
| Preservation | Read temporary settings and both backups after native setup/removal | Neighboring Stop hook and unrelated setting preserved; backups verified |
| Native quit | Quit via Lantern menu with one actual relay waiting | Relay exited 0 with empty stdout; isolated socket removed |
| UI | Native accessibility trees/screenshots of empty state, two requests, compact state and setup | Readable bounded layout; queue selection, expand/collapse, quiet toggle and menu worked |
| Scripts | `bash -n scripts/swift.sh scripts/package.sh scripts/smoke.sh` | Passed |

The 20 tests cover independent sessions/provider identity, concurrent request routing, single-use resolution,
expiry/session end, full proposed input, invalid input, provider event sets, config preservation/idempotence,
shell quoting, stale preview, verified backup, symlink/FIFO rejection, occupied socket, disconnect, shutdown,
and telemetry callback ordering. The first 12-test slice also passed before UI implementation.

## Toolchain repairs

- Swift 6.4 CLT stores Testing macros in a nested directory: the build wrapper supplies its plugin path.
- This SDK exposes a State macro unavailable in CLT: `ViewState` aliases the existing system property wrapper.
- File Provider adds FinderInfo in Documents: signing occurs in temporary staging; copied-root FinderInfo
  is removed and the delivered signature reverified. Archive extraction/signature verification also passed.
- Installed CLT emits linker warnings for absent Developer framework/library search directories.
  These warnings did not prevent successful compilation, linking, packaging or tests.
- Unix socket tests and release symbol generation required execution outside the filesystem sandbox;
  they used isolated temporary paths. No live agent settings were changed by those checks.

## Remaining validation

- **Live Codex desktop and Claude Code in VS Code delivery remains unverified.** Global hook config and
  Codex trust records were not changed. The installed CLI reports `hooks stable true`; the shared app-server
  control socket was absent, so it is not used. Codex requires review/trust through `/hooks`; both hosts
  require a new/reloaded session. Managed/project policy may prevent user hooks.
- Codex deep links and Claude workspace links are implemented with escaped URLs; actual live chat/terminal
  navigation was not exercised. Claude opens/focuses its workspace, not one exact integrated terminal.
- Screen-change and reduced-motion paths are implemented but multi-monitor, full-screen, reduced-motion
  settings and a full VoiceOver session were not exercised on this machine.
- GitHub CI was authored; it has not run remotely. Bundle is ad-hoc signed, not notarized/Developer ID signed.

No paid model turns, credential-file reads, third-party package installation, external messages,
production mutation or global agent activation were used. Synthetic tool proposals were never executed.

## Decision

Local code/build/synthetic-flow acceptance passes. This is a reviewable local trial with live activation
still explicit, consistent with the pre-registered partial-result rule in `SPEC.md`.
