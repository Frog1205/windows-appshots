---
name: windows-appshots
description: Capture a Windows foreground application window snapshot for Codex using the local windows-appshots MCP tool.
---

# Windows Appshots

Use this skill when the user wants to capture the current state of a Windows desktop app, settings
panel, browser window, error dialog, or other foreground window for Codex context.

## Tool

Call the `take_windows_appshot` MCP tool.

Recommended arguments:

```json
{
  "delay_seconds": 3,
  "include_ui_text": true
}
```

Tell the user to switch focus to the target app during the delay. The tool writes:

- a PNG screenshot
- a JSON metadata file
- a Markdown file that embeds the screenshot and lists captured UI Automation text

By default files are saved under:

```text
%USERPROFILE%\.codex\appshots\windows
```

## Notes

- The capture target is the foreground window at the end of the delay.
- UI text depends on what the target app exposes through Windows UI Automation.
- Sensitive windows should only be captured when the user explicitly wants that content shared with Codex.
- The plugin also includes `scripts/start-hotkey.ps1`, which starts a `Ctrl+Alt+PrintScreen`
  listener for direct foreground-window capture outside a Codex tool call.
