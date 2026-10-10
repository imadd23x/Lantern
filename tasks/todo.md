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
- [x] Automated verification/package — full suite 68 functions/72 cases, final focused login tests, both smoke fixtures, ZIP CRC, extracted signatures and exact resource hashes.
- [x] GitHub checks/archives — committed feature branch, green code CI, draft PR #1, verified exact source archive.
- [x] Native review and rollout — native Settings/usage, physical Allow/Hide, installed Show/Hide/Settings confirmation, safe empty-queue upgrade with signed rollback, native login On.
- [x] Complete final handoff and stop heartbeat after native rollout; OS/user-only checks remain explicitly documented.

Open live check: installed Claude extension2.1.289 consumes unified usage events internally, but
no documented public export or statusLine emission has been established for native panel sessions.
Inspect supported telemetry before claiming live quota integration. Do not scrape auth/log files.

Overnight continuation: heartbeat `finish-lantern-overnight`, every30min until08:00 Dubai,
stop on completion. Fresh design review completed; its eight substantive findings are accepted.
Installed extension's `usage_EXPERIMENTAL_MAY_CHANGE_DO_NOT_RELY_ON_THIS_API_YET` and private
panel_usage_update messaging are not used as Lantern integrations. Official status-line telemetry
remains the supported relay path; native-panel live data is an explicit compatibility check.

Current checkpoint: feature source `8dc91d8` passed the complete local suite (68/72), final focused
login/installation tests, release packaging and both smoke fixtures. GitHub run37588602158 is green;
[draft PR #1](https://github.com/imadd23x/Lantern/pull/1) is attached to the task. The 0.2.0 ZIP
passes CRC and macOS extraction/deep strict signatures. Head/icons/A-Train and both hook hashes
are unchanged. The source ZIP is checked against every tracked blob; SHA256SUMS covers both ZIPs.

Native review is blocked by the locked Mac. CUA `getApp` took until07:21 UTC to return the lock
failure; do not retry before the user's unlock reply. An async unlock question is pending.
Installed0.1.14/build15 is untouched. No login registration or live usage setup was attempted.
The prepared rollback installer `/private/tmp/lantern-install-0.2.0.py` has not run. Preserve
main/release tags until native acceptance and a safe no-live-approval upgrade. The bounded
overnight heartbeat rule expired at08:00 Dubai; do not create a replacement automation.
Next: after unlock, review an isolated final package, observe/quit the old app safely, install
with rollback, verify native login/listener state, finish GitHub rollout and pause the heartbeat.
Do not repeat unchanged local checks; documentation-only updates need whitespace/archive checks.

Resumed after user unlock: build16 native General/Shortcuts/Usage layouts and private connection
preview inspected. Fresh42%/17%, reset-passed and missing-window meters rendered correctly. User
refined the shortcut scope to exactly Command+Return Allow once and Command+Option+H Hide.
Build17 replaces the five navigation actions; original candidate ZIPs are retained as build16.
Tests reproduce the missing API and held-at-registration behavior before implementation. Internal
review found registration/latch churn, premature onAppear readiness and edit-path availability
bypass; all are addressed. User skipped extra external review; a fresh implementation review and
full suite are running. The installed app/settings remain unchanged. Source changes are uncommitted
pending final verification/package/native acceptance; do not install the older build16 candidate.

User confirmed physical Cmd-Return and Cmd-Option-H Hide in build17. Socket ack was exact allow.
User then requested the same visibility shortcut also unhide. Build18 delegates that action to the
existing toggleCompanionVisibility path, preserves the raw stored key, and returns compact on Show.
The visibility regression failed on the old always-Hide behavior before this fix. Final checks
and safe installation are next; no fresh review needed for the existing helper delegation.

Build18 final checkpoint: full76/81, both smoke fixtures, strict extracted signatures/CRC and exact
supplied assets passed. ZIP SHA6fc4b4e. Private physical Allow ack and return-to-pill passed;
user confirmed Hide, then requested toggle, now tested and packaged. Private review was quit.
Live Claude settings changed independently; valid current hook baseline hash28c7bf5e is preserved.
Installed0.1.14 remains Connected/Enabled. Fresh pre-Quit check detected four real Claude requests,
so Quit was aborted. Async user ready question is pending; do not disconnect that queue. Installer
is prepared for /private/tmp/lantern-release18-4my5idp6/Lantern.app, expected build18 and current
hook hashes. Continue safe upgrade/native login/visibility, GitHub final rollout, stop heartbeat.

User added Settings z-order fix: screenshot traces to companion .statusBar vs Settings .normal.
Build19 raises Settings just above the companion only while key/open, lowers on resign, and leaves
presentation/approval state untouched. Static native configuration: no mirror unit test. Rebuild,
relay smoke and actual visible native review required. Live approval ready reply is still pending.

Installed0.2.0/build19 after ready + fresh empty-queue check, ordered native Quit and guarded swap.
Backup: ~/Applications/Lantern Backups/0.1.14-build15-b58fd38e/Lantern.app. Strict signed bundles,
exact installed files and unchanged current hook hashes passed. Restart compact; Connected/live
Codex/Enabled observed. Native login switch On with no warning, exact two bindings/no error.
Usage honestly unavailable, relay not installed. Async final installed toggle/Settings confirmation
pending. Next-login/physical hover/typing remain manual residuals. No code changes required unless
user reports a runtime failure; finish GitHub handoff/release and pause heartbeat after acceptance.

User confirmed both installed visibility toggle/compact return and active Settings foreground.
Native acceptance is complete within documented next-login/hover/typing and telemetry limitations.
Finish docs-only commit, green final CI, merge/release/source archive and pause automation.

Final acceptance: user confirmed installed visibility toggle/compact return and foreground Settings.
PR #1 merged to main at3b264240; final PR checks37631331612/37631339978 passed. Overnight automation
finish-lantern-overnight is PAUSED (tool confirmed). Installed build19 and signed0.1.14 rollback
are verified; native login On/Connected/live Codex/Enabled observed; both hook hashes unchanged.
Usage relay remains optional and unapplied for the unsupported native VS Code telemetry path.
No required feature work remains; next-login/physical hover/unsteered typing are manual residuals.
Final release/source archives are tied to the immutable v0.2.0 release; do not re-run unchanged checks.

## Arc interface refinement — 2026-10-07

- [x] Retire usage end to end; preserve hooks and confirm no installed status-line wrapper.
- [x] Shared native Arc controls, semantic badges, emblem and compact gear menu.
- [x] Content-sized Settings/Connections/companion, rounded surfaces and expanded-header drag.
- [x] Regression tests, release smoke/signatures, isolated native interaction review.
- [x] Safe upgrade with rollback, unchanged configuration and final GitHub handoff.

Arc checkpoint: branch codex/arc-interface from clean main3cf4d0a. Usage removed from production
Core/App/Hook/Transport and active docs/fixtures; unknown-envelope fail-closed test retained.
Live hook hashes55afa1a2/28c7bf5e unchanged, neither contains an owned usage status-line wrapper.
72 functions/77 parameterized cases passed with local socket permissions (sandboxed sockets denied).
Content-size/header-drag tests failed before PanelLayout implementation; menu blocks global Allow.

Native review: /private/tmp/lantern-arc20-ybpt77q_/Lantern Arc Review.app,
bundleID local.imad.Lantern.arc-review20, private runtime/codex/claude directories. Review defaults
have autoHide/global shortcuts off, so the installed app keeps its registrations. Supplied transparent
emblem cutout generated via built-in editor, bundled template in exact accent. User head/icons/sound unchanged.
Build20 review: empty396px, two rows311px, nine rows640px/scroll, Codex filter518px, expanded title
pan moved and persisted x1410/top1282 without collapse. Arc menu/Connections310px/preview630px/Done
worked; native semantic badges and truthful states visible. End selected Claude after explicit reopen.

Settings refinement: content-sized tab window catches a native failure — initial preference callback
only supplied400 and didn't update after General selection, clipping footer. Build21/22 rejected for
that outcome; temporary numeric diagnostics in build23 reproduced it and are now removed. Build24
uses onGeometryChange on actual content instead; review must pass both tab directions before rollout.
CompanionHostingView.needsPanelToBecomeKey lets manual clicks regain key after Settings; automatic
panel.canBecomeKey gate still preserves passive focus. Native verification of final focus/approval pending.

Production remains installed0.2.0/build19. Do not install stale candidate ZIPs. Prepared signed build24
package is being built; review update script /private/tmp/lantern-arc-review-update.py preserves each
old private app, verifies stopped process, and only removes a proven unowned/refused private test socket.
Private review was quit through CmdQ after build23 trace; confirm before update. Latest receipt is
outputs/arc-review.json (update it after final bundle), docs/VERIFICATION still needs final evidence.
Next: review build24 Settings resize/footer, private socket approval and header drag; tests/smoke/signatures;
commit/push/PR then fresh real empty queue / signed build19 rollback / safe installation and release.

Final native/install checkpoint: build25 full72/77 passed, packaged relay smoke/signatures/CRC and retained
assets passed. Direct content geometry fixed Settings; final Connections310/preview630 and both Settings
footers passed. Real coordinate click after Settings regained keyboard navigation; AX-only activation
does not establish native mouse focus. Non-executing sample returned exact allow and collapsed. No real
approval or configuration action was performed. Expanded header remains draggable without collapse.

Installed0.3.0/build25 after fresh empty real queue, ordered Quit and guarded verified swap. Signed19
rollback: ~/Applications/Lantern Backups/0.2.0-build19-b729e846/Lantern.app. Both live hook hashes unchanged;
no owned usage wrapper. Compact restart/real Codex/242-point one-row view/both installed hooks observed.
Retained idle5min, login On, two expected bindings and Enabled sound; no registration errors. Production
is left compact and listening. Code is final; GitHub commit/PR/checks and source archive remain.
No need to rerun unchanged local tests/package. Physical composited corners/new hover/typing/next-login
are explicit residuals, not blockers invented for otherwise complete implementation. Automation remains paused.

Completed handoff: implementation source19ad6b8 passed push37650664324 and PR37650672576 checks.
PR #2: https://github.com/imadd23x/Lantern/pull/2. App ZIP SHA406fa50e, source ZIP checked against all97
tracked blobs; SHA256SUMS covers both. Final documentation closes this checkpoint; regenerate the source
archive at the final documentation commit. Local app/build25 is already verified and unchanged by docs.
Main/release publication remains a review choice; the feature branch and installed result are ready.
No required implementation, local verification or installation work remains for this refinement.

## Guardian subtitle and Settings crash — 2026-10-08

- [x] Replace the gear-menu subtitle with "Your desktop guardian".
- [x] Reproduce and remove the shortcut label crash on Settings → Agent connections.
- [x] Regression checks and repeated isolated native focus/recording/connection review.
- [x] Signed patch package, safe upgrade with rollback and preserved hooks, GitHub checks.

Scope: shortcut label rendering and static subtitle only. Retain keyboard capture/release,
approval identity/expiry/queue, passive focus, native connection backup/transactions and current design.
Crash reports from installed25 (2026-10-08 15:02:58 Dubai) and isolated25 (15:08:25) both terminate
at ShortcutInput.draw line96, NSAttributedString.size → CoreText ApplyFont → nil dictionary object.
The isolated Shortcuts/Connections focus loop reproduces the same abort before any configuration write.
Hypothesis: custom attributed-string measurement on inactive redraw is unsafe on this host; use the
native label renderer while retaining the existing capture view and Arc surface. Verify readable glyphs,
record/release/cancel and repeated focus transitions before installation. Rollback retains signed25;
do not quit a real pending approval or unlink an owned/live endpoint. No unrelated source/config changes.

Patch checkpoint: 0.3.1/build26 uses a native NSTextField for shortcut text, keeps the recorder as its
mouse/key/accessibility target, and retains custom Arc surface drawing. Full74/79, relay smoke, ZIP CRC,
strict signatures and five retained assets pass. The offscreen rendering check also passed before the
fix; it is coverage for readable/clickable labels, not evidence of reproducing the intermittent abort.
The red evidence is the actual isolated25 crash, matching the installed report. Patched focus handoffs,
record CmdK/release and Escape/cancel pass through CUA; long rapid loops stopped on targeting/focus
guards while the app stayed alive, so do not claim a completed20-cycle stress test.

Installed26 over stopped/crashed25, removing only the proven unowned/refused stale socket. Signed rollback:
~/Applications/Lantern Backups/0.3.0-build25-833cd66d/Lantern.app. Preserved current Claude hash06f4c844;
Codex55afa1a2 unchanged. Installed Guardian caption, live Codex/Connected, both Settings→Connections
paths, both hooks, exact shortcut defaults and login On observed. Left compact and listening.
No real approval, paid inference or agent configuration write occurred. Private review is quit.
Code/artifact are final; finish docs, GitHub checks and source archive without repeating unchanged package tests.

Completed guardian patch handoff: source80e5c7e passed GitHub push37774403626 and PR37774409373.
PR #2 includes the reproduced crash, native-label fix and current installed evidence. Final source archive
is regenerated and compared with every tracked blob at the closing documentation commit. Installed26
and app ZIP remain unchanged by docs. Main/release publication remains a review choice; no further
implementation, installation or local runtime work remains for these two requested changes.

## Approval sync and private portable download — 2026-10-10

- [x] Trace installed Claude/native hook schemas without account files, transcripts or paid inference.
- [x] Fix request-owned Carbon tokens, stale/held releases and delayed presses across cards or menus.
- [x] Cancel an orphaned Claude relay through every transport phase with a shared monotonic deadline.
- [x] Run 78 Swift tests (83 parameterized cases); old compiled relay fails parent-cancellation regression, patched relay passes receive/send/sibling/partial-reply checks.
- [x] Final fresh internal review found no further approval contract failure; external review offered and declined.
- [x] Package 0.3.2/build27 for arm64 and x86_64; strict signature, extraction and personal-path audit pass.
- [x] Packaged smoke, isolated native click/queue review and safe installed update.
- [x] GitHub private release/checks and exact source archive.
- [ ] User choice on keeping Claude's Lantern Allow versus accurately mirrored VS Code-only approvals.

Current supported PermissionRequest has no tool-use ID. Parent liveness is only cancellation
evidence, not a VS Code approval callback. Public mods provide exact decision IDs but no supported
identity bridge to the existing anonymous permission hook or native permission-dialog race.
Do not guess from matching commands, ordering or one visible card. Keep both existing agent
connections/settings unchanged; the repo remains private with all five supplied resources.
No public conversion, history rewrite, vendor patch or usage feature is authorized.

Completed patch handoff: 0.3.2/build27 is installed, compact and listening. Both
configuration hashes are unchanged and both providers show Hooks installed. Real Codex
activity is observed. Signed rollback: ~/Applications/Lantern Backups/0.3.1-build26-db747f8/Lantern.app.
The isolated review is quit. Both samples returned their own Allow; the first was clicked
by the user before the first snapshot (confirmed), the second by CUA, and the queue drained
to a pill. CUA's synthetic shortcut established no native key result. Physical sequential
shortcuts and new live Claude approval behavior remain unverified; do not claim otherwise.
Private release v0.3.2 targets db747f8, with all 103 source blobs checked and matching remote
app/source digests. Push38082863424 and PR38082867422 checks passed. Main is not merged;
use the release app asset for installation. No repeated local build/test is needed for this
closing documentation. Immediate native Claude decision sync still requires the user's
surface choice; Lantern's existing Allow button remains intact meanwhile.
