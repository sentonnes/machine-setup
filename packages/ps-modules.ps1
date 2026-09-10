<#
    Data file, dot-sourced by setup.ps1. Defines $PSModules — the PowerShell
    Gallery modules to install. Edit this file to add/remove modules;
    setup.ps1 itself should not need to change.
#>

$PSModules = @(
    @{ Name = 'Az';             CheckModule = 'Az.Accounts' }
    @{ Name = 'posh-git';       CheckModule = 'posh-git' }
    @{ Name = 'Terminal-Icons'; CheckModule = 'Terminal-Icons' }
    @{ Name = 'PSFzf';          CheckModule = 'PSFzf' }
    # Add more PowerShell Gallery modules here, e.g.:
    # @{ Name = 'Pester';      CheckModule = 'Pester' }
)
