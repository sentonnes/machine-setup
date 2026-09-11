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
# CONFIG — defined in packages/winget.ps1 and packages/ps-modules.ps1.
# Edit those files to add/remove what gets installed; this file shouldn't
# need to change.
# ===========================================================================

. "$PSScriptRoot\packages\winget.ps1"
. "$PSScriptRoot\packages\ps-modules.ps1"

# ===========================================================================
# FUNCTIONS
# ===========================================================================

function Test-Prerequisites {
    Write-Step "Checking prerequisites"
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget not found. Install 'App Installer' from the Microsoft Store first."
    }
    Write-Ok "winget found"
}

function Install-WingetPackages {
    param([array]$PackageList)

    Write-Step "Installing packages via winget"
    foreach ($pkg in $PackageList) {
        $installed = winget list --id $pkg.Id --exact --accept-source-agreements 2>$null | Select-String $pkg.Id
        if ($installed) {
            Write-Skip "$($pkg.Name) already installed"
            continue
        }

        Write-Host "  installing $($pkg.Name)..."
        try {
            $installArgs = @('install', '--id', $pkg.Id, '--exact', '--silent',
                              '--accept-package-agreements', '--accept-source-agreements')
            if ($pkg.Version) {
                $installArgs += @('--version', $pkg.Version)
            }
            winget @installArgs
            Write-Ok "$($pkg.Name) installed"
        } catch {
            if ($pkg.Optional) {
                Write-Warn "optional package $($pkg.Name) failed, continuing"
            } else {
                throw "Failed to install required package $($pkg.Name): $_"
            }
        }
    }
}

function Install-PSModules {
    param([array]$ModuleList)

    Write-Step "Installing PowerShell modules"
    foreach ($mod in $ModuleList) {
        $checkName = if ($mod.CheckModule) { $mod.CheckModule } else { $mod.Name }
        if (Get-Module -ListAvailable -Name $checkName -ErrorAction SilentlyContinue) {
            Write-Skip "$($mod.Name) already installed"
            continue
        }

        Write-Host "  installing $($mod.Name)..."
        try {
            Install-Module -Name $mod.Name -Scope CurrentUser -Repository PSGallery -Force
            Write-Ok "$($mod.Name) installed"
        } catch {
            throw "Failed to install PowerShell module $($mod.Name): $_"
        }
    }
}

function Update-SessionPath {
    param([array]$PackageList)

    Write-Step "Refreshing PATH for this session"
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + `
                [System.Environment]::GetEnvironmentVariable('Path','User')

    $cmdsToCheck = $PackageList | Where-Object { $_.Cmd } | Select-Object -ExpandProperty Cmd -Unique

    foreach ($cmd in $cmdsToCheck) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            Write-Ok "$cmd on PATH"
        } else {
            Write-Warn "$cmd not on PATH yet — you may need to restart your terminal"
        }
    }
}

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
