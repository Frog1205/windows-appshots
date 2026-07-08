# 开发与验证

## 目录职责

```text
src/windows_appshots/   核心运行时代码
scripts/                安装和启动脚本
examples/mcp/           Agent 配置示例
docs/                   详细文档
skills/                 Codex skill 元数据
.codex-plugin/          Codex plugin manifest
```

## 校验 Python

```powershell
python -m py_compile `
  .\src\windows_appshots\mcp_server.py `
  .\src\windows_appshots\hotkey_listener.py
```

## 校验 Codex 插件

```powershell
python "$env:USERPROFILE\.codex\skills\.system\plugin-creator\scripts\validate_plugin.py" .
```

## 校验示例 JSON

```powershell
Get-Content -Raw -Encoding UTF8 .\examples\mcp\generic-mcp-server.json | ConvertFrom-Json | Out-Null
Get-Content -Raw -Encoding UTF8 .\examples\mcp\opencode.jsonc | ConvertFrom-Json | Out-Null
```

## MCP 冒烟测试

在 Agent 中添加 MCP server 后，确认工具列表里出现：

```text
take_windows_appshot
```

也可以直接运行 server 看是否能启动并等待 stdio 输入：

```powershell
python .\src\windows_appshots\mcp_server.py
```

直接运行时没有输出是正常的，按 `Ctrl+C` 退出。
