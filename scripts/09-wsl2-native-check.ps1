<#
.SYNOPSIS
  Windows-side WSL2 diagnostics + conversion. Run from a normal (non-elevated) PowerShell first
  to see what state you're in; the two possible fixes below need an ELEVATED PowerShell + reboot
  and are intentionally not auto-applied by this script.
.PARAMETER DistroName
  Name of the WSL distro to convert to version 2 (default: Ubuntu)
#>

param(
    [string]$DistroName = "Ubuntu"
)

Write-Host "Current WSL status:"
wsl --status

Write-Host "`nAttempting conversion to WSL2 for distro '$DistroName'..."
wsl --set-version $DistroName 2

if ($LASTEXITCODE -ne 0) {
    Write-Host @"

Conversion failed. This commonly means HCS_E_HYPERV_NOT_INSTALLED, which has two independent
possible causes — check both in an ELEVATED PowerShell, then reboot:

  1. "Virtual Machine Platform" optional feature not enabled:
       wsl.exe --install --no-distribution

  2. Hypervisor launch type disabled at the boot-config level even with the feature enabled:
       bcdedit /set hypervisorlaunchtype auto

Reboot after either change, then re-run this script.
"@
} else {
    Write-Host "`nConversion succeeded. Verifying kernel..."
    wsl -d $DistroName -- bash -lc "uname -r"
    Write-Host "`nNext: run scripts/10-wsl2-firstmate.sh INSIDE that WSL distro (wsl -d $DistroName)."
}
