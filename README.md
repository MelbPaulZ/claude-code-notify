# Claude Code Notify

Claude Code 的 macOS 通知 hooks：**权限请求时立刻弹通知并自动切换到对应的 iTerm2 tab（消灭静默等待）；任务完成时弹出可点击跳转的通知（不抢焦点）**。

适合同时开多个 Claude Code 会话：不错过任何一个等待授权的会话，也不会被"干完活"的会话来回打断。

## 行为设计（v2）

| 时刻 | 事件 | 通知 | 焦点行为 |
|---|---|---|---|
| 权限请求（任务被卡住） | `Notification` | 「等你授权」+ 提示音 | **立即自动切换**到对应 window + tab |
| 其他等待（如空闲提醒） | `Notification` | 显示通知原文 | 不抢焦点，**点击通知跳转** |
| 任务完成 | `Stop` | 「任务完成」+ 提示音 | 不抢焦点，**点击通知跳转** |

设计原则：**按紧急度区分**。权限请求会卡住任务进度，你不来它就停摆，所以立即拉人；任务完成后晚点看没有任何损失，所以只通知不打断——尤其是多会话场景，v1 的"完成后 3 秒强制切换"会在几个 tab 之间来回抢焦点，v2 彻底移除了这个行为。

## 文件说明

| 文件 | 挂载事件 | 作用 |
|---|---|---|
| `notify-permission.sh` | `Notification` | 读取通知内容：权限类 → 弹窗并立即切换；其他 → 可点击跳转的通知 |
| `notify-idle.sh` | `Stop` | 任务完成通知，`-execute` 挂载跳转命令，点击才切换 |
| `switch-to-session.sh` | （公共） | 按 `$ITERM_SESSION_ID` 定位会话并聚焦。先 `select w` 再 `select t` 再 `select s`，修复了 v1 多窗口时聚焦错窗口的 bug |

所有触发和错误都会记录到 `~/.claude/scripts/notify-hook.log`，方便排障。

## 依赖

- macOS
- [iTerm2](https://iterm2.com/)
- [terminal-notifier](https://github.com/julienXX/terminal-notifier)（`brew install terminal-notifier`）
- `jq`（macOS 15+ 自带）

## 安装

```bash
git clone https://github.com/MelbPaulZ/claude-code-notify.git
cd claude-code-notify
bash install.sh
```

## 手动安装

1. `brew install terminal-notifier`
2. 复制脚本：

```bash
mkdir -p ~/.claude/scripts
cp notify-idle.sh notify-permission.sh switch-to-session.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/notify-idle.sh ~/.claude/scripts/notify-permission.sh ~/.claude/scripts/switch-to-session.sh
```

3. 在 `~/.claude/settings.json` 中添加两个 hook：

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
```

4. 重启 Claude Code 或打开 `/hooks` 菜单使配置生效。

## 排障

- **通知没弹**：查 `~/.claude/scripts/notify-hook.log`——每次 hook 触发都会记一行。没有记录说明事件没触发（检查 settings.json）；有记录但没通知，检查 系统设置 → 通知 → terminal-notifier 是否允许。
- **切换不生效**：首次运行时 macOS 会请求「自动化」权限（允许终端控制 iTerm2）。如果当时拒绝了，去 系统设置 → 隐私与安全性 → 自动化 里重新打开。osascript 的报错也会写进日志。
- **有横幅没声音**：系统设置 → 通知 → terminal-notifier → 打开「播放通知声音」。
- **tmux 用户**：tmux 内拿不到 `$ITERM_SESSION_ID`，切换功能不生效（通知仍正常）。

## 自定义

- 通知文字、提示音：改各脚本里 `terminal-notifier` 的 `-title` / `-message` / `-sound` 参数（提示音可选：Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse, Ping, Pop, Purr, Sosumi, Submarine, Tink）
- 权限类通知的判定关键词：改 `notify-permission.sh` 里 `case` 分支的匹配模式
- 想恢复"完成后也自动切换"的 v1 行为：把 `notify-idle.sh` 里的 `-execute` 行改成直接调用 `switch-to-session.sh`

## Changelog

### v2 (2026-07-10)

- 新增 `Notification` hook：权限请求不再静默等待，立即通知并自动切换过去
- `Stop`（任务完成）改为**点击跳转**，不再抢焦点——多会话时不会被来回打断；移除 3 秒延迟
- 修复多窗口 bug：v1 只 `select tab` 不聚焦 window，目标在非前台窗口时切换无效
- 切换逻辑抽出为公共的 `switch-to-session.sh`，并额外 `select session` 精确到分屏 pane
- 新增触发/错误日志 `~/.claude/scripts/notify-hook.log`，不再全链路静默失败

### v1 (2026-03-31)

- Stop hook：通知 + 3 秒后自动切换 iTerm2 tab
