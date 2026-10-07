# Desktop controls

Open **Settings…** from Lantern's menu bar, or use the gear in the expanded panel.
Preferences are stored in the app's UserDefaults; session proposals remain in memory only.

## Shortcuts

The two defaults follow the user's refined choice:

| Keys | Action |
|---|---|
| Command + Return | Allow the displayed request once |
| Command + Option + H | Hide the pill |

Allow is registered only while a selected, unexpired card with a proposal is visible and settled.
It is disabled in Settings, connections sheets and demos. Holding the combination does not approve
the next queued request; release and press again. A combination already held when a request arrives
also needs a fresh press. Plain Enter remains in the typing app. Automatic approvals retain passive
focus and return to the pill after the last decision; a manually opened card stays expanded.

Click a binding in Settings, press the new combination and release the key to save. Escape cancels.
Recording pauses global actions and owns only an app-local release monitor. Plain and Shift-only
combinations, invalid keys and duplicate active bindings are rejected. A failed native replacement
retains the working registration and reports its error. Hide always hides; use the menu to Show.

## Idle presentation

An idle compact pill hides after 30 seconds by default. Settings offers 15 seconds through
5 minutes. **Keep visible** pins it; explicit Hide remains available. Work, attention, queued
requests, expansion, the connections sheet, Settings, menus, pointer presence and dragging
block the deadline. Finishing an interaction starts a full new idle interval.

Automatic hide orders the panel out. A separate low-frequency pointer sampler detects entry
at the hidden pill's top edge, using its current display-clamped frame. Hover and new work
reveal it without taking keyboard focus. A manually hidden pill stays hidden until Show,
or Finder reopen. Automatic approval expansion
retains the existing return-to-pill and passive focus behavior.

## Launch at login

The native switch uses macOS `SMAppService.mainApp`, only for the canonical installed bundle.
The UI reads the actual OS status, including registration failure and approval required.
If macOS requires approval, use **Open Login Items…** and approve Lantern yourself. Review
and demo builds cannot register. No reboot or logout is used for verification.

## Claude usage boundary

Claude's documented status-line JSON supplies `rate_limits.five_hour` and `seven_day`, with
percentages and reset epochs. See [Claude status-line documentation](https://code.claude.com/docs/en/statusline).
It runs locally without model tokens. A native VS Code extension panel is not documented to
export this status-line data. Lantern must display waiting/unavailable when that host supplies
none; the extension's private experimental APIs are outside this integration.

Review the connection in **Settings → Usage** before enabling the local relay. Installation wraps
your prior command, preserves its stdin/stdout/stderr/environment/cwd/exit, and creates an exact
backup. Invalid or oversized usage data and an absent Lantern do not interrupt that command.
Only the unchanged owned wrapper can be restored; an external edit requires fresh review.
Remove the relay before rolling back to a pre-0.2.0 executable.

Native review resumed after unlock. The two-shortcut refinement is under verification before
installation; installed0.1.14 and both agent settings are unchanged. Current evidence is in VERIFICATION.md.
