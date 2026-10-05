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
