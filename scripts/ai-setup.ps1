# setup.ps1 — ~/.agents framework setup for Windows PowerShell
# Run as Administrator (required for symlink creation on Windows)

$ErrorActionPreference = "Stop"

# HOME\.agents
if (-not (Test-Path "$env:USERPROFILE\.agents") ) {
    New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.agents"  -Target "D:\Users\user\.agents"  -Force
}

# Cursor
if (-not (Test-Path "$env:USERPROFILE\.cursor") ) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.cursor" -Force | Out-Null
}
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.cursor\rules"  -Target "$env:USERPROFILE\.agents\rules"  -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.cursor\skills" -Target "$env:USERPROFILE\.agents\skills"  -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.cursor\agents" -Target "$env:USERPROFILE\.agents\agents"  -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.cursor\commands" -Target "$env:USERPROFILE\.agents\prompts"  -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.cursor\AGENTS.md" -Target "$env:USERPROFILE\.agents\AGENTS.md" -Force

# Claude 
if (-not (Test-Path "$env:USERPROFILE\.claude") ) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.claude" -Force | Out-Null
}

New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\CLAUDE.md" -Target "$env:USERPROFILE\.agents\AGENTS.md" -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\rules"  -Target "$env:USERPROFILE\.agents\rules" -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\skills" -Target "$env:USERPROFILE\.agents\skills" -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\agents" -Target "$env:USERPROFILE\.agents\agents" -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\commands" -Target "$env:USERPROFILE\.agents\prompts" -Force


# Codex
if (-not (Test-Path "$env:USERPROFILE\.codex") ) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.codex" -Force | Out-Null
}

New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.codex\skills" -Target "$env:USERPROFILE\.agents\skills" -Force
# Codex config.toml:
$toml = "$env:USERPROFILE\.codex\config.toml"
$path = ($env:USERPROFILE -replace "\\", "/") + "/.agents/AGENTS.md"
$line = "model_instructions_file = `"$path`""
if (-not (Test-Path $toml)) {
    Set-Content -Path $toml -Value $line -Encoding UTF8
} elseif (-not (Select-String -Path $toml -Pattern "model_instructions_file")) {
    Add-Content -Path $toml -Value $line -Encoding UTF8
}

# Copilot
[System.Environment]::SetEnvironmentVariable("COPILOT_CUSTOM_INSTRUCTIONS_DIRS", "$env:USERPROFILE\.agents", "User")
if (-not (Test-Path "$env:USERPROFILE\.github") ) {
    New-Item -ItemType Directory -Path "$env:USERPROFILE\.github" -Force | Out-Null
}

New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.github\copilot-instructions.md" -Target "$env:USERPROFILE\.agents\AGENTS.md" -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.github\agents" -Target "$env:USERPROFILE\.agents\agents" -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.github\instructions" -Target "$env:USERPROFILE\.agents\rules" -Force
New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.github\prompts" -Target "$env:USERPROFILE\.agents\prompts" -Force

