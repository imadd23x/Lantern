# Native UI refinement — local component library

## 0.1.6 Codex row icon

User-supplied attachment: `/Users/imad/Downloads/codex-logo.webp`, 320×320 opaque WebP with a baked
checkerboard (SHA-256 `2be8eb405110c4ce899fca2e7289fe04e15590ba09d10d0d9d0921bf1531dd55`).
The built-in imagegen editor produced `Sources/LanternApp/Resources/Codex.png`, a 1254×1254 PNG with
real alpha and transparent terminal cutouts (SHA-256
`3e1f8aa7e3f3d9f15d84afec454f04b6f9c9c638c9cfa904fb7a2b76a87e6be8`). No CLI/API fallback was used.
It is a raster cutout of the supplied art, not an SVG. Native bundled-URL loading is cached like the
Claude image. Codex uses smooth interpolation at 32 points, compensating for its transparent margins
inside the same 36-point tile. Claude retains its original bytes and pixel-art scaling.

Final built-in edit prompt:

> Use case: background-extraction.
> Asset type: Codex provider icon in a native macOS session row.
> Input image: edit target, supplied Codex icon.
> Primary request: remove the baked gray-and-white checkerboard from the image. Make the exterior background and the checkerboard visible inside the > and _ terminal cutouts truly alpha-transparent. Preserve the supplied smooth blue-to-purple gradient, exact rounded cloud/blob silhouette, proportions, orientation, and the shape and arrangement of the terminal >_ cutouts.
> Composition: square canvas, centered icon, tightly framed with a small transparent margin, no clipping.
> Constraints: change only background transparency and framing; keep the artwork faithful to the supplied icon. No redesign, new text, shadows, glow, border, checkerboard or opaque background.

## 0.1.5 Claude Code row icon

User-supplied attachment: `/Users/imad/Downloads/claude-code-icon.png.webp`, 512×512 transparent WebP.
Source bytes are copied unchanged to `Sources/LanternApp/Resources/ClaudeCode.webp` (SHA-256
`0fddbf948efaf0b2b06ef9bae6dbf464c6b1b78192089f397e7ca80ecc4aaf94`). SwiftPM bundles the asset;
packaging copies that resource bundle into the app. AppKit loads its URL once, because SwiftUI's
named-image lookup displayed a blank tile for this WebP. The original orange/alpha image is drawn
at 26×26 within the existing 36×36 row tile, with no recoloring. This is the supplied raster attachment,
not an SVG conversion or newly generated artwork. Codex and the green companion are unchanged.

## 0.1.4 Arc card and segmented control

The requested pair is in Arc, snapshot `7238f98196b147a8d50ce467abcbad310d4d8414`:
`registry/components/segmented-control/{segmented-control.tsx,segmented-control.module.css}` and
`registry/components/expandable-card/{expandable-card.tsx,expandable-card.module.css}`, plus
`registry/motion-tokens.ts`. Read the actual source/CSS and MIT notice before implementation.

SwiftUI retains stationary segment labels/counts, a rounded moving selection, roving keyboard focus,
all directional arrows/Home/End and selected accessibility state. The expandable card retains a
persistent trigger/avatar and mounted but inert details, real width/height changes, a fixed-width
detail layout, staged opacity, chevron rotation and Escape. AppKit owns actual window bounds and
native dragging; a shared 0.32s curve is used rather than equating web and native spring constants.
Reduced Motion removes the morph and fades. No web runtime/dependency is shipped. Existing MIT
notices cover the additional Arc references.

The move grip hands the original mouse-down to AppKit's documented
[performDrag(with:)](https://developer.apple.com/documentation/appkit/nswindow/performdrag(with:)).
Hide orders the window out; it does not leave an invisible expanded window over other applications.
Geometry and filtering changes are explicitly authorized by the 0.1.4 request, superseding the earlier
presentation-only geometry constraint below.

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

## 0.1.3 Componentry eye tracking

Reviewed `sources/componentry/apps/web/public/r/eye-tracking.json`, specifically the embedded
`components/ui/eye-tracking.tsx` at the same Componentry snapshot above. The registry's runtime
dependencies are React, Motion and its class-name helper; these remain web references.

The source computes angle/distance from each eye center, caps travel and follows via a spring
(stiffness 300, damping 25, mass 0.5). Lantern adapts the distance/3 near-cursor falloff, an elliptical
travel cap, independently centered pupils and a SwiftUI spring (response 0.26, damping 0.98).
Native coordinate conversion replaces DOM bounds; clipped eye openings bound interrupted motion.
The MIT notice is already bundled. No React runtime is added.

The source's random idle micro-movements and blink loops are deliberately omitted: their nested
interval/timeout ownership does not reliably clean up every timer, and Lantern should stay still
when the cursor and agents are still. A single lifecycle-owned native sampler publishes changes,
stops on window occlusion/detach, and is absent under Reduce Motion or icon rendering. No event tap.

The built-in image-editing tool rejected the Rick head cutout. Per the user's explicit instruction,
the original native lantern is restored in green; this supersedes the 0.1.2 portrait choice and the
original amber-avatar criterion. Amber attention controls and all agent behavior remain unchanged.
