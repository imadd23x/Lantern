# Spec: approval sync and keyboard intent

Inherits privacy, focus, expiry and transport rules from `SPEC.md`.

## Outcome

An approval belongs to one hook connection, one agent session and one displayed
proposal. Each Command–Return press may answer only that visible proposal, once.
Cancelling a hook or resolving an approval in the agent must never answer another
queued request. Automatically opened cards return to the pill when the queue drains;
the app in which the user was typing retains keyboard focus.

## Keyboard contract

- Every native registration has a unique, non-reused token. Events for retired
  tokens are ignored. Held keys remain owned by their original token until release.
- Changing the displayed approval changes its shortcut registration context even
  when the key combination stays the same. A held press cannot cross that change.
- Native event timestamps use the same monotonic clock as display/readiness times.
  A press queued before the current card is visible and ready cannot approve it.
- Reconcile a missing native release by checking only a registered, held shortcut's
  configured key. Do not capture general input or request Accessibility permission.
- Command–Return is registered only while a live, unexpired proposal is fully visible
  and settings/menus are closed. Command–Option–H continues to toggle the pill.

## Agent resolution contract

Use supported Claude events and exact identity where available. PermissionRequest
in the current standard hook schema has no tool-use ID, while PostToolUse does.
Do not pretend a session-level working event or matching command identifies an
approval: concurrent identical commands must remain independent. Parent-process
cancellation is an additional hook-lifetime safeguard, not evidence of a VS Code
permission decision. No transcript/auth reads, vendor patches or paid inference.

Implementation of immediate host-decision sync requires a documented identity
bridge; if the installed Claude interface cannot provide it, record that limitation
instead of inferring permission or silently deleting unrelated cards.

## Verification

Pure tests cover retired tokens, stale releases, held-at-registration keys,
registration context changes and delayed native presses across two requests.
Socket/process tests cover cancellation while waiting, partial responses and
independent connections. Native review uses non-executing approvals only.

## Design review

The first fresh review found actionable gaps in action-only Carbon IDs, delayed
keypress identity, receive cancellation and release delivery. Those gaps are
requirements above. Additional external review was offered and declined by the user.
