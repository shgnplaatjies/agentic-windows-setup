<#
.SYNOPSIS
  Installs Handy, the Windows-native substitute for OpenSuperWhisper (which is macOS-only).
.NOTES
  Everything past this install is a manual, GUI-driven, one-time setup:
    - Grant microphone permission when prompted
    - Download a model (Parakeet/Moonshine/Whisper, your choice)
    - In Settings, explicitly select the "DirectML" accelerator (NOT "Auto") if you want
      GPU acceleration for Parakeet/Moonshine on an NVIDIA/AMD/Intel GPU
    - Bind a push-to-talk hotkey
    - Optionally enable "auto-submit after paste" (may be under an experimental-features toggle)
  See README.md section 3 for details on why "Auto" accelerator mode silently stays on CPU.
#>

winget install cjpais.Handy -e --accept-package-agreements --accept-source-agreements
Write-Host "Handy installed. Launch it and complete first-run setup manually (see comments in this script / README section 3)."
