# Native UI refinement — local component library

## 0.3.1 native recorder text

The Arc-styled recorder keeps its existing hover/focus surface and key capture view. A native
NSTextField now owns centered shortcut text and font fallback, replacing attributed-string size/draw
calls that aborted during inactive Settings redraw. Its label cannot take mouse events away from
the recorder. Menu typography is unchanged; the subtitle now says "Your desktop guardian".

## 0.1.9 green accent and head cleanup

The user chose #069b2e as the app accent. `Palette.accent` stores its exact sRGB channels (6,155,46)
and replaces the former gold token across branding, actions, focus outlines, approval content and
attention indication. Primary labels stay black; Claude/Codex artwork and independent error/work
status colors remain as before. Existing Arc/Space UI control behavior stays native and unchanged.

The source screenshot remains byte-identical. `CompanionHead` tightens the left cheek and steeper
left hair contour and adds a 2-source-pixel inward margin. The latter also excludes screenshot
antialias pixels that mix hair with the baked checkerboard during smooth image sampling. The first
large render still showed a light upper fringe and was rejected; the corrected render and native
compact/expanded review passed. No new raster generation or image-editing CLI was used.

## 0.1.7 compact-pill controls and supplied head

Reviewed Arc `action-button/{action-button.tsx,action-button.module.css}` and
`expandable-card/{expandable-card.tsx,expandable-card.module.css}`, registry metadata and shared
`motion-tokens.ts` from the existing snapshot. SwiftUI adapts the arrow's hover color, muted surface,
0.12s feedback, press scale and focus state into a separate 28-point toolbar button. The existing
real-bounds card morph and staged details remain. Async success glyphs/text morphs do not fit a
simple disclosure control and are omitted. No React/Motion runtime is included; Arc MIT is bundled.

Source avatar is the user's 417×214 PNG screenshot, copied unchanged to
`Sources/LanternApp/Resources/GreenLanternHead.png` (SHA-256
`9477a326d3c7370ceb13cd55286b1bac2d14ec56ba6a00e7e5c10a74a125233e`). Its checkerboard is opaque.
The built-in image editor rejected extraction, so no generated raster or CLI/API fallback is used.
`CompanionHead.swift` centers the exact bitmap behind a head-outline clipping shape; this masks the
exterior checkerboard and neck connector in native rendering. Original white eyes are preserved per
the user's explicit choice; working bob/attention/Reduce Motion remain. The procedural pet/gaze is
retained only as a missing-asset fallback. Bundle/icon rendering both use the same native mask.

Pill dragging is native rather than adapted from a web drag library. A compact-only `NSPanGestureRecognizer`
delays primary mouse events; failed pans deliver ordinary clicks, while recognized pans consume them.
Frame/constraints/preferences remain owned by PanelController. Primary references:
[Apple gesture recognizers](https://developer.apple.com/documentation/appkit/nsgesturerecognizer)
and the installed SDK's `AppKit/NSGestureRecognizer.h`. Expanded controls/sheets opt out before recognition.

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

## 0.1.10 footer bell

Reuse the existing native `LanternButtonStyle.toolbar` adaptation of Arc action-button feedback.
The bell keeps SwiftUI Button activation/cancellation, a 28-point hit target, hover/focus/press
surface, sound-state accessibility value and Reduce Motion support. No new library dependency.

## 0.2.0 desktop settings

Reviewed Arc `registry/components/switch/switch.module.css` and
`registry/components/progress/progress.module.css` in the existing local snapshot. Settings
adapts the switch's compact track/clear state distinction through native SwiftUI switches;
rounded cards and existing Arc action-button feedback retain keyboard and accessibility
behavior. Shortcut recorders use a fixed-width label, visible recording border and native
key handling. No React, npm dependency or Planes Pro source is added.

Claude usage adapts Arc's 7px rounded progress track and stationary monospaced percentage label.
The native meters show five-hour/week values only from validated telemetry. Missing/reset-passed
windows have no filled segment; stale values retain a dimmed segment and explicit stale label.
Quota exhaustion is not treated as task completion. No confirmation checkmark or simulated value.

## 0.3.0 Arc interface refinement

Reviewed the local Arc snapshot 7238f981's registry metadata, source and CSS for tabs, user-menu,
button, switch, badge, empty-states and notification-center. Their React/Radix/Motion dependencies
are references only; no pnpm runtime is installed in the Swift package. Existing Arc MIT notice
continues to ship in the app bundle.

- ArcTabs shares the stationary labels/gliding raised selection, selected accent, focus outline and
  Arrow/Home/End behavior across provider, Settings and configuration-preview tabs.
- SettingsMenu adapts user-menu's compact identity header, 38-point destination rows and quiet
  green highlight to General/Shortcuts/Agent connections. AppKit/SwiftUI own anchoring, outside-click
  dismissal and keyboard focus; account/theme/sign-out actions do not fit this local app.
- LanternButtonStyle covers primary, secondary, danger, ghost, toolbar, menu, row and tab rendering.
  Native Button retains release/cancellation/disabled semantics. Popover anchors never press-scale.
- ArcSwitchStyle uses the 42×24 fixed track and 18-point thumb with interruptible native selection
  animation, immediate press feedback and native Toggle accessibility representation.
- SessionStatusBadge follows Arc's semantic tones and 22-point small pills; Complete is success,
  Ended neutral, attention/approval warning. No simulated progress or looping completed-state effects.
- AgentEmptyState adapts the card/illustration/copy/single-action hierarchy. The user's emblem
  replaces the sparkle. Notification-center grouping inspired the approval section's presentation;
  read/unread history is omitted because it would introduce an unauthorized new data feature.

The supplied images.png is opaque with a baked checkerboard. The built-in editor extracted a PNG
with real alpha, including the emblem's internal cutouts. LanternEmblem renders that alpha as a
native template in the exact #069b2e accent. Supplied head/avatar, provider icons and sound remain
byte-identical. Native menus and macOS title-bar controls remain system-owned.

Connections uses an independent transparent NSPanel rather than an attached sheet: the companion
retains its own rounded alpha surface. Direct content geometry sizes only that setup card.
PanelLayout gives the companion a content-based height with a 640-point cap; the AppKit controller
retargets actual bounds and retains the existing reveal-readiness deadline. Header pans reuse the
fixed-screen-coordinate PanelDrag; below-header events are excluded before recognition.
