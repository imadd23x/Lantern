# Lantern tasks

- [x] 1. session-state contract/reducer (4 source/test files).
  - Accept: independent sessions; concurrent requests queue; expired/ended requests cannot allow.
  - Verify: `bash scripts/swift.sh test --filter Session`.
- [x] 2. hook-configuration (3 files), depends on 1.
  - Accept: preserves arbitrary settings/neighbor handlers; invalid/stale target unchanged; verified backup.
  - Verify: configuration tests in temp directories.
- [x] 3. hook-connection (4 files), depends on 1.
  - Accept: same-user socket, concurrent routing, deadlines, no allow on errors.
  - Verify: transport tests and packaged relay smoke.
- [x] Checkpoint: domain/config/transport tests pass and binaries compile.
- [x] 4. companion-ui session display (4 files), depends on 1/3.
  - Accept: original character, bounded session list, compact/expanded panel and menu fallback.
  - Verify: launch isolated app, visually inspect and interact.
- [x] 5. companion-ui approvals/setup (3 files), depends on 2/4.
  - Accept: exact proposal/deadline, one-click request-specific response, explicit config preview/removal.
  - Verify: real hook decisions and setup UI without live config writes.
- [x] 6. build/package/CI (4 files), depends on 5.
  - Accept: repeatable app bundle and no external dependencies; proportionate automated checks.
  - Verify: `bash scripts/package.sh`; `bash scripts/smoke.sh`.
- [x] 7. handoff documentation (README, architecture, verification).
  - Accept: exact startup/activation/rollback instructions; honest live-vs-synthetic evidence.
  - Verify: follow documented build/run steps and review final diff.
- [x] Checkpoint: all release-critical kill criteria clear; live host activation explicitly recorded.

## Live activation (outside the completed local build)

- [ ] User reviews/trusts Codex hook definitions and starts a new desktop session.
- [ ] User reloads Claude Code in VS Code and verifies live delivery/navigation.
- [ ] Optional wider-device verification: multi-monitor/full-screen/VoiceOver/reduced motion.

Local acceptance and evidence: `docs/VERIFICATION.md`. No global agent configuration was changed.

## 0.1.1 local component library refinement

- [x] Read catalog/metadata, selected source and notices from Arc, Space UI, Componentry and free Planes.
- [x] Register presentation acceptance and omitted effects in `docs/UI-REFERENCES.md`.
- [x] Add shared native styles, keyboard provider filters/counts and event-driven status badges.
- [x] Preserve model/actions/transport/configuration and panel geometry; bundle license notices.
- [x] Verify 20 tests, packaged relay, isolated queue routing, disabled/cancelled presses,
  full proposal scrolling, connection previews, compact state and normal/reduced motion.
- [x] Package version 0.1.1 and record observed evidence and live limitations.

## 0.1.2 supplied Rick portrait

- [x] Register avatar scope; copy the supplied bitmap unchanged into SwiftPM resources.
- [x] Replace procedural artwork, retain working/reduced-motion/attention states and regenerate icon.
- [x] Verify 20 tests, packaged relay, rendered artwork, relocated signature and no build-cache fallback.
- [x] Package 0.1.2 and preserve prior ZIPs for rollback.
- [x] After manual unlock, verify expanded/compact portrait, attention/deny control and reduced motion onscreen.

## 0.1.3 transparent head and Componentry gaze

- [x] Inspect Componentry source; attempt the Rick edit, then apply the authorized green fallback after rejection.
- [x] Implement bounded native pupils and lifecycle-owned tracking; verify geometry and sampler cleanup.
- [x] Integrate the green avatar at both sizes and static icon; preserve agent actions and working/attention states.
- [x] Verify 25 tests/relay, relocated resource/signature, native cursor delivery and compact/expanded states.
- [x] Record provenance/evidence and package 0.1.3; retain earlier releases.
- [x] After manual unlock, repeat the clean-release onscreen check and confirm physical left/right mouse tracking.
  - Final 0.1.3/build 4 extraction: user confirmed both pupils follow; native compact clicks, working/attention,
    matching synthetic Deny and static process-local Reduce Motion passed. Isolated reviews quit cleanly.
