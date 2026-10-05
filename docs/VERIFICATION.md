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
- GitHub CI was authored; it has not run remotely. Bundle is ad-hoc signed, not notarized/Developer ID signed.

The build and isolated validation used no credential-file reads, third-party package installation,
external messages, production mutation or global agent activation. Synthetic tool proposals were never executed.

## Decision

Local code/build/synthetic-flow acceptance and the extracted archive pass. The synced workspace copy
has the observed metadata limitation above. The ZIP remains the portable deliverable. The subsequent
authorized local installation is running with both providers' live startup/activity evidence above;
real permission decisions retain the stated verification limit, consistent with the pre-registered
partial-result rule in `SPEC.md`.
