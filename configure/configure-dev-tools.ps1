<#
.SYNOPSIS
    Ensures C:\dev-tools exists and flags manual-download binaries that must
    live there but can't be fetched via winget/package managers.

    Currently this is just sqlite3.dll: the SQLite.SQLite3 winget package
    only ships the sqlite3 CLI, not the loadable DLL that Neovim's sqlite.lua
    (used by CopilotChat/telescope history, etc) needs at runtime. That DLL
    That DLL has to be grabbed by hand from https://www.sqlite.org/download.html
    (the "sqlite-dll-win-x64-*.zip" precompiled binary) and dropped into
    C:\dev-tools, with vim.g.sqlite_clib_path (in your nvim config) pointed
    at C:\dev-tools\sqlite3.dll.

    Idempotent \u2014 safe to re-run. This script never overwrites an existing
    DLL and never downloads anything itself; it only creates the directory
    and warns if the DLL is missing.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

$DevToolsDir = 'C:\dev-tools'
$Sqlite3Dll = Join-Path $DevToolsDir 'sqlite3.dll'

Write-Step "Configuring dev-tools directory ($DevToolsDir)"

if (Test-Path $DevToolsDir) {
    Write-Skip "$DevToolsDir already exists"
} else {
    New-Item -ItemType Directory -Path $DevToolsDir -Force | Out-Null
    Write-Ok "created $DevToolsDir"
}

if (Test-Path $Sqlite3Dll) {
    Write-Ok "sqlite3.dll present at $Sqlite3Dll"
} else {
    Write-Warn "sqlite3.dll not found in $DevToolsDir"
    Write-Host "  winget's SQLite.SQLite3 package only installs the sqlite3 CLI, not the loadable DLL."
    Write-Host "  Neovim's sqlite.lua-based plugins need the DLL to work. To fix:"
    Write-Host "    1. Download the precompiled binaries zip (sqlite-dll-win-x64-*.zip) from https://www.sqlite.org/download.html"
    Write-Host "    2. Extract sqlite3.dll into $DevToolsDir"
    Write-Host "    3. Point vim.g.sqlite_clib_path at $Sqlite3Dll in your nvim config"
}
