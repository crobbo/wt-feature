#!/usr/bin/env bash
# wt-feature - Git worktree helper for feature branch development
# https://github.com/xtian/wt-feature

# Load config if exists
[[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/wt-feature/config" ]] && \
  source "${XDG_CONFIG_HOME:-$HOME/.config}/wt-feature/config"

# Defaults
: ${WT_WORKTREES_DIR:=""}
: ${WT_FILES_TO_COPY:=""}
: ${WT_SETUP_COMMANDS:=""}

wt-feature() {
  local name="$1"
  local base="$2"
  local branch_name

  if [[ -z "$name" ]]; then
    echo "Usage: wt-feature <name> [base-branch]"
    echo ""
    echo "Creates a git worktree with automatic setup."
    echo ""
    echo "Arguments:"
    echo "  name        - Branch name (e.g., 'my-feature' or 'bugfix/issue-123')"
    echo "  base-branch - Base branch (optional, auto-detected)"
    echo ""
    echo "Branch type defaults:"
    echo "  hotfix/*  -> origin/main"
    echo "  feature/* -> origin/develop"
    echo "  bugfix/*  -> origin/develop"
    echo ""
    echo "Configuration: ${XDG_CONFIG_HOME:-$HOME/.config}/wt-feature/config"
    return 1
  fi

  # Must be run from within a git repository
  local src
  src="$(git rev-parse --show-toplevel 2>/dev/null)"
  if [[ -z "$src" ]]; then
    echo "Error: Not in a git repository"
    return 1
  fi

  # Determine worktrees directory
  local worktrees_dir="${WT_WORKTREES_DIR:-$(dirname "$src")/$(basename "$src")-worktrees}"

  # Determine branch name
  if [[ "$name" == */* ]]; then
    branch_name="$name"
  else
    branch_name="feature/$name"
  fi

  # Auto-select base branch if not provided
  if [[ -z "$base" ]]; then
    if [[ "$branch_name" == hotfix/* ]]; then
      base="origin/main"
    else
      base="origin/develop"
    fi
  fi

  # Use the last segment of the branch name for the directory
  local dest="$worktrees_dir/${branch_name##*/}"

  # Create worktrees directory if needed
  mkdir -p "$worktrees_dir"

  # Fetch if using a remote branch
  if [[ "$base" == origin/* ]]; then
    echo "Fetching ${base#origin/}..."
    git fetch origin "${base#origin/}" || return 1
  fi

  # Create worktree
  echo "Creating worktree at $dest..."
  if git show-ref --verify --quiet "refs/heads/$branch_name"; then
    echo "Using existing branch: $branch_name"
    HUSKY=0 git worktree add "$dest" "$branch_name" || return 1
  else
    echo "Creating new branch: $branch_name from $base"
    git worktree add "$dest" -b "$branch_name" "$base" || return 1
  fi

  # Copy configured files
  if [[ -n "$WT_FILES_TO_COPY" ]]; then
    for file in $WT_FILES_TO_COPY; do
      if [[ -f "$src/$file" ]]; then
        local dir=$(dirname "$dest/$file")
        mkdir -p "$dir"
        cp "$src/$file" "$dest/$file"
        echo "Copied $file"
      fi
    done
  fi

  # Run setup commands
  if [[ -n "$WT_SETUP_COMMANDS" ]]; then
    echo "Running setup..."
    (cd "$dest" && eval "$WT_SETUP_COMMANDS")
  fi

  cd "$dest"
  echo ""
  echo "Ready! Now in: $dest"
}
