# Agentic Engineering Setup for Windows

A Windows-native port of the terminal-first "agentic engineering" workflow described by **Kun**
(ex-Meta/Microsoft/Atlassian principal engineer) in his YouTube walkthrough of how he ships
40-50 PRs a day with a crew of coding agents. His original tools and workflow are macOS-first;
this repo documents how to replicate the same capabilities on Windows 10/11, including the
places where a direct port isn't possible and a different tool had to be substituted.

This is a **guide + best-effort automation**, not a single magic installer. Several steps
require GUI interaction, admin elevation, or a reboot and cannot be safely scripted — those
are called out explicitly below and in the scripts.

## Table of contents

1. [Prerequisites](#prerequisites)
2. [Terminal & editor](#1-terminal--editor)
3. [Agent skills tooling](#2-agent-skills-tooling)
4. [Voice input](#3-voice-input)
5. [AXI tools](#4-axi-tools-agent-ergonomic-clis)
6. [Lavish Editor](#5-lavish-editor)
7. [no-mistakes](#6-no-mistakes)
8. [gnhf (good night have fun)](#7-gnhf-good-night-have-fun)
9. [treehouse](#8-treehouse)
10. [WSL2 + firstmate](#9-wsl2--firstmate)
11. [Environment/PATH gotcha](#environmentpath-gotcha-read-this-first)
12. [Corporate/managed machines](#corporate--managed-machines)
13. [TODO / future work](#todo--future-work)
14. [Credits](#credits)

## Prerequisites

- Windows 10/11 with `winget` available (ships with modern Windows; update via Microsoft Store
  "App Installer" if missing)
- `git` for Windows
- Node.js + npm (needed for the `npx skills` CLI and several tools below)
- A GitHub account, for `gh` auth and pushing your own work

## Environment/PATH gotcha (read this first)

On Windows, environment/PATH changes made by `winget` installers, `setx`, or
`[System.Environment]::SetEnvironmentVariable(...)` do **not** become visible to already-running
shells or automation tooling — only to genuinely new terminal sessions started afterward. If a
command "isn't recognized" right after installing it, either:

- open a brand new terminal window, or
- call the tool by its full executable path for that one invocation.

This trips up scripted setups more than manual ones — keep it in mind if you're driving this
guide from an agent/automation session rather than typing commands by hand yourself.

## 1. Terminal & editor

**[WezTerm](https://github.com/wez/wezterm)** (by Wez Furlong) replaces tmux as the terminal
multiplexer, since tmux itself doesn't run natively on Windows. A well-configured
`wezterm.lua` gets you tmux-equivalent capability:

- Leader key + pass-through (`CTRL+b`, matching tmux's default prefix)
- Panes: split/nav/resize/zoom/rotate/close
- Tabs (= tmux windows) and Workspaces (= tmux sessions)
- Vim-style copy mode with search and clipboard yank
- Quick-select for URLs/paths/hashes (no tmux equivalent — a bonus)

**Known gap:** WezTerm does not support Unix-domain mux serving natively on Windows, so there's
no true background daemon you can detach from and reattach to later the way tmux's server works
— panes/tabs only persist while the WezTerm GUI process itself is alive. True detach/reattach
(e.g. for phone/remote access) would require running the mux server inside WSL instead.

See `scripts/01-neovim.ps1` for automated install of **[Neovim](https://github.com/neovim/neovim)**
via `winget install Neovim.Neovim`.

Neovim on Windows defaults to `%LOCALAPPDATA%\nvim` for its config, not `~/.config/nvim` like
Unix. To keep config paths consistent with Unix conventions (and with the rest of this stack),
set `XDG_CONFIG_HOME` as a persistent **user** environment variable pointing at
`$env:USERPROFILE\.config`, then place `init.lua` at `$env:USERPROFILE\.config\nvim\init.lua`.
This is a GUI-adjacent step (`setx`/`SetEnvironmentVariable` only takes effect in new shells —
see the gotcha above), so verify it in a fresh terminal.

## 2. Agent skills tooling

**[npx skills](https://github.com/vercel-labs/skills)** (Vercel Labs) is a package manager for
agent skills, works identically on Windows via `npx skills add ...`. Use it to install
Anthropic's own **skill-creator** skill, which teaches an agent how to author new skills:

```powershell
npx -y skills add anthropics/skills --skill skill-creator -g -a claude-code -y
```

See `scripts/02-skills-cli.ps1`.

## 3. Voice input

Kun's tutorial uses **[OpenSuperWhisper](https://github.com/starmel/OpenSuperWhisper)** (by
starmel) — a free, local, Whisper-based dictation app. It is **macOS-only** (Apple Silicon),
so it has no direct Windows port.

**Windows substitute: [Handy](https://github.com/cjpais/Handy)** (by cjpais) — also free, local,
and open source, with a comparable feature set (push-to-talk hotkey, fully offline transcription,
paste-into-active-field). Install via:

```powershell
winget install cjpais.Handy
```

Notes from real-world setup:

- Handy offers multiple STT engines: Whisper-family models (accelerated via **Vulkan** on
  Windows — the installer pulls in the Vulkan Runtime as a dependency) and ONNX-based engines
  (Parakeet V2/V3, Moonshine, SenseVoice, GigaAM).
- ONNX engines can use GPU acceleration on Windows via **DirectML**, which works with any
  DirectX 12-capable GPU (including older NVIDIA cards). **Important:** Handy's "Auto"
  accelerator mode does **not** include DirectML (it needs special ORT session settings that
  would hurt other backends) — you must explicitly select "DirectML" in settings for GPU
  acceleration to actually apply to Parakeet/Moonshine.
- True CUDA acceleration is not in the prebuilt binary (would require building from source, and
  even then newer CUDA toolkits are dropping support for older GPU architectures) — DirectML is
  the practical path on Windows.
- Look for an "auto-submit" / "press Enter after paste" option in settings (may be gated behind
  an experimental-features toggle) if you want dictated prompts to submit automatically in chat
  tools — very useful for agent workflows.
- First-run setup (mic permission, model download, hotkey binding, accelerator selection) is a
  GUI-only step and cannot be scripted.

See `scripts/03-voice-dictation.ps1` for the winget install; everything else is manual.

## 4. AXI tools (agent-ergonomic CLIs)

**[AXI](https://axi.md/)** (Agent eXperience Interface, by Kun) is a set of design principles
for token-efficient, agent-first CLI design, plus reference implementations:

- **[gh-axi](https://github.com/kunchenguid/axi)** — GitHub operations. Requires the real
  **[GitHub CLI](https://cli.github.com/)** (`gh`) installed and authenticated
  (`winget install GitHub.cli`, then `gh auth login` — an interactive browser OAuth flow, cannot
  be scripted).
- **[chrome-devtools-axi](https://github.com/kunchenguid/axi)** — browser automation, works out
  of the box via `npx -y chrome-devtools-axi`.

Both are used via `npx -y <tool> <command>` with no persistent global install required.

See `scripts/04-axi-tools.ps1`.

## 5. Lavish Editor

**[lavish-axi](https://github.com/kunchenguid/lavish-axi)** (by Kun) turns agent responses that
would otherwise be a wall of planning text into a reviewable HTML artifact in your browser, with
inline annotation and a feedback loop back to the agent. Install as a Claude Code skill:

```powershell
npx -y skills add kunchenguid/lavish-axi --skill lavish -a claude-code -g -y
```

Basic workflow once installed as a skill: the agent creates an HTML file under `.lavish/`, runs
`npx -y lavish-axi <file>` to open a local review session, then `npx -y lavish-axi poll <file>`
to long-poll for your annotations/feedback and reply with `--agent-reply`. Confirmed working
fully cross-platform, including on Windows.

See `scripts/05-lavish-axi.ps1`.

## 6. no-mistakes

**[no-mistakes](https://github.com/kunchenguid/no-mistakes)** (by Kun) is the validation/PR
pipeline: push to it instead of `origin` and it runs an isolated-worktree review/test/docs pass
before forwarding to your real remote and opening a PR. Has a native Windows installer:

```powershell
irm https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.ps1 | iex
```

Verify with `no-mistakes doctor` (checks git, `gh`, its background daemon, and which agent CLIs
it detects).

See `scripts/06-no-mistakes.ps1`.

## 7. gnhf (good night have fun)

**[gnhf](https://github.com/kunchenguid/gnhf)** (by Kun) runs an agent in an autonomous
iteration loop against an objective (with iteration/token caps and stop conditions) — useful for
long unattended runs. Install via npm:

```powershell
npm install -g gnhf
```

It ships a `--mock` flag that simulates a full run (fake reasoning steps, commits, a live
moon-phase TUI) without spending real agent time/tokens — good for smoke-testing the install.

See `scripts/07-gnhf.ps1`.

## 8. treehouse

**[treehouse](https://github.com/kunchenguid/treehouse)** (by Kun) maintains a reusable pool of
git worktrees so multiple agents can work the same repo in parallel without manually managing
`git worktree add/remove`. Native Windows installer:

```powershell
irm https://kunchenguid.github.io/treehouse/install.ps1 | iex
```

Key commands: `treehouse init` (writes `treehouse.toml`), `treehouse get` (interactive — opens a
subshell in a leased worktree), `treehouse get --lease` (non-interactive — prints just the
worktree path, for scripting), `treehouse status`, `treehouse return <path>`.

See `scripts/08-treehouse.ps1`.

## 9. WSL2 + firstmate

**[firstmate](https://github.com/kunchenguid/firstmate)** (by Kun) is the top-level multi-agent
orchestrator — you talk to one "first mate" agent and it dispatches/supervises a crew of other
agents across tmux windows and treehouse worktrees. It **requires macOS or Linux + tmux**, so on
Windows it has to run inside **WSL2** (WSL1 is not sufficient).

### 9a. Getting to WSL2

If you already have a WSL distro on version 1:

```powershell
wsl --set-version <DistroName> 2
```

**Gotcha:** this can fail with `HCS_E_HYPERV_NOT_INSTALLED` even when your CPU/firmware fully
supports virtualization, for two independent reasons — check both:

1. The **"Virtual Machine Platform"** Windows optional feature isn't enabled. Fix (elevated
   PowerShell, then reboot):
   ```powershell
   wsl.exe --install --no-distribution
   ```
2. The boot config's hypervisor launch type is effectively off, even with the feature enabled.
   Fix (elevated PowerShell, then reboot):
   ```powershell
   bcdedit /set hypervisorlaunchtype auto
   ```

Both require UAC elevation and a reboot — this cannot be safely scripted end-to-end from an
unattended/agent session; run these two yourself and reboot before continuing.

### 9b. Native Linux tooling inside WSL2 — don't use the Windows interop binaries

WSL2 can see your Windows PATH via interop (`/mnt/c/...`), which means `node`/`npm`/`claude`
"work" out of the box inside WSL — but they're actually crossing the Windows/Linux boundary on
every invocation. This matters a lot for firstmate, which spawns many tmux panes each running an
agent process — do this properly instead:

```bash
# Remove any apt-installed Node if present, to avoid two Node installs fighting over PATH
sudo apt-get purge -y nodejs npm && sudo apt-get autoremove -y

# Install Node via nvm instead
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install --lts

# Install Claude Code (or your agent CLI of choice) natively
npm install -g @anthropic-ai/claude-code
```

**npm gotcha:** newer npm (v11+) blocks postinstall scripts for global packages and suggests
`npm approve-scripts` — which actually errors with `EGLOBAL` and does not work for global
installs at all (see [npm/cli#9463](https://github.com/npm/cli/issues/9463), a known bug in that
new "unreviewed scripts" feature). The real fix for global installs is:

```bash
npm install -g --allow-scripts=<package-name> <package-name>
```

Verify with `which node` / `which claude` in a **fresh** shell — both should resolve under
`~/.nvm/versions/node/...`, not `/mnt/c/...`. Then run `claude` on its own once to log in — this
is a separate credential from your Windows-side Claude Code install (different filesystem, so a
different `~/.claude`), and it's an interactive login you should run yourself.

### 9c. firstmate itself

```bash
git clone https://github.com/kunchenguid/firstmate
cd firstmate && claude
```

Running `claude` inside the clone triggers firstmate's one-time interactive setup (choose your
agent, choose validation strictness, describe a first task). This is inherently conversational
— run it yourself rather than scripting it. firstmate resolves the agent binary dynamically via
`PATH` at dispatch time (it does not hardcode an absolute path during setup), so once the native
binary from step 9b is first on `PATH`, firstmate will use it automatically.

See `scripts/09-wsl2-native-check.ps1` (Windows-side WSL2 conversion + checks) and
`scripts/10-wsl2-firstmate.sh` (run *inside* WSL2, covers 9b/9c).

## Corporate / managed machines

On a locked-down/managed Windows machine, expect some of the above to be blocked or require IT
involvement rather than a script:

- Enabling Windows optional features (Virtual Machine Platform) and boot config edits typically
  need local admin rights you may not have.
- Group Policy may block `winget`, PowerShell script execution, or WSL entirely.
- Corporate proxies/TLS inspection can break `curl`/`irm` one-liners that fetch installers.
- Persisting environment variables via the System Properties GUI is the safer, IT-visible
  alternative to `setx`/`SetEnvironmentVariable` on such machines.

Treat every script in `/scripts` as "run this, then read the error if your environment blocks
it" rather than something guaranteed to succeed unattended.

## TODO / future work

Deferred to a later session — **not done yet**:

- Replicate this exact stack on additional personal devices so agents can run in parallel across
  machines (treehouse/firstmate coordination across hosts is untested).
- Run a real first end-to-end task through firstmate (dispatch → treehouse worktree → agent →
  no-mistakes validation → PR) and document what that looked like in practice.

## Credits

This entire workflow concept — and every `kunchenguid/*` tool below — comes from **Kun**'s
YouTube walkthrough of his agentic engineering setup. This repo only documents how to run the
same ideas on Windows; all credit for the design and tooling goes to the original authors.

| Tool | Author / Org | Link |
|---|---|---|
| WezTerm | Wez Furlong | https://github.com/wez/wezterm |
| Neovim | Neovim core team | https://github.com/neovim/neovim |
| npx skills | Vercel Labs | https://github.com/vercel-labs/skills |
| skill-creator | Anthropic | https://github.com/anthropics/skills |
| OpenSuperWhisper (macOS original) | starmel | https://github.com/starmel/OpenSuperWhisper |
| Handy (Windows substitute) | cjpais | https://github.com/cjpais/Handy |
| AXI design principles | Kun | https://axi.md/ |
| gh-axi / chrome-devtools-axi | Kun | https://github.com/kunchenguid/axi |
| GitHub CLI (`gh`) | GitHub | https://github.com/cli/cli |
| lavish-axi | Kun | https://github.com/kunchenguid/lavish-axi |
| no-mistakes | Kun | https://github.com/kunchenguid/no-mistakes |
| gnhf (good night have fun) | Kun | https://github.com/kunchenguid/gnhf |
| treehouse | Kun | https://github.com/kunchenguid/treehouse |
| firstmate | Kun | https://github.com/kunchenguid/firstmate |
| nvm | nvm-sh | https://github.com/nvm-sh/nvm |
| WSL2 | Microsoft | https://learn.microsoft.com/windows/wsl/ |

## License

The guide and scripts in this repo are MIT licensed (see `LICENSE`). All third-party tools
referenced above carry their own separate licenses — check each project before use.
