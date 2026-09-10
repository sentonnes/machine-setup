<#
.SYNOPSIS
    Sets global git config (user identity, line-ending handling). Idempotent —
    only touches values that differ from the desired state.

.PARAMETER UserName
    git config user.name. Defaults to Scott's own value — override for other machines.

.PARAMETER UserEmail
    git config user.email.
#>

param(
    [string]$UserName = 'Scott James',
    [string]$UserEmail = 'scott.james@ukho.gov.uk'
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Write-Step "Configuring git"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "git not found on PATH. Run setup.ps1 first (installs via winget) and restart your terminal."
}

function Set-GitConfigValue {
    param(
        [string]$Key,
        [string]$Value
    )

    $current = git config --global --get $Key 2>$null
    if ($current -eq $Value) {
        Write-Skip "$Key already set to '$Value'"
        return
    }

    git config --global $Key $Value
    Write-Ok "$Key set to '$Value'"
}

Set-GitConfigValue -Key 'user.name'      -Value $UserName
Set-GitConfigValue -Key 'user.email'     -Value $UserEmail
Set-GitConfigValue -Key 'core.autocrlf'  -Value 'true'
Set-GitConfigValue -Key 'core.eol'       -Value 'lf'
