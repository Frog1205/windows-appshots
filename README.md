# Windows Appshots

Windows Appshots 是一个面向 Codex 的 Windows 本地应用快照插件。它可以捕获当前 Windows 前台应用窗口，保存截图、窗口元数据和可选的 UI Automation 文本，让 Codex 在 Windows 上获得类似 macOS Appshots 的上下文能力。

当前项目是可用原型，重点解决三件事：

- 在 Codex 中通过 MCP 工具触发前台窗口快照
- 在 Windows 上用热键直接捕获当前窗口
- 生成本地 PNG、JSON、Markdown 三种快照产物，方便继续分析或归档

## 功能

- 捕获当前前台窗口为 PNG
- 保存窗口标题、进程、窗口句柄、边界、输出路径等 JSON 元数据
- 可选抓取目标应用暴露的 Windows UI Automation 文本
- 生成 Markdown 文件，自动嵌入截图并列出 UI 文本
- 提供 Codex MCP 工具：`take_windows_appshot`
- 提供全局热键监听脚本：`Ctrl+Alt+PrintScreen`

默认输出目录：

```text
%USERPROFILE%\.codex\appshots\windows
```

## 环境要求

- Windows 10 或 Windows 11
- Python 3.10+
- PowerShell 5+
- Codex 客户端或 Codex CLI
- 可选：GitHub CLI，仅用于开发者发布仓库

项目不需要额外 Python 依赖；截图和 UI Automation 由 Windows/.NET/PowerShell 提供。

## 快速安装到 Codex

推荐把仓库 clone 到用户目录的 `plugins` 文件夹：

```powershell
mkdir "$env:USERPROFILE\plugins" -Force
git clone https://github.com/Frog1205/windows-appshots.git "$env:USERPROFILE\plugins\windows-appshots"
```

运行安装脚本，将插件加入 Codex 个人 marketplace：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\plugins\windows-appshots\scripts\Install-PersonalMarketplace.ps1"
```

然后安装插件：

```powershell
codex plugin add windows-appshots@personal
```

确认状态：

```powershell
codex plugin list
```

你应该能看到：

```text
windows-appshots@personal  installed, enabled
```

安装后请重启 Codex 客户端，或至少新开一个线程，让新的 plugin、skill 和 MCP 工具被加载。

## 在 Codex 中使用

在新线程里直接说：

```text
使用 windows-appshots 抓取 3 秒后的前台窗口快照
```

然后在倒计时内切换到你想捕获的应用窗口。插件会保存截图和元数据，并把路径返回给 Codex。

MCP 工具名：

```text
take_windows_appshot
```

常用参数：

```json
{
  "delay_seconds": 3,
  "include_ui_text": true,
  "max_text_nodes": 250
}
```

参数说明：

| 参数 | 默认值 | 说明 |
| --- | --- | --- |
| `delay_seconds` | `2` | 捕获前等待秒数，用来从 Codex 切换到目标窗口 |
| `include_ui_text` | `true` | 是否抓取 Windows UI Automation 文本 |
| `max_text_nodes` | `250` | 最多抓取多少个 UI 文本节点 |
| `output_dir` | `%USERPROFILE%\.codex\appshots\windows` | 自定义输出目录 |

## Codex 客户端手动添加 MCP

如果你想在 Codex 客户端的「集成 > MCP 服务器」里手动添加，可以这样填：

```text
Name: windows-appshots
Command: python
Args: C:\Users\<你的用户名>\plugins\windows-appshots\scripts\windows_appshots_mcp.py
```

如果你的仓库不在 `%USERPROFILE%\plugins\windows-appshots`，把 `Args` 改成实际路径。

## 使用全局热键

启动热键监听：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\plugins\windows-appshots\scripts\Start-Hotkey.ps1"
```

默认热键：

```text
Ctrl+Alt+PrintScreen
```

按下热键后，它会立即捕获当前前台窗口，并把 PNG、JSON、Markdown 写入默认输出目录。

停止方式：

```powershell
Get-Process python | Where-Object { $_.Path -like "*python*" } | Stop-Process
```

如果你同时运行多个 Python 程序，请用任务管理器按命令行确认后再结束对应进程。

## 手动测试截图脚本

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\plugins\windows-appshots\scripts\Capture-Window.ps1" `
  -DelaySeconds 2 `
  -IncludeText `
  -MaxTextNodes 25
```

成功后会输出类似：

```json
{
  "title": "Example - Microsoft Edge",
  "processName": "msedge",
  "imagePath": "C:\\Users\\you\\.codex\\appshots\\windows\\20260708-xxxxxx-msedge.png",
  "metadataPath": "C:\\Users\\you\\.codex\\appshots\\windows\\20260708-xxxxxx-msedge.json",
  "markdownPath": "C:\\Users\\you\\.codex\\appshots\\windows\\20260708-xxxxxx-msedge.md"
}
```

## 文件结构

```text
windows-appshots/
  .codex-plugin/plugin.json
  .mcp.json
  scripts/
    Capture-Window.ps1
    Install-PersonalMarketplace.ps1
    Start-Hotkey.ps1
    hotkey_listener.py
    windows_appshots_mcp.py
  skills/
    windows-appshots/SKILL.md
```

## 开发验证

校验 Python：

```powershell
python -m py_compile `
  .\scripts\windows_appshots_mcp.py `
  .\scripts\hotkey_listener.py
```

校验 Codex 插件 manifest：

```powershell
python "$env:USERPROFILE\.codex\skills\.system\plugin-creator\scripts\validate_plugin.py" .
```

测试 MCP 握手可以用任意 MCP Inspector，或直接在 Codex 新线程中请求使用 `windows-appshots`。

## 隐私与安全

Windows Appshots 会保存你当前前台窗口的截图和可能的 UI 文本。请避免捕获密码、密钥、私人聊天、财务信息、客户数据等敏感内容，除非你明确需要把这些内容提供给 Codex。

默认情况下，快照保存在本机：

```text
%USERPROFILE%\.codex\appshots\windows
```

项目不会主动上传快照。是否把快照内容发给 Codex，取决于你在 Codex 中如何使用工具和返回路径。

## 当前限制

- 热键监听只保存本地文件，还不会自动把快照注入到已有 Codex 线程
- UI 文本质量取决于目标应用是否暴露 Windows UI Automation 信息
- 全局热键目前固定为 `Ctrl+Alt+PrintScreen`
- 捕获的是触发时或延迟结束时的前台窗口，不支持选择后台窗口

## 路线图

- 增加托盘图标和设置界面
- 支持自定义热键
- 捕获完成后显示 Windows 通知
- 更好地把快照 Markdown 或 PNG 交给 Codex 当前线程
- 增加安装器和卸载脚本

## License

MIT
