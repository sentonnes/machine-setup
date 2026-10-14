<#
    Data file, dot-sourced by setup.ps1. Defines $NpmPackages — the global npm
    packages to install — plus the function used to install them. Requires
    Node.js/npm (installed by sources/winget.ps1). Edit the package list to
    add/remove packages; setup.ps1 itself should not need to change.
#>

function Install-NpmPackages {
    param([array]$PackageList)

    Write-Step "Installing global npm packages"
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
        throw "npm not found. Ensure Node.js is installed (winget source) and restart your terminal."
    }

    foreach ($pkg in $PackageList) {
        $spec = if ($pkg.Version) { "$($pkg.Package)@$($pkg.Version)" } else { $pkg.Package }

        # Skip when the command already reports the pinned version (or, unpinned, simply exists).
        if ($pkg.Cmd -and (Get-Command $pkg.Cmd -ErrorAction SilentlyContinue)) {
            if (-not $pkg.Version) {
                Write-Skip "$($pkg.Name) already installed"
                continue
            }
            $current = (& $pkg.Cmd --version 2>$null | Select-Object -First 1)
            if ($current -and $current.Trim() -eq $pkg.Version) {
                Write-Skip "$($pkg.Name) $($pkg.Version) already installed"
                continue
            }
        }

        Write-Host "  installing $spec..."
        npm install -g $spec
        if ($LASTEXITCODE -ne 0) {
            if ($pkg.Optional) {
                Write-Warn "optional npm package $spec failed, continuing"
                continue
            }
            throw "Failed to install required npm package $spec (exit code $LASTEXITCODE)"
        }
        Write-Ok "$spec installed"
    }
}

$NpmPackages = @(
    @{ Package = 'prettier'; Name = 'Prettier'; Version = '3.9.10'; Cmd = 'prettier' }
)
