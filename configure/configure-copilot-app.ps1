<#
.SYNOPSIS
    No scripted config needed — GitHub Copilot App is a GUI app that just
    needs a one-time interactive sign-in (OAuth device-flow via browser),
    which can't be automated safely. This script just checks it's installed
    and reminds you to sign in if you haven't.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Write-Step "Configuring GitHub Copilot App"

$copilotApp = Get-StartApps | Where-Object { $_.Name -like '*Copilot*' }

if (-not $copilotApp) {
    Write-Warn "GitHub Copilot App not found. Run setup.ps1 first (installs via winget)."
    return
}

Write-Skip "nothing to configure — sign in on first launch (Start > GitHub Copilot) with your GitHub account"

