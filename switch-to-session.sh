#!/bin/bash
# Switch iTerm2 focus to the window+tab+pane containing the given session GUID.
# Usage: switch-to-session.sh <GUID>
GUID="$1"
LOG="$HOME/.claude/scripts/notify-hook.log"
if [ -z "$GUID" ]; then
  echo "$(date '+%F %T') switch-to-session: missing GUID" >> "$LOG"
  exit 1
fi
osascript >> "$LOG" 2>&1 <<EOF
tell application "iTerm2"
    activate
    repeat with w in windows
        repeat with t in tabs of w
            repeat with s in sessions of t
                if unique ID of s is "$GUID" then
                    select w
                    select t
                    select s
                    return
                end if
            end repeat
        end repeat
    end repeat
end tell
EOF
