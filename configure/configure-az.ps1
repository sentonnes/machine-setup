<#
.SYNOPSIS
    Sets opinionated Azure CLI config. Idempotent.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Write-Step "Configuring Azure CLI"

if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "az not found on PATH. Run setup.ps1 first (installs via winget) and restart your terminal."
}

az config set core.output=table --only-show-errors | Out-Null
Write-Ok "core.output set to 'table'"
