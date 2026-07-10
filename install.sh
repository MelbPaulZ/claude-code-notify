#!/bin/bash
# Install Claude Code notify hooks (v2: Stop + Notification)
set -e

echo "=== Claude Code Notify Installer (v2) ==="

# 1. Install terminal-notifier
if ! command -v terminal-notifier &>/dev/null; then
  echo "Installing terminal-notifier..."
  brew install terminal-notifier
else
  echo "terminal-notifier already installed."
fi

# 2. Copy scripts
mkdir -p ~/.claude/scripts
for f in notify-idle.sh notify-permission.sh switch-to-session.sh; do
  cp "$(dirname "$0")/$f" ~/.claude/scripts/"$f"
  chmod +x ~/.claude/scripts/"$f"
done
echo "Scripts installed to ~/.claude/scripts/"

# 3. Add hooks to settings.json
SETTINGS=~/.claude/settings.json

if [ ! -f "$SETTINGS" ]; then
  # Create new settings file with both hooks
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
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/notify-permission.sh",
            "timeout": 10,
            "async": true
          }
        ]
      }
    ]
  }
}
ENDJSON
  echo "Created $SETTINGS with Stop + Notification hooks."
elif ! grep -q "notify-idle.sh" "$SETTINGS" || ! grep -q "notify-permission.sh" "$SETTINGS"; then
  echo ""
  echo "NOTE: Please merge the following hooks into $SETTINGS"
  echo "(v1 users: also change the Notification hook command to notify-permission.sh):"
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
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/scripts/notify-permission.sh",
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
  echo "Hooks already configured in $SETTINGS."
fi

echo ""
echo "Done! Restart Claude Code or open /hooks to activate."
