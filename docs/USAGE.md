# 使用说明

## MCP 工具

工具名：

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
| `delay_seconds` | `2` | 捕获前等待秒数，用来从 Agent 切换到目标窗口 |
| `include_ui_text` | `true` | 是否抓取 Windows UI Automation 文本 |
| `max_text_nodes` | `250` | 最多抓取多少个 UI 文本节点 |
| `output_dir` | `%USERPROFILE%\.codex\appshots\windows` | 自定义输出目录 |

## 示例 Prompt

```text
调用 windows-appshots，3 秒后抓取当前前台窗口，并读取 UI 文本
```

```text
使用 take_windows_appshot，delay_seconds=5，include_ui_text=true。倒计时结束后我会切到目标窗口。
```

## 输出文件

默认输出目录：

```text
%USERPROFILE%\.codex\appshots\windows
```

每次捕获会生成：

- `.png`：窗口截图
- `.json`：窗口元数据和 UI 文本
- `.md`：嵌入截图的 Markdown 快照

## 热键模式

启动热键监听：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\plugins\windows-appshots\scripts\start-hotkey.ps1"
```

默认热键：

```text
Ctrl+Alt+PrintScreen
```

按下热键后，它会立即捕获当前前台窗口，并写入默认输出目录。

停止方式：

```powershell
Get-Process python | Where-Object { $_.Path -like "*python*" } | Stop-Process
```

如果你同时运行多个 Python 程序，请用任务管理器按命令行确认后再结束对应进程。

## 手动测试截图脚本

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\plugins\windows-appshots\src\windows_appshots\Capture-Window.ps1" `
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
