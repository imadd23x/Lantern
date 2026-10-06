# Lantern desktop additions — 2026-10-07

## Scope and authority

User explicitly selected recommendation 1 (shortcuts), 2 (idle hide/hover), 10 (login),
and 11 (Claude usage), and requested unattended overnight implementation. Use native SwiftUI/
AppKit, downloaded Arc switch/progress/tooltip designs as references, existing licenses, no web
runtime or dependencies. Preserve safe existing Claude focus behavior; one successful user
observation is recorded as partial evidence, not proof of exact-chat routing.

## Acceptance registered before implementation

1. Configurable global shortcuts: show/hide, next attention, next/previous provider filter, mute.
   Default modifiers Control+Option+Command reduce ordinary editing conflicts. Unsafe plain or
   shift-only keys and duplicate active bindings are rejected. Registration errors are visible;
   failed edits retain a working binding. Commands never send Allow/Deny. Selections use stable
   request IDs and one model source of truth. Explicit commands may reveal manually hidden UI.
2. Auto-hide enabled with default30s configurable delay, pin off. Only an idle compact pill hides;
   working/thinking, attention/pending requests, expanded UI, hover, settings, menus or drags block
   hide and reset the deadline. Manual hide differs from idle hide and remains hidden on hover/
   alerts. Automatic hide/reveal retain passive focus. Hidden panels intercept no clicks. Hotspot
   uses the current clamped compact frame and true pointer entry, with its own monitor.
3. Launch at login uses SMAppService on the installed canonical app, with native status, error
   and requires-approval reporting. Demo/review builds never register. No login/logout/reboot or
   silent OS approval bypass for verification.
4. Claude usage shows validated 5-hour/week percentages/reset times only when supplied. Each
   window has defined missing/fresh/stale/reset-passed states; no fabricated zero or unlimited data.
   Usage never creates sessions, expands Lantern, steals focus, plays alerts or resolves requests.
   Keep existing activity wire format. Add a discriminated versioned usage envelope, close/ack
   usage connections promptly and bound input.
5. A supported Claude statusLine relay may be installed through preserving preview/backup/atomic
   configuration. Preserve absent versus null originals and all unrelated settings/hooks. Repeated
   install unwraps the owned wrapper; removal restores only a recognized current wrapper. An
   encoded original snapshot is bounded. Previous-command stdin/stdout/stderr/env/cwd/exit status
   survive invalid telemetry, absent Lantern or socket failure. Unsupported host telemetry is
   reported as waiting/unavailable, not hidden behind credential scraping or paid inference.

## Verification and kill criteria

Use existing Swift Testing, real socket and packaged relay tests; isolate UserDefaults/runtime/
config directories. Write failing feature tests, then implement each slice. Full test command:
`bash scripts/swift.sh test`. Package: `bash scripts/package.sh`; relay checks:
`bash scripts/smoke.sh`. Inspect native Settings/header/pill, registered hotkeys/login status and
passive hover where possible; report physical/locked-screen limitations separately. GitHub CI
must pass. Reject stale decisions, implicit approval, hidden click surfaces, focus theft, lost
prior statusLine behavior/settings, misleading usage or unreviewed auth access. No paid turns.

## Review decisions

Fresh design review flagged manual/automatic focus separation, independent hotspot monitoring,
clamped geometry, deadline reset, shared selections, preserving delegation, wrapper ownership/
idempotence and independent freshness. All are actionable and incorporated above. Cross-model
review is skipped for this unattended run; no external model CLI is authorized.

## Rollout / rollback

Ship 0.2.0/build16 as native additions; retain the installed0.1.14 app. Back up any explicitly
activated usage statusLine, preserve both providers' existing hooks/trust, and install only with no
live approval connections pending. Retain old app/tag/ZIPs. Publish current source and checks to
the existing private imadd23x/Lantern repo. User-only OS approval or unsupported live telemetry
remains an explicit partial result, not a redefined success.
