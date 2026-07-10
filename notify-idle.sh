#!/bin/bash
# Claude Code Stop hook: task finished -> notification with click-to-jump.
# Deliberately does NOT steal focus (the work is done, no urgency).
exec < /dev/null
LOG="$HOME/.claude/scripts/notify-hook.log"
echo "$(date '+%F %T') stop-hook fired" >> "$LOG"
ARGS=(-title "Claude Code 任务完成" -message "等待你的下一条输入（点击跳转）" \
  -sound Glass -group "claude-code-idle")
if [ -n "$ITERM_SESSION_ID" ]; then
  ARGS+=(-execute "$HOME/.claude/scripts/switch-to-session.sh ${ITERM_SESSION_ID#*:}")
fi
terminal-notifier "${ARGS[@]}" >/dev/null 2>&1 \
  || echo "$(date '+%F %T') notify-idle: terminal-notifier failed" >> "$LOG"
exit 0
