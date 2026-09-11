<#
    Data file, dot-sourced by setup.ps1. Defines $WingetPackages — the winget
    packages to install. Edit this file to add/remove software; setup.ps1
    itself should not need to change.
#>

$WingetPackages = @(
    # Editor / core
    @{ Id = 'Neovim.Neovim'; Name = 'Neovim'; Cmd = 'nvim' }
    @{ Id = 'Git.Git'; Name = 'Git'; Cmd = 'git' }
    @{ Id = 'BurntSushi.ripgrep.MSVC'; Name = 'ripgrep (Telescope live grep)'; Cmd = 'rg' }
    @{ Id = 'sharkdp.fd'; Name = 'fd (Telescope find files)'; Cmd = 'fd' }
    @{ Id = 'junegunn.fzf'; Name = 'fzf (fallback fuzzy finder)'; Cmd = 'fzf' }
    @{ Id = 'BrechtSanders.WinLibs.POSIX.UCRT'; Name = 'C compiler for treesitter parsers'; Cmd = 'gcc' }
    @{ Id = 'gerardog.gsudo'; Name = 'gsudo (optional, elevation helper)'; Cmd = 'gsudo' }

    # Programming languages / runtimes
    @{ Id = 'OpenJS.NodeJS.LTS'; Name = 'Node.js (LSP servers, CopilotChat)'; Cmd = 'node' }
    @{ Id = 'GoLang.Go'; Name = 'Go'; Cmd = 'go' }
    @{ Id = 'Microsoft.DotNet.SDK.8'; Name = '.NET SDK 8'; Cmd = 'dotnet' }
    @{ Id = 'Microsoft.DotNet.SDK.10'; Name = '.NET SDK 10'; Cmd = 'dotnet' }
    @{ Id = 'DEVCOM.Lua'; Name = 'Lua'; Cmd = 'lua' }
    @{ Id = 'Microsoft.PowerShell'; Name = 'PowerShell 7+'; Cmd = 'pwsh' }
    @{ Id = 'Microsoft.NuGet'; Name = 'NuGet CLI'; Cmd = 'nuget' }

    # IaC / Kubernetes
    @{ Id = 'Hashicorp.Terraform'; Name = 'TerraformCLI'; Cmd = 'terraform' }
    @{ Id = 'OpenTofu.Tofu'; Name = 'OpenTofu'; Cmd = 'tofu' }
    @{ Id = 'Gruntwork.Terragrunt'; Name = 'Terragrunt'; Cmd = 'terragrunt' }
    @{ Id = 'Terraform-docs.Terraform-docs'; Name = 'terraform-docs'; Cmd = 'terraform-docs' }
    @{ Id = 'TerraformLinters.tflint'; Name = 'tflint'; Cmd = 'tflint' }
    @{ Id = 'Helm.Helm'; Name = 'Helm'; Version = '4.2.4'; Cmd = 'helm' }
    @{ Id = 'Kubernetes.kubectl'; Name = 'kubectl'; Cmd = 'kubectl' }
    @{ Id = 'Kubernetes.minikube'; Name = 'minikube'; Cmd = 'minikube' }
    @{ Id = 'Microsoft.AzureCLI'; Name = 'Azure CLI'; Cmd = 'az' }

    # Containers / WSL
    @{ Id = 'Docker.DockerDesktop'; Name = 'Docker Desktop'; Cmd = 'docker' }
    @{ Id = 'Microsoft.WSL'; Name = 'WSL'; Cmd = 'wsl' }

    # Terminal / shell
    @{ Id = 'Microsoft.WindowsTerminal'; Name = 'Windows Terminal'; Cmd = 'wt' }
    @{ Id = 'JanDeDobbeleer.OhMyPosh'; Name = 'Oh My Posh'; Cmd = 'oh-my-posh' }
    @{ Id = 'DEVCOM.JetBrainsMonoNerdFont'; Name = 'JetBrainsMono Nerd Font' }  # font, no CLI/Cmd to check

    # GitHub
    @{ Id = 'GitHub.cli'; Name = 'GitHub CLI'; Cmd = 'gh' }
    @{ Id = 'GitHub.CopilotApp'; Name = 'GitHub Copilot App' }  # GUI app, no CLI/Cmd to check

    # Utilities
    @{ Id = 'NickeManarin.ScreenToGif'; Name = 'ScreenToGif' }  # GUI app, no CLI/Cmd to check
    @{ Id = 'liule.Snipaste'; Name = 'Snipaste' }  # GUI app, no CLI/Cmd to check
    @{ Id = 'Ditto.Ditto'; Name = 'Ditto' }  # GUI app, no CLI/Cmd to check
)
