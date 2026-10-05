# Local installation — Imad's Mac

2026-10-05. The user requested immediate use and explicitly approved enabling both reviewed agent
connections. This follow-up supersedes the earlier build-only boundary for local installation.

- Installed **0.1.3/build 4** at `/Users/imad/Applications/Lantern.app`, extracted from the verified
  release ZIP. No existing app was replaced. Strict/deep signatures passed before and after copying.
- Opened the installed app; the native panel reports **Local connection ready**. Its normal socket at
  `~/Library/Application Support/Lantern/lantern.sock` belongs to this user and has mode `0600`.
- Applied each provider's native **Preview connection → Back up and connect** after the user's approval.
  `~/.codex/hooks.json` now has 10 Lantern handlers; `~/.claude/settings.json` has 12. Both files are `0600`.
  Every handler points to the stable installed relay and carries `lantern-managed-v1`.
- Claude's backup is `~/.claude/settings.json.lantern-backup-012CFEF5-3F6C-43F8-853D-D048CB9E6EAF`.
  Its bytes exactly match the pre-activation file (SHA256
  `7d3cdb4fe7db9c74e0a9b693bc71b9c686141acc92f2955368decf98063c8cf5`).
  All non-hook settings and existing hook groups were verified unchanged. Codex had no hooks.json before
  activation, so there was no previous file to back up.
- Installed CLI checks: Codex reports `hooks stable true`; Claude Code reports **2.1.245**.
- A synthetic session reached the installed app and rendered a session row. It was marked ended;
  no prompt, model call or proposed tool was executed. This proves local relay delivery, not live host delivery.

## Trust and live host check

Codex requires review/trust of the exact definitions through `/hooks` before non-managed hooks run.
Lantern and this agent did not edit or bypass trust records. The computer-use tool refuses access to
Terminal, so the user performed the review. `outputs/Trust-Lantern.command` is a syntax-checked launcher for the installed
Codex CLI; it submits no prompt and changes no trust or agent settings itself.

The user confirmed completion of the Codex `/hooks` review. Fresh native inspection then observed:

- **Codex desktop:** this actual Building Tools chat appeared as Working, naming the current
  `mcp__cua_repl__js` tool and reporting last activity 0–1 seconds ago.
- **Claude Code in VS Code:** a new empty Claude tab was visible, and Lantern received a real
  Trak Football session as Ready. No prompt was submitted by this agent, and existing VS Code sessions
  were not closed or edited.
- **Handoff:** the installed app remained running with Local connection ready and was confirmed in its
  compact notch presentation. No paid API call or agent task was started for verification.

Live Codex tool activity and Claude session startup are therefore verified. A real host permission request
and Claude tool activity still need observation; the packaged Allow/Deny/Delegate paths have separate
synthetic coverage in `VERIFICATION.md`. Keep Lantern open while using either agent. Open the installed
`~/Applications/Lantern.app` again after quitting it; no login item was requested or added.

Sources: [Codex hook review/trust](https://learn.chatgpt.com/docs/hooks#review-and-trust-hooks),
[Claude Code hooks](https://code.claude.com/docs/en/hooks). Claude's current documentation describes
automatic settings-file watching; starting a fresh session also exercises its SessionStart event.

No login item or background daemon was added. To disconnect, use Lantern's **Connections → Preview
removal → Apply removal** for each provider; this removes only Lantern-marked handlers and keeps unrelated
settings. The app's location must stay stable while these absolute-path hooks are installed.

## 0.1.4 upgrade — 2026-10-06

Strict/deep signatures passed on the final extracted archive and installed 0.1.4/build 5. The live card
had no pending approval before native Quit. The stopped old app was moved to
`/Users/imad/Applications/Lantern Backups/0.1.3-build4-66de45d5/Lantern.app`; the new release occupies
the existing `/Users/imad/Applications/Lantern.app` relay path and is running again.

Both configuration files were byte-for-byte unchanged before/after this upgrade:

- Codex `hooks.json`: `55afa1a23c58eeb767e50bc48161f61afe24f2edbebcec87fe7be48a72b4d779`
- Claude `settings.json`: `c5eefd580bab15712e8f580351933f1d2be7cb0398ea4491a0c513d7b2191fa0`

Claude's hash differs from the earlier activation record; that file changed independently before
this upgrade. No connection transaction was applied during this correction. Native inspection
recognizes Claude's complete hooks, and real Codex tool activity resumed without another trust edit.
The relay binary changed with the build; hook definitions, paths and trust records stayed intact.

Drag the dotted grip to move Lantern (position is remembered). × or **Hide Lantern (keep listening)**
clears it from the screen; **Show Lantern** restores it and **Reset position** returns it below the notch.
Quit stops the listener, but installed hooks persist; reopening waits for fresh activity.
Rollback: quit 0.1.4 and restore the saved 0.1.3 app to the existing path. Do not activate the backup at
its backup path or rewrite hooks just to roll back.

## 0.1.5 icon upgrade — 2026-10-06

Installed verified 0.1.5/build 6 at the same path. Previous app:
`/Users/imad/Applications/Lantern Backups/0.1.4-build5-007f0948/Lantern.app`.
The supplied transparent Claude icon is bundled unchanged; onscreen it renders in an actual Claude
session row. Both Codex and Claude activity arrived after launch. Configuration hashes remain exactly
those listed for 0.1.4 above. No hook transaction or trust change was performed.

An unowned stale runtime socket was found before upgrade (inode 100138359, current-user owned,
no lsof owner, ECONNREFUSED). It was removed only after the unavailable app had quit and those checks
were repeated. The new installed process owns the working endpoint. Normal occupied-socket refusal
remains unchanged in the source; no automatic unlink or singleton policy change was added.

## 0.1.6 Codex icon upgrade — 2026-10-06

Installed verified 0.1.6/build 7 at `/Users/imad/Applications/Lantern.app`. Rollback copy:
`/Users/imad/Applications/Lantern Backups/0.1.5-build6-e2281328/Lantern.app`.
Both packaged icon bytes match the sources. Native inspection showed the transparent blue Codex
icon on the real Building Tools row with live tool activity and Local connection ready; lsof identified
the installed process as the socket owner. Hook hashes remain exactly those listed for 0.1.4 above.
No connection transaction, trust change or live approval decision was performed.

The prior instance reported an occupied endpoint again. The exact current-user socket inode
100143200 had no lsof owner and refused connections. After native Quit and repeated identity/owner/
connection checks, only that stale socket was removed. This is operational cleanup, not a fix for
abnormal-exit recovery. Rollback restores the saved app at the stable installed path after quitting.
