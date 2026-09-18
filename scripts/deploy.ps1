<#
.SYNOPSIS
  Deploy the framework (skills/hooks/templates) from this repo into the runtime
  locations, so there is ONE source of truth. Edit in the repo, re-run deploy.

  Uses directory junctions on Windows (no admin needed). Junctions mean the
  deployed copy IS the repo copy — zero drift. Falls back to copy if junctions
  are unavailable.

.PARAMETER Vault
  Runtime memory vault. Default: $HOME\AgentMemory
.PARAMETER ClaudeDir
  Agent config dir. Default: $HOME\.claude
#>
param(
  [string]$Vault     = (Join-Path $HOME 'AgentMemory'),
  [string]$ClaudeDir = (Join-Path $HOME '.claude')
)
$ErrorActionPreference = 'Stop'
$Repo = Split-Path -Parent $PSScriptRoot

function Link-Dir($target, $source) {
  if (Test-Path $target) {
    $item = Get-Item $target -Force
    if ($item.LinkType) { Remove-Item $target -Force }           # stale link -> replace
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
# 1. Skills -> agent config so the agent can invoke /reflect /remember /recall
Link-Dir (Join-Path $ClaudeDir 'skills\agent-memory') (Join-Path $Repo 'skills')
# 2. Hooks -> agent config (referenced by settings.json)
Link-Dir (Join-Path $ClaudeDir 'agent-memory\hooks') (Join-Path $Repo 'hooks')
# 3. Templates -> vault (so remember/reflect can read them locally)
Link-Dir (Join-Path $Vault 'templates') (Join-Path $Repo 'templates')

Write-Host ""
Write-Host "Done. Next:"
Write-Host "  1. Merge hooks/settings.snippet.json into $ClaudeDir\settings.json (set AGENT_MEMORY_VAULT=$Vault)."
Write-Host "  2. Add the contract from docs/MEMORY-PROTOCOL.md to $ClaudeDir\CLAUDE.md."
Write-Host "  3. scripts/backup-remote.sh <private-remote> to wire homelab backup."
