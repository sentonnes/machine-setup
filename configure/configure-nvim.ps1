<#
.SYNOPSIS
    Clones or updates the Neovim config repo. Idempotent — safe to re-run.
    Extracted from setup.ps1: this is configuration, not installation.

.PARAMETER RepoUrl
    Git URL of the neovim config repo. Defaults to Scott's own config —
    override for other machines/repos.

.PARAMETER Force
    Discard the existing config directory (backing it up first) and do a fresh clone.
#>

param(
    [string]$RepoUrl = 'https://github.com/sentonnes/neovim-setup.git',
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

$ConfigPath = Join-Path $env:LOCALAPPDATA 'nvim'

function Sync-NvimConfig {
    param(
        [string]$RepoUrl,
        [string]$ConfigPath,
        [switch]$Force
    )

    if (-not $RepoUrl) {
        Write-Step "No -RepoUrl supplied — skipping nvim config sync"
        Write-Host "Pass -RepoUrl <git-url> to clone/update your LazyVim config."
        return
    }

    Write-Step "Syncing nvim config at $ConfigPath"

    $isExistingRepo = Test-Path (Join-Path $ConfigPath '.git')
    $remoteMatches = $false

    if ($isExistingRepo) {
        Push-Location $ConfigPath
        try {
            $currentRemote = git remote get-url origin 2>$null
            $remoteMatches = ($currentRemote -eq $RepoUrl)
        } finally {
            Pop-Location
        }
    }

    $needsFreshClone = $Force -or ((Test-Path $ConfigPath) -and -not $remoteMatches)

    if ($needsFreshClone) {
        if (Test-Path $ConfigPath) {
            $backupPath = "$ConfigPath.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            $reason = if ($Force) { '-Force set' } else { 'existing dir is not the target repo' }
            Write-Host "  $reason, backing up to $backupPath"
            Move-Item $ConfigPath $backupPath
            Write-Ok "backed up"
        }

        foreach ($dir in @('nvim-data','nvim-state','nvim-cache')) {
            $p = Join-Path $env:LOCALAPPDATA $dir
            if (Test-Path $p) {
                Remove-Item $p -Recurse -Force
                Write-Ok "cleared $dir"
            }
        }

        git clone $RepoUrl $ConfigPath
        Write-Ok "config cloned"

        Write-Step "Bootstrapping plugins (headless, may take a minute)"
        nvim --headless "+Lazy! sync" +qa
        Write-Ok "plugins synced"
        return
    }

    if ($remoteMatches) {
        Write-Skip "config already cloned from $RepoUrl"
        Push-Location $ConfigPath
        try {
            $dirty = git status --porcelain
            if ($dirty) {
                Write-Warn "local changes present — skipping pull to avoid clobbering them"
                Write-Host "  local changes:`n$dirty"
            } else {
                git pull --ff-only
                Write-Ok "pulled latest config"

                Write-Step "Syncing plugins (headless, may take a minute)"
                nvim --headless "+Lazy! sync" +qa
                Write-Ok "plugins synced"
            }
        } finally {
            Pop-Location
        }
        return
    }

    git clone $RepoUrl $ConfigPath
    Write-Ok "config cloned"

    Write-Step "Bootstrapping plugins (headless, may take a minute)"
    nvim --headless "+Lazy! sync" +qa
    Write-Ok "plugins synced"
}

Sync-NvimConfig -RepoUrl $RepoUrl -ConfigPath $ConfigPath -Force:$Force
