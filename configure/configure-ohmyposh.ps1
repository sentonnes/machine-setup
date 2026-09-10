<#
.SYNOPSIS
    Wires Oh My Posh into your PowerShell profile. Idempotent.

.PARAMETER Theme
    Theme name (without .omp.json) from the built-in Oh My Posh theme set,
    or an absolute path to a custom .omp.json.
    Default is a placeholder — pick your actual theme.
    Browse themes: https://ohmyposh.dev/docs/themes
#>

param(
    [string]$Theme = "jandedobbeleer"
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Write-Step "Configuring Oh My Posh"

if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    throw "oh-my-posh not found on PATH. Run setup.ps1 first (installs via winget) and restart your terminal."
}

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Write-Ok "created $PROFILE"
}

$initLine = "oh-my-posh init pwsh --config `"$Theme`" | Invoke-Expression"
$profileContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue

if ($profileContent -match [regex]::Escape('oh-my-posh init pwsh')) {
    # Already wired in — replace the existing line in case the theme changed
    $updated = $profileContent -replace 'oh-my-posh init pwsh.*', $initLine
    if ($updated -ne $profileContent) {
        Set-Content -Path $PROFILE -Value $updated
        Write-Ok "updated existing oh-my-posh init line (theme: $Theme)"
    } else {
        Write-Skip "oh-my-posh already configured with theme: $Theme"
    }
} else {
    Add-Content -Path $PROFILE -Value "`n$initLine"
    Write-Ok "added oh-my-posh init to $PROFILE (theme: $Theme)"
}

Write-Host "Restart your terminal or run '. `$PROFILE' to apply." -ForegroundColor Green
