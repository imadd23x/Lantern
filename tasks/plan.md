# Implementation plan — Lantern

2026-10-05. See `SPEC.md` for the acceptance/kill bar and `CAPABILITY-MAP.md` for dependency direction.
Initial source inspection and isolated toolchain probe complete. Work tracked in `tasks/todo.md`.

1. session-state: tests and reducer; no UI/config mutation.
2. hook-configuration: transaction tests then implementation; only temporary-directory writes in validation.
3. hook-connection: real socket tests then server and compiled relay; isolate runtime paths.
4. companion-ui: render typed state, deliberate decisions, panel placement and reviewed setup.
5. package + verify: build scripts, CI, maintainer docs, real relay smoke, native visual checks.

Seams concentrate policy in the state/config modules, socket ownership in transport, and platform UI in the app.
Each increment remains compilable; record checks in `docs/VERIFICATION.md`.
No new dependency, installation, external message, paid request or user config mutation is required to build.
Source edits and local build artifacts are reversible. Activation is a separately reviewable user action.

## 0.1.3 head pet and gaze correction

1. Review Componentry's eye-tracking registry and make the supplied Rick image a transparent,
   pupil-free head asset with built-in image editing. Inspect alpha/silhouette and eye landmarks.
2. Encapsulate native pupil geometry, pointer sampling and spring drawing in the presentation module;
   test bounds/direction and lifecycle. Integrate with the existing avatar and deterministic icon renderer.
3. Run regression/relay checks, package in unsynced staging, inspect the extracted app at both sizes
   and with Reduce Motion. Document evidence, asset provenance and release 0.1.3.

The risky assumption is that Rick's narrow eyelids remain legible at compact size. Inspect actual
native rendering before accepting the asset; the user's green procedural fallback is already authorized.

## 0.1.4 restart messaging and panel presentation

1. Add exact read-only hook inspection and regression tests; replace unconditional setup messaging.
2. Add native move/hide/reset, bounded placement and position preferences; preserve the listening socket.
3. Adapt Arc's Segmented Control and Expandable Card into SwiftUI/AppKit; verify real window bounds,
   interruption, keyboard behavior and Reduce Motion rather than scaling a hidden large window.
4. Build/test/package, review in isolated runtime/configuration directories, then upgrade the existing
   app with a rollback copy and confirm unchanged agent configuration/relay identity.

Key assumptions: hooks remain installed (verified and confirmed by the user); Hide is preferable to
Quit for clearing click obstruction; no sessions/proposals need to be persisted. Specifications above
define pass/kill/mixed rules before coding. Keep the existing green pet and approval/transport policy.

## 0.1.7 supplied head and pill controls

1. Bundle the supplied head unchanged and encapsulate native outline clipping in the avatar drawing.
   Keep white eyes per the user's choice; verify both sizes and deterministic icon rendering.
2. Combine menu visibility at the existing presentation seam, remove Reset and header slogans,
   and give the chevron Arc-inspired toolbar feedback. Verify hidden-listener/queued-request behavior.
3. Attach a compact-only native pan recognizer to the hosting view. Delaying primary button events
   lets a failed pan retain ordinary clicks while a recognized drag cancels control activation.
   Keep frame movement/constraints/position ownership in PanelController. Check the actual drag path.
4. Run tests, package/relay checks, isolated native review and Reduce Motion. Upgrade with rollback
   and unchanged settings, record evidence, then archive the matching source.

Risk: drag arbitration over embedded buttons is judged through real native input, not just unit tests.
The image editor rejected extraction; native clipping displays the exact supplied bytes without a
generation fallback. Park transport recovery and multi-monitor hardware checks outside this change.

## 0.1.8 automatic approval presentation and focus

1. Reproduce last-answer stickiness with a real private socket and register presentation/focus criteria.
2. Keep automatic presentation ownership in AppModel, reconcile every queue-draining path, and treat
   manual presentation/Connections as overrides. Inject only the clock needed to verify actual expiry.
3. Keep key-window eligibility and interrupted-application ownership in PanelController. Automatic
   popups/compact returns cannot take key; explicit cards/Connections retain keyboard use. Return focus
   on Allow/Deny only when Lantern owns it and no newer foreground application would be displaced.
4. Verify queue/manual/hidden/ordering/cancel/expiry, full suite, signing/relay and isolated native choices.
   Use an unsteered physical typing check rather than targeted automation as proof of keyboard routing.
5. Upgrade with unchanged hooks, previous quiet mode and a rollback copy; archive exact matching source.

The socket-backed tests run in a sequential Swift Testing suite: too many detached blocking clients
exhausted the cooperative executor required by main-actor callbacks. No assertion/test is skipped and
timeouts are not increased. The same formerly failing case passed in isolation before serialization.

## 0.1.9 live Claude navigation

1. Inspect both callers and installed Claude/VS Code URI handling; do not reproduce folder opening on
   the live task. Register that cwd is a worktree, not an editor-window/session identity.
2. Prove the legacy folder route fails a pure regression. Concentrate live/fake navigation effects in
   AgentNavigator and move handoff sequencing into AppModel. Reject launches and ended-session resumes.
3. Verify real private-socket handoff failure/retention, selected-only success, row non-delegation and
   unchanged Codex links; full suite and release/relay checks. Activate Code only through a native review.
4. Compare existing window/workspace/selected session before and after navigation; upgrade with rollback
   and preserved settings/quiet mode, then archive exact matching source.

Decision: preserve the selected live Claude extension tab in the last-active existing Code window.
Anthropic's /open?session handler can create a panel when it cannot find that session in its target
window, so it is not used to guess across windows. No new bridge/extension or Accessibility grant is needed.
