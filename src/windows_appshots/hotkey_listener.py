import ctypes
import subprocess
import sys
from pathlib import Path


PLUGIN_ROOT = Path(__file__).resolve().parents[2]
CAPTURE_SCRIPT = PLUGIN_ROOT / "src" / "windows_appshots" / "Capture-Window.ps1"
OUTPUT_DIR = Path.home() / ".codex" / "appshots" / "windows"

MOD_ALT = 0x0001
MOD_CONTROL = 0x0002
VK_SNAPSHOT = 0x2C
WM_HOTKEY = 0x0312
HOTKEY_ID = 1


class MSG(ctypes.Structure):
    _fields_ = [
        ("hwnd", ctypes.c_void_p),
        ("message", ctypes.c_uint),
        ("wParam", ctypes.c_void_p),
        ("lParam", ctypes.c_void_p),
        ("time", ctypes.c_uint),
        ("pt_x", ctypes.c_long),
        ("pt_y", ctypes.c_long),
    ]


def capture_now():
    command = [
        "powershell",
        "-NoProfile",
        "-ExecutionPolicy",
        "Bypass",
        "-File",
        str(CAPTURE_SCRIPT),
        "-OutputDir",
        str(OUTPUT_DIR),
        "-DelaySeconds",
        "0",
        "-IncludeText",
    ]
    subprocess.Popen(
        command,
        cwd=str(PLUGIN_ROOT),
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        creationflags=subprocess.CREATE_NO_WINDOW,
    )


def main():
    user32 = ctypes.windll.user32
    if not user32.RegisterHotKey(None, HOTKEY_ID, MOD_CONTROL | MOD_ALT, VK_SNAPSHOT):
        raise RuntimeError("Could not register Ctrl+Alt+PrintScreen. Another app may already use it.")

    print("Windows Appshots hotkey active: Ctrl+Alt+PrintScreen")
    print(f"Snapshots will be saved to: {OUTPUT_DIR}")
    print("Press Ctrl+C here to stop the listener.")

    msg = MSG()
    try:
        while user32.GetMessageW(ctypes.byref(msg), None, 0, 0) != 0:
            if msg.message == WM_HOTKEY and msg.wParam == HOTKEY_ID:
                capture_now()
            user32.TranslateMessage(ctypes.byref(msg))
            user32.DispatchMessageW(ctypes.byref(msg))
    finally:
        user32.UnregisterHotKey(None, HOTKEY_ID)


if __name__ == "__main__":
    if sys.platform != "win32":
        raise SystemExit("windows-appshots hotkey listener only runs on Windows.")
    main()
