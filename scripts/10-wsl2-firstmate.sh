#!/usr/bin/env bash
# Run this INSIDE your WSL2 distro (not from Windows PowerShell).
# Installs native Node (via nvm) + Claude Code + firstmate, avoiding the Windows-interop
# /mnt/c/... binaries that WSL can see by default but which cross the OS boundary on every call.
set -euo pipefail

echo "== Checking for tmux/git (should already be present on Ubuntu) =="
command -v tmux >/dev/null || { echo "Installing tmux..."; sudo apt-get update && sudo apt-get install -y tmux; }
command -v git >/dev/null || { echo "git not found — install it first"; exit 1; }

echo "== Removing any apt-installed Node (avoids two Node installs fighting over PATH) =="
if dpkg -l | grep -qi '^ii  nodejs'; then
    sudo apt-get purge -y nodejs npm
    sudo apt-get autoremove -y
fi

echo "== Installing Node via nvm =="
if [ ! -d "$HOME/.nvm" ]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.5/install.sh | bash
fi
# shellcheck disable=SC1091
\. "$HOME/.nvm/nvm.sh"
nvm install --lts

echo "== Installing Claude Code natively =="
# Note: newer npm blocks global-install postinstall scripts and wrongly suggests
# `npm approve-scripts`, which errors EGLOBAL for global installs (npm/cli#9463).
# --allow-scripts is the actual fix.
npm install -g --allow-scripts=@anthropic-ai/claude-code @anthropic-ai/claude-code
hash -r

echo "== Verify (open a NEW shell if these still show /mnt/c paths) =="
which node
which claude
node --version
claude --version

echo ""
echo "Next steps (run yourself — both are interactive):"
echo "  1. Run 'claude' on its own once to log in (separate credential from your Windows-side install)."
echo "  2. git clone https://github.com/kunchenguid/firstmate && cd firstmate && claude"
echo "     (triggers firstmate's one-time interactive setup: agent choice, strictness, first task)"
