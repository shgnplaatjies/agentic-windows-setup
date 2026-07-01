<#
.SYNOPSIS
  Installs Neovim and points its config at ~/.config/nvim (Unix-style) instead of the
  Windows default (%LOCALAPPDATA%\nvim).
#>

if (-not (Get-Command nvim -ErrorAction SilentlyContinue)) {
    winget install --id Neovim.Neovim -e --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "Neovim already installed, skipping."
}

# Persist XDG_CONFIG_HOME for the current user so Neovim (and other XDG-aware tools) use
# ~/.config instead of %LOCALAPPDATA%. NOTE: only visible in *new* shells (see README).
[System.Environment]::SetEnvironmentVariable("XDG_CONFIG_HOME", "$env:USERPROFILE\.config", "User")

$nvimConfigDir = "$env:USERPROFILE\.config\nvim"
New-Item -ItemType Directory -Force -Path $nvimConfigDir | Out-Null

$initLua = Join-Path $nvimConfigDir "init.lua"
if (-not (Test-Path $initLua)) {
@'
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true
vim.opt.signcolumn = 'yes'
vim.opt.clipboard = 'unnamedplus'
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.undofile = true
'@ | Set-Content -Path $initLua -Encoding utf8
}

Write-Host "Neovim installed. Open a NEW terminal before verifying — XDG_CONFIG_HOME won't be visible in this one (see README's PATH gotcha)."
Write-Host "Verify in a new shell with: nvim --headless -c \"lua print(vim.fn.stdpath('config'))\" -c qa"
