#!/bin/bash
# Claude Code Stop hook: notification + 3s delay + switch iTerm2 tab
exec < /dev/null

# Single notification with sound
terminal-notifier -title "Claude Code 等待你的输入" -message "3 秒后将切换到对应窗口" -sound Glass -group "claude-code-idle" >/dev/null 2>&1

sleep 3

# Remove notification and switch tab
terminal-notifier -remove "claude-code-idle" >/dev/null 2>&1

if [ -n "$ITERM_SESSION_ID" ]; then
  GUID="${ITERM_SESSION_ID#*:}"
  osascript <<EOF 2>/dev/null
tell application "iTerm2"
    activate
    repeat with w in windows
        repeat with t in tabs of w
            repeat with s in sessions of t
                if unique ID of s is "$GUID" then
                    select t
                    return
                end if
            end repeat
        end repeat
    end repeat
end tell
EOF
fi

exit 0
