#!/usr/bin/env bash
set -e

INSTALL_DIR="${HOME}/.local/bin"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/wt-feature"

echo "wt-feature uninstaller"
echo "======================"
echo ""

# Remove script
if [[ -f "$INSTALL_DIR/wt-feature.sh" ]]; then
  rm "$INSTALL_DIR/wt-feature.sh"
  echo "Removed $INSTALL_DIR/wt-feature.sh"
fi

# Remove config
if [[ -d "$CONFIG_DIR" ]]; then
  rm -rf "$CONFIG_DIR"
  echo "Removed $CONFIG_DIR"
fi

# Remove from shell configs
remove_from_shell_config() {
  local rc_file="$1"
  if [[ -f "$rc_file" ]]; then
    if grep -qF "wt-feature" "$rc_file"; then
      # Create backup
      cp "$rc_file" "$rc_file.bak"
      # Remove the lines
      grep -vF "wt-feature" "$rc_file.bak" > "$rc_file"
      rm "$rc_file.bak"
      echo "Removed from $rc_file"
    fi
  fi
}

remove_from_shell_config "$HOME/.zshrc"
remove_from_shell_config "$HOME/.bashrc"

echo ""
echo "Uninstall complete!"
echo "Restart your shell to complete removal."
