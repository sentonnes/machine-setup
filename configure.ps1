#Requires -Version 7.0
<#
.SYNOPSIS
    Orchestrator: auto-discovers and runs every configure/configure-*.ps1 script.
    Each is independently re-runnable and idempotent — this is just the "do
    everything" entry point. Add a new configure/configure-<name>.ps1 file and
    it gets picked up automatically, no edits needed here.

    Scripts are responsible for their own configuration values (e.g. the nvim
    repo URL, the oh-my-posh theme) via parameter defaults — configure.ps1
    does not pass anything down except -Force, and only to scripts that
    declare it.

.PARAMETER Force
    Passed through to any configure/*.ps1 script that declares a -Force switch
    (e.g. configure-nvim.ps1, to force a fresh clone).

.EXAMPLE
    .\configure.ps1 -Force
#>

param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$ConfigureDir = Join-Path $PSScriptRoot 'configure'

# Scripts that need to run before the rest (order-sensitive), in order.
# Everything else discovered in the folder runs after these, alphabetically.
$PriorityOrder = @('configure-nvim.ps1', 'configure-ohmyposh.ps1')

$allScripts = Get-ChildItem -Path $ConfigureDir -Filter 'configure-*.ps1' | Sort-Object Name
$priorityScripts = $PriorityOrder | ForEach-Object {
    $name = $_
    $allScripts | Where-Object { $_.Name -eq $name }
}
$remainingScripts = $allScripts | Where-Object { $PriorityOrder -notcontains $_.Name }

$orderedScripts = @($priorityScripts) + @($remainingScripts) | Where-Object { $_ }

foreach ($script in $orderedScripts) {
    # Only pass -Force through if the script actually declares it — every
    # other value (nvim repo URL, oh-my-posh theme, etc) lives as a default
    # inside each configure-*.ps1 script itself, not here.
    $paramNames = (Get-Command $script.FullName).Parameters.Keys
    if ($paramNames -contains 'Force') {
        & $script.FullName -Force:$Force
    } else {
        & $script.FullName
    }
}

Write-Host "`nConfiguration pass complete." -ForegroundColor Green
