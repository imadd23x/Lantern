# Arc interface refinement — 2026-10-07

## Objective and capability map

Deliver the user's fourteen requested refinements in native SwiftUI, using the downloaded Arc
snapshot as a design reference. The detailed user direction authorizes implementation; no new
web runtime, dependency, paid service or inference call is needed for the app.

| Module id | Responsibility | Depends on |
|---|---|---|
| native-controls | Arc tabs, buttons, switches, badges, empty states and gear menu | existing session/approval model |
| content-presentation | Content-sized companion/connections, rounded windows, header drag | native-controls |
| retire-usage | Remove quota UI, model, transport, relay, configuration, tests/docs | existing hooks remain intact |

Build order: retire-usage → native-controls → content-presentation → isolated runtime review.
Interfaces remain in their existing source modules. Approval identity/expiry/queue/focus and
safe existing Claude navigation are outside the redesign and must stay intact.

## Assumptions

- The supplied emblem replaces the green sparkle shown in the screenshot, including empty states;
  the supplied head remains the avatar. Extract genuine transparency from the emblem with the
  built-in image editor; if unavailable, render exact supplied bitmap through a native mask.
- Remove header pin/connections icons; keep existing idle preferences accessible in Settings.
- Gear opens a compact Arc-style destination menu (General, Shortcuts, Agent connections).
- Native macOS menu-bar/system controls stay native. All app-drawn actions use shared Arc styles.
- No owned usage status-line wrapper is currently installed: targeted read confirms neither agent
  configuration contains it. Recheck before installation. A newly installed wrapper blocks rollout
  until its saved command is restored through the old app, never silently dropped.

## Success criteria

1. Companion remains transparent and rounded with Connections open. Connections initial height
   follows its compact content; preview grows only to display the reviewed diff. Preserving backup,
   atomic write, concurrency check and provider reload guidance remain.
2. Gear opens a trigger-anchored menu, dismisses on Escape/outside click, and opens the intended
   General/Shortcuts tab or Connections above Lantern. No invented account/theme actions.
3. Main provider and Settings tabs adapt Arc navigation tabs, preserve counts/filtering, arrows,
   Home/End, focus and selected accessibility state. No visible "Settings section" label.
4. No header pin or connections control; no drag dots. Expanded header accepts hold-and-drag,
   session/approval content does not. A drag never activates its underlying button.
5. Shared primary/secondary/ghost/danger buttons and switches answer hover/press/focus/disabled
   states. Status badges: success Complete, neutral Ended/Ready, warning Approval/Needs attention,
   danger Error, informational Working/Thinking. Labels derive from actual events only.
6. Settings says "Agent connections". Shortcuts keeps the concise recording instruction, removes
   the requested Command–Return explanation. Exactly two existing bindings and safety gates remain.
7. No quota tabs/footer/preferences, telemetry model/wire callbacks, parser/relay/config installer,
   usage fixtures or active feature documentation remain. Unknown typed messages fail closed.
8. Two rows use materially less height than the old 584-point panel; more rows increase height
   until a bounded maximum, then scroll. Filtering/arrival/removal retarget the window. Requests
   retain a readable fixed proposal region and all decisions within screen constraints.
9. Zero sessions uses an Arc empty-state card with the supplied emblem, truthful setup state and
   one relevant action. No perpetual simulated activity or decorative blocking animation.

## Commands, structure and style

Build/test: `bash scripts/swift.sh test`; focused: `bash scripts/swift.sh test --filter PanelLayoutTests`.
Release: `bash scripts/package.sh`; relay: `bash scripts/smoke.sh`.
Sources: `Sources/LanternApp` native UI/presentation; Core existing typed state/configuration;
Transport socket ownership; Hook compiled executable. Tests mirror those directories.
Docs: this spec, `tasks/plan.md`, `tasks/todo.md`, `docs/UI-REFERENCES.md`, `docs/VERIFICATION.md`.

Keep policy pure and small, e.g. `PanelLayout.size(sessionCount:approval:notice:) -> CGSize`.
Views call the same tested model decisions; styles change rendering, never dispatch permissions.
Swift Testing regression tests cover sizing, filtering and blocked global Allow with an open menu.
Native review covers real bounds, corner transparency, click/drag arbitration and menu/window order.

## Boundaries, kill rule, rollout/rollback

Always preserve existing hooks/settings, supplied head/icons/accent/sound and unrelated work.
Never approve real requests in tests, start new Claude chats, read auth files or install npm libraries.
Stop/reject any wrong-request decision, shortened expiry, lost queue/focus, clipped decision controls,
drag-triggered approval, live setting overwrite, or newly detected owned status-line wrapper.
Mixed results: keep a candidate reviewable and explicitly record unverified OS/physical checks.
Package and review in private runtime/configuration directories first. Only replace the installed
app after acceptance and a fresh empty-queue check; retain a signed build19 rollback and exact
configuration hashes. No forced Quit while an approval waits. GitHub review/release follows tests.

Parked: changing navigation strategy, adding notification history/accounts, multi-display hardware
claims, system preferences and new approval semantics. They are outside the requested refinement.
