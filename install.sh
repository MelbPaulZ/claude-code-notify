#!/bin/bash
# Install Claude Code notify-idle hook
set -e

echo "=== Claude Code Notify-Idle Installer ==="

# 1. Install terminal-notifier
if ! command -v terminal-notifier &>/dev/null; then
  echo "Installing terminal-notifier..."
  brew install terminal-notifier
else
  echo "terminal-notifier already installed."
fi

# 2. Copy script
mkdir -p ~/.claude/scripts
cp "$(dirname "$0")/notify-idle.sh" ~/.claude/scripts/notify-idle.sh
chmod +x ~/.claude/scripts/notify-idle.sh
echo "Script installed to ~/.claude/scripts/notify-idle.sh"

# 3. Add hook to settings.json
SETTINGS=~/.claude/settings.json
HOOK_CMD="~/.claude/scripts/notify-idle.sh"

if [ ! -f "$SETTINGS" ]; then
  # Create new settings file with hook
  cat > "$SETTINGS" <<'ENDJSON'
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/notify-idle.sh",
            "timeout": 10,
            "async": true
          }
        ]
      }
    ]
  }
}
ENDJSON
  echo "Created $SETTINGS with Stop hook."
elif ! grep -q "notify-idle.sh" "$SETTINGS"; then
  echo ""
  echo "NOTE: Please manually add the following hook to $SETTINGS:"
  echo ""
  cat <<'ENDJSON'
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/notify-idle.sh",
            "timeout": 10,
            "async": true
          }
        ]
      }
    ]
  }
ENDJSON
  echo ""
  echo "Or merge it into your existing hooks configuration."
else
  echo "Hook already configured in $SETTINGS."
fi

echo ""
echo "Done! Restart Claude Code or open /hooks to activate."
