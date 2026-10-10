# Install on another Mac

Lantern requires macOS 15 or newer. The app includes Apple Silicon and Intel
executables; no Xcode, Homebrew, Python, API key or paid model call is needed to run it.
This is a private personal build with the supplied artwork and sound.

1. Sign in to GitHub with access to this private repository. Open **Releases** and
   download the latest **Lantern-version.zip** asset, rather than GitHub's source ZIP.
2. Extract the ZIP. Move **Lantern.app** into your home folder's **Applications**
   folder (create that folder if needed), or into **/Applications**. Do this before
   connecting agents; the hooks use the installed app's full path.
3. Open Lantern. This build is locally signed, not notarized. If macOS blocks it,
   review the app and use the normal **System Settings → Privacy & Security →
   Open Anyway** control. Do not disable Gatekeeper or remove security metadata.
4. Click the gear → **Agent connections**. Select each installed agent, choose
   **Preview connection**, review the proposed settings, then **Back up and connect**.
5. In Codex CLI, use **/hooks** to review and trust the exact Lantern hooks. Start a
   new Codex desktop session. Lantern cannot transfer hook trust from another Mac.
6. Restart Claude Code in VS Code to load the new local hooks. Existing projects,
   agent settings and accounts stay on that Mac; none are carried in the download.

**⌘Return** allows the visible selected Lantern request once. **⌘⌥H** hides or
shows the compact pill. Your agent retains its own sandbox and permission rules.

Claude's current standard PermissionRequest hook has no tool-use ID or immediate
host-decision callback. A decision made in VS Code can leave Lantern's card visible
until that hook closes, the turn ends or the card expires. Prefer answering one
surface per request; Lantern does not infer approval from similar commands.

## Updates and rollback

Finish outstanding requests, quit Lantern, retain your existing app as a rollback
copy outside the active installation path, then place the new app at that same path.
Hooks still point there; reconnect only if you moved the app or changed agents.
Download checksums are in **SHA256SUMS** alongside the release.

To disconnect, use **Agent connections → Preview removal → Apply removal** and
restart the agent. Turn off **Launch at login** before removing the app.
