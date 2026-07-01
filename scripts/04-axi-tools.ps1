<#
.SYNOPSIS
  Installs the GitHub CLI (a hard prerequisite for gh-axi) and smoke-tests both gh-axi and
  chrome-devtools-axi.
.NOTES
  `gh auth login` is an interactive browser OAuth flow — run it yourself, it cannot be scripted.
#>

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    winget install --id GitHub.cli -e --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "GitHub CLI already installed, skipping."
}

Write-Host "Now run 'gh auth login' yourself (interactive browser flow), then re-run this script's checks below:"
Write-Host "  npx -y gh-axi --help"
Write-Host "  npx -y gh-axi issue list -R <owner>/<repo>"
Write-Host "  npx -y chrome-devtools-axi open https://example.com"
Write-Host "  npx -y chrome-devtools-axi snapshot"
Write-Host "  npx -y chrome-devtools-axi stop"
