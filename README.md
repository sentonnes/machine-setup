# machine-setup

Windows dev machine bootstrap scripts. Two phases:

1. **Install** — winget packages + PowerShell Gallery modules (`setup.ps1`)
2. **Configure** — dotfiles, tool wiring, and settings (`configure.ps1`)

Both phases are idempotent — safe to re-run any time to pick up updates or
repair drift.

## Usage

```powershell
.\setup.ps1
```

This installs everything and then automatically hands off to `configure.ps1`.

| Flag              | Effect                                                        |
|-------------------|----------------------------------------------------------------|
| `-Force`          | Passed through to `configure-nvim.ps1` — forces a fresh clone   |
| `-SkipConfigure`  | Install only, don't run `configure.ps1` at the end              |

You can also run configuration on its own (e.g. to re-apply config without
reinstalling anything):

```powershell
.\configure.ps1 -Force
```

## Repo layout

```
setup.ps1                     # Entry point: install, then configure
configure.ps1                 # Orchestrator: auto-discovers configure/configure-*.ps1
sources/
  winget.ps1                  # $WingetPackages + winget install functions
  ps-modules.ps1              # $PSModules + PowerShell Gallery install function
configure/
  _common.ps1                 # Shared Write-Step/Write-Ok/Write-Skip/Write-Warn helpers
  configure-*.ps1              # One script per tool; auto-discovered, no registration needed
```

### `sources/`

Data files dot-sourced by `setup.ps1`. Each defines what to install (a list)
and the function that installs it, so `setup.ps1` itself never needs to
change — only these files do, when you add/remove software:

- **`winget.ps1`** — `$WingetPackages` (id/name/optional pinned version/expected
  command), plus `Test-Prerequisites`, `Install-WingetPackages`, and
  `Update-SessionPath`.
- **`ps-modules.ps1`** — `$PSModules` (PowerShell Gallery modules), plus
  `Install-PSModules`.

Future package sources (e.g. Chocolatey) can be added the same way — a new
`sources/choco.ps1` with its own `$ChocoPackages` list and install function,
dot-sourced from `setup.ps1`.

### `configure/`

`configure.ps1` auto-discovers every `configure/configure-*.ps1` file and
runs it — add a new file and it's picked up automatically, no edits needed
to the orchestrator. `configure-nvim.ps1` always runs first (order-sensitive,
since other scripts may depend on nvim's config being cloned); everything
else runs after, alphabetically.

Each script is independently re-runnable and responsible for its own
configuration values (repo URLs, themes, etc) via parameter defaults.

Implemented so far: `configure-nvim`, `configure-git`, `configure-gh`,
`configure-az`, `configure-az-module`, `configure-helm`, `configure-terraform`,
`configure-terminal`, `configure-powershell-profile` (also owns oh-my-posh
init — see below), `configure-dotnet`, `configure-dev-tools`,
`configure-docker`, `configure-copilot-app`. The rest are stubs
(`Write-Skip "not yet implemented"`)
— TODO ideas are documented in each file's header comment.

## Manual steps

A couple of things can't be fully automated and need doing by hand:

- **`sqlite3.dll`** — winget's `SQLite.SQLite3` package only ships the
  `sqlite3` CLI, not the loadable DLL that Neovim's `sqlite.lua`-based
  plugins need at runtime. Running `configure-dev-tools.ps1` (part of the
  normal `configure.ps1` pass) creates `C:\dev-tools` and will warn you if
  the DLL is missing, with a link and instructions. In short:
  1. Download the precompiled binaries zip (`sqlite-dll-win-x64-*.zip`) from
     <https://www.sqlite.org/download.html>
  2. Extract `sqlite3.dll` into `C:\dev-tools`
  3. Point `vim.g.sqlite_clib_path` at `C:\dev-tools\sqlite3.dll` in your
     nvim config

- **NuGet source** — `configure-dotnet.ps1` (part of the normal
  `configure.ps1` pass) checks for and registers the official `nuget.org`
  source (`dotnet nuget add source https://api.nuget.org/v3/index.json -n
  nuget.org`) if it isn't already there, so `dotnet restore` works for any
  Neovim plugins/tools that shell out to `dotnet`.

