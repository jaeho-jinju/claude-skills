#!/bin/bash
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$HOME/.claude/skills"

mkdir -p "$SKILLS_DIR"

echo "Installing Claude skills to $SKILLS_DIR..."

for skill_dir in "$REPO_DIR"/skills/*/; do
  skill_name=$(basename "$skill_dir")

  # SKILL.md 없으면 스킬 폴더가 아님 — 건너뜀
  if [ ! -f "$skill_dir/SKILL.md" ]; then
    continue
  fi

  target="$SKILLS_DIR/$skill_name"

  if [ -L "$target" ]; then
    rm "$target"
    ln -s "$skill_dir" "$target"
    echo "  Updated:   $skill_name"
  elif [ -d "$target" ]; then
    echo "  Skipped:   $skill_name (이미 존재하는 디렉토리 — 직접 제거 후 재실행)"
  else
    ln -s "$skill_dir" "$target"
    echo "  Installed: $skill_name"
  fi
done

# CLAUDE.md 설치
CLAUDE_MD="$REPO_DIR/CLAUDE.md"
CLAUDE_TARGET="$HOME/.claude/CLAUDE.md"

if [ -f "$CLAUDE_MD" ]; then
  if [ -L "$CLAUDE_TARGET" ]; then
    rm "$CLAUDE_TARGET"
    ln -s "$CLAUDE_MD" "$CLAUDE_TARGET"
    echo "  Updated:   CLAUDE.md"
  elif [ -f "$CLAUDE_TARGET" ]; then
    echo "  Skipped:   CLAUDE.md (이미 존재하는 파일 — 직접 제거 후 재실행)"
  else
    ln -s "$CLAUDE_MD" "$CLAUDE_TARGET"
    echo "  Installed: CLAUDE.md"
  fi
fi

echo "Done!"
