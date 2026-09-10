<#
.SYNOPSIS
    Writes an opinionated, managed block into $PROFILE: PSReadLine tuning,
    handy aliases, module imports (posh-git, Terminal-Icons, PSFzf), and
    CLI tab-completion registration (kubectl, gh). Idempotent — the managed
    block is delimited by markers and fully replaced on each run; anything
    you add to $PROFILE outside the markers is left untouched.
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Write-Step "Configuring PowerShell profile"

$StartMarker = '# >>> dotfiles-managed: do not edit between markers >>>'
$EndMarker   = '# <<< dotfiles-managed <<<'

$requiredModules = @('posh-git', 'Terminal-Icons', 'PSFzf')
$missingModules = $requiredModules | Where-Object { -not (Get-Module -ListAvailable -Name $_) }
if ($missingModules) {
    Write-Warn "module(s) not installed: $($missingModules -join ', ') — run setup.ps1 first. Profile will still be written, but Import-Module for these will fail until installed."
}

$managedBlock = @"
$StartMarker

# --- PSReadLine ---
Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView -HistorySearchCursorMovesToEnd
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# --- Modules ---
# --- oh-my-posh (cached) ---
$ompCache = "$HOME\.cache\omp-jandedobbeleer.ps1"
if (-not (Test-Path $ompCache)) {
    New-Item -ItemType Directory -Path (Split-Path $ompCache) -Force | Out-Null
    oh-my-posh init pwsh --config "jandedobbeleer" | Out-File $ompCache -Encoding utf8
}
. $ompCache

# --- kubectl completion (cached) ---
$kubectlCache = "$HOME\.cache\kubectl-completion.ps1"
if ((Get-Command kubectl -ErrorAction SilentlyContinue) -and -not (Test-Path $kubectlCache)) {
    kubectl completion powershell | Out-File $kubectlCache -Encoding utf8
}
if (Test-Path $kubectlCache) { . $kubectlCache }

# --- gh completion (cached) ---
$ghCache = "$HOME\.cache\gh-completion.ps1"
if ((Get-Command gh -ErrorAction SilentlyContinue) -and -not (Test-Path $ghCache)) {
    gh completion -s powershell | Out-File $ghCache -Encoding utf8
}
if (Test-Path $ghCache) { . $ghCache }

if (Get-Module -Name PSFzf) {
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

# --- Aliases ---
function ll { Get-ChildItem @args }
function gs { git status @args }
Set-Alias -Name k -Value kubectl -ErrorAction SilentlyContinue

# --- CLI tab completion ---
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    kubectl completion powershell | Out-String | Invoke-Expression
}
if (Get-Command gh -ErrorAction SilentlyContinue) {
    gh completion -s powershell | Out-String | Invoke-Expression
}

$EndMarker
"@

if (-not (Test-Path $PROFILE)) {
    New-Item -ItemType File -Path $PROFILE -Force | Out-Null
    Write-Ok "created $PROFILE"
}

$existingContent = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ([string]::IsNullOrEmpty($existingContent)) { $existingContent = '' }

$pattern = [regex]::Escape($StartMarker) + '.*?' + [regex]::Escape($EndMarker)

if ($existingContent -match $pattern) {
    $updatedContent = [regex]::Replace($existingContent, $pattern, { $managedBlock }, 'Singleline')
    if ($updatedContent -eq $existingContent) {
        Write-Skip "managed profile block already up to date"
    } else {
        Set-Content -Path $PROFILE -Value $updatedContent
        Write-Ok "updated managed profile block"
    }
} else {
    $separator = if ($existingContent.TrimEnd().Length -gt 0) { "`n`n" } else { '' }
    Add-Content -Path $PROFILE -Value "$separator$managedBlock"
    Write-Ok "added managed profile block to $PROFILE"
}

Write-Host "Restart your terminal or run '. `$PROFILE' to apply." -ForegroundColor Green
