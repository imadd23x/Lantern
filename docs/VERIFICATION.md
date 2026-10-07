# Verification evidence — Lantern

2026-10-05. Results below distinguish observed local behavior from live host activation.

## Observed checks

| Layer | Evidence | Result |
|---|---|---|
| Platform | macOS 27.0.1, Apple silicon, Swift 6.4 Command Line Tools | Native build supported |
| Domain/config/transport | `bash scripts/swift.sh test` | **20/20 passed** |
| Release app | `bash scripts/package.sh` | Release build, icon rendering and packaging passed |
| Workspace signature | `codesign --verify --deep --strict outputs/Lantern.app` | Passed immediately after packaging; **later recheck failed** when File Provider reapplied FinderInfo |
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
  is removed and the delivered signature reverified. **The metadata returns later, failing strict checks on
  the workspace copy.** Archive extraction/signature verification passed in unsynced temporary storage.
  Deliver the ZIP and extract to a stable unsynced local folder before connection; no sync policy was changed.
- Installed CLT emits linker warnings for absent Developer framework/library search directories.
  These warnings did not prevent successful compilation, linking, packaging or tests.
- Unix socket tests and release symbol generation required execution outside the filesystem sandbox;
  they used isolated temporary paths. No live agent settings were changed by those checks.

## 0.1.1 native UI refinement

2026-10-05. Source selection and acceptance were registered in `docs/UI-REFERENCES.md` before edits.
No React source/runtime or new production dependencies were embedded. Three MIT notices are included
in the source and bundled Resources. The downloaded `component-library/` remains user-owned and untracked.

| Check | Observed result |
|---|---|
| Final source tests | `bash scripts/swift.sh test`: **20/20 passed**; release build also passed |
| Packaged relay | Absent app/malformed input and Allow/Deny/Delegate for both providers passed |
| Archive and notices | Strict/deep signature verification passed after ZIP extraction in unsynced temporary storage; bundled `ThirdPartyNotices.txt` exists |
| Isolation | Distinct `LanternReview.app` identity, same compiled binaries, socket/config paths under `/private/tmp/ln-ui-gvjrgm_k`; existing user app was not stopped |
| Filtering/focus | Accurate All/Codex/Claude counts, selected AX traits, native click and Arrow/Home/End navigation; rapid reversals settled on the chosen provider |
| Queue routing | Two actual packaged relays: select Claude request 2/Deny, then Codex request 1/Allow once; each exited 0 with its exact provider response |
| No default approval | Return while the filter was focused left both queued proposals pending |
| Disabled approval | Missing tool input exposed a disabled Allow once; an activation attempt left the proposal pending, then Deny returned only deny |
| Cancellation | Dragging from Allow once to outside the button left the complete proposal pending; explicit Deny returned only deny |
| Full proposal | Long input remained scrollable; the final `END OF COMPLETE PROPOSAL` marker was visibly reachable |
| Compact/expanded | 246×46 and 460×584 layouts retained attention and all five session identities after collapse/expand |
| Connections | 520×510 sheet, proposed/current comparison and provider switch remained readable; preview-only checks wrote no settings |
| Normal motion | Final archive's decoded consecutive screenshots: avatar 2,801 changed pixels, working badge 176, completed badge 0 in their bounded regions |
| Reduced motion | `--reduce-motion` in the review process: avatar, status badges, filter and main content each had **0 changed pixels** between decoded captures; keyboard filtering still worked |
| Clean exit | Review app exited 0; its socket was removed; temporary agent config directories stayed empty |
| Scope/scripts | No diff in Core, Transport, Hook or AppModel; panel sizing/screen path, sounds and action callbacks unchanged; shell syntax checks passed |

Native tests exposed absent keyboard focus on plain filter buttons; explicit SwiftUI focusability fixed it.
The filter supplies its own amber focus outline rather than adding the platform's default focus effect.
Reduced-motion frame verification excludes the computer-use cursor overlay in empty space below the
main content: raw screenshot bytes differed there; decoded content pixels were identical. This is a
short observed rendering check, not a frame-rate or CPU benchmark. The OS preference itself was not changed.
Expiry/session-end invariants remain covered by the existing tests; native expiry was not timed again.

Shared `UIChrome.swift` owns presentation timing/styles and the system-or-local reduced-motion value;
`ProviderFilter.swift` and `SessionStatusBadge.swift` receive typed domain values without owning agent
actions. Filter animation is scoped to its own control so parent session filtering remains immediate.
Each approval card is keyed by request ID to reset scrolling when a different proposal is selected.

## 0.1.2 supplied portrait

2026-10-05. The avatar request supersedes the original procedural-artwork choice. The attached
`Young_Adult_Rick.webp` is copied unchanged into the app's SwiftPM resource bundle. Source and extracted
bundle bytes match SHA256 `d99e5d7853e6c0434827cd7386bb33ca05020a64d34c78bc27d134e2ad498438`.

| Check | Observed result |
|---|---|
| Regression suite | **20/20 passed** after the avatar/resource change |
| Packaged relay | Missing app, malformed input and Allow/Deny/Delegate for both providers passed |
| Release | 0.1.2 build and icon rendering passed; ZIP extracted into another temporary folder passed strict/deep signature verification |
| Actual artwork rendering | Relocated app's `--render-icon` renders the same SwiftUI avatar; PNG visually inspected and shows the supplied Rick portrait |
| Portable resource lookup | With only a disposable copy's embedded resource bundle renamed, `--render-icon` exits 1 with the explicit missing-portrait error; no build-cache fallback |
| Scope | No changes in Core, Transport, Hook, AppModel, approval/card/filter actions or panel geometry; source bitmap remains unchanged |
| Native panels | After the user unlocked the Mac, the relocated review app displayed Rick in both 460×584 expanded and 246×46 compact states; collapse/expand preserved the working session |
| Attention/approval | Synthetic Claude approval visibly added the amber portrait outline/glow; native Deny returned the documented deny response, executing no tool |
| Portrait motion | Working portrait changed by 5,693 pixels across separate observations; with process-local `--reduce-motion`, portrait and main content both had 0 changed pixels across captures |

Two initial packaging attempts hit the previously observed File Provider metadata error immediately
after copying the app into synced Documents. Signing in unsynced staging passed both times. Packaging
now creates the ZIP from that verified staging first, then removes only FinderInfo from generated app
and resource-bundle roots. It reports the known workspace metadata error separately; other signature
errors remain fatal. The subsequent package command and relocated archive verification passed.

Working-only bobbing, static reduced motion and attention indication are preserved in the avatar view.
The photograph's facial expression remains the supplied one; there is no generated face animation.
No Downloads dependency, source-image edit, global hook activation or system preference change was made.
The Mac was initially locked; native checks resumed after the user manually unlocked it.

## 0.1.3 transparent green companion and gaze

2026-10-05. The built-in image editor rejected the Rick head cutout; the user's explicit green
fallback was used. The supplied attachment remains unchanged in Downloads. The new app has no photo
tile, bitmap/resource bundle, or build-cache image dependency. Prompt/provenance: `docs/AVATAR.md`.

| Check | Observed result |
|---|---|
| Regression and gaze tests | **25/25 passed**: 20 existing tests plus 5 app tests for neutral/near direction, far-pointer elliptical bounds, invalid input and native attach/detach/dismantle ownership |
| Sampler teardown | A non-presented test window exercises real NSView attachment and removal; dismantling clears its callback and prevents an already queued visibility recheck from restarting it |
| Packaging | 0.1.3 ZIP built from strictly verified unsynced staging; relocated app passed strict/deep signature verification, had matching notices and no portrait resource bundle |
| Icon | Same green SwiftUI avatar with static neutral gaze; two relocated `--render-icon` exports were byte-identical and visually inspected |
| Packaged adapters | Absent app/malformed input and Allow/Deny/Delegate for both providers passed |
| Native panels | Expanded 460×584 and compact 246×46 show the transparent green silhouette; clicking the compact avatar itself opens the expanded panel |
| Attention/approval | Green glass retains its color with amber attention outline/glow; native Deny returned only the matching synthetic Claude deny response and executed no tool |
| Native motion | Raised, visible diagnostic review: avatar changed by 3,631 pixels across separate captures; working timeline trace advanced in 1/24-second increments |
| Reduced motion | Process-local override with an active synthetic session: avatar and main content had 0 changed pixels across captures |
| Real cursor input | Diagnostic reader sampled flipped local cursor coordinates in the actual CompanionPanel, and recomputed coordinates across collapse/expand; pupils visibly differed from neutral |
| Scope | No source changes in Core, Transport, Hook, AppModel, CompanionView, ApprovalCard or PanelController; shell syntax and diff whitespace checks passed |

Verification found two defects and fixed them: the unsupported AppKit reader must be absent from
static ImageRenderer exports, and disabling hit testing on the whole avatar excluded it from the
compact button's hit area. Only the transparent cursor reader/eyes now disable hit testing. The reader
sits outside the animation timeline, rechecks presentation after initial layout, and owns one timer
per attached avatar. AppKit timer/run-loop ownership follows [Apple's Timer documentation](https://developer.apple.com/documentation/foundation/timer).

The test tool uses a virtual cursor: coordinate clicks did not change the physical coordinates read
by NSEvent. Also, its review window initially reported itself occluded (raw state 8192). Raising that
exact window exposed the visible bit (8194), started the sampler and allowed actual motion capture.
Initial identical normal-mode frames therefore did not establish working motion; the raised-window
check above did. This is a short rendering observation, not a frame-rate or CPU benchmark.

Temporary frame/window/cursor traces were removed before handoff packaging. The first clean-release
onscreen recheck was blocked when the Mac locked again; no automatic unlock/bypass was attempted.
The user was asked to unlock and to manually check physical left/right mouse movement.
While locked, only the disposable review PID was terminated; after confirming it exited, its owned
temporary socket was removed. Both isolated agent configuration directories remained empty. Earlier
review instances quit normally through the native menu shortcut. No existing user app was stopped.

### Clean-release recheck after manual unlock

2026-10-05. Re-extracted the final 0.1.3/build 4 app ZIP into unsynced temporary storage and verified
its strict/deep signature. Refreshed the disposable review from that extraction, changing only its
temporary bundle identity and signing it locally. Runtime and both agent configuration paths remained
isolated. Raised each review window before observing its rendering.

| Check | Fresh observed result |
|---|---|
| Physical cursor tracking | User moved the physical mouse left and right and confirmed **both pupils follow** |
| Artwork and compact interaction | Expanded and compact panels show the green native silhouette with no photo tile; clicking the compact avatar itself expands sessions |
| Normal motion | Synthetic Codex working event reached the released app; separate decoded screenshots showed **3,631 changed avatar pixels** |
| Attention and decision routing | Synthetic Claude permission request showed the amber attention glow and full proposal; native Deny removed its card and the packaged relay returned the matching `behavior: deny` response, exit 0 |
| Reduced motion | A second launch with process-local `--reduce-motion` and an active synthetic session produced **0 changed avatar pixels and 0 changed main-content pixels**; gaze was neutral and compact avatar click still expanded the panel |
| Cleanup | Both reviews quit through the native shortcut, exit 0; no review process or owned socket remained, and both isolated agent configuration directories were empty |
| Archives | App/source checksum verification passed; source ZIP CRC and file content matched, with no component-library, output, Git or portrait files |

The final hardware-direction check is now complete. No source changes or app rebuild were required
for this recheck. The 25-test implementation result above was not rerun for this documentation-only
follow-up. The actual macOS Reduce Motion preference and live agent integrations remain untested as
listed below; the process-local override does not change system settings. Synthetic proposals were
never executed, and no installed user app or live hook configuration was changed.

## 0.1.4 restart and presentation verification — 2026-10-06

Baseline 0.1.3 was exercised in isolation: a working row appeared, native Quit exited 0, and reopening
returned to the unconditional setup screen. The user confirmed new activity already resumed normally.
The correction recognizes installed hooks; no session cache or reconnection transaction is needed.

- **30 tests passed** (21 Core/Transport + 9 App): complete/partial/other-relay/disabled hook inspection,
  bounded placement with offscreen/invalid coordinates, and a real proposal while hidden followed by
  Show and explicit Deny. Hide dismisses setup; stop removes the owned socket. New regression tests
  first failed for missing APIs. Existing CLT linker search-path warnings remain, with no Swift concurrency
  warnings. `git diff --check` passed.
- Final release packaging and strict/deep signing passed in unsynced staging and on the unmodified
  extracted archive. Packaged relays passed absent-app, malformed-input and Allow/Deny/Delegate smoke.
- Native queue review displayed two full synthetic proposals. Selecting Codex and Deny returned only
  Codex's `behavior: deny`; Allow once returned Claude's `behavior: allow`. No proposed command ran.
- Native card review passed compact (288×46), expanded (460×584), Escape, rapid toggle reversal,
  filter keyboard selection/wrapping and stationary segment labels/counts. Dragging wrote the review's
  position preference; restart retained it. Reset removed it. Menu Show/Hide/Reset were exposed.
- Hide removed the review window from the enabled inventory. Its process stayed alive and its private
  socket acknowledged another event with `delegate`. The UI tool cannot inspect a windowless app's menu,
  so hidden-to-Show is covered by the lifecycle test rather than an onscreen menu click. One disposable
  hidden review was stopped by SIGTERM, leaving its stale socket in isolation; later reviews used new
  runtime paths and exited 0 through native Quit with their owned sockets removed.
- The final extracted build with process-local `--reduce-motion` received a working event. Decoded
  460×584 captures had **0 changed avatar pixels and 0 changed body pixels**; Escape restored compact
  bounds. The system accessibility setting was not changed.
- **Installed 0.1.4/build 5** at the existing path with a rollback copy. Real Codex tool activity returned
  immediately. The empty Claude filter recognized installed hooks and awaited activity. Both agent
  files were unchanged across upgrade, and trust records were not edited.

App ZIP SHA-256: `9c9fd3f9473f61481c8e44cd0115156cc870afb207056b9ea2aee64c5adeabad`.
Machine-specific evidence: `LOCAL-INSTALLATION.md`. The unobserved live Claude/permission and hardware
paths below retain their limits; synthetic routing and geometry tests do not verify those paths.

## Remaining validation

### 0.1.9 Claude navigation and green appearance — 2026-10-06

- Confirmed the user's live Claude extension tab already exists in the Trak Football Code window;
  the hook's cwd is a changing worktree rather than that window's identity. Inspected installed
  Anthropic extension 2.1.289 URI registration/createPanel: an unmatched /open session can create a
  panel, so it is not used as an uncertain fallback. Primary routing references:
  [VS Code URL routing](https://github.com/microsoft/vscode/blob/main/src/vs/platform/url/electron-main/url.ts)
  and [Claude VS Code sessions](https://code.claude.com/docs/en/vs-code#resume-past-conversations).
- The corrected domain-backed regression failed on the legacy vscode://file worktree route before
  the fix. The full suite passed afterward: 21 core/transport + 20 app tests (41 functions, 45 cases).
  Private sockets cover navigation failure retaining both requests, selected-only Delegate on success,
  row navigation not delegating, ended-session rejection and escaped Codex identity. First fixture
  construction used an inaccessible initializer; it was corrected to use the public SessionState seam.
- Package and both-provider relay smoke passed. After the workspace moved to Documents/Codex, a local
  copy preserved all 62 tracked files and both pending navigation files; the full suite/build/smoke
  passed again there. Original source/library are retained. Current source is Documents/Codex/Lantern.
- Large native renders identified and then removed the upper light fringe; final head clipping also
  cleaned the lower-left cheek. Compact and expanded native review showed the supplied white eyes
  and green attention/brand/action accents. No original bitmap bytes changed. The 2-pixel sampling
  margin was packaged again; it changes only static drawing, so no geometry-mirroring tests were added.
- Final isolated native row navigation preserved the Code window title, selected Claude tab and tab
  count, with the sample approval still queued and no navigation error. Answer in agent then returned
  exit 0 with empty stdout/stderr (Delegate) from the private packaged relay. The same window/tab state
  remained unchanged; the native Window menu listed only the existing Review live run 5 tasks window.
  No live permission decision, prompt, workspace replacement, VS Code restart or new session occurred.
- The final review quit through its own native menu, exit 0, and released its private socket. An earlier
  review and native handoff attempt were interrupted by the environment/runtime change; their missing
  temporary files/results are not used as evidence. Some background-review captures returned invalid
  capture parameters; subsequent Code identity checks and final sample handoff provide the evidence above.
- Installed verified 0.1.9/build 10 at the stable relay path with a 0.1.8 rollback. Both hook files were
  byte-for-byte unchanged, and the fresh app showed live Codex activity and Local connection ready.
  Before upgrade the old restarted instance found an occupied socket. After native Quit, its exact
  current-user endpoint had no lsof owner and ECONNREFUSED; the same inode was verified before removal.
  Only that stale endpoint was cleaned; automatic recovery policy remains outside this update.

Navigation preserves the selected conversation in the last-active existing Code window. It intentionally
does not recreate/resume or guess another inactive tab/window. Original 0.1.8 physical typing confirmation
remains unobserved and is not claimed here. Existing CLT linker search-path warnings remain.

### 0.1.8 approval restoration — 2026-10-06

The original real-socket regression failed because the card remained expanded after Allow. After
the fix, the full suite passed: 21 core/transport and 16 app tests (37 functions, 40 parameterized
cases). Coverage includes Allow/Deny/Delegate, two-provider queue retention, manual cards/Connections,
notification-before-request ordering, relay cancellation, and actual timer expiry with an injected
clock. Hidden/listening and request-scoped decisions still pass. Test fixture constructors were
corrected to supply required working directories. A timeout case initially assumed a thrown error;
inspection confirmed the relay contract safely returns Delegate on disconnected/timeout reads, and
the assertion now checks that actual contract.

Concurrent blocking test clients exhausted the cooperative executor used by their main-actor callbacks.
The same failing case passed alone in 15ms. The new medium-test suite now runs sequentially, retaining
every assertion and original timeout; the full suite passed in that configuration. No product transport
policy was changed to accommodate testing. Release/package and packaged relay smoke passed; existing
CLT linker search-path warnings remain.

An isolated native 0.1.8 review automatically expanded for two real packaged relay proposals. Coordinate
clicks on Allow once kept the first remaining request visible, then returned the final card to a 288×46
pill. Both Codex and Claude relay processes exited 0 with their individual Allow output. No proposed
command executed. Native keyboard routing is checked with an unsteered user FocusCheck separately;
targeted automation is not treated as proof of which app receives subsequent physical typing.

The user reported that the FocusCheck request was no longer visible. Its relay log records Allow,
not expiry, and exit 0. Typing resumption after that click remains unconfirmed; a follow-up question
is pending. Once the non-key review collapsed, the UI tool could no longer reliably capture its menu
(invalid capture parameter); it was stopped by exact process identity and its confirmed stopped,
unowned/refusing private socket was removed. No live endpoint was removed.

Final 0.1.8/build 9 is installed with a 0.1.7 rollback at the stable relay path. Strict/deep signatures,
matching packaged binary/artwork and unchanged hook hashes passed. Quiet mode was restored; native
inspection showed live Codex tool activity and Local connection ready. Explicit opening now makes
the panel key for keyboard controls, while automatic presentations cannot become key. Native Tab
focused All agents in the manually opened final app. The full test/package/smoke sequence passed again
after that explicit-opening refinement. A saved interim 0.1.8 app is retained separately; the final
release ZIP and source archive are the authoritative deliverables.

### 0.1.7 avatar and compact-pill controls — 2026-10-06

- Final full suite passed: 21 core/transport tests and 9 native app tests. The hidden-listener test
  now exercises both visibility toggles, exact Show/Hide titles and preservation of its queued request.
  Release packaging and packaged relay smoke passed for both providers. Strict/deep signatures passed
  after extraction and installation; all three packaged bitmap assets exactly match their sources.
- A cleanup briefly left Connections calling a removed helper; release compilation caught it. The call
  was corrected and the full test → package → smoke sequence was rerun successfully. The smoke against
  the previous package before that correction is not used as evidence for this release.
- The isolated native app displayed the supplied head at compact/expanded sizes without a checkerboard
  rectangle, retaining the original white eyes. Expanded header had only avatar/brand/controls; no slogan.
  Native images were 288×46 and 460×584. Both provider icons and the demo proposal still rendered.
- Native drags from avatar, text, chevron and close button kept the pill collapsed and visible. Saved
  coordinates changed by the requested displacement, including text (-70,-40), chevron (-60,-57), and
  close (-65,-67); no embedded action fired. Ordinary arrow clicks and Escape still changed presentation.
  The visible native menu had exactly one Hide Lantern command and no Reset position.
- The UI tool cannot reliably inspect a windowless review's menu; it reported invalid capture parameters
  and sometimes restored its presentation. Hidden Show title/listener/queue behavior is verified at the
  AppModel interface, rather than claimed as a native hidden-menu click. That disposable hidden review
  was stopped by identity-checked SIGTERM; only its confirmed unowned/refusing private socket was cleaned.
- A separate review using process-local Reduce Motion received a synthetic working event through the
  packaged relay. Two decoded 460×584 captures had 0 changed avatar pixels. It quit normally, exit 0,
  removing its socket. No OS accessibility preference was changed. The user confirmed the physical
  up/down-arrow hover produces the rounded highlight in the installed app on 2026-10-06.
- Installed 0.1.7/build 8 at the stable relay path with a 0.1.6 rollback. Native inspection showed the new
  head on real Codex activity and Local connection ready. Both hook files were unchanged. The previous
  app released its live socket on normal Quit; no live stale-endpoint cleanup was needed. Existing quiet
  mode was restored through the native control and observed as Enable attention sounds.

Multi-monitor hardware and full VoiceOver remain unobserved; physical hover has the user's confirmation.
Existing linker search-path warnings remain; no new dependency, trust change, paid fallback or real
approval decision was introduced.

### 0.1.6 supplied Codex icon — 2026-10-06

Release build/package passed; strict/deep signing passed on the unmodified extracted archive and
installed app. Both bundled provider assets exactly matched their workspace sources. The Codex PNG
has real alpha (0–255), with no checkerboard visible in the native row. An isolated, separately named
demo app displayed both icons at actual size and quit normally, exit 0, removing its private socket.
The demo request was dismissed only in that isolated app; no real approval was decided.

Installed 0.1.6/build 7 at the existing relay path with a 0.1.5 rollback copy. Native live inspection
showed the blue icon on the real Building Tools Codex row, ongoing tool activity and Local connection
ready. The installed process owned the listening endpoint. Both agent files were byte-for-byte
unchanged across upgrade. Before upgrade, the old app again showed an occupied socket; inspection
found no lsof owner and ECONNREFUSED. After native Quit, only that same confirmed current-user socket
inode was removed. Automatic stale-socket recovery is unchanged and was not added in this icon patch.

No new logic tests or full-suite rerun were needed for this static asset substitution. Existing CLT
linker search-path warnings remain. Asset provenance and the exact built-in edit prompt are recorded
in `UI-REFERENCES.md`; installation/rollback evidence is in `LOCAL-INSTALLATION.md`.

### 0.1.5 supplied icon — 2026-10-06

Release build/package passed. Native decoding confirmed NSImage/ImageIO can read the 512×512
transparent WebP; the first named-image implementation rendered a blank tile onscreen and was
replaced with direct bundled-URL loading. The corrected extracted app displayed the orange icon in
a clearly marked demo Claude row. Resource bytes exactly matched the attachment; the generated
resource lookup has no build-cache or Downloads fallback. Strict/deep signing passed after extraction
and installation. Existing CLT linker warnings remain. No new logic tests were added for this static
asset change; the 30-test result above belongs to 0.1.4, rather than being claimed as rerun here.

Installed 0.1.5/build 6 at the existing app path with a 0.1.4 rollback copy. Native live inspection then
showed the new icon on a real Claude Code session row, real Codex activity and Local connection ready.
Both agent configuration files were byte-for-byte unchanged across upgrade. Before the upgrade,
the old app reported an occupied socket: lsof found no owner, and a connection probe returned
ECONNREFUSED. After stopping the unavailable instance, only that same owner-matching socket inode
was removed; no active endpoint was removed. The isolated review quit normally, exit 0.

- **Live Codex tool activity and Claude Code in VS Code session startup are verified** after the later
  user-authorized installation and manual Codex `/hooks` trust review. Exact native observations and
  configuration preservation checks: [LOCAL-INSTALLATION.md](LOCAL-INSTALLATION.md). Claude tool activity
  and a real host PermissionRequest/decision remain unverified; synthetic decision coverage is separate.
  The shared app-server control socket was absent, so it is not used. Managed/project policy can restrict
  user hooks in other workspaces.
- Codex deep links and Claude workspace links are implemented with escaped URLs; actual live chat/terminal
  navigation was not exercised. Claude opens/focuses its workspace, not one exact integrated terminal.
- Multi-monitor, full-screen and a full VoiceOver session were not exercised on this machine.
  The reduced-motion rendering path was verified with the process-local override; toggling the actual
  system accessibility preference was not tested.
- GitHub CI is enabled on the private repository; the initial import and test-harness fix are recorded below. Bundle is ad-hoc signed, not notarized/Developer ID signed.

The build and isolated validation used no credential-file reads, third-party package installation,
external messages, production mutation or global agent activation. Synthetic tool proposals were never executed.

## Decision

Local code/build/synthetic-flow acceptance and the extracted archive pass. The synced workspace copy
has the observed metadata limitation above. The ZIP remains the portable deliverable. The subsequent
authorized local installation is running with both providers' live startup/activity evidence above;
real permission decisions retain the stated verification limit, consistent with the pre-registered
partial-result rule in `SPEC.md`.

### 0.1.10 compact dragging and footer — 2026-10-06

The focused compact-Show regression first failed on the old implementation, then passed with
the fix. Full `bash scripts/swift.sh test` passed: 44 test functions (48 parameterized cases),
including stationary-screen-pointer stability, reversed/negative-coordinate grab-offset retention,
queued requests through compact Show and explicit expanded Connections. `git diff --check` passed.
Release packaging, strict/deep extracted signatures and packaged relay smoke checks passed.
The existing CLT missing linker-search-path warnings remain; no new dependency was introduced.

Isolated 0.1.10 demo: `/private/tmp/lantern-drag-95xscaqk/LanternDragReview.app`, private runtime
and agent-config directories, configuration writes disabled. Compact drags from text/avatar/arrow/
close stayed compact without triggering embedded buttons. Synthetic drag displacement is not a
reliable physical-motion measure; the virtual cursor/grip behavior differs from physical input.
Hands-on drag smoothness and bell hover confirmation are pending. Bell clicks changed its glyph and
accessible state between Enabled and Muted. The footer wording is absent. Connections opened its
sheet and left the expanded card after Done. Hidden/reopen inspection returned compact; visibility
policy is also covered by the model regression because native automation may activate/reopen its target.

Installed 0.1.10/build 11 at the existing app path. Strict/deep signing, all installed bundle-file
bytes against the extracted ZIP, version/build and unchanged hook hashes passed. Native restart
started compact; expansion showed live Codex tool delivery and Local connection ready. Sound
remained Enabled. No live approval, agent restart, trust or settings transaction was performed.
Final app is compact. The isolated review exited 0 and removed its owned socket. AppKit emitted
“Window move completed without beginning” during the synthetic native grip attempt; physical
drag behavior remains unconfirmed rather than being inferred from that attempt.
Rollback: `/Users/imad/Applications/Lantern Backups/0.1.9-build10-7fdae2e6/Lantern.app`.

### 0.1.11 drag icon removal — 2026-10-07

The only production UI change removes `GripView.draw`; its native mouseDown/performDrag,
frame, cursor, tooltip and compact pan are unchanged. No new or repeated logic tests were
needed for deleting static drawing code. Release build/package and diff whitespace checks
passed, as did strict/deep signatures on extracted, staged and installed bundles. Installed
files match the extracted package byte-for-byte; hook hashes are unchanged. Native expansion
confirmed no dots to the left of the avatar, retained accessible drag target, Enabled sound,
live Codex delivery and Local connection ready. Final presentation is compact. This verifies
the visual removal; no new physical drag-smoothness claim is made.

### 0.1.12 header spacing — 2026-10-07

Release build/package, diff checks and extracted/staged/installed strict signatures passed.
Installed files exactly match the package. Native inspection confirmed the avatar/title moved
20 points left, card-aligned avatar inset, unchanged right controls, retained accessible drag
target and live Codex delivery. Drag handlers and compact layout are unchanged; no new logic
tests or physical-motion claim for this static layout change. Both hook hashes and Enabled
sound are unchanged. Final app is compact.

### 0.1.13 connection dot — 2026-10-07

Two new real-listener lifecycle tests first failed before wiring the new state. Full Swift suite
then passed: 46 test functions (50 parameterized cases). Coverage includes Connecting→Connected
publication, idempotent start, disconnected shutdown, occupied endpoint failure without removing
its owner, successful retry and cleared startup errors. Existing session/approval/transport tests
passed. Status reflects the hook listener; idle agents do not imply failure.

Release package/diff checks, ZIP extraction and extracted/staged/installed strict signatures
passed. Installed bundle files match the extracted package. Native inspection showed a green
footer dot, no connection wording, Connected tooltip/accessibility help and live Codex activity.
Yellow is mapped to the tested Connecting state; synchronous startup is too brief to claim an
onscreen yellow capture. Failed/disconnected map to red; real failure/recovery were verified
through tests, without disrupting the user's listener. Final app is compact. Both hook hashes
and Enabled sound remain unchanged. No new relay/config behavior or artificial startup delay.

### 0.1.14 A-Train alert resource — 2026-10-07

Bundled the exact supplied MP3, SHA256
`02f4c9c109616020623e0f66d08eefb11799282cf34cfb7e9385da6f0e37a07b`.
Resource bytes match Downloads, extracted package and installed bundle. Native NSSound decoded
the packaged asset (0.32 seconds of valid audio; afinfo container estimate is 0.36 seconds),
returned true from play, completed playback and exited 0. This checks the native playback API,
not an observed real agent attention alert or a claim about what the user heard.

The model retains one decoded sound and the existing approval/attention/failure triggers and
quiet guard. Tink is a missing/undecodable-asset fallback. Static resource swap: no new or repeated
logic tests. Release build, diff check and strict extracted/staged/installed signatures passed.
Installed bundle files match the package. Native restart showed live Codex delivery, Connected
status and unchanged Enabled sound; final app is compact. Both hook hashes are unchanged.

### GitHub import and test executor fix — 2026-10-07

Created private `imadd23x/Lantern`, default main, and uploaded source history plus v0.1.11–v0.1.14.
The first main SHA matched local `1b60056f55b3742e627664c1b313738ae49830e0`. Scanned 259
historical blobs for common credential patterns and sensitive config filenames; none matched.
No runtime agent configuration, generated build output or other project files were uploaded.

Initial Actions run 37532856964 failed two permission-flow tests with delayed delivery/timeouts.
Unlike the local Swift runtime, the runner executed both test targets together. Detached tasks
performed blocking socket reads and could starve the cooperative executor required by model
callbacks. Shared LanternTestSupport now runs that I/O on dedicated threads and resumes an async
continuation. All 18 exchange sites retain real sockets, decisions and deadlines; all test and
assertion counts are unchanged. No production executable depends on the test support module.
Full local suite passes (46 functions / 50 cases); remote checks are the acceptance gate for this fix.
Current remote results: https://github.com/imadd23x/Lantern/actions/workflows/checks.yml
The installed 0.1.14 app and hook configuration are unchanged.

### 0.2.0 desktop additions — 2026-10-07

Implemented configurable native Carbon shortcuts/recording and shared request/provider selection;
idle compact hide, pointer-entry reveal, pin and interaction blockers; native login controls with
truthful OS status; validated five-hour/week usage and preserving local status-line relay/setup.
Arc switch/progress references remain native adaptations with existing notices. No dependencies,
auth-file access, experimental extension API calls or paid inference were added.

Tests failed before each logic slice. Full local suite passed 68 functions / 72 parameterized cases
(28 Core + 40 App) in `/private/tmp/lantern-0.2.0-tests.log`. A final one-line Settings key-window
delegate refreshes the login status after returning from macOS; its three focused guard/login tests
passed. Final release packaging and both smoke fixtures passed; the complete final code suite,
packaging, smoke fixtures and whitespace checks also passed in
[GitHub CI run 37588602158](https://github.com/imadd23x/Lantern/actions/runs/37588602158)
for source commit `8dc91d8eaa4ee408832f6459650238285551623d`.

Coverage includes retained hotkey registrations on failure, disabled/metadata-only bindings,
stable request selection without decisions, idle blockers/manual hiding/passive reveal, queue
restoration and expiry, native registration errors/approval states, canonical installed-path guards,
usage missing/stale/reset/invalid windows, additive discriminator rejection, no-session/no-decision
delivery, reversible absent/null wrapper snapshots, idempotence, exact backups and stale previews.
Fresh review's boolean-vs-number wrapper defect was reproduced with a failing test and fixed using
canonical JSON comparison. Review also produced temporary-app and missing-executable setup guards.

Both packaged relay fixtures passed. The usage fixture verifies malformed/600KB stdin, early prior
command exit, absent Lantern, stdin/stdout/stderr/environment/cwd/exit preservation, quota-only wire,
and no printed permission grant even from an unexpected allow acknowledgement.

The ZIP CRC passed. Python's generic extraction exposed AppleDouble metadata as files and failed
the temporary copy's signature check; no such copy was installed. macOS `ditto` extraction passes
deep strict signatures for app and relay. The supplied head, provider icons and A-Train resource
match installed0.1.14 byte-for-byte. The verified app ZIP is `outputs/Lantern-0.2.0.zip`,
SHA256 `9df0cfe60e5efc53ecc2b305076c22227b3fe96282e25b1c7a373566a4c68561`.
The candidate source ZIP passes CRC and matches every tracked blob in its archived commit;
`outputs/SHA256SUMS` records both archive digests. Agent settings hashes remain unchanged:
Codex `55afa1a23c58eeb767e50bc48161f61afe24f2edbebcec87fe7be48a72b4d779`;
Claude `c5eefd580bab15712e8f580351933f1d2be7cb0398ea4491a0c513d7b2191fa0`.

Native review/upgrade is **pending**, not a completed live validation. The isolated review bundle
was prepared with private runtime/config paths and a distinct identity, but computer use returned
that the Mac is locked; it cannot unlock the screen. Installed app remains0.1.14/build15. No new
login registration or usage configuration was attempted. Finish the native review and safe upgrade
after manual unlock; do not replace a running app with unknown live approvals.

Claude extension2.1.289's native panel has no established documented public quota export.
The supported source is [Claude's status-line JSON](https://code.claude.com/docs/en/statusline),
not private messaging or credentials. Native-panel usage stays unavailable until valid data arrives.
Next-login behavior, physical hover/focus, multi-display and exact inactive-tab navigation remain
separate live checks; existing safe Claude navigation code is unchanged.

The feature branch is published as [draft PR #1](https://github.com/imadd23x/Lantern/pull/1).
Main and release tags remain unchanged pending native acceptance. The staged installer is
`/private/tmp/lantern-install-0.2.0.py`; it has not run. It stages and verifies the new bundle,
retains a unique 0.1.14/build15 rollback copy, compares hook hashes and restores the old bundle
if replacement fails. Run it only after the installed app is observed without pending approvals
and quit through its own menu. Remove any installed usage relay before a pre-0.2 rollback.

### 0.2.0/build17 shortcut refinement after unlock

The user narrowed global actions to Command+Return Allow once and Command+Option+H Hide.
The prior five navigation actions are removed. Tests reproduced missing action APIs, a held chord
at registration, precise expiry delayed by polling, and late callbacks after disable before fixes.
The final full suite passed 76 functions / 81 parameterized cases (28 Core + 48 App functions).
Both packaged activity and usage fixtures pass. Logs: `/private/tmp/lantern-0.2.0-build17-*.log`.

Three bounded internal review cycles found and resolved latch clearing during queue/registration
churn, premature card appearance, edit-path eligibility bypass, nonanimated relayout readiness and
expiry registration timing. The final read-only review found no material scoped violations.
Extra external review was explicitly skipped. Native registrations retain held references only to
receive release; every callback re-checks current enabled/visible/displayed/deadline conditions.

The build17 ZIP passes CRC, macOS extraction and deep strict signatures. SHA256:
`6d95ec16bf5771172cee93bbec98bddd43f52d017140d448a4b3c0e49304ec14`.
Head, both provider icons and A-Train remain byte-identical to installed0.1.14. Build16 ZIP/source
copies are retained. New isolated review: `/private/tmp/lantern-build17-mpz41nko/review/Lantern Shortcut Review.app`,
with private runtime/config directories and configuration/login writes disabled.

Native Settings shows exactly the requested two defaults, with no visible registration error.
Command-key recording now commits after release: CUA changed the isolated Allow binding to Cmd-K,
then restored Cmd-Return; neither remained stuck in Recording. The private non-executing
ShortcutCheck proposal showed its Cmd-Return badge. The user pressed Cmd-Return, confirmed return
to the pill, and its socket client received exactly `allow`. Physical Hide was not clearly confirmed
on the first attempt; a clarified second check is pending. Unsteered physical typing is not explicitly
confirmed by that response. No real agent permission was clicked or granted by automation.

The native-control launch took 86 minutes to return despite a timeout; subsequent ID-based bindings
and actions returned promptly. An idle review window was ordered out, with no windows available;
explicit reopen returned the compact pill. This demonstrates idle hide and compact reopen, not
physical hover reveal. Build16 fresh/reset/missing quota renders and preserving preview passed.
Installed0.1.14 is unchanged pending the safe upgrade; native login status/next-login remain pending.

### 0.2.0/build18 visibility toggle and rollout gate

After confirming physical Cmd-Option-H hides the private review, the user requested the same
chord also Show. The visibility regression failed on always-Hide before delegating to the existing
`toggleCompanionVisibility` path. Show returns compact, with the listener and queued request IDs
preserved by existing real-socket lifecycle coverage. The stored raw action key remains `hide` for
compatibility; its code name and UI title now describe visibility. No approval-path logic changed.

Full 76-function/81-case suite, both packaged smoke fixtures, ZIP CRC, macOS extraction and deep
strict signatures pass. Build18 ZIP SHA256:
`6fc4b4e6b7a8e8125727fbb29ae54e5bd31ae784ff1c5d85bc2d28e0249aa8c9`.
Supplied assets match installed0.1.14 exactly. Build17 app/source archives are retained.
Private review was quit through its own menu shortcut before rollout.

Live settings changed independently during the day. Both current JSON roots are valid, same-user
regular files and retain all recognized Lantern hook events at the stable relay path. Codex hash
remains `55afa1a23c58eeb767e50bc48161f61afe24f2edbebcec87fe7be48a72b4d779`; Claude is now
`28c7bf5ecb66b6701f26e65508f93c20209bc5006e0a4681c2e75ddd05172ec6`. The installer captures
that current preserving baseline, rather than overwriting the user's changes. No live settings
were written. Usage statusLine is absent; unsupported native-panel telemetry remains unavailable.

Installed0.1.14 shows Connected, active Claude/Codex rows and Enabled sound. It initially had no
approval; the fresh check immediately before Quit found four real Claude approvals. Quit was
aborted and the app left running. User was asked to handle the queue and reply ready. Prepared
installer `/private/tmp/lantern-install-0.2.0.py` targets the verified build18 extraction and has not
run. Native login, installed visibility toggle, and final safe upgrade remain pending. Next-login,
physical hover and unsteered physical typing are explicit residual checks.

### 0.2.0/build19 Settings ordering

User's supplied screenshot reproduces the expanded companion covering Settings. The real path sets
companion level `.statusBar`, while Settings retained `.normal`; `makeKeyAndOrderFront` cannot cross
level ordering. [Apple's window-level reference](https://developer.apple.com/documentation/appkit/nswindow/level-swift.struct)
defines that higher levels obscure lower levels. Settings now rises one level above the companion
on Show/become-key and returns to normal on resign-key. No proposal, focus-grant or transport change.

Release build and both packaged relay fixtures pass. ZIP CRC, macOS extraction and strict/deep
signatures pass for build19; SHA256
`ab63f53a7c4bc3f12e4c1e5624b9fc4cae1c292d6a16023634a5d8fbe964632d`.
No unit test mirroring AppKit's property assignment was added; build18's full76/81 remains the logic
regression result. GitHub checks will run the full final source. Isolated review is
`/private/tmp/lantern-settings19-_a07x192/review/Lantern Settings Review.app`. Native gear click
opened the focused Settings window with readable General controls; the user's physical ordering
confirmation is pending, since a per-window capture alone does not prove desktop occlusion.

Native launch again stalled (101 minutes) despite the supplied timeout, then ID-based rebind/actions
returned promptly. Installed0.1.14 remains untouched; the user-ready reply for an empty live approval
queue is still pending. Installer now points to the verified build19 extraction. No live config writes.

### Installed0.2.0/build19 — 2026-10-07

After the user's ready reply, a fresh full native check found an empty live approval queue; Quit
was requested through Lantern's own menu shortcut. Private review was quit first. The guarded
installer verified stopped process, release/stage/installed signatures, all installed files against
extraction and current hook hashes. It retained signed0.1.14/build15 at
`/Users/imad/Applications/Lantern Backups/0.1.14-build15-b58fd38e/Lantern.app`.
No stale endpoint cleanup was needed. Installed version/build is0.2.0/19.

Native restart was compact, then expansion showed Connected, actual Codex activity, retained head/
icon/green styling and Enabled sound. Both hook hashes remain the preserving current baseline.
Settings gear opened the focused Settings window. Native canonical-path guard enables Launch at
login; switching it On produced no error or requires-approval text. Shortcuts shows the exact two
requested defaults and no registration error. Usage shows both windows Unavailable and relay not
configured, reflecting no supported live native-panel telemetry. No usage configuration was applied.

The user confirmed installed Show/Hide restores the compact pill and active Settings stays above
the companion. This provides desktop-stacking evidence beyond the per-window capture. Next-login behavior,
physical top-edge hover and unsteered physical typing remain separate checks; no logout/reboot or
paid agent turn was used. Earlier private physical Allow/Hide tests and exact allowance receipt stand.

Final handoff: [PR #1](https://github.com/imadd23x/Lantern/pull/1) merged to main with
[final PR checks](https://github.com/imadd23x/Lantern/actions/runs/37631339978) green. User confirmed
installed visibility and Settings ordering. The overnight automation tool returned PAUSED.
App ZIP remains build19, SHAab63f53a; source archive is checked against its immutable release commit.
No further agent inference, real permission grants, global config writes or logout/reboot were used.
