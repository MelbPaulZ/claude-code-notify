# Claude Code Notify-Idle

Claude Code 的 Stop hook：当 Claude 回复完成等待输入时，弹出 macOS 通知并在 3 秒后自动切换到对应的 iTerm2 tab。

## 效果

1. Claude 回复完成 → 弹出通知「Claude Code 等待你的输入 — 3 秒后将切换到对应窗口」（带提示音）
2. 3 秒后通知消失，自动激活 iTerm2 并切到对应 tab

适合同时开多个 Claude Code 会话时，不错过任何等待输入的窗口。

## 依赖

- macOS
- [iTerm2](https://iterm2.com/)
- [terminal-notifier](https://github.com/julienXX/terminal-notifier)（`brew install terminal-notifier`）

## 安装

```bash
git clone https://github.com/MelbPaulZ/claude-code-notify.git
cd claude-code-notify
bash install.sh
```

## 手动安装

1. 安装 terminal-notifier：

```bash
brew install terminal-notifier
```

2. 复制脚本：

```bash
mkdir -p ~/.claude/scripts
cp notify-idle.sh ~/.claude/scripts/notify-idle.sh
chmod +x ~/.claude/scripts/notify-idle.sh
```

3. 在 `~/.claude/settings.json` 中添加 hook：

```json
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
```

4. 重启 Claude Code 或打开 `/hooks` 菜单使配置生效。

## 自定义

- 修改 `sleep 3` 的秒数调整切换延迟
- 修改 `-sound Glass` 更换提示音（可选值：Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink）
- 修改通知标题和内容中的文字
