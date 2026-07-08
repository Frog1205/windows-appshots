# 安装指南

## 环境要求

- Windows 10 或 Windows 11
- Python 3.10+
- Git
- PowerShell 5+
- 可选：Codex CLI、Claude Code、opencode 等 Agent CLI

## 复制 Prompt 让 Agent 安装

### Codex

```text
请帮我在 Windows 上安装 Windows Appshots 插件。

目标：
1. 检查本机是否有 git、python、codex 命令。
2. 如果缺少依赖，请告诉我需要先安装什么。
3. 把 https://github.com/Frog1205/windows-appshots 克隆到 %USERPROFILE%\plugins\windows-appshots。
4. 如果目录已存在并且是这个仓库，请执行 git pull 更新。
5. 运行 scripts\install-codex-personal.ps1，把插件加入 Codex personal marketplace。
6. 运行 codex plugin add windows-appshots@personal。
7. 运行 codex plugin list，确认 windows-appshots@personal 是 installed, enabled。
8. 告诉我需要重启 Codex 客户端或新开线程后再使用。
```

### WorkBuddy / 通用 MCP Agent

```text
请帮我在 Windows 上安装 Windows Appshots MCP 工具，供当前 Agent 使用。

目标：
1. 检查本机是否有 git 和 python。
2. 把 https://github.com/Frog1205/windows-appshots 克隆到 %USERPROFILE%\plugins\windows-appshots。
3. 如果目录已存在并且是这个仓库，请执行 git pull 更新。
4. 找到 MCP 配置入口，添加一个 stdio MCP server：
   - name: windows-appshots
   - command: python
   - args: %USERPROFILE%\plugins\windows-appshots\src\windows_appshots\mcp_server.py
5. 保存配置后，告诉我如何重启当前 Agent 会话。
6. 重启后确认工具列表里有 take_windows_appshot。

如果你不能直接修改当前 Agent 的 MCP 配置，请把应该复制进去的 JSON 配置完整输出给我。
```

### Trae

```text
请帮我把 Windows Appshots 安装到 Trae IDE。

目标：
1. 检查本机是否有 git 和 python。
2. 把 https://github.com/Frog1205/windows-appshots 克隆到 %USERPROFILE%\plugins\windows-appshots。
3. 如果目录已存在并且是这个仓库，请执行 git pull 更新。
4. 打开或指导我打开 Trae 的 Settings > MCP。
5. 新增一个 stdio MCP server：
   - name: windows-appshots
   - command: python
   - args: %USERPROFILE%\plugins\windows-appshots\src\windows_appshots\mcp_server.py
6. 保存后告诉我如何重启 Trae 或刷新 MCP 工具。
7. 重启后确认工具里有 take_windows_appshot。
```

### Cursor

```text
请帮我把 Windows Appshots 安装到 Cursor。

目标：
1. 检查本机是否有 git 和 python。
2. 把 https://github.com/Frog1205/windows-appshots 克隆到 %USERPROFILE%\plugins\windows-appshots。
3. 如果目录已存在并且是这个仓库，请执行 git pull 更新。
4. 打开 Cursor 的 MCP 设置，或编辑全局/项目 mcp.json。
5. 添加 MCP server：
   - name: windows-appshots
   - command: python
   - args: %USERPROFILE%\plugins\windows-appshots\src\windows_appshots\mcp_server.py
6. 保存后刷新 Cursor MCP 工具，确认出现 take_windows_appshot。
```

### Claude Code

```text
请帮我把 Windows Appshots 安装到 Claude Code。

目标：
1. 检查本机是否有 git、python、claude 命令。
2. 把 https://github.com/Frog1205/windows-appshots 克隆到 %USERPROFILE%\plugins\windows-appshots。
3. 如果目录已存在并且是这个仓库，请执行 git pull 更新。
4. 用 Claude Code CLI 添加 user scope 的本地 stdio MCP server：
   claude mcp add --scope user windows-appshots -- python "%USERPROFILE%\plugins\windows-appshots\src\windows_appshots\mcp_server.py"
5. 运行 claude mcp list，确认 windows-appshots 已连接。
6. 告诉我启动 claude 后可以用 /mcp 查看和批准 MCP 工具。
```

### opencode

```text
请帮我把 Windows Appshots 安装到 opencode。

目标：
1. 检查本机是否有 git、python、opencode 命令。
2. 把 https://github.com/Frog1205/windows-appshots 克隆到 %USERPROFILE%\plugins\windows-appshots。
3. 如果目录已存在并且是这个仓库，请执行 git pull 更新。
4. 找到或创建 opencode.json / opencode.jsonc 配置文件。
5. 在 mcp 下添加 windows-appshots：
   - type: local
   - command: ["python", "%USERPROFILE%\\plugins\\windows-appshots\\src\\windows_appshots\\mcp_server.py"]
   - enabled: true
   - timeout: 30000
6. 运行 opencode mcp list 或启动 opencode 后确认 windows-appshots 可用。
```

## 手动安装

### 克隆仓库

```powershell
mkdir "$env:USERPROFILE\plugins" -Force
git clone https://github.com/Frog1205/windows-appshots.git "$env:USERPROFILE\plugins\windows-appshots"
```

### 通用 MCP JSON

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

如果工具是表单式配置，通常这样填：

```text
Name: windows-appshots
Type: stdio
Command: python
Args: C:\Users\<你的用户名>\plugins\windows-appshots\src\windows_appshots\mcp_server.py
```

## 指定工具

### Codex

```powershell
powershell -NoProfile -ExecutionPolicy Bypass `
  -File "$env:USERPROFILE\plugins\windows-appshots\scripts\install-codex-personal.ps1"

codex plugin add windows-appshots@personal
codex plugin list
```

### Trae

打开 `Settings > MCP`，新增 stdio server：

```text
Name: windows-appshots
Command: python
Args: C:\Users\<你的用户名>\plugins\windows-appshots\src\windows_appshots\mcp_server.py
```

### Cursor

打开 `Command Palette > View: Open MCP Settings`，添加：

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

### Claude Code

```powershell
claude mcp add --scope user windows-appshots -- python "$env:USERPROFILE\plugins\windows-appshots\src\windows_appshots\mcp_server.py"
claude mcp list
```

也可以在项目根目录写 `.mcp.json`：

```json
{
  "mcpServers": {
    "windows-appshots": {
      "type": "stdio",
      "command": "python",
      "args": [
        "C:\\Users\\<你的用户名>\\plugins\\windows-appshots\\src\\windows_appshots\\mcp_server.py"
      ]
    }
  }
}
```

### opencode

在 `opencode.json` 或 `opencode.jsonc` 中添加：

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "mcp": {
    "windows-appshots": {
      "type": "local",
      "command": [
        "python",
        "C:\\Users\\<你的用户名>\\plugins\\windows-appshots\\src\\windows_appshots\\mcp_server.py"
      ],
      "enabled": true,
      "timeout": 30000
    }
  }
}
```

## 参考文档

- Trae: https://docs.trae.ai/ide/add-mcp-servers
- Cursor: https://cursor.com/docs/mcp
- Claude Code: https://code.claude.com/docs/en/mcp-quickstart
- opencode: https://opencode.ai/docs/mcp-servers/
