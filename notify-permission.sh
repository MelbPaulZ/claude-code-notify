#!/bin/bash
# Claude Code Notification hook.
# Permission requests block the task -> notify + switch over IMMEDIATELY.
# Other notifications (idle waiting etc.) -> click-to-jump only, no focus steal.
LOG="$HOME/.claude/scripts/notify-hook.log"
input=$(cat)
msg=$(echo "$input" | jq -r '.message // ""' 2>/dev/null)
echo "$(date '+%F %T') notification-hook fired: msg=[$msg]" >> "$LOG"
GUID="${ITERM_SESSION_ID#*:}"
SWITCH="$HOME/.claude/scripts/switch-to-session.sh"

case "$msg" in
  *permission* | *Permission* | *授权* | *approval* )
    terminal-notifier -title "Claude Code 等你授权" \
      -message "任务被权限请求卡住，正在切换过去…" \
      -sound Glass -group "claude-code-perm" >/dev/null 2>&1 \
      || echo "$(date '+%F %T') notify-permission: terminal-notifier failed" >> "$LOG"
    if [ -n "$ITERM_SESSION_ID" ]; then
      "$SWITCH" "$GUID"
    fi
    ;;
  * )
    ARGS=(-title "Claude Code 在等你" -message "${msg:-需要你的输入}（点击跳转）" \
      -sound Glass -group "claude-code-notif")
    [ -n "$ITERM_SESSION_ID" ] && ARGS+=(-execute "$SWITCH $GUID")
    terminal-notifier "${ARGS[@]}" >/dev/null 2>&1 \
      || echo "$(date '+%F %T') notify-permission: terminal-notifier failed" >> "$LOG"
    ;;
esac
exit 0
