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

## Remaining user step and live check

Codex requires review/trust of the exact definitions through `/hooks` before non-managed hooks run.
Trust records were not edited or bypassed. The computer-use tool refuses access to Terminal, so the user
must perform this review. `outputs/Trust-Lantern.command` is a syntax-checked launcher for the installed
Codex CLI; it submits no prompt and changes no trust or agent settings itself.

Open that launcher in Finder, type `/hooks`, and trust only the Lantern definitions pointing to
`/Users/imad/Applications/Lantern.app/Contents/MacOS/lantern-hook`. Then start a new Codex desktop chat
and a new Claude Code session in VS Code. Keep Lantern open. Live session/tool events and a real permission
request still need observation; they are not claimed verified from the synthetic row.

Sources: [Codex hook review/trust](https://learn.chatgpt.com/docs/hooks#review-and-trust-hooks),
[Claude Code hooks](https://code.claude.com/docs/en/hooks). Claude's current documentation describes
automatic settings-file watching; starting a fresh session also exercises its SessionStart event.

No login item or background daemon was added. To disconnect, use Lantern's **Connections → Preview
removal → Apply removal** for each provider; this removes only Lantern-marked handlers and keeps unrelated
settings. The app's location must stay stable while these absolute-path hooks are installed.
