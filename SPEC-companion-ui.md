# Spec: companion-ui

Inherits commands, style and boundaries from `SPEC.md`.

Objective: calm, compact agent visibility and deliberate approvals near the screen's top center.
Interface: observable app model; views call only `decide(id, decision)` and setup/launch actions.
UI never owns sockets or edits JSON. Session cards show provider, project, status, and session suffix.
Approval card shows the full tool proposal, working directory, reason, deadline, provider and session identity.
Allow once, Deny, and Answer in agent are explicit buttons. No keyboard default for allow and no always-allow.
Menu bar fallback, no focus stealing on alerts, screen-change repositioning, bounded scroll views,
VoiceOver labels and reduced-motion behavior. Bundled transparent head with cursor-following eyes.
Setup offers exact before/after config preview, actionable failures, install/remove and trust/reload guidance.
Verify: package launch, panel/menu interactions and visual inspection; real hook flow in isolated runtime.

2026-10-05 refinement: `docs/UI-REFERENCES.md` registers presentation-only acceptance for the
requested local Arc/Space UI/Componentry/Planes review. SwiftUI filters get a shared spring highlight,
status badges report existing phases, and native buttons get quiet hover/press feedback. Actions,
deadlines, proposal content and connection transactions remain unchanged. Reduced motion removes
decorative movement; `--reduce-motion` can force that environment in an isolated review process.

2026-10-05 avatar replacement: use the user's `Young_Adult_Rick.webp` attachment unchanged as bundled
portrait artwork in expanded/compact UI and the generated icon. Preserve working-only bobbing, static
reduced motion, attention indication, panel dimensions and all agent actions. The app must load the
portrait after extraction to another directory without depending on Downloads or a build-cache path.
Verify the packaged resource bytes against the attachment, native UI states and archive signature.

2026-10-05 correction (0.1.3): the user explicitly replaces the portrait requirement above with a
transparent Rick head pet and Componentry eye tracking. No neck, torso, background, card, or border
may remain around the avatar. Use the supplied cartoon as the edit target, preserving its expression;
blank pupil openings allow native pupils to move without moving the face. If the cutout cannot meet
the visual bar, use the original procedural lantern in green, as the user authorized.

Acceptance, registered before implementation:
- Expanded (72×80) and compact (37×37) artwork shows the full head silhouette, including hair/ears/chin.
- Both pupils follow the cursor with bounded, spring-settled movement adapted from Componentry's
  `eye-tracking` source; neither pupil can leave its original white opening.
- Tracking uses current window/screen coordinates, has no event tap, and owns/cancels its sampling
  with the avatar's visibility. Reduced motion and icon rendering use a static neutral gaze.
- Existing working-only bobbing and attention indication survive; approval actions, deadlines,
  keyboard filtering, panel geometry, sockets and settings remain unchanged.
- Assets live inside the extracted app. No Downloads/build-cache dependency or web runtime is added.

Verify pure gaze limits/direction and tracking lifecycle with Swift Testing, then existing tests,
packaged relay smoke, relocated signing/resource checks and native compact/expanded pointer checks.
Reject a rectangular photo tile, residual neck/background, unbounded pupils, decorative input capture,
reduced-motion movement, incorrect decisions or any change to agent/configuration behavior.
Mixed result rule: use the authorized green fallback if Rick fails the visual bar; report native checks
as unverified if the Mac is locked, while completing isolated build/artifact checks.
Rollout: deliver 0.1.3 ZIP and source ZIP; retain earlier releases. Rollback: use a prior ZIP; no live
configuration writes or installation are part of this presentation correction.

Decision before code: the built-in image-editing tool rejected the head-cutout request (output safety
rejection). Apply the user's explicit fallback: restore the original procedural lantern silhouette,
recolor its glass/light green, and adapt Componentry's bounded spring gaze to native eye openings.
The acceptance bar above applies to the transparent lantern instead of a Rick head. No image-editing
CLI/API fallback or separate paid generation is authorized or used. The unused portrait is removed
from the production resource bundle; earlier archives retain the previous artwork for rollback.

## 0.1.4 presentation and restart correction — 2026-10-05

Reproduced: quitting clears in-memory rows; reopening successfully listens again but displays
"Set up connections" regardless of installed hooks. The user confirms fresh agent activity works.
Fix the misleading setup state by inspecting existing configuration read-only. No session cache,
daemon, login item, hook rewrite, trust change or replay of old approval requests is needed.

Acceptance registered before implementation:
- With installed hooks and no activity, show which providers have hooks installed and that Lantern
  is waiting for activity. Distinguish installation from agent trust/reload and live delivery.
- Incomplete, absent or unreadable settings offer review/setup without claiming they are connected.
  Empty provider filters say there is no activity for that provider, rather than asking to reconnect.
- Start compact. A dedicated grip moves the panel; remember the position, constrain it to a visible
  display, and expand at that position. Hide removes the window while the listener keeps running.
  Menu-bar Show restores it; Reset position returns it below the notch. Escape collapses the card.
- Arc Segmented Control: stationary labels/counts, moving rounded selection, keyboard arrows/Home/End,
  selected accessibility state, no animation with Reduce Motion.
- Arc Expandable Card: one persistent card, animated actual window bounds, clipped content at its final
  width, staged detail fade, reversible transitions and an unchanged safe approval interface.
- A deliberately hidden companion stays hidden on incoming activity, including approvals. The menu
  identifies pending requests; the original agent remains the fallback. Quit still delegates requests.

Verify configuration detection and placement with focused regression tests, then the full suite/relay
smoke and a relocated isolated native app: restart, hidden-listener delivery, drag/restore, rapid card
reversal, keyboard filtering, full proposals/decisions and reduced motion. Reject any unclicked Allow,
incorrect routing, invisible expanded hit area when compact/hidden, settings writes or lost grip.
Mixed result: keep fixes that pass; report any unavailable physical-input check explicitly.
Rollout: verified 0.1.4 archive and upgrade at the existing relay path; preserve the previous app/archive.
Rollback: restore 0.1.3 at that same path. Presentation preferences may remain and are harmless to 0.1.3.

## 0.1.5 supplied Claude Code row icon — 2026-10-06

Replace only the Claude session row's asterisk with the attached transparent
`claude-code-icon.png.webp` (the attachment is WebP, despite the request calling it SVG).
Bundle the original bytes, retain its orange color and transparent eyes/background, and size it
within the existing 36-point tile. Keep Codex's symbol, row labels/actions and the green pet intact.
Acceptance: the extracted app loads the icon without Downloads/build-cache access, it is legible
onscreen in the session row, and installed hook configuration remains unchanged. Verify the release
build, bundled asset hash/signature and an isolated synthetic Claude row; no new logic tests are
needed for this asset substitution. Deliver 0.1.5 and retain 0.1.4 for rollback.

## 0.1.6 supplied Codex row icon — 2026-10-06

Replace the Codex session row's terminal symbol with the supplied blue-gradient icon. The attachment
is an opaque WebP with a baked checkerboard, so use the built-in image editor to extract a transparent
PNG, preserving the silhouette and terminal cutouts. Bundle the resulting asset and load it through
the existing native resource path. Use smooth interpolation for Codex and retain Claude's pixel-art
interpolation. Keep the existing row actions, approval interface and green companion unchanged.

Acceptance: no checkerboard rectangle appears at actual row size; both provider icons load from an
extracted app with no Downloads/build-cache dependency. Verify release packaging/signatures and native
rows. No new logic tests are needed for this static asset change. Upgrade the existing app with a
0.1.5 rollback copy and unchanged hook configuration; deliver app/source 0.1.6 archives.

## 0.1.7 avatar, visibility and pill interaction — 2026-10-06

User direction is settled: use the supplied masked LEGO-style head with its original white eyes,
remove "Your agents, in view", combine Show/Hide into one menu command, remove Reset position,
drag the compact pill from anywhere, and give its chevron visible hover/press feedback. Arc's
Expandable Card and Action Button are native design references; no web dependency is added.

The built-in image editor rejected background extraction. Bundle the supplied PNG unchanged and
display it through a native head-outline clipping shape, excluding checkerboard and neck. Do not
use a paid CLI/API fallback. Keep working-only bobbing, attention indication and Reduce Motion;
the user's white-eye choice intentionally supersedes moving pupils for this avatar.

Pass criteria registered before code:
- The supplied head is legible at compact/expanded size, with no rectangular/checkerboard background
  and no clipping of hair/face. Its original white eyes remain unchanged. Assets are self-contained.
- Expanded header has only the avatar/brand and controls; no idle or approval slogan. More room goes
  to sessions; actual compact bounds remain 288×46 and expanded bounds remain 460×584.
- Each native menu exposes exactly one visibility action with the correct Show/Hide title, and no
  Reset position. Hide keeps the listener and queued requests; Show restores the card deliberately.
- A native primary-button pan on any compact-pill region moves the panel, preserves the grab offset
  and remembered bounded placement, and cancels click activation. Clicks and keyboard actions still
  open/collapse/hide; expanded session/approval/scroll controls cannot drag the whole window.
- Chevron has a 28-point target, visible hover/focus/press feedback and accessible Expand/Collapse
  state. Rapid reversal and Reduce Motion remain supported. No global input monitor/event tap.

Verify focused lifecycle tests, full suite, packaged relay smoke, isolated native clicks/drags across
the pill, both menu states, screenshot rendering and reduced-motion behavior. Reject accidental
expansion/hiding/approval during a drag, exposed hidden input surfaces, a photo tile, lost listener,
or altered hook settings. Mixed rule: report unobserved hardware paths honestly; do not claim them.
Rollout: 0.1.7 app/source archives and same-path installation after verifying no pending live approval,
with a 0.1.6 rollback copy and byte-for-byte preserved hook files. No automatic stale-socket policy
change is part of this UI request.

## 0.1.8 approval presentation and keyboard focus — 2026-10-06

Reproduction path: receive expands without recording its cause, decide removes the request without
restoring presentation, and the nonactivating panel unconditionally permits becoming key. A click
can therefore redirect keyboard input even though Lantern never activates its application.

Pass criteria registered before implementation:
- If attention automatically opens a compact pill, answering the last queued request returns it to
  compact. Earlier answers keep the remaining queue visible. A manually opened card stays open.
- Notification-before-PermissionRequest ordering retains automatic ownership. Request cancellation,
  expiry and session completion also restore the pill when the automatically shown queue drains.
- Explicit expand/collapse/Show or opening Connections overrides automatic presentation; a hidden
  companion stays hidden. No automatic permission decision or replay is added.
- Automatically managed presentations cannot become key or move SwiftUI focus to the disclosure
  button. Manual cards/Connections retain keyboard support. After Allow/Deny from a key manual card,
  release panel focus to the app active at the click, without switching away from a newer foreground
  app. Answer in agent retains its intentional navigation semantics.
- Use native AppKit focus policy; no Accessibility permission, event tap, simulated keystroke or
  background app automation. Native Allow/Deny remain deliberate and request-scoped.

Verify the existing behavior with a failing socket-backed regression, then queue/manual/hidden/
cancellation cases and the full suite. Verify native collapse with isolated synthetic proposals;
physical typing resumption requires an unsteered user check if targeted UI automation cannot prove
keyboard routing. Reject lost queued requests, collapsed manual cards, focus jumps to an old app,
incorrect decisions or modified hook settings. Package/install 0.1.8 at the stable path with a 0.1.7
rollback copy. Report each verification layer separately and keep unobserved typing behavior explicit.

## 0.1.9 preserve live Claude navigation — 2026-10-06

Observed source fault: both Claude navigation actions use vscode://file/<cwd>, an openable file/folder
route rather than a live-session locator. Hook cwd can be a nested worktree; the screenshot's session
95fdca5d-…-7b013abd670b is already visible in the existing Trak Football Code window. Answer in agent
also delegates its pending request before navigation succeeds. Do not reproduce the bad folder link
against the user's running agent.

Acceptance registered before code:
- Claude navigation activates an already running VS Code with an existing editor window. It never
  sends a folder/workspace URI, launches Code, opens/resumes a chat, replaces a workspace or sends keys.
  Preserve the selected live conversation. The existing last-active Code window is the destination;
  inactive chats in other windows are not resumed or recreated to guess a match.
- Both row navigation and Answer in agent use one tested navigation interface. Allow/Deny are unchanged.
- Answer in agent releases only its selected request with Delegate after Code accepts activation.
  If navigation fails/missing editor, preserve the queued request and show an actionable message.
- Ended Claude sessions cannot create replacement chats. Codex's escaped chat link remains supported.
- No VS Code setting, extension, agent config, trust state, Accessibility grant or external service is
  needed. Native AppKit activation and window metadata replace the dangerous workspace-opening path.

Verify navigation failure/success with real private approval sockets and injected navigation effects,
pure route tests, then full suite/package/relay. An isolated native review may activate the existing
Code app, with before/after window count, workspace and selected Claude session checks; never decide
a live proposal or restart/close a Claude session. Reject new windows, changed workspace/chat,
premature delegation or changed hooks. Report last-active-window limitations explicitly if relevant.
Rollout: same-path 0.1.9/build 10 with 0.1.8 rollback, preserved hooks and quiet mode, matching archives.

### Additional 0.1.9 steering — head edges and green accent

The user reports checkerboard remnants at the bottom-left cheek and left side of the top hair edge.
Tighten those two segments of the existing native outline against the supplied screenshot; preserve
hair/face, white eyes and the original raster bytes. Do not introduce a generated or rectangular avatar.
Replace the former gold design token with the requested sRGB #069b2e accent throughout brand,
approval actions/content, focus borders, attention badges and head outline/glow. Keep black primary
button text for legibility, provider logos and independent work/error status colors.
Verify the large native-rendered icon and compact/expanded head for residual background at both
locations; check the green approval card and focus feedback. No geometry-mirroring tests are needed
for the static mask/color adjustment. The current writable source is Documents/Codex/Lantern; it is a
local working copy with the pending navigation changes, and the original folder/library are preserved.
