<#
.SYNOPSIS
  Installs treehouse via its official Windows PowerShell installer.
#>

irm https://kunchenguid.github.io/treehouse/install.ps1 | iex

Write-Host "Open a NEW terminal (PATH gotcha — see README), then from inside a git repo:"
Write-Host "  treehouse init             # writes treehouse.toml"
Write-Host "  treehouse get --lease       # non-interactive: leases a worktree, prints its path"
Write-Host "  treehouse status           # list pool state"
Write-Host "  treehouse return <path>    # release a leased worktree"
