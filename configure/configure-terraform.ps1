<#
.SYNOPSIS
    Configures a shared Terraform plugin cache dir so `terraform init` doesn't
    re-download the same providers for every project. Idempotent.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Write-Step "Configuring Terraform"

if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    throw "terraform not found on PATH. Run setup.ps1 first (installs via winget) and restart your terminal."
}

$RcPath = "$env:APPDATA\terraform.rc"
$CacheDir = "$env:APPDATA\terraform.d\plugin-cache"

if (-not (Test-Path $CacheDir)) {
    New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
    Write-Ok "created plugin cache dir at $CacheDir"
} else {
    Write-Skip "plugin cache dir already exists"
}

$cacheDirForHcl = $CacheDir.Replace('\', '\\')
$desiredLine = "plugin_cache_dir = `"$cacheDirForHcl`""

if (Test-Path $RcPath) {
    $content = Get-Content $RcPath -Raw
    if ($content -match [regex]::Escape('plugin_cache_dir')) {
        $updated = $content -replace 'plugin_cache_dir\s*=\s*".*"', $desiredLine
        if ($updated -ne $content) {
            Set-Content -Path $RcPath -Value $updated
            Write-Ok "updated plugin_cache_dir in $RcPath"
        } else {
            Write-Skip "plugin_cache_dir already correct in $RcPath"
        }
    } else {
        Add-Content -Path $RcPath -Value "`n$desiredLine"
        Write-Ok "added plugin_cache_dir to existing $RcPath"
    }
} else {
    Set-Content -Path $RcPath -Value $desiredLine
    Write-Ok "created $RcPath with plugin_cache_dir"
}
