import json
import locale
import os
import subprocess
import sys
from pathlib import Path


PLUGIN_ROOT = Path(__file__).resolve().parents[2]
CAPTURE_SCRIPT = PLUGIN_ROOT / "src" / "windows_appshots" / "Capture-Window.ps1"
DEFAULT_OUTPUT_DIR = Path.home() / ".codex" / "appshots" / "windows"


def read_message():
    headers = {}
    while True:
        line = sys.stdin.buffer.readline()
        if not line:
            return None
        line = line.decode("utf-8").strip()
        if line == "":
            break
        key, value = line.split(":", 1)
        headers[key.lower()] = value.strip()

    length = int(headers.get("content-length", "0"))
    if length <= 0:
        return None
    payload = sys.stdin.buffer.read(length).decode("utf-8")
    return json.loads(payload)


def write_message(message):
    payload = json.dumps(message, separators=(",", ":"), ensure_ascii=False).encode("utf-8")
    sys.stdout.buffer.write(f"Content-Length: {len(payload)}\r\n\r\n".encode("ascii"))
    sys.stdout.buffer.write(payload)
    sys.stdout.buffer.flush()


def success(request_id, result):
    write_message({"jsonrpc": "2.0", "id": request_id, "result": result})


def error(request_id, code, message):
    write_message({"jsonrpc": "2.0", "id": request_id, "error": {"code": code, "message": message}})


def tool_schema():
    return {
        "name": "take_windows_appshot",
        "description": (
            "Capture the Windows foreground window after an optional delay. "
            "Use the delay to switch focus from Codex to the target app."
        ),
        "inputSchema": {
            "type": "object",
            "properties": {
                "delay_seconds": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 30,
                    "default": 2,
                    "description": "Seconds to wait before capturing the foreground window.",
                },
                "include_ui_text": {
                    "type": "boolean",
                    "default": True,
                    "description": "Also collect text exposed through Windows UI Automation.",
                },
                "output_dir": {
                    "type": "string",
                    "description": "Directory for PNG, JSON, and Markdown snapshot files.",
                },
                "max_text_nodes": {
                    "type": "integer",
                    "minimum": 0,
                    "maximum": 1000,
                    "default": 250,
                    "description": "Maximum UI Automation text nodes to collect.",
                },
            },
        },
    }


def take_windows_appshot(arguments):
    delay = int(arguments.get("delay_seconds", 2))
    include_text = bool(arguments.get("include_ui_text", True))
    output_dir = Path(arguments.get("output_dir") or DEFAULT_OUTPUT_DIR).expanduser()
    max_text_nodes = int(arguments.get("max_text_nodes", 250))

    command = [
        "powershell",
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        str(CAPTURE_SCRIPT),
        "-OutputDir",
        str(output_dir),
        "-DelaySeconds",
        str(delay),
        "-MaxTextNodes",
        str(max_text_nodes),
    ]
    if include_text:
        command.append("-IncludeText")

    completed = subprocess.run(
        command,
        cwd=str(PLUGIN_ROOT),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        timeout=max(45, delay + 30),
    )
    stdout = decode_process_output(completed.stdout)
    stderr = decode_process_output(completed.stderr)
    if completed.returncode != 0:
        raise RuntimeError((stderr or stdout).strip())

    raw = stdout.strip()
    data = json.loads(raw)
    summary = [
        "Captured Windows appshot.",
        f"Window: {data.get('title') or '(untitled)'}",
        f"Process: {data.get('processName')} ({data.get('processId')})",
        f"Image: {data.get('imagePath')}",
        f"Metadata: {data.get('metadataPath')}",
        f"Markdown: {data.get('markdownPath')}",
    ]
    ui_text = data.get("uiText") or []
    if ui_text:
        summary.append(f"UI text nodes: {len(ui_text)}")

    return {
        "content": [
            {
                "type": "text",
                "text": "\n".join(summary),
            }
        ],
        "structuredContent": data,
    }


def decode_process_output(data):
    if not data:
        return ""
    encodings = ["utf-8-sig", "utf-8", locale.getpreferredencoding(False), "gb18030"]
    for encoding in encodings:
        try:
            return data.decode(encoding)
        except UnicodeDecodeError:
            continue
    return data.decode("utf-8", errors="replace")


def handle_request(message):
    request_id = message.get("id")
    method = message.get("method")
    params = message.get("params") or {}

    try:
        if method == "initialize":
            success(
                request_id,
                {
                    "protocolVersion": params.get("protocolVersion", "2024-11-05"),
                    "capabilities": {"tools": {}},
                  "serverInfo": {"name": "windows-appshots", "version": "0.2.0"},
                },
            )
        elif method == "tools/list":
            success(request_id, {"tools": [tool_schema()]})
        elif method == "tools/call":
            name = params.get("name")
            if name != "take_windows_appshot":
                raise ValueError(f"Unknown tool: {name}")
            success(request_id, take_windows_appshot(params.get("arguments") or {}))
        elif method and method.startswith("notifications/"):
            return
        else:
            error(request_id, -32601, f"Method not found: {method}")
    except Exception as exc:
        error(request_id, -32000, str(exc))


def main():
    if os.name != "nt":
        # Keep the MCP server alive so tools/list can still explain the mismatch.
        pass
    while True:
        message = read_message()
        if message is None:
            break
        if "id" in message:
            handle_request(message)


if __name__ == "__main__":
    main()
