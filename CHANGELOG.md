# Changelog

## 0.3.2 — 2026-10-10

- Fixed shortcut ownership across queued approvals, stale callbacks, held keys and menu/settings transitions.
- Orphaned Claude approval hooks cancel their own connection during connect, send and receive; partial replies and other requests stay intact.
- Added a private portable Apple Silicon/Intel app package, personal build-path checks and a short installation guide.
- Known limitation: a decision made in VS Code can leave its anonymous Claude approval hook pending. This release does not infer or claim immediate host-decision sync.

## 0.3.1 — 2026-10-08

- Fixed a crash when Agent connections takes focus from the Shortcuts tab: shortcut text now uses a native macOS label.
- Changed the gear-menu subtitle to "Your desktop guardian".

## 0.3.0 — 2026-10-07

- Arc-inspired native tabs, gear menu, buttons, switches, status badges and empty states.
- Compact Connections and Settings windows; the session window grows with its contents and scrolls at a height limit.
- Expanded header can be dragged anywhere without a grip icon.
- Supplied Green Lantern emblem replaces the sparkle; head, agent icons and A-Train cue retained.
- Removed header pin/connections icons, long shortcut explanation and the entire usage feature.
- Connections opens as a separate rounded card, preserving the companion's corner transparency.

## 0.2.0 — 2026-10-07

- Command–Return Allow once and Command–Option–H show/hide shortcuts.
- Idle hide with hover reveal, launch at login and foreground Settings.
- Optional Claude usage telemetry, subsequently removed in 0.3.0 at the user's request.

## 0.1.14 — 2026-10-07

Use the supplied A-Train.mp3 clip for attention alerts. Bundle the original audio locally,
retain native playback between events, and preserve the existing alert triggers and mute control.

## 0.1.13 — 2026-10-07

Replace footer connection text with a status dot: green when the local listener is connected,
yellow during startup, red when unavailable or failed. Preserve tooltip and accessible status.
Idle agents keep the connected state. Startup failure and recovery now publish explicit states.

## 0.1.12 — 2026-10-07

Close the expanded header's empty grip column: shift the avatar and title 20 points left,
align the avatar with the card inset, and retain native dragging in the left outer padding.

## 0.1.11 — 2026-10-07

Remove the visible drag dots beside the expanded avatar. Retain the same native drag target,
cursor and tooltip, header spacing, and compact-pill dragging.

## 0.1.10 — 2026-10-06

Track compact-pill drags in screen coordinates, preserving the original grab offset and removing
the moving-window translation feedback that caused vibration. Keep click/drag arbitration and
screen bounds. Show Lantern and Finder reopen restore the compact pill; Connections still opens
its panel. Retain queued requests and the local listener through hide/show.

Remove the footer's privacy wording and give its bell the same Arc-inspired hover, focus and press
feedback as the toolbar. Keep the sound toggle, accessible state and footer height.

## 0.1.9 — 2026-10-06

Return Claude navigation to the existing VS Code window and its selected chat, preserving live work.
Remove folder-opening URLs and app-launch fallback, which could replace a workspace for a nested
worktree. Answer in agent now releases only the selected request after activation succeeds; failed
navigation leaves it actionable in Lantern. Ended sessions cannot open replacement chats.

Tighten the top-left hair and bottom-left cheek mask, including a small inward sampling margin to
remove the screenshot's light background fringe. Replace gold accents throughout the native UI with
the requested #069b2e green, retaining black primary-button text and the original provider artwork.

## 0.1.8 — 2026-10-06

Return automatically opened approval cards to the pill after the last queued request is answered,
cancelled or expires. Keep manually opened cards and explicit Connections/user presentation choices.
Automatic popups retain the current application's keyboard focus; Allow/Deny release a key manual
panel back to the app active at the click. Answer in agent retains its navigation behavior.

## 0.1.7 — 2026-10-06

Display the supplied masked toy head with its original white eyes and a native outline cutout.
Remove the expanded header slogans. Combine Show/Hide into one state-aware menu command and remove
Reset position. Drag the compact pill from any region, preserving ordinary clicks and cancelling
embedded button activation during drags. Give the chevron its own hover/focus/press surface, adapting
Arc's toolbar feedback. Keep agent icons, explicit approvals and installed hook settings intact.

## 0.1.6 — 2026-10-06

Use Imad's supplied blue Codex icon in the existing session-row tile. Remove the attachment's baked
checkerboard with a transparent cutout, bundle it locally and retain the gradient with smooth scaling.
Claude's supplied icon, the green companion and all row/agent behavior remain unchanged.

## 0.1.5 — 2026-10-06

Use Imad's supplied transparent orange Claude Code icon in the existing session-row tile, replacing
the asterisk. Bundle the original WebP with the app; retain Codex's symbol and all row/agent behavior.

## 0.1.4 — 2026-10-05

Recognize installed local hooks after reopening; empty sessions now wait for activity instead of
asking to reconnect. Add a native drag grip, remembered position, Hide while listening, menu-bar
Show/Reset and Escape collapse. Start compact and keep deliberate hiding in effect during alerts.
Adapt Arc's Segmented Control and Expandable Card into native controls and real animated window
bounds, with fixed-width details, staged fades, keyboard selection and Reduce Motion support.
Existing green gaze and explicit approval decisions remain; no agent settings or trust are rewritten.

## 0.1.3 — 2026-10-05

Restore the original transparent lantern avatar in green, using Imad's authorized fallback after the
Rick head edit failed. Remove the portrait tile and its bundled bitmap. Adapt Componentry eye tracking
into native bounded, spring-settled pupils; suspend sampling when occluded and disable it under Reduce
Motion. Icons use a static neutral gaze. Working-only bobbing, attention and all agent behavior remain.
Packaging discards the obsolete generated 0.1.2 resource bundle rather than merging it into the new app.

## 0.1.2 — 2026-10-05

Replace the companion and generated icon with Imad's supplied Rick portrait, bundled unchanged.
Retain working-only bobbing and reduced-motion behavior; attention uses an amber outline/glow.
The resource travels inside the app and cannot fall back to Downloads or an absolute build-cache path.
Session, approval, navigation, sound and configuration behavior are unchanged.

## 0.1.1 — 2026-10-05

Native SwiftUI adaptations of the downloaded Arc, Space UI, Componentry and Planes references:
spring provider selection with counts and Arrow/Home/End navigation, event-driven status badges,
quiet hover/press feedback, and a clearer remaining-time badge. Reduced motion removes decorative
movement; keyboard focus uses a static amber outline. Selecting another queued proposal resets its
scroll position so review starts at the top. Shared UI primitives keep agent actions independent.

The session model, hook adapters, transport, approval callbacks and configuration transactions are
unchanged. Includes upstream MIT notices in the app and source. Verified with 20 tests, packaged relay
checks and isolated native approval, cancellation, preview and motion checks. Live agent activation
remains unverified. Use the release ZIP outside the synced workspace as described in the README.

## 0.1.0 — 2026-10-05

Initial local macOS build for Imad: native companion, independent Codex/Claude sessions,
queued Allow once/Deny/Answer in agent controls, attention sounds and quiet mode,
workspace/chat launch links, and reviewed hook connection/removal with verified backups.
Includes isolated real-socket tests, packaged-relay checks and build/CI instructions.
Live agent activation requires the user's hook trust and session reload; it was not performed.
Use the release ZIP extracted to an unsynced local folder; File Provider reapplies bundle metadata
to the workspace copy in synced Documents and can fail a later strict signature check.
