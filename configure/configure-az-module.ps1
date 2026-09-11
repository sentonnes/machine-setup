<#
.SYNOPSIS
    Sets opinionated Az PowerShell module config. Idempotent — safe to re-run.
    Separate from configure-az.ps1, which only covers the az CLI.

.PARAMETER TenantId
    Default Azure AD tenant to set on the Az module context. Subscriptions
    vary per-task, so only the tenant gets a default here — pick your
    subscription per-session with Set-AzContext / Select-AzSubscription.
#>

param(
    [string]$TenantId = '9134ca48-663d-4a05-968a-31a42f0aed3e'
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Write-Step "Configuring Az PowerShell module"

if (-not (Get-Module -ListAvailable -Name Az.Accounts -ErrorAction SilentlyContinue)) {
    Write-Warn "Az module not found. Run setup.ps1 first (installs via PSGallery) and restart your terminal."
    return
}

Import-Module Az.Accounts -ErrorAction Stop

# Persist login across sessions so you don't need Connect-AzAccount every new terminal.
Enable-AzContextAutosave -Scope CurrentUser | Out-Null
Write-Ok "context autosave enabled (persists login across sessions)"

# Quiet down the noisy breaking-change warnings and survey prompts.
Update-AzConfig -DisplayBreakingChangeWarning $false -DisplaySurveyMessage $false -Scope CurrentUser | Out-Null
Write-Ok "breaking-change warnings and survey prompts suppressed"

if ($TenantId) {
    $currentContext = Get-AzContext -ErrorAction SilentlyContinue
    if ($currentContext -and $currentContext.Tenant.Id -eq $TenantId) {
        Write-Skip "already using tenant $TenantId"
    } else {
        Write-Host "  Not signed in with tenant $TenantId yet."
        Write-Host "  Run: Connect-AzAccount -Tenant $TenantId"
    }
} else {
    Write-Host "Pass -TenantId <tenant-id> to pin a default tenant, or run Connect-AzAccount manually."
}

