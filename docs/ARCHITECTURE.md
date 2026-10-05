# Architecture and operational contract

## Data path

`agent hook stdin → lantern-hook → HookNormalizer → versioned AgentEvent → Unix socket`
`→ AppModel → SessionState → SwiftUI → explicit decision → same socket → documented hook output`

No model turns or external requests are made by Lantern. Codex chat and VS Code workspace links are user-triggered.
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
No timer-driven idle character animation; active character is capped at 24 fps and honors reduced motion.

## Approval lifecycle

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
FinderInfo added to the generated bundle root by File Provider; provenance attributes are preserved.
File Provider reapplies this metadata later on this synced volume, so the ZIP from unsynced staging
is the handoff artifact. Extract it to a stable local folder before activating full-path hook commands.
This build is local-use software, not notarized distribution. No install/update daemon or login item.
Do not move the app after connecting without regenerating hook commands from its new stable location.

## Decisions, 2026-10-05

- Native Swift package: installed Swift tools can build without Homebrew/XcodeGen; SwiftUI/AppKit fit the Mac workflow.
- Hooks: installed Codex reports stable enabled hooks; shared app-server control socket did not exist.
- Separate sessions/queued approvals: avoids Coucou's one-slot pending approval behavior.
- Original procedural character: no dependency on protected Coucou assets.
- No persistent allow: keeps the approval surface deliberate and narrow.
- No built-in chat/API integrations: not needed for the confirmed workflow and would add credentials/cost.
- CLI trust / host reload stays explicit: never bypass the user's agent policy.
