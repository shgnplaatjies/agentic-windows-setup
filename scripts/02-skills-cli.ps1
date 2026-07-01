<#
.SYNOPSIS
  Verifies the npx skills CLI works and installs Anthropic's skill-creator skill globally
  for Claude Code.
.NOTES
  Requires Node.js/npm to already be installed.
#>

npx -y skills --help | Out-Null
npx -y skills add anthropics/skills --skill skill-creator -g -a claude-code -y
npx -y skills list -g
