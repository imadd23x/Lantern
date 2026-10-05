# Implementation plan — Lantern

2026-10-05. See `SPEC.md` for the acceptance/kill bar and `CAPABILITY-MAP.md` for dependency direction.
Initial source inspection and isolated toolchain probe complete. Work tracked in `tasks/todo.md`.

1. session-state: tests and reducer; no UI/config mutation.
2. hook-configuration: transaction tests then implementation; only temporary-directory writes in validation.
3. hook-connection: real socket tests then server and compiled relay; isolate runtime paths.
4. companion-ui: render typed state, deliberate decisions, panel placement and reviewed setup.
5. package + verify: build scripts, CI, maintainer docs, real relay smoke, native visual checks.

Seams concentrate policy in the state/config modules, socket ownership in transport, and platform UI in the app.
Each increment remains compilable; record checks in `docs/VERIFICATION.md`.
No new dependency, installation, external message, paid request or user config mutation is required to build.
Source edits and local build artifacts are reversible. Activation is a separately reviewable user action.

## 0.1.3 head pet and gaze correction

1. Review Componentry's eye-tracking registry and make the supplied Rick image a transparent,
   pupil-free head asset with built-in image editing. Inspect alpha/silhouette and eye landmarks.
2. Encapsulate native pupil geometry, pointer sampling and spring drawing in the presentation module;
   test bounds/direction and lifecycle. Integrate with the existing avatar and deterministic icon renderer.
3. Run regression/relay checks, package in unsynced staging, inspect the extracted app at both sizes
   and with Reduce Motion. Document evidence, asset provenance and release 0.1.3.

The risky assumption is that Rick's narrow eyelids remain legible at compact size. Inspect actual
native rendering before accepting the asset; the user's green procedural fallback is already authorized.
