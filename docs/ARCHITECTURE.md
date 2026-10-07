# Architecture and operational contract

## 0.1.4 presentation and installation status

`HookConfiguration.installation` inspects exact provider/event commands through the existing bounded
configuration reader. Installation is separate from trust and live delivery; setup and the card share
provider paths. No session/proposal cache, daemon or hook rewrite is added.

`PanelController` owns real bounds, visibility and AppKit dragging. `PanelPlacement` clamps a top-center
anchor to the usable display, including the notch with hidden menus. Only position is remembered in
the app's UserDefaults. One persistent trigger/avatar and fixed-width inert details form the card.
Settled closes hold 60ms for the detail fade; quick reversals cancel that hold. Reduce Motion jumps
to the target dimensions. Hide dismisses setup and orders the panel out while keeping the listener
running. Alerts respect hiding; pending requests appear on the menu icon/title. Show, Finder reopen
and Reset share presentation state. Quit still delegates requests and stops the server.

## Data path

`agent hook stdin → lantern-hook → HookNormalizer → versioned AgentEvent → Unix socket`
`→ AppModel → SessionState → SwiftUI → explicit decision → same socket → documented hook output`

No model turns or external requests are made by Lantern. Codex chat links and existing VS Code activation
are user-triggered. Claude navigation never opens a workspace or resumes/creates a conversation.
No polling private databases or transcript files is needed. User prompts and tool responses are stripped by normalization.
Proposed tool inputs remain in app memory while displayed; nothing logs or persists their contents.

## Module interfaces / seams

| Module | Interface | Hidden implementation / invariants |
|---|---|---|
| session-state | apply, resolve, expire | Provider/session identity; all concurrent requests queue; resolution is single-use and deadline-bound |
| hook-connection | start, respond, stop; exchange | Same UID, owner-only endpoint, framing, limits, thread/descriptor ownership, disconnect events |
| hook-configuration | preview; read/apply | Shape validation, owned-command filtering, shell quoting, byte comparison, exclusive backups, atomic rename |
| companion-ui | observe model; decide/setup/open actions | Main-actor UI, presentation, screen geometry, exact proposal review |

The same interfaces are the test surfaces. Two actual agent adapters share the wire event contract; no generic
adapter hierarchy exists. The pure state reducer has no knowledge of UI or sockets. Configuration code never
has to know a view's state. UI never writes JSON directly or touches a file descriptor.

## Concurrency and resources

Socket server: NSLock protects listener/peer table; each accepted peer gets a background worker.
Only the worker closes its client descriptor; response/stop shut it down, avoiding descriptor reuse during a read.
The accept worker owns and closes the listener. Server stop delegates outstanding requests and removes only
the socket inode it created. UI callbacks hop to the main actor; early disconnect tombstones handle reordered Tasks.

Maximum 32 active connections and 256 KB frame. Hook input ≤200 KB. Initial receive deadline 2 seconds;
approval UI deadline 110 seconds; client wait 115 seconds; agent hook deadline 120 seconds.
Idle hook exchanges wait ≤0.3 seconds. Unknown/oversized/malformed events produce no allow.
Sessions prune to 100 entries excluding pending approvals, and discard hour-old entries on subsequent events.
No random idle character animation; active bobbing is capped at 24 fps and honors reduced motion.
`LanternAvatar(busy:attention:interactive:)` hides green drawing, cursor conversion, sampling,
bounded pupil geometry and spring presentation behind one small interface. Its native reader samples
`NSEvent.mouseLocation` at 30 Hz only in a visible window and publishes changed coordinates only.
Coordinates are reconverted from screen to flipped local view on every sample, including after resize;
the avatar subtracts centering/bobbing offsets before passing them to `TrackingEyes(pointer:)`.
Window occlusion suspends sampling; detach/dismantle invalidates the timer and removes the observer.
The tracker cannot hit-test, installs no event tap or global input monitor, and adds no permission prompt.
Reduce Motion disables tracking/bobbing; icon rendering explicitly disables tracking. There are no
external image resources. `EyeGaze.offset` is the pure test seam for direction and elliptical limits;
the visible pupil is also clipped to its eye opening during spring interruption.
The AppKit reader sits outside the animation timeline and rechecks visibility after initial layout,
which can attach before the panel is ordered. Static icons/reduced motion omit it entirely.

## Approval lifecycle

`AgentNavigator` is the shared navigation seam for rows and handoff. The Claude adapter activates only
a running Code process with an existing editor-sized layer-zero window (owner PID/layer/bounds only).
It ignores hook cwd, requires no Accessibility grant and cannot launch Code or open folder/session URLs.
Activation preserves the last-active window's selected chat. It does not claim exact inactive-tab routing.
`AppModel.answerInAgent` delegates only its selected request after navigation accepts the activation;
a failure remains visible/actionable in Lantern. Ordinary row navigation never delegates approvals.

Every accepted request has a random per-connection ID. UI resolves this ID once in SessionState before transport sends.
Finished/failed/ended sessions delegate only their own pending requests. A timeout/EOF cancels the card.
When multiple requests coexist, no later request can displace an earlier one.
No automatic allow or persistent grant exists. Socket/auth/validation errors are no-decision fallbacks,
not replacements for the agent's own sandbox or rules.

## Configuration safety

Preview accepts bytes, validates every event/group/handler shape, removes only marked owned handlers,
then adds explicit provider commands. It preserves siblings even in a mixed group. Commands are single-quote escaped.
Apply acquires an advisory writer lock and compares the exact original bytes. It rejects symlinks/non-owner targets.
Original bytes are written exclusively to a UUID backup, synchronized and reread. New settings are written
to an exclusive same-directory temporary file, synchronized, rechecked, then renamed atomically.
The lock protects other Lantern writers, not arbitrary editors; this final race is explicitly documented.

## Packaging / distribution

Swift package builds without external dependencies or full Xcode. Build products and signing staging use unsynced
temporary directories. The package script renders the app icon from the same SwiftUI character,
ad-hoc signs nested relay then app, and verifies both staging and delivered bundles. It removes only
FinderInfo added to the generated app root by File Provider; provenance attributes are preserved.
File Provider reapplies this metadata later on this synced volume, so the ZIP from unsynced staging
is the handoff artifact. Extract it to a stable local folder before activating full-path hook commands.
This build is local-use software, not notarized distribution. No install/update daemon.
Do not move the app after connecting without regenerating hook commands from its new stable location.

## Decisions, 2026-10-05

- Native Swift package: installed Swift tools can build without Homebrew/XcodeGen; SwiftUI/AppKit fit the Mac workflow.
- Hooks: installed Codex reports stable enabled hooks; shared app-server control socket did not exist.
- Separate sessions/queued approvals: avoids Coucou's one-slot pending approval behavior.
- 0.1.3 restores the original silhouette in green with Componentry gaze after the Rick head edit failed;
  the user explicitly authorized this fallback. The old portrait is absent from new release resources.
- No persistent allow: keeps the approval surface deliberate and narrow.
- No built-in chat/API integrations: not needed for the confirmed workflow and would add credentials/cost.
- CLI trust / host reload stays explicit: never bypass the user's agent policy.

## 0.2.0 desktop additions

`DesktopPreferences` owns persisted presentation and shortcut choices. `ShortcutRegistry` protects
working registrations during replacement; `CarbonShortcuts` hides native callback/token ownership.
The main-actor controller pauses registrations during key recording and publishes conflicts/errors.
Commands share AppModel's provider filter and selected request ID; no command approves a request.

Automatic hide is distinct from manual Hide. AppModel owns the deadline and blockers. PanelController
orders the hidden panel out and samples pointer entry at its current compact top edge at 0.15s intervals.
This sampler survives hidden-window occlusion, creates no click surface and reveals with passive focus.
It stops at application termination. Pin, menus, settings, sheets, drag, expansion, work and attention
reset/block the idle deadline. Screen changes recompute the hotspot from the clamped frame.

Login startup uses `SMAppService.mainApp`; OS status is authoritative. Login registration and usage
configuration require the canonical bundle ID and a regular installed path in the user's or system
Applications folder; demo/temporary/review copies cannot perform those changes.

Claude quota follows an additive `claude_usage` v1 envelope. Discriminated frames never fall back to
AgentEvent decoding. They receive a prompt no-decision acknowledgement, create no request/session,
and never affect presentation, sound or idle activity. Only quota fields cross this channel; input is
bounded and percentages/reset values validated. A snapshot replaces both windows; omissions clear
old values. Freshness uses host receipt time, 15-minute expiry and reset passage, never inferred zero.

The status-line wrapper embeds a bounded original snapshot, including absent versus null. Exact
canonical JSON ownership preserves boolean/number distinctions. Reinstall unwraps one owned wrapper;
restore refuses a changed wrapper or external replacement. The existing optimistic backup/atomic
transaction applies the preview. Setup checks the executable before preview and apply.
UsageRelay streams stdin to the saved command while capturing at most 200KB for quota parsing;
oversized/invalid data and socket absence do not interrupt that command's stdout/stderr/env/cwd/exit.
No auth files, private experimental extension APIs or paid model turns supply usage.
