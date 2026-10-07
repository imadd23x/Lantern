# Desktop controls

Open **Settings…** from Lantern's menu bar, or choose General/Shortcuts from the expanded panel's gear menu.
Preferences are stored in the app's UserDefaults; session proposals remain in memory only.

## Shortcuts

The two defaults follow the user's refined choice:

| Keys | Action |
|---|---|
| Command + Return | Allow the displayed request once |
| Command + Option + H | Show / hide the pill |

Allow is registered only while a selected, unexpired card with a proposal is visible and settled.
It is disabled in Settings, Connections, the gear menu and demos. Holding the combination does not approve
the next queued request; release and press again. A combination already held when a request arrives
also needs a fresh press. Plain Enter remains in the typing app. Automatic approvals retain passive
focus and return to the pill after the last decision; a manually opened card stays expanded.

Click a binding in Settings, press the new combination and release the key to save. Escape cancels.
Recording pauses global actions and owns only an app-local release monitor. Plain and Shift-only
combinations, invalid keys and duplicate active bindings are rejected. A failed native replacement
retains the working registration and reports its error. The visibility shortcut toggles Show/Hide and always reopens as a compact pill.

## Idle presentation

An idle compact pill hides after 30 seconds by default. Settings offers 15 seconds through
5 minutes. **Keep visible** pins it; explicit Hide remains available. Work, attention, queued
requests, expansion, Connections, Settings, menus, pointer presence and dragging
block the deadline. Finishing an interaction starts a full new idle interval.

Automatic hide orders the panel out. A separate low-frequency pointer sampler detects entry
at the hidden pill's top edge, using its current display-clamped frame. Hover and new work
reveal it without taking keyboard focus. A manually hidden pill stays hidden until Show,
or Finder reopen. Automatic approval expansion
retains the existing return-to-pill and passive focus behavior.

## Launch at login

The native switch uses macOS `SMAppService.mainApp`, only for the canonical installed bundle.
The UI reads the actual OS status, including registration failure and approval required.
If macOS requires approval, use **Open Login Items** and approve Lantern yourself. Review
and demo builds cannot register. No reboot or logout is used for verification.

Installed 0.3.0/build25 at `~/Applications/Lantern.app`, with signed 0.2.0 and earlier rollback bundles retained.
Native listener/activity, retained two shortcut defaults and login switch On are observed.
Private non-executing Allow returned exactly allow and collapsed to the pill. Earlier physical
Allow/visibility and foreground Settings acceptance stand; next-login, new physical hover and
unsteered typing remain separate manual checks.
Current evidence and rollback location are in VERIFICATION.md.
