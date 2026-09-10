<#
.SYNOPSIS
    Ensures gh CLI is authenticated and configured to use SSH for git operations.
    Idempotent.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Write-Step "Configuring GitHub CLI"

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "gh not found on PATH. Run setup.ps1 first (installs via winget) and restart your terminal."
}

$authStatus = gh auth status 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Skip "gh already authenticated"
} else {
    Write-Step "Not authenticated \u2014 launching 'gh auth login' (interactive)"
    gh auth login
    Write-Ok "gh authenticated"
}

$currentProtocol = gh config get git_protocol 2>$null
if ($currentProtocol -eq 'ssh') {
    Write-Skip "git_protocol already set to 'ssh'"
} else {
    gh config set git_protocol ssh
    Write-Ok "git_protocol set to 'ssh'"
}
