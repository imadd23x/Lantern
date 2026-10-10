# Lantern

A native macOS desktop guardian for **Codex desktop and Claude Code in VS Code**.
Independent sessions, a queue of permission requests, and the supplied masked toy head.
Runs locally with no API key, network analytics, paid model calls, or third-party dependencies.

## Install

Download the app ZIP from this private repository's [Releases](https://github.com/imadd23x/Lantern/releases),
extract it and put **Lantern.app** in `~/Applications` or `/Applications` before connecting agents.
The app includes Apple Silicon and Intel executables and requires macOS 15+; no developer tools
are needed to run it. See [the installation guide](docs/INSTALL.md) for local setup and updates.
The source ZIP is for development and does not contain a ready-to-run application.

The app download contains no account settings, agent hooks, trust records or session data.
Configure each Mac locally through **Agent connections**. This personal build remains private
and retains the supplied artwork and A-Train alert. It is ad-hoc signed, not notarized;
macOS may require its normal **Open Anyway** approval on first launch.

## Build and run

macOS 15+, Swift 6 Command Line Tools or Xcode. No Homebrew packages are needed.

```sh
bash scripts/swift.sh test
bash scripts/package.sh
bash scripts/smoke.sh
open outputs/Lantern.app
```

The app starts compact below the notch/menu bar. Click the companion to expand or collapse; Escape
also collapses. Drag anywhere on the compact pill to move it; a drag does not click embedded controls.
Drag anywhere on the expanded header too; there is no grip icon. Position is remembered and kept
on a visible screen. The expanded window grows with its session list, then scrolls at its height limit.
Click **×** or **Hide Lantern** in the menu to hide it while it keeps listening. The same menu command
becomes **Show Lantern** while hidden. Alerts expand a visible panel without activating your app,
and a deliberately hidden panel stays hidden (pending requests appear on the menu-bar icon).
Quiet mode turns off the attention sound. Installed hooks are recognized after reopening; session
rows appear on fresh activity. Installation is distinct from agent trust/reload and live hook delivery.
The head gently bobs while an agent works; a green outline/glow indicates attention. Its white mask
eyes remain as supplied. Reduce Motion disables decorative movement. The original
PNG is bundled unchanged and a native outline mask clips away its baked checkerboard. No photo tile
or external image dependency is displayed. The original procedural green pet is a missing-asset fallback.

The app's accent is #069b2e. Head clipping includes an inward sampling margin so the screenshot's
antialiased background does not leave a light fringe.

Provider filters include session counts and keyboard navigation. Status badges follow real agent events;
only active work pulses. Selection, hover and press feedback respect reduced motion. These native
adaptations of the downloaded UI libraries are documented in [docs/UI-REFERENCES.md](docs/UI-REFERENCES.md).

The bundle is ad-hoc signed for local use, **not Developer ID signed or notarized for distribution**.
Extract the release ZIP to a stable, unsynced local folder (for example `~/Applications`) before connecting:
hook commands contain its full executable path. This workspace is in synced Documents; File Provider
reapplies FinderInfo after packaging, which can invalidate strict signature checks on the workspace copy.
The release ZIP is created from verified unsynced staging and passes verification when extracted locally.
`outputs/Lantern-0.3.2.zip` is the portable build; `outputs/SHA256SUMS` records its digest.

## Desktop settings

The expanded panel's gear opens a compact destination menu. General and Shortcuts open
content-sized Settings tabs; Agent connections opens a separate rounded setup window. **Settings…**
in the menu bar opens General. Preferences include configurable global shortcuts, idle hide with
hover reveal, keeping the pill visible, and native launch at login. Defaults: Command+Return allows the visible, selected request once;
Command+Option+H shows or hides the pill. No approval shortcut is active without an actionable card.
The idle compact pill hides after 30 seconds; work, attention and interaction keep it visible.
Manual Hide stays hidden until explicitly shown. Hover reveals an idle-hidden pill without focus.

Login setup is available only from `~/Applications/Lantern.app` or `/Applications/Lantern.app`.
Launch at login changes only when its switch is used; macOS may require approval in Login Items.
See [desktop controls](docs/DESKTOP-CONTROLS.md) for behavior and limitations.

## Connect the agents

1. Launch the packaged app and open **Agent connections** from the gear menu or Settings.
2. Pick Codex or Claude Code and click **Preview connection**.
3. Compare **Proposed settings** and **Current settings**, then click **Back up and connect**.
4. For Codex, review/trust the exact definitions using `/hooks` in Codex CLI. Start a new desktop
   session (or reload its host) so hooks are loaded. Lantern does not write hook-trust state.
5. Restart Claude Code in VS Code so it loads its user settings. Managed/project policy can disable hooks.

Default targets are `~/.codex/hooks.json` and `~/.claude/settings.json`; `CODEX_HOME` and
`CLAUDE_CONFIG_DIR` are respected when present in the **Lantern process environment**.
No account or credential files are read. Launching the app by itself does not edit agent configuration.

## Approvals

Every session has a separate row and identity. Concurrent requests stay queued; the numbered buttons
select the request to inspect. The card shows provider/session, working directory, reason, and the complete
tool input in a scrollable area. **Allow once** applies only to the selected hook connection.
There is no persistent always-allow, automatic approval, or Return-key default.

If attention opened Lantern from a pill, answering the last queued request returns it to the pill.
A card you opened yourself stays expanded. Automatic popups preserve your current application's
keyboard focus, so clicking Allow/Deny lets you keep typing there. Explicitly open Lantern to use
its keyboard controls or Connections. Answer in agent intentionally returns to the running agent.

**Deny** returns the agent's documented deny response. **Answer in agent** first navigates; if navigation
fails the request stays in Lantern. Successful handoff, timeout, connection loss,
or quit returns no permission decision, allowing the agent's normal approval path to continue.
The response window is 110 seconds. A hook's original sandbox/rules remain owned by its agent;
Lantern does not modify them. Requests with no tool input must be reviewed in the agent.

Claude's current standard approval hook does not expose a tool-use ID or an immediate callback
when VS Code wins the permission decision. A card can therefore remain until the original hook
closes, the turn ends or the 110-second deadline passes. Lantern does not dismiss another queued
request by guessing from a similar command. Answer a request on one surface at a time.
Orphaned Claude approval relays close their own connection when their original parent exits;
parent liveness does not identify a decision made in VS Code.

Click a Codex session to open its chat via the Codex deep link. Claude rows bring the already running
VS Code window forward, preserving its selected chat and workspace. No folder is opened, no session
is resumed/recreated and Code is not launched when unavailable. If you use several Code windows or
inactive Claude tabs, the last-active Code window is shown; select a different existing tab yourself.

## Disconnect / rollback

Open **Connections → Preview removal → Apply removal** for each provider. This removes only commands
marked `lantern-managed-v1`, preserving other handlers and subsequent unrelated edits. A new verified backup
is written alongside the settings file. Restart the agent session to stop loading the removed hooks.
Quit Lantern to release every pending request without a decision. No background daemon is installed.
Turn off **Settings → General → Launch at login** before removing the app.

Configuration transactions refuse malformed shapes, symlink targets, failed backups and changes since preview.
They coordinate Lantern writers with an advisory lock and replace settings by atomic rename. A non-cooperating
editor can still race between the final comparison and rename; avoid editing settings while applying a preview.

## Maintainer map

Start with [SPEC.md](SPEC.md), [CAPABILITY-MAP.md](CAPABILITY-MAP.md) and [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).
Behavioral module specs are `SPEC-session-state.md`, `SPEC-hook-connection.md`,
`SPEC-hook-configuration.md`, and `SPEC-companion-ui.md`. Implementation state is in `tasks/todo.md`;
observable evidence and live limitations are in [docs/VERIFICATION.md](docs/VERIFICATION.md).

## Diagnostics / development

```sh
# Clearly labeled sample data; live configuration writes disabled in demo mode.
LANTERN_RUNTIME_DIR=/private/tmp/lantern-demo outputs/Lantern.app/Contents/MacOS/Lantern --demo

# Isolated real hook event (app must use the same runtime directory).
printf '%s' '{"hook_event_name":"SessionStart","session_id":"local-test","cwd":"/tmp/project"}' \
  | LANTERN_RUNTIME_DIR=/private/tmp/lantern-demo outputs/Lantern.app/Contents/MacOS/lantern-hook --provider codex
```

`LANTERN_RUNTIME_DIR` overrides the owner-only socket directory for isolated tests.
Normal path: `~/Library/Application Support/Lantern/lantern.sock`.
If a crash leaves a socket file, first confirm Lantern is no longer running; remove only that stale socket and relaunch.
Lantern refuses to unlink an existing endpoint. Events/session state are memory-only and bounded.

The wrapper stages build/signing products in a project-specific temporary directory to avoid File Provider
metadata interfering with codesign. `LANTERN_BUILD_DIR` can choose another unsynced directory.
Packaging removes generated FinderInfo from the copied app root and checks the workspace
signature. A recurring File Provider metadata failure is reported separately; other signature failures stop
packaging. The release ZIP always comes from verified unsynced staging. Use it outside the synced folder.
The icon is rendered from the same masked head as the panel, with motion disabled for deterministic
artwork. The app needs no Downloads or development build-cache image resource.
`ViewState` is a typealias of the system SwiftUI `State` property wrapper; it avoids an SDK macro absent
from Swift 6.4 Command Line Tools and introduces no custom state implementation.

## Inspiration and source references

The interaction concept was studied from [Coucou](https://github.com/Louis-CFM/coucou), revision
`7314790a814d48e57d7a732d1a317e5583149adf`. Its source separates agent hooks and a floating native panel;
Lantern independently implements those ideas with per-session state and transactional configuration.
No Coucou/Mochi character, icon, sounds, artwork or animation assets are copied.

Agent interfaces follow [Codex hooks](https://learn.chatgpt.com/docs/hooks) and
[Claude Code hooks](https://code.claude.com/docs/en/hooks). Live host delivery depends on installed versions,
hook trust, policy, and session reload; passing synthetic tests is not live desktop verification.
