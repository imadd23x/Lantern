# Spec: companion-ui

Inherits commands, style and boundaries from `SPEC.md`.

Objective: calm, compact agent visibility and deliberate approvals near the screen's top center.
Interface: observable app model; views call only `decide(id, decision)` and setup/launch actions.
UI never owns sockets or edits JSON. Session cards show provider, project, status, and session suffix.
Approval card shows the full tool proposal, working directory, reason, deadline, provider and session identity.
Allow once, Deny, and Answer in agent are explicit buttons. No keyboard default for allow and no always-allow.
Menu bar fallback, no focus stealing on alerts, screen-change repositioning, bounded scroll views,
VoiceOver labels and reduced-motion behavior. Original lantern character rendered in SwiftUI Canvas.
Setup offers exact before/after config preview, actionable failures, install/remove and trust/reload guidance.
Verify: package launch, panel/menu interactions and visual inspection; real hook flow in isolated runtime.

2026-10-05 refinement: `docs/UI-REFERENCES.md` registers presentation-only acceptance for the
requested local Arc/Space UI/Componentry/Planes review. SwiftUI filters get a shared spring highlight,
status badges report existing phases, and native buttons get quiet hover/press feedback. Actions,
deadlines, proposal content and connection transactions remain unchanged. Reduced motion removes
decorative movement; `--reduce-motion` can force that environment in an isolated review process.
