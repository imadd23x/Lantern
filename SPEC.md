# Lantern specification

Date: 2026-10-05. Scope and acceptance were registered in `docs/PLAN.md` before implementation.
The user's instruction is to propose and build, keeping momentum on low-risk decisions.
The confirmed integrations and approval feature settle the consequential direction.

## Objective / stack

Imad can see which of his coding sessions needs attention and answer one exact permission request
without switching apps. Swift 6, SwiftUI/AppKit, Foundation/Darwin, Swift Testing;
macOS 15+, zero external runtime dependencies. Lantern branding and its green procedural companion
are independently designed. Componentry gaze and Arc control/card interactions are adapted natively.

## Commands / structure

`bash scripts/swift.sh test` — all module tests.
`bash scripts/swift.sh build -c release` — production build.
`bash scripts/package.sh` — reproducible local app bundle, ad-hoc signing.
`bash scripts/smoke.sh` — real socket and packaged relay tests in temporary directories.
`open outputs/Lantern.app` — start app; no hook activation on launch.

`Sources/LanternCore` owns session-state and hook-configuration; `Sources/LanternTransport`
owns hook-connection with the `LanternHook` executable. `Sources/LanternApp` owns companion-ui.
Tests live in `Tests/LanternCoreTests` and `Tests/LanternAppTests`; `work/` and `outputs/` are ignored generated material.
`tasks/plan.md` and `tasks/todo.md` are the implementation index.

## Code style

Small Swift files, explicit `Sendable` wire/domain values, main-actor UI, throws for actionable errors.
No shared mutable global state or silent error suppression on configuration transactions.

```swift
let event = try HookNormalizer.normalize(data, provider: .codex)
if let event { state.apply(event, requestID: requestID, now: clock) }
```

## Testing / decision rule

Tests cross each module's interface and use deterministic clocks and temporary directories.
Use actual sockets and the packaged binary for integration; no mocked transport-only proof.
Never invoke a paid model turn for validation. UI gets visual/native interaction verification.
Completion is judged per layer: source, tests, bundle launch, synthetic hook flow, live agent flow.
A live host step requiring hook trust is reported as pending rather than claimed verified.

## Boundaries

- Always: validate external input, bound resources, preserve unrelated configuration, record evidence.
- Ask first: destructive operations, paid inference, global agent activation, installation outside the workspace.
- Never: read auth files, bypass Codex hook trust, change sandbox policy, auto-approve, copy Coucou protected assets.

## Kill criteria / partial results

- Any unclicked allow, approval identity mismatch, or losing a queued request rejects release.
- Any mutation on invalid/stale config or inability to verify backup rejects config activation.
- If the live host cannot deliver trusted hooks, do not invent private IPC or claim desktop integration verified.
- If Swift cannot build with installed tools, report blocked build; don't replace the native app with a web mock.
- A passing synthetic flow permits a reviewable local build, not an unconditional live integration claim.

## Open / parked

Live activation and host reload/trust are user steps. Display name Lantern is a reversible working choice.
Paid chat, file context, music, wardrobe and service integrations are parked because they don't serve the confirmed first workflow.

Module specs: see `CAPABILITY-MAP.md` and `SPEC-*.md`. Operational assumptions and rollout: `docs/PLAN.md`.
