<#
.SYNOPSIS
  Installs gnhf (good night have fun) globally via npm.
#>

npm install -g gnhf

Write-Host "Verify with: gnhf --help"
Write-Host "Smoke test (no real agent calls) in a scratch git repo:"
Write-Host "  gnhf `"test objective`" --mock --max-iterations 1"
