<#
    Data file, dot-sourced by setup.ps1. Defines $PSModules — the PowerShell
    Gallery modules to install — plus the function used to install them.
    Edit the module list to add/remove modules; setup.ps1 itself should not
    need to change.
#>

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

$PSModules = @(
    @{ Name = 'Az';             CheckModule = 'Az.Accounts' }
    @{ Name = 'posh-git';       CheckModule = 'posh-git' }
    @{ Name = 'Terminal-Icons'; CheckModule = 'Terminal-Icons' }
    @{ Name = 'PSFzf';          CheckModule = 'PSFzf' }
    # Add more PowerShell Gallery modules here, e.g.:
    # @{ Name = 'Pester';      CheckModule = 'Pester' }
)
