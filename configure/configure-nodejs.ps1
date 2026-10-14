<#
.SYNOPSIS
    Configures Node.js/npm for quieter output (disables the funding message and
    the update notifier). Idempotent.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Write-Step "Configuring Node.js / npm"

if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw "npm not found on PATH. Run setup.ps1 first (installs Node.js via winget) and restart your terminal."
}

$settings = [ordered]@{
    'fund'            = 'false'
    'update-notifier' = 'false'
}

foreach ($key in $settings.Keys) {
    $desired = $settings[$key]
    $current = (npm config get $key 2>$null | Select-Object -First 1)
    if ($current -and $current.Trim() -eq $desired) {
        Write-Skip "npm $key already set to '$desired'"
        continue
    }

    npm config set $key $desired
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to set npm config '$key' (exit code $LASTEXITCODE)"
    }
    Write-Ok "npm $key set to '$desired'"
}
