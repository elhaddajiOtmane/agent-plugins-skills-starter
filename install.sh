#!/usr/bin/env bash
# osmeng-agent-starter — pulls curated Agent Skills (SKILL.md) repos and
# installs them where OpenCode looks for skills.
#
# OpenCode skill locations (see https://opencode.ai/docs/skills/):
#   global:  ~/.config/opencode/skills/<name>/SKILL.md
#   project: ./.opencode/skills/<name>/SKILL.md
# It also auto-reads ~/.claude/skills and ~/.agents/skills (and project
# .claude/skills, .agents/skills), so anything already there is picked up
# for free — this script only needs to write ONE of these, and it writes
# the native opencode/ path.
#
# Usage:
#   ./install.sh                     install core set, global scope
#   ./install.sh --scope project     install into ./.opencode/skills instead
#   ./install.sh --include-mega      also pull the two huge collections (ECC, OmniRoute)
#   ./install.sh --force             overwrite skills that already exist locally
#   ./install.sh --dry-run           show what would happen, touch nothing

set -euo pipefail
shopt -s nullglob

SCOPE="global"
INCLUDE_MEGA=false
FORCE=false
DRY_RUN=false

usage() {
  sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --scope) SCOPE="${2:-}"; shift 2 ;;
    --include-mega) INCLUDE_MEGA=true; shift ;;
    --force) FORCE=true; shift ;;
    --dry-run) DRY_RUN=true; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1"; usage; exit 1 ;;
  esac
done

if ! command -v git >/dev/null 2>&1; then
  echo "git is required and wasn't found on PATH." >&2
  exit 1
fi

case "$SCOPE" in
  global)  TARGET="$HOME/.config/opencode/skills" ;;
  project) TARGET="$(pwd)/.opencode/skills" ;;
  *) echo "Invalid --scope '$SCOPE' (use 'global' or 'project')" >&2; exit 1 ;;
esac

mkdir -p "$TARGET"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

installed=0
skipped=0
failed=0

install_skill_dir() {
  # $1 = source dir containing SKILL.md   $2 = target skill name
  local src="$1" name="$2"
  local dest="$TARGET/$name"
  if [[ -e "$dest" ]]; then
    if [[ "$FORCE" == true ]]; then
      [[ "$DRY_RUN" == true ]] || rm -rf "$dest"
    else
      echo "  skip    $name (exists — rerun with --force to overwrite)"
      skipped=$((skipped + 1))
      return
    fi
  fi
  if [[ "$DRY_RUN" == true ]]; then
    echo "  would install  $name"
  else
    cp -r "$src" "$dest"
    echo "  installed      $name"
  fi
  installed=$((installed + 1))
}

process_source() {
  # $1 repo (owner/name)  $2 path to skills/ inside repo  $3 depth (1 or 2)  $4 label
  local repo="$1" base="$2" depth="$3" label="$4"
  echo "== $label — $repo =="
  local dir="$WORKDIR/${repo//\//_}"
  if ! git clone --depth 1 --quiet "https://github.com/$repo.git" "$dir" 2>"$WORKDIR/err"; then
    echo "  ERROR: clone failed"
    sed 's/^/  /' "$WORKDIR/err"
    failed=$((failed + 1))
    echo
    return
  fi
  local base_path="$dir/$base"
  if [[ ! -d "$base_path" ]]; then
    echo "  ERROR: expected path '$base' not found in repo"
    failed=$((failed + 1))
    echo
    return
  fi
  if [[ "$depth" == "1" ]]; then
    for skill_md in "$base_path"/*/SKILL.md; do
      local skill_dir name
      skill_dir="$(dirname "$skill_md")"
      name="$(basename "$skill_dir")"
      install_skill_dir "$skill_dir" "$name"
    done
  else
    for skill_md in "$base_path"/*/*/SKILL.md; do
      local skill_dir name category
      skill_dir="$(dirname "$skill_md")"
      name="$(basename "$skill_dir")"
      category="$(basename "$(dirname "$skill_dir")")"
      install_skill_dir "$skill_dir" "${category}-${name}"
    done
  fi
  rm -rf "$dir"
  echo
}

echo "osmeng-agent-starter"
echo "scope:  $SCOPE"
echo "target: $TARGET"
[[ "$DRY_RUN" == true ]] && echo "(dry run — nothing will be written)"
echo

echo "### core skills ###"
echo
process_source "Leonxlnx/taste-skill"    "skills"        1 "taste-skill (design taste / anti-slop, 13 skills)"
process_source "DietrichGebert/ponytail" "skills"        1 "ponytail (lean/minimal-diff coding discipline, 6 skills)"
process_source "AgriciDaniel/claude-seo" "skills"        1 "claude-seo core (technical SEO, no API keys needed, 25 skills)"
process_source "kepano/obsidian-skills"  "skills"        1 "obsidian-skills (Obsidian CLI/Bases/Markdown, 5 skills)"
process_source "mattpocock/skills"       "skills"        2 "mattpocock/skills (eng + productivity workflows, 37 skills)"

if [[ "$INCLUDE_MEGA" == true ]]; then
  echo "### mega collections (--include-mega) ###"
  echo
  process_source "affaan-m/ECC"           "skills" 1 "ECC (286 skills, broad stack coverage — big)"
  process_source "diegosouzapw/OmniRoute" "skills" 1 "OmniRoute (46 skills, teaches use of the OmniRoute gateway)"
fi

echo "----------------------------------------"
echo "installed: $installed   skipped: $skipped   failed: $failed"
echo "target:    $TARGET"
echo
echo "Restart OpenCode (or start a new session) and ask it to list its"
echo "skills to confirm they loaded."
