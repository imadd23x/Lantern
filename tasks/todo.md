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

Initial isolated acceptance and evidence: `docs/VERIFICATION.md`. Global configuration was unchanged
until the later user-authorized installation recorded at the end of this file.

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

## Local installation and activation

- [x] Install and launch verified 0.1.3/build 4 at `~/Applications/Lantern.app`.
- [x] Prepare both native previews, obtain explicit activation approval, and apply both connections.
- [x] Verify Claude's exact backup, preserved settings/hooks, stable relay paths and private socket/config modes.
- [x] User reviews/trusts Codex Lantern definitions through `/hooks`; fresh host sessions are observed.
- [x] Observe actual Codex desktop tool activity and Claude Code in VS Code session startup in Lantern.
- [ ] Observe Claude tool activity and a real host PermissionRequest/decision; synthetic decision checks pass.

Machine-specific evidence and handoff: `docs/LOCAL-INSTALLATION.md`. Terminal access is blocked by the
computer-use tool; a syntax-checked `outputs/Trust-Lantern.command` launcher was prepared for the user.

## 0.1.4 restart messaging and panel presentation

- [x] Reproduce empty restart UI and confirm existing hooks resume on activity; inspect exact Arc components.
- [x] Register acceptance, rollback and implementation sequence before code.
- [x] Implement read-only installation detection and correct empty/filter messaging.
- [x] Implement move/hide/reset, remembered bounded placement and menu fallback.
- [x] Adapt Arc Segmented Control and Expandable Card with reduced-motion behavior.
- [x] Verify 30 tests, packaged relay, native interactions and static reduced-motion captures.
- [x] Package/upgrade at the existing path, preserve rollback and record observed evidence.

## 0.1.5 supplied Claude icon

- [x] Inspect supplied alpha/color and bundle original WebP bytes; replace the Claude row asterisk.
- [x] Fix the blank named-image lookup with native bundled-URL loading and review at actual row size.
- [x] Verify extracted signing/resources, install with rollback, and observe the icon on a real Claude row.
- [x] Confirm unchanged hook files and record the safely confirmed stale-socket cleanup.

## 0.1.6 supplied Codex icon

- [x] Inspect the opaque attachment and extract a transparent PNG with the built-in image editor.
- [x] Bundle the asset, retain smooth Codex scaling and original Claude pixel-art rendering.
- [x] Verify extracted signatures/resources and both provider icons in an isolated native review.
- [x] Upgrade with rollback and unchanged hook files; observe the icon on a real Codex session row.

## 0.1.7 supplied head, visibility and pill controls

- [x] Register acceptance; inspect Arc Action Button/Expandable Card and actual native event handling.
- [x] Bundle the exact head screenshot and clip it natively; preserve white eyes per user preference.
- [x] Remove header slogans/Reset and combine Show/Hide with queued-request/listener regression coverage.
- [x] Implement compact-only full-pill pan arbitration and separate chevron hover/focus/press feedback.
- [x] Pass all 30 tests, release packaging, relocated signing/resources and packaged relay smoke.
- [x] Verify avatar sizes, four drag regions, ordinary clicks/Escape, visible menu and static Reduce Motion.
- [x] Upgrade with rollback, unchanged hooks and restored quiet mode; observe live Codex activity.
- [x] User confirms the installed arrow's physical hover highlight; hidden native menu inspection remains
  limited by the UI tool, with both visibility states covered by the lifecycle test.

## 0.1.8 approval restoration and keyboard focus

- [x] Reproduce sticky expansion with a failing real-socket regression; register acceptance before code.
- [x] Track automatic presentation and restore the pill on queue drain, preserving explicit user choices.
- [x] Restrict automatic key-window eligibility and release owned focus on Allow/Deny.
- [x] Verify queue/manual/hidden/ordering/cancellation/expiry and all 37 tests (40 cases).
- [x] Verify release signing/relay and native first/last decisions with two isolated provider proposals.
- [ ] Verify unsteered physical typing after the private FocusCheck sample.
- [x] Upgrade with rollback, unchanged hooks/restored quiet mode, live activity and matching binaries.
- [x] Preserve keyboard controls on explicit opening; native Tab focuses All agents in the final build.

## 0.1.9 live navigation, clean head and green accent

- [x] Trace unsafe worktree folder URLs and premature handoff; inspect the existing Claude extension tab.
- [x] Register scope and reproduce the folder-route fault without invoking it against the live agent.
- [x] Share existing-window navigation and preserve pending requests on activation failure.
- [x] Pass all 41 tests (45 cases), package/signature/resource checks and packaged relay smoke.
- [x] Carry pending work into the newly writable Documents/Codex/Lantern source, preserving the old tree.
- [x] Tighten both head edges and reject the first remaining light fringe; verify corrected native renders.
- [x] Replace gold with #069b2e and inspect the final green approval card, compact and expanded head.
- [x] Verify native sample row/handoff preserve Code's workspace, selected chat, tabs and existing window.
- [x] Install with rollback, unchanged hooks and observed live activity; archive matching source/checksums.

## Overnight desktop additions — 2026-10-07

- [x] Desktop preferences and safe bindings — two tests failed before implementation, now pass; unsafe/duplicate keys rejected and preferences persist.
- [x] Native shortcut driver and Settings — registration errors, user editing, shared selection; compiled and regression-tested.
- [x] Idle presentation — deterministic deadlines/manual hide/focus/pending-request tests; independent pointer-entry hotspot wired.
- [x] Native login item — installed-path/identity/demo guards tested, truthful OS states; native registration still awaits rollout.
- [x] Usage state — invalid/missing/stale/reset/partial window tests passed.
- [x] Usage transport/relay — real delivery has no decisions/sessions/presentation changes; executable fixture preserves prior command on malformed/600KB input, early exit, absent server and unexpected allow ack.
- [x] Usage configuration — exact ownership/idempotence/restoration/concurrency tests and setup UI; boolean-vs-number ownership defect reproduced and fixed.
- [ ] Runtime/review/package — all tests, native UI, signatures/assets, rollback, safe install.
- [ ] GitHub checks/archives — source commits, CI success, honest morning handoff; stop heartbeat.

Open live check: installed Claude extension2.1.289 consumes unified usage events internally, but
no documented public export or statusLine emission has been established for native panel sessions.
Inspect supported telemetry before claiming live quota integration. Do not scrape auth/log files.

Overnight continuation: heartbeat `finish-lantern-overnight`, every30min until08:00 Dubai,
stop on completion. Fresh design review completed; its eight substantive findings are accepted.
Installed extension's `usage_EXPERIMENTAL_MAY_CHANGE_DO_NOT_RELY_ON_THIS_API_YET` and private
panel_usage_update messaging are not used as Lantern integrations. Official status-line telemetry
remains the supported relay path; native-panel live data is an explicit compatibility check.

Checkpoint 04:40 Dubai: local commits `81d77d3`, `3d52ed6`, `3c417e1`, `2268f22` preserve
completed slices. Final uncommitted usage transport/relay/UI and canonical-app guard are under
full verification, package and smoke command (exec cell213; logs `/private/tmp/lantern-0.2.0-*.log`).
No installed-app, login item, live configuration or GitHub changes yet. Last full suite before
guard addition passed 67 functions (71 parameterized cases); guard's three focused tests passed.
Next: finish final native review, package extraction/signatures, safe upgrade with 0.1.14 backup,
native login status, GitHub CI and source archive. Do not repeat checks without intervening changes.

11:22 Dubai: native review blocked by locked Mac. CUA `getApp` took until07:21 UTC to return
the lock failure; do not repeat it without the user's unlock reply. User asked asynchronously.
Full suite passed68/72 and both packaged smoke fixtures passed. Head/icons/A-Train match installed
bytes and both hook hashes are unchanged. Added a Settings key-window login-status refresh;
three focused tests passed, final packaging/smoke is exec cell227. Installed0.1.14 is untouched.
Finish source commits, feature-branch CI/archives while waiting. Preserve main/release rollout until
native acceptance and a safe no-live-approval upgrade can be completed.
