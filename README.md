# wt-feature

A CLI tool for creating git worktrees with automatic setup.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/crobbo/wt-feature/master/install.sh | bash
```

## Folder Structure

```
~/projects/
├── your-repo/               # Main repository (auto-detected)
│
└── your-repo-worktrees/     # Worktrees live beside the main repo
    ├── feature-login/
    ├── bugfix-issue-123/
    └── hotfix-urgent/
```

## Usage

### Create a worktree

```bash
wt-feature <name> [base-branch]
```

- **name** - Branch name or feature name
- **base-branch** - Base branch (optional, auto-detected based on branch type)

### Remove a worktree

```bash
wt-remove <name>
```

Removes the worktree and cleans up. If you're inside the worktree, it moves you to the main repo first.

### Update

```bash
wt-update
```

Downloads the latest version of wt-feature. Your configuration is preserved.

### Default Base Branches

| Branch Type | Default Base    |
|-------------|-----------------|
| `hotfix/*`  | `origin/main`   |
| `feature/*` | `origin/develop`|
| `bugfix/*`  | `origin/develop`|

## Examples

```bash
# New feature branch from origin/develop
wt-feature my-feature

# New bugfix from origin/develop
wt-feature bugfix/login-issue

# New hotfix from origin/main
wt-feature hotfix/urgent

# Branch off a specific local branch
wt-feature my-feature some-local-branch

# Use existing branch
wt-feature feature/existing-branch

# Remove a worktree
wt-remove feature-my-feature
wt-remove feature/my-feature  # also works
```

## What It Does

1. Fetches latest from remote (if base is `origin/*`)
2. Creates worktree beside your main repo (e.g., `~/projects/myapp-worktrees/feature-name`)
3. Creates new branch or checks out existing branch
4. Copies configured files to the new worktree
5. Runs setup commands (e.g., `bundle install`, `yarn install`)
6. Changes into the new worktree directory

## Configuration

The installer prompts for configuration, which is saved to `~/.config/wt-feature/config`.

You can edit this file directly:

```bash
# Where to create worktrees
# (default: if repo is ~/projects/myapp, worktrees go in ~/projects/myapp-worktrees)
WT_WORKTREES_DIR=""

# Files to copy from main repo (space-separated)
WT_FILES_TO_COPY="config/master.key .env"

# Commands to run after creating worktree
WT_SETUP_COMMANDS="bundle install && yarn install"
```

## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/crobbo/wt-feature/master/uninstall.sh | bash
```

Or manually:

```bash
rm ~/.local/bin/wt-feature.sh
rm -rf ~/.config/wt-feature
# Remove the source line from ~/.zshrc or ~/.bashrc
```

## License

MIT
