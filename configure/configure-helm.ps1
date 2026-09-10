<#
.SYNOPSIS
    Adds commonly-used Helm chart repos. Idempotent.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Write-Step "Configuring Helm"

if (-not (Get-Command helm -ErrorAction SilentlyContinue)) {
    Write-Warn "helm not found on PATH \u2014 run setup.ps1 first (installs via winget). Skipping."
    return
}

$Repos = @(
    @{ Name = 'bitnami'; Url = 'https://charts.bitnami.com/bitnami' }
)

$existingRepos = (helm repo list -o json 2>$null | ConvertFrom-Json)

$anyAdded = $false
foreach ($repo in $Repos) {
    $match = $existingRepos | Where-Object { $_.name -eq $repo.Name }
    if ($match) {
        Write-Skip "repo '$($repo.Name)' already added"
        continue
    }

    helm repo add $repo.Name $repo.Url | Out-Null
    Write-Ok "added repo '$($repo.Name)' -> $($repo.Url)"
    $anyAdded = $true
}

if ($anyAdded) {
    helm repo update | Out-Null
    Write-Ok "helm repos updated"
}
