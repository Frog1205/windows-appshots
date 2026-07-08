# Windows Appshots

Windows Appshots 是一个面向 Windows Agent 工具的本地应用快照 MCP 插件。它可以捕获当前前台窗口，保存 PNG 截图、JSON 元数据和可选的 Windows UI Automation 文本，让 Codex、WorkBuddy、Cursor、Trae、Claude Code、opencode 等 Agent 获得当前桌面应用上下文。

## 能做什么

- 捕获当前 Windows 前台窗口为 PNG
- 保存窗口标题、进程、窗口位置、输出路径等 JSON 元数据
- 可选抓取目标应用暴露的 UI Automation 文本
- 生成 Markdown 快照文件，方便给 Agent 继续分析
- 提供 MCP 工具：`take_windows_appshot`
- 提供热键模式：`Ctrl+Alt+PrintScreen`

默认输出目录：

```text
%USERPROFILE%\.codex\appshots\windows
```

## 快速开始

不熟悉命令行的用户，可以直接把这段 Prompt 发给 Codex、WorkBuddy 或其他能操作本机命令行的 Agent：

```text
请帮我在 Windows 上安装 Windows Appshots。

目标：
1. 检查本机是否有 git 和 python。
2. 把 https://github.com/Frog1205/windows-appshots 克隆到 %USERPROFILE%\plugins\windows-appshots。
3. 如果目录已存在并且是这个仓库，请执行 git pull 更新。
4. 如果当前工具是 Codex，请运行 scripts\install-codex-personal.ps1，然后执行 codex plugin add windows-appshots@personal。
5. 如果当前工具支持 MCP，请添加 stdio MCP server：
   - name: windows-appshots
   - command: python
   - args: %USERPROFILE%\plugins\windows-appshots\src\windows_appshots\mcp_server.py
6. 安装后告诉我如何重启当前 Agent，并确认工具列表里有 take_windows_appshot。

如果你不能直接修改 Agent 配置，请输出我应该复制进去的 MCP JSON。
```

安装后，对 Agent 说：

```text
调用 windows-appshots，3 秒后抓取当前前台窗口，并读取 UI 文本
```

然后在 3 秒内切到目标应用窗口。

## 手动安装

```powershell
mkdir "$env:USERPROFILE\plugins" -Force
git clone https://github.com/Frog1205/windows-appshots.git "$env:USERPROFILE\plugins\windows-appshots"
```

通用 MCP 配置：

```json
{
  "mcpServers": {
    "windows-appshots": {
      "command": "python",
      "args": [
        "C:\\Users\\<你的用户名>\\plugins\\windows-appshots\\src\\windows_appshots\\mcp_server.py"
      ]
    }
  }
}
```

Codex 插件安装：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\plugins\windows-appshots\scripts\install-codex-personal.ps1"

codex plugin add windows-appshots@personal
```

更多工具说明见 [docs/INSTALL.md](docs/INSTALL.md)。

## 目录结构

```text
windows-appshots/
  .codex-plugin/          Codex 插件 manifest
  .mcp.json               Codex 插件内置 MCP server 配置
  src/windows_appshots/   核心运行时代码
    mcp_server.py         MCP stdio server，暴露 take_windows_appshot
    Capture-Window.ps1    Windows 前台窗口截图和 UI Automation 文本捕获
    hotkey_listener.py    Ctrl+Alt+PrintScreen 热键监听
  scripts/                用户可直接运行的脚本
    install-codex-personal.ps1
    start-hotkey.ps1
  examples/mcp/           不同 Agent 的 MCP 配置示例
    generic-mcp-server.json
    opencode.jsonc
  docs/                   详细文档
  skills/                 Codex skill 元数据
```

## 文档

- [安装指南](docs/INSTALL.md)
- [使用说明](docs/USAGE.md)
- [开发与验证](docs/DEVELOPMENT.md)
- [通用 MCP 示例](examples/mcp/generic-mcp-server.json)
- [opencode 示例](examples/mcp/opencode.jsonc)

## 隐私与安全

Windows Appshots 会保存你当前前台窗口的截图和可能的 UI 文本。请避免捕获密码、密钥、私人聊天、财务信息、客户数据等敏感内容，除非你明确需要把这些内容提供给 Agent。

项目不会主动上传快照。是否把快照内容发送给 Agent，取决于你如何调用 MCP 工具和处理返回路径。

## License

MIT
