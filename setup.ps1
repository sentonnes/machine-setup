#Requires -Version 7.0
<#
.SYNOPSIS
    Installs software (winget packages + PowerShell modules) and then runs
    configure.ps1. Safe to re-run regularly to keep everything up to date —
    installation is idempotent; configuration re-running is handled by
    configure.ps1 and its own scripts.

.PARAMETER Force
    Passed through to configure.ps1 -> configure-nvim.ps1 (forces a fresh clone).

.PARAMETER SkipConfigure
    Install only — don't run configure.ps1 at the end.

.EXAMPLE
    .\setup.ps1
#>

param(
    [switch]$Force,
    [switch]$SkipConfigure
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\configure\_common.ps1"

# ===========================================================================
# CONFIG — package lists and their install functions live in
# packages/winget.ps1 and packages/ps-modules.ps1. Edit those files to
# add/remove what gets installed or how; this file shouldn't need to change.
# ===========================================================================

. "$PSScriptRoot\packages\winget.ps1"
. "$PSScriptRoot\packages\ps-modules.ps1"

# ===========================================================================
# MAIN
# ===========================================================================

Test-Prerequisites
Install-WingetPackages -PackageList $WingetPackages
Install-PSModules -ModuleList $PSModules
Update-SessionPath -PackageList $WingetPackages

if ($SkipConfigure) {
    Write-Step "Done (install only)"
    Write-Warn "-SkipConfigure set — configure.ps1 was not run"
} else {
    Write-Step "Handing off to configure.ps1"
    & "$PSScriptRoot\configure.ps1" -Force:$Force
}
