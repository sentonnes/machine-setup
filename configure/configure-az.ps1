<#
.SYNOPSIS
    Sets opinionated Azure CLI config. Idempotent — safe to re-run.

.PARAMETER DefaultLocation
    Default Azure region for commands that need one (az config set
    defaults.location). Override for other machines/regions.
#>

param(
    [string]$DefaultLocation = 'uksouth'
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Write-Step "Configuring Azure CLI"

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "az not found on PATH. Run setup.ps1 first (installs via winget) and restart your terminal."
}

az config set core.output=table --only-show-errors | Out-Null
Write-Ok "core.output set to 'table'"

az config set core.collect_telemetry=false --only-show-errors | Out-Null
Write-Ok "telemetry collection disabled"

az config set auto-upgrade.enable=true --only-show-errors | Out-Null
Write-Ok "auto-upgrade enabled"

if ($DefaultLocation) {
    az config set defaults.location=$DefaultLocation --only-show-errors | Out-Null
    Write-Ok "defaults.location set to '$DefaultLocation'"
} else {
    Write-Host "Pass -DefaultLocation <region> to set a default Azure region."
}

