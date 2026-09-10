<#
    Shared helpers for configure/*.ps1 scripts. Dot-sourced, not run directly.
#>

function Write-Step($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "  [ok] $msg" -ForegroundColor Green }
function Write-Skip($msg) { Write-Host "  [skip] $msg" -ForegroundColor DarkGray }
function Write-Warn($msg) { Write-Host "  [warn] $msg" -ForegroundColor Yellow }
