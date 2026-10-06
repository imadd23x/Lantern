# Lantern capability map

Direction: Imad's Codex desktop + Claude Code in VS Code, progress and explicit approvals.
Authorized by the build request and clarified answers. Updated 2026-10-05 after the requested design skills.

| Module id | Responsibility | Depends on |
|---|---|---|
| session-state | Versioned event contract, normalization, per-session state, approval queue | — |
| hook-connection | Local authenticated transport and compiled agent hook adapter | session-state |
| hook-configuration | Validated preview, exclusive backup, atomic install/removal | session-state |
| companion-ui | Native panel, character, sessions, approval decisions and connection setup | all above |

Build order: session-state → hook-connection + hook-configuration → companion-ui.
Swift targets are deployment groupings; the modules above are the behavioral seams.
No generic event bus or adapter protocol until another implementation actually needs it.

## Overnight desktop additions — authorized 2026-10-07

| Module id | Responsibility | Depends on |
|---|---|---|
| desktop-controls | Persisted shortcut preferences, native registration, login item, Settings | — |
| idle-presentation | Idle deadlines, manual/automatic hide distinction, passive hotspot reveal | desktop-controls |
| usage-state | Validated independent Claude quota windows and freshness | — |
| usage-relay | Versioned telemetry, preserving status-line wrapper, owner-only transport | usage-state, hook-connection, hook-configuration |
| companion-ui | Shared selection commands, pin, settings and usage display | all above |

Build order: desktop-controls → idle-presentation; usage-state → usage-relay → companion-ui.
The four requested capabilities are approved for unattended implementation; ordinary defaults
are resolved within scope. Existing approval, navigation, artwork and sound contracts are retained.
