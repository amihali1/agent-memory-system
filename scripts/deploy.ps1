<#
.SYNOPSIS
  Deploy the framework (skills/hooks/templates) from this repo into the runtime
  locations, so there is ONE source of truth. Edit in the repo, re-run deploy.

  Uses directory junctions on Windows (no admin needed). Junctions mean the
  deployed copy IS the repo copy — zero drift. Falls back to copy if junctions
  are unavailable.

.PARAMETER Vault
  Runtime memory vault. Default: $env:AGENT_MEMORY_VAULT, else the
  AGENT_MEMORY_VAULT entry in <ClaudeDir>\settings.json, else $HOME\AgentMemory.
  Must be an existing vault (run scripts/init-vault.sh first).
.PARAMETER ClaudeDir
  Agent config dir. Default: $HOME\.claude
#>
param(
  [string]$Vault     = '',
  [string]$ClaudeDir = (Join-Path $HOME '.claude')
)
$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $PSScriptRoot

# Resolve the vault the same way the hooks do. AGENT_MEMORY_VAULT usually lives
# only in settings.json's "env" block (Claude Code sessions), not in this shell.
if (-not $Vault) { $Vault = $env:AGENT_MEMORY_VAULT }
if (-not $Vault) {
  $settings = Join-Path $ClaudeDir 'settings.json'
  if (Test-Path $settings) {
    try { $Vault = (Get-Content $settings -Raw | ConvertFrom-Json).env.AGENT_MEMORY_VAULT } catch {}
  }
}
if (-not $Vault) { $Vault = Join-Path $HOME 'AgentMemory' }
# Never scaffold a vault here: a wrong path would silently create a stray one.
if (-not (Test-Path (Join-Path $Vault 'MEMORY.md'))) {
  throw "No vault at $Vault (no MEMORY.md). Run scripts/init-vault.sh <path>, or pass -Vault <path>."
}
Write-Host "Vault: $Vault"

function Link-Dir($target, $source) {
  if (Test-Path $target) {
    $item = Get-Item $target -Force
    # Stale link -> replace. .Delete() removes only the link, never the target, and
    # unlike Remove-Item it doesn't prompt for confirmation on a directory link.
    if ($item.LinkType) { $item.Delete() }
    else { Write-Warning "  $target exists as a real dir; leaving it. Remove it to link."; return }
  }
  New-Item -ItemType Directory -Force -Path (Split-Path $target) | Out-Null
  try {
    New-Item -ItemType Junction -Path $target -Target $source | Out-Null
    Write-Host "  linked  $target -> $source"
  } catch {
    Copy-Item $source $target -Recurse -Force
    Write-Host "  copied  $target (junction unavailable)"
  }
}

Write-Host "Deploying framework from $Repo"
# 1. Skills -> agent config, one link per skill so each is invocable as /<name>
#    (/recall /remember /reflect /handoff). Claude Code only discovers skills one
#    level under skills/, so a single nested link would hide them all.
$legacy = Join-Path $ClaudeDir 'skills\agent-memory'
if ((Test-Path $legacy) -and (Get-Item $legacy -Force).LinkType) {
  (Get-Item $legacy -Force).Delete()
  Write-Host "  removed legacy nested link $legacy"
}
Get-ChildItem (Join-Path $Repo 'skills') -Directory | ForEach-Object {
  Link-Dir (Join-Path $ClaudeDir "skills\$($_.Name)") $_.FullName
}
# 2. Hooks -> agent config (referenced by settings.json)
Link-Dir (Join-Path $ClaudeDir 'agent-memory\hooks') (Join-Path $Repo 'hooks')
# 3. Templates -> vault (so remember/reflect can read them locally)
Link-Dir (Join-Path $Vault 'templates') (Join-Path $Repo 'templates')

Write-Host ""
Write-Host "Done. Next:"
Write-Host "  1. Merge hooks/settings.snippet.json into $ClaudeDir\settings.json (set AGENT_MEMORY_VAULT=$Vault)."
Write-Host "  2. Add the contract from docs/MEMORY-PROTOCOL.md to $ClaudeDir\CLAUDE.md."
Write-Host "  3. scripts/backup-remote.sh <private-remote> to wire homelab backup."
