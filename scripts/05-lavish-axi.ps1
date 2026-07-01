<#
.SYNOPSIS
  Installs lavish-axi as a global Claude Code skill.
#>

npx -y skills add kunchenguid/lavish-axi --skill lavish -a claude-code -g -y
Write-Host "Installed. Usage inside an agent session: create an HTML artifact under .lavish/, then:"
Write-Host "  npx -y lavish-axi <html-file>          # open/resume a review session"
Write-Host "  npx -y lavish-axi poll <html-file>      # long-poll for feedback, keep it running"
Write-Host "  npx -y lavish-axi end <html-file>       # end the session"
