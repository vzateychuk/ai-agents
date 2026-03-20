#!/usr/bin/env bash
# setup.sh — ~/.agents framework setup for Linux / WSL
# No root required; symlinks work natively in Linux

set -euo pipefail

# ── Target: real .agents directory ────────────────────────────────────────────
AGENTS_TARGET="$HOME/.agents"

if [[ ! -d "$AGENTS_TARGET" ]]; then
  echo "ERROR: Target directory '$AGENTS_TARGET' does not exist. Aborting." >&2
  exit 1
fi

# ── Helper ────────────────────────────────────────────────────────────────────
link() {
  # link <target> <link_path>
  # Creates parent dir if needed; overwrites existing symlink.
  local target="$1" link_path="$2"
  mkdir -p "$(dirname "$link_path")"
  ln -sfn "$target" "$link_path"
}

# ── Cursor ────────────────────────────────────────────────────────────────────
mkdir -p "$HOME/.cursor"
link "$AGENTS_TARGET/rules"     "$HOME/.cursor/rules"
link "$AGENTS_TARGET/skills"    "$HOME/.cursor/skills"
link "$AGENTS_TARGET/agents"    "$HOME/.cursor/agents"
link "$AGENTS_TARGET/prompts"   "$HOME/.cursor/commands"
link "$AGENTS_TARGET/AGENTS.md" "$HOME/.cursor/AGENTS.md"

# ── Claude Code ───────────────────────────────────────────────────────────────
mkdir -p "$HOME/.claude"
link "$AGENTS_TARGET/AGENTS.md" "$HOME/.claude/CLAUDE.md"
link "$AGENTS_TARGET/rules"     "$HOME/.claude/rules"
link "$AGENTS_TARGET/skills"    "$HOME/.claude/skills"
link "$AGENTS_TARGET/agents"    "$HOME/.claude/agents"
link "$AGENTS_TARGET/prompts"   "$HOME/.claude/commands"

# ── Codex CLI ─────────────────────────────────────────────────────────────────
mkdir -p "$HOME/.codex"
link "$AGENTS_TARGET/skills" "$HOME/.codex/skills"

TOML="$HOME/.codex/config.toml"
TOML_LINE="model_instructions_file = \"$AGENTS_TARGET/AGENTS.md\""

if [[ ! -f "$TOML" ]]; then
  echo "$TOML_LINE" > "$TOML"
elif ! grep -q "model_instructions_file" "$TOML"; then
  echo "$TOML_LINE" >> "$TOML"
fi

# ── GitHub Copilot ────────────────────────────────────────────────────────────
mkdir -p "$HOME/.github"
link "$AGENTS_TARGET/AGENTS.md" "$HOME/.github/copilot-instructions.md"
link "$AGENTS_TARGET/agents"    "$HOME/.github/agents"
link "$AGENTS_TARGET/rules"     "$HOME/.github/instructions"
link "$AGENTS_TARGET/prompts"   "$HOME/.github/prompts"

# ── Copilot env var ───────────────────────────────────────────────────────────
if [[ -n "${ZSH_VERSION:-}" ]]; then
  PROFILE="$HOME/.zshrc"
else
  PROFILE="$HOME/.bashrc"
fi

EXPORT_LINE="export COPILOT_CUSTOM_INSTRUCTIONS_DIRS=\"$AGENTS_TARGET\""

if ! grep -q "COPILOT_CUSTOM_INSTRUCTIONS_DIRS" "$PROFILE" 2>/dev/null; then
  printf "\n# Added by setup.sh — ~/.agents framework\n%s\n" "$EXPORT_LINE" >> "$PROFILE"
  echo "NOTE: Run 'source $PROFILE' or restart your shell to apply COPILOT_CUSTOM_INSTRUCTIONS_DIRS"
fi

echo "Done. All symlinks created."