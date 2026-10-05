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
