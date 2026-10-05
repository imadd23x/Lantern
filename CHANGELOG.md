# Changelog

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
