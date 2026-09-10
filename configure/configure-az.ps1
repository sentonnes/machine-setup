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

$current = (az config get core.output --only-show-errors 2>$null | ConvertFrom-Json).value
if ($current -eq 'table') {
    Write-Skip "core.output already set to 'table'"
} else {
    az config set core.output=table --only-show-errors | Out-Null
    Write-Ok "core.output set to 'table'"
}
