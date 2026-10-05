# Avatar decision — 0.1.3

2026-10-05. The user requested a transparent Rick head with Componentry gaze, and explicitly
permitted the original lantern recolored green if the head edit could not be completed.

The built-in image editing tool rejected the cutout request at output moderation (category `other`).
No image was returned. No CLI/API fallback, separate paid generation or upload was used.
The original Downloads attachment remains unchanged. The final avatar is native SwiftUI artwork in
`Sources/LanternApp/LanternAvatar.swift`, with gaze in `EyeTracking.swift`; it has no bitmap dependency.
The exported preview is `outputs/Green-avatar-preview.png`. There is no new Rick asset.

## Final attempted prompt (built-in edit mode)

```text
Use case: background-extraction
Asset type: transparent head-only companion sprite for a native macOS notch pet.
Input image: edit target — the supplied young Rick cartoon.
Primary request: isolate ONLY Rick's head: complete spiky blue hair, face, both ears, and chin. Remove ALL background, ALL neck, collar, shirt, coat and torso. Keep the head's recognizable original shape, blue hair, skin color, thin black cartoon linework, eyebrow, nose, mouth and sleepy half-lidded expression. No redesign or photorealism.
Animation preparation: remove only the two black pupils, leaving the original white exposed eye openings clean and blank beneath the same droopy eyelids. Native code will draw moving pupils on top. Keep every eyelid and eye outline intact.
Composition: a single large head centered on a square transparent canvas with a small even margin. Include every hair tip and both ears, no clipped silhouette. Keep original orientation.
Constraints: actual transparent alpha outside the head, no backdrop, no tile, no circle, no rectangular border, no shadow, no glow, no text, no watermark. No neck or body. Only two blank white half-lidded eye openings.
```

## Green fallback

Restore the original handle/glass/base silhouette, use luminous green glass and dark green facial
features, retain amber attention on the glass outline, and add bounded pupils adapted from
Componentry's eye-tracking source. This is the user's fallback direction, not a generated replacement
image. Static icon exports omit the AppKit pointer reader entirely so ImageRenderer exports only SwiftUI
artwork; the panel keeps its native pointer sampler outside the animation timeline during normal motion.
