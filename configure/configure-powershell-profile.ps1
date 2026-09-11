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

$StartMarker = '# >>> managed: do not edit between markers >>>'
$EndMarker   = '# <<< managed <<<'

$requiredModules = @('posh-git', 'Terminal-Icons', 'PSFzf')
$missingModules = $requiredModules | Where-Object { -not (Get-Module -ListAvailable -Name $_) }
if ($missingModules) {
    Write-Warn "module(s) not installed: $($missingModules -join ', ') — run setup.ps1 first. Profile will still be written, but Import-Module for these will fail until installed."
}

$managedBlock = @"
$StartMarker

# Toggle without editing this file: $env:PROFILE_TIMING = $true  (set before opening a new shell)
$TimingEnabled = $false
$Timings = [ordered]@{}

function Measure-Section {
    param([string]$Name, [scriptblock]$Body)
    if ($TimingEnabled) {
        $ms = (Measure-Command { & $Body }).TotalMilliseconds
        $Timings[$Name] = [math]::Round($ms, 1)
    } else {
        & $Body
    }
}

$CachePath = "$HOME\.cache"

function Invoke-CachedInit {
    param([string]$Path, [string]$Expression)
    if (-not (Test-Path $Path)) {
        New-Item -ItemType Directory -Path (Split-Path $Path) -Force | Out-Null
        Invoke-Expression $Expression | Out-File $Path -Encoding utf8
    }
    . $Path
}

# --- PSReadLine ---
Measure-Section 'PSReadLine' {
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView -HistorySearchCursorMovesToEnd
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
}

# --- Modules ---
Measure-Section 'posh-git' {
    Import-Module posh-git -ErrorAction SilentlyContinue
}
Measure-Section 'Terminal-Icons' {
    Import-Module Terminal-Icons -ErrorAction SilentlyContinue
}
Measure-Section 'PSFzf' {
    Import-Module PSFzf -ErrorAction SilentlyContinue
    if (Get-Module -Name PSFzf) {
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
    }
}

# --- oh-my-posh (cached) ---
Measure-Section 'oh-my-posh init' {
    Invoke-CachedInit -Path "$CachePath\omp-jandedobbeleer.ps1" -Expression 'oh-my-posh init pwsh --config "jandedobbeleer"'
}

# --- kubectl completion (cached) ---
Measure-Section 'kubectl completion' {
    if (Get-Command kubectl -ErrorAction SilentlyContinue) {
        Invoke-CachedInit -Path "$CachePath\kubectl-completion.ps1" -Expression 'kubectl completion powershell'
    }
}

# --- gh completion (cached) ---
Measure-Section 'gh completion' {
    if (Get-Command gh -ErrorAction SilentlyContinue) {
        Invoke-CachedInit -Path "$CachePath\gh-completion.ps1" -Expression 'gh completion -s powershell'
    }
}

# --- Aliases ---
function ll { Get-ChildItem @args }
function gs { git status @args }
Set-Alias -Name k -Value kubectl -ErrorAction SilentlyContinue

if ($TimingEnabled) {
    Write-Host "`n--- profile timing ($([math]::Round(($Timings.Values | Measure-Object -Sum).Sum, 1))ms total) ---" -ForegroundColor Cyan
    $Timings.GetEnumerator() | Sort-Object Value -Descending | Format-Table Name, @{L='ms';E={$_.Value}} -AutoSize
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
