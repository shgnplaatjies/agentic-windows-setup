<#
.SYNOPSIS
  Installs no-mistakes via its official Windows PowerShell installer.
#>

irm https://raw.githubusercontent.com/kunchenguid/no-mistakes/main/docs/install.ps1 | iex

Write-Host "Open a NEW terminal (PATH gotcha — see README), then verify with:"
Write-Host "  no-mistakes doctor"
