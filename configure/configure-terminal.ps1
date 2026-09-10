<#
.SYNOPSIS
    Applies opinionated Windows Terminal settings (keybindings, default profile
    font/scheme) by merging them into the existing settings.json. Idempotent —
    only writes if something actually changed, and never touches unrelated keys
    (profile list, schemes, actions you've added yourself, etc).
#>

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot\_common.ps1"

Write-Step "Configuring Windows Terminal"

$SettingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (-not (Test-Path $SettingsPath)) {
    Write-Warn "settings.json not found at $SettingsPath — is Windows Terminal installed? Skipping."
    return
}

$json = Get-Content $SettingsPath -Raw | ConvertFrom-Json -Depth 20
$changed = $false

function Set-JsonProperty {
    param($Object, [string]$Name, $Value)
    $current = $Object.PSObject.Properties[$Name]
    if ($null -eq $current) {
        $Object | Add-Member -MemberType NoteProperty -Name $Name -Value $Value
        return $true
    }
    if (($current.Value | ConvertTo-Json -Depth 20 -Compress) -ne ($Value | ConvertTo-Json -Depth 20 -Compress)) {
        $current.Value = $Value
        return $true
    }
    return $false
}

# --- default profile: PowerShell 7 (pwsh), not Windows PowerShell ---
$pwshProfile = $json.profiles.list | Where-Object { $_.source -eq 'Windows.Terminal.PowershellCore' }
if ($pwshProfile -and (Set-JsonProperty -Object $json -Name 'defaultProfile' -Value $pwshProfile.guid)) {
    $changed = $true
    Write-Ok "defaultProfile set to PowerShell (pwsh)"
} else {
    Write-Skip "defaultProfile already correct (or pwsh profile not found)"
}

# --- theme ---
if (Set-JsonProperty -Object $json -Name 'theme' -Value 'light') {
    $changed = $true
    Write-Ok "theme set to light"
} else {
    Write-Skip "theme already light"
}

# --- profile defaults: font, colour scheme, acrylic, antialiasing ---
if (-not $json.profiles.defaults) {
    $json.profiles | Add-Member -MemberType NoteProperty -Name 'defaults' -Value ([PSCustomObject]@{})
}
$defaults = $json.profiles.defaults

if (Set-JsonProperty -Object $defaults -Name 'font' -Value ([PSCustomObject]@{ face = 'JetBrainsMono NF' })) {
    $changed = $true
    Write-Ok "default font set to JetBrainsMono NF"
} else {
    Write-Skip "default font already JetBrainsMono NF"
}

if (Set-JsonProperty -Object $defaults -Name 'colorScheme' -Value ([PSCustomObject]@{ light = 'Campbell' })) {
    $changed = $true
    Write-Ok "default colour scheme set to Campbell (light)"
} else {
    Write-Skip "default colour scheme already set"
}

if (Set-JsonProperty -Object $defaults -Name 'useAcrylic' -Value $true) {
    $changed = $true
    Write-Ok "useAcrylic enabled"
} else {
    Write-Skip "useAcrylic already enabled"
}

if (Set-JsonProperty -Object $defaults -Name 'antialiasingMode' -Value 'grayscale') {
    $changed = $true
    Write-Ok "antialiasingMode set to grayscale"
} else {
    Write-Skip "antialiasingMode already grayscale"
}

# --- keybindings: merge in the desired ones, leave any others untouched ---
$desiredKeybindings = @(
    @{ id = 'Terminal.CopyToClipboard';   keys = 'ctrl+c' }
    @{ id = 'Terminal.PasteFromClipboard'; keys = 'ctrl+v' }
    @{ id = 'Terminal.DuplicatePaneAuto';  keys = 'alt+shift+d' }
)

$existingKeybindings = @($json.keybindings)
foreach ($kb in $desiredKeybindings) {
    $match = $existingKeybindings | Where-Object { $_.keys -eq $kb.keys -and $_.id -eq $kb.id }
    if (-not $match) {
        $existingKeybindings += [PSCustomObject]$kb
        $changed = $true
        Write-Ok "added keybinding $($kb.keys) -> $($kb.id)"
    } else {
        Write-Skip "keybinding $($kb.keys) -> $($kb.id) already present"
    }
}
$json.keybindings = $existingKeybindings

if ($changed) {
    $backupPath = "$SettingsPath.bak-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item $SettingsPath $backupPath
    Write-Ok "backed up existing settings to $backupPath"

    $json | ConvertTo-Json -Depth 20 | Set-Content -Path $SettingsPath -Encoding utf8
    Write-Ok "settings.json updated"
} else {
    Write-Skip "no changes needed — settings.json already matches desired config"
}
