<#
.SYNOPSIS
    Configures .NET / NuGet. Ensures the official nuget.org package source
    is registered so `dotnet restore` (e.g. Lazy/Mason-installed .NET tools,
    Neovim plugins that shell out to dotnet) can actually resolve packages.

    Idempotent — safe to re-run.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Write-Step "Configuring .NET / NuGet"

$NuGetSourceUrl = 'https://api.nuget.org/v3/index.json'
$NuGetSourceName = 'nuget.org'

$existingSources = dotnet nuget list source 2>$null
$sourceExists = $existingSources -and ($existingSources -join "`n") -match [regex]::Escape($NuGetSourceUrl)

if ($sourceExists) {
    Write-Skip "NuGet source '$NuGetSourceName' already registered"
} else {
    dotnet nuget add source $NuGetSourceUrl -n $NuGetSourceName
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "added NuGet source '$NuGetSourceName' ($NuGetSourceUrl)"
    } else {
        Write-Warn "failed to add NuGet source '$NuGetSourceName' — check output above"
    }
}

# TODO: default SDK pinning (global.json), common global tools
# (dotnet tool install -g ...).
