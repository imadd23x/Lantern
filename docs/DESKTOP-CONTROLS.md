# Desktop controls

Open **Settings…** from Lantern's menu bar, or use the gear in the expanded panel.
Preferences are stored in the app's UserDefaults; session proposals remain in memory only.

## Shortcuts

The default modifier chord is Control + Option + Command:

| Key | Action |
|---|---|
| L | Show / hide the pill |
| A | Select the next request needing attention |
| ] / [ | Next / previous agent filter |
| M | Mute / unmute attention sounds |

Click a binding in Settings, press the new combination and release the key to save. Escape
cancels. Recording temporarily unregisters global shortcuts. Plain and Shift-only combinations,
invalid keys and duplicate active bindings are rejected. A failed native replacement retains
the working registration and reports its error. Shortcuts never grant or deny permission.

## Idle presentation

An idle compact pill hides after 30 seconds by default. Settings offers 15 seconds through
5 minutes. **Keep visible** pins it; explicit Hide remains available. Work, attention, queued
requests, expansion, the connections sheet, Settings, menus, pointer presence and dragging
block the deadline. Finishing an interaction starts a full new idle interval.

Automatic hide orders the panel out. A separate low-frequency pointer sampler detects entry
at the hidden pill's top edge, using its current display-clamped frame. Hover and new work
reveal it without taking keyboard focus. A manually hidden pill stays hidden until Show,
Finder reopen or an explicit global presentation shortcut. Automatic approval expansion
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

Usage implementation, runtime review and release rollout are still in progress. The installed
0.1.14 app has not been replaced at this checkpoint.
