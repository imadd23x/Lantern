# Native UI refinement — local component library

2026-10-05. Scope: adapt suitable visual and interaction ideas to Lantern's existing SwiftUI views.
The user authorized implementation while preserving existing behavior. This is a presentation change.

## Reviewed references

Snapshot: `component-library/manifest.json`, downloaded 2026-10-05. Registry metadata and the
source of each selected component were read; dependencies below remain web-only references.

| Library / snapshot | References | Native adaptation |
|---|---|---|
| Arc / `7238f98196b147a8d50ce467abcbad310d4d8414` | `segmented-control`, `button`, shared motion tokens | One sliding filter highlight, fixed labels, clear primary/secondary actions, immediate press feedback |
| Space UI / `e2d8d404713c0d9d4752fc489d8e614aa2604415` | `components-spaceui-status-badge` | Compact phase badges with text plus an indicator; pulse only for actual working/thinking events |
| Componentry / `4591f4235837f1eb378cf1642ff9f63b48c7e435` | `hover-transition` registry payload | Subtle surface/border emphasis on hover and keyboard focus; content remains fixed and readable |
| Planes / downloaded free registry payload | `segmented-control`; `thinking-loader` reviewed | Spring-settled selection pill; retain real event-driven phases instead of cycling simulated progress |

Source paths are indexed in the local `component-library/catalog.json`:

- Arc: `sources/arc-library/registry/components/{segmented-control,button}/`, `registry/motion-tokens.ts`.
- Space UI: `sources/space-ui/src/registry/components/spaceui/status-badge/`.
- Componentry: `sources/componentry/apps/web/public/r/hover-transition.json` (source is embedded).
- Planes: `sources/planes/components/segmented-control/components/interactions/SegmentedControl.tsx`
  and `sources/planes/components/thinking-loader/components/interactions/ThinkingLoader.tsx`.

Arc/Planes use React and Motion, Space UI uses class-variance-authority plus a registry helper,
and Componentry uses clsx/tailwind-merge. No web code, JS runtime, npm dependencies or Pro components
are installed or embedded in Lantern. Implementations are native SwiftUI. The three local MIT notices
are preserved in `Resources/ThirdPartyNotices.txt` and the app bundle; Planes is a design reference only.

## Acceptance registered before edits

1. Provider filters preserve the same All/Codex/Claude selection semantics and accurate session counts.
   The highlight travels while labels stay stationary. Arrow/Home/End keys work when a filter is focused.
2. Native Buttons retain normal release, cancellation, keyboard activation, disabled and expiry semantics.
   Allow once, Deny and Answer in agent retain their exact callbacks. There is no default approval shortcut.
3. Status labels derive only from existing EventKind values. Idle/completed/failed/approval states have
   static indicators; working/thinking may pulse. No invented task completion percentage or phase timer.
4. All motion is decorative and interruptible. Reduced motion disables travel, pulse and press scaling.
   Full proposal text, identity and remaining seconds stay readable and unchanged during selection.
5. Session reducer, hook normalization, socket transport, configuration transaction, model actions,
   panel geometry and attention sounds remain unchanged. No live hook activation/settings mutation.
6. Original lantern character and amber/dark identity remain. No content flip, 3D tilt, persistent shimmer,
   automatic dismissal or long entry stagger around permission controls.

Kill criteria: any wrong-request decision, changed expiry/disabled behavior, unreadable proposal,
blocking decorative transition or changed non-presentation source rejects this refinement.

## Ordered verification

- Implement small shared SwiftUI styling/motion primitives and the provider filter.
- Apply to session status, approval buttons and setup controls; keep data/action interfaces unchanged.
- Compile and run the existing 20 tests, then package and run relay smoke checks.
- Launch a distinct temporary review bundle using the same binaries and isolated sockets/settings,
  so an existing user app/session remains undisturbed. Check rapid filter reversal, keyboard selection,
  collapse/expand, queued approvals and disabled proposal controls. Repeat with reduced motion forced
  only in the review process using `--reduce-motion`; no system accessibility preference is changed.
- Record observed results and limitations in `docs/VERIFICATION.md`; deliver version 0.1.1.

## Deliberately omitted

Planes' simulated thinking phases and rolling labels cannot report real agent progress. Componentry's
wipe/curtain/3D effects would obscure proposals or move controls. Large Space UI orb/particle animations
and Arc confirmation morphs add distraction or change approval semantics. Planes Pro has no local source
and was not accessed. Window resizing stays on its existing AppKit path.

Version 0.1.2 replaces the original character under a subsequent explicit user request with the supplied
Rick portrait. This supersedes the original-character criterion above; the amber identity, state-driven
motion, reduced-motion handling and all agent controls remain in scope unchanged.
