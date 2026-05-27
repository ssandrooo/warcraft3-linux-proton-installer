#!/usr/bin/env python3
"""Add non-Steam game shortcuts and configure GE-Proton compatibility."""

import argparse
import binascii
import ctypes
import glob
import os
import shutil
import sys

try:
    import vdf
except ImportError:
    print("Missing 'vdf' package. Install: pip install vdf", file=sys.stderr)
    sys.exit(1)


def find_steam_dir():
    for p in ["~/.local/share/Steam", "~/.steam/steam",
              "~/.var/app/com.valvesoftware.Steam/.local/share/Steam"]:
        d = os.path.expanduser(p)
        if os.path.isdir(os.path.join(d, "steamapps")):
            return d
    return None


def find_shortcuts_vdf(steam_dir):
    pattern = os.path.join(steam_dir, "userdata", "*", "config", "shortcuts.vdf")
    matches = glob.glob(pattern)
    if matches:
        if len(matches) > 1:
            print(f"  Warning: multiple Steam users found, using most recent", file=sys.stderr)
        return max(matches, key=os.path.getmtime)
    config_dirs = glob.glob(os.path.join(steam_dir, "userdata", "*", "config"))
    if config_dirs:
        return os.path.join(sorted(config_dirs)[0], "shortcuts.vdf")
    return None


def shortcut_appid(exe, name):
    crc = binascii.crc32((f'"{exe}"{name}').encode("utf-8")) | 0x80000000
    return ctypes.c_int32(crc).value


def add_shortcuts(vdf_path, games):
    if vdf_path and os.path.exists(vdf_path):
        with open(vdf_path, "rb") as f:
            data = vdf.binary_load(f)
        shutil.copy2(vdf_path, vdf_path + ".bak")
    else:
        data = {"shortcuts": {}}

    shortcuts = data.setdefault("shortcuts", {})
    existing = {v.get("AppName", "") for v in shortcuts.values() if isinstance(v, dict)}
    next_idx = max((int(k) for k in shortcuts if k.isdigit()), default=-1) + 1

    app_ids = []
    for name, exe, start_dir in games:
        if name in existing:
            for v in shortcuts.values():
                if isinstance(v, dict) and v.get("AppName") == name:
                    app_ids.append(v["appid"])
                    break
            print(f"  '{name}' already exists, skip")
            continue

        aid = shortcut_appid(exe, name)
        app_ids.append(aid)

        shortcuts[str(next_idx)] = {
            "appid": aid,
            "AppName": name,
            "Exe": f'"{exe}"',
            "StartDir": f'"{start_dir}"',
            "icon": "",
            "ShortcutPath": "",
            "LaunchOptions": "",
            "IsHidden": 0,
            "AllowDesktopConfig": 1,
            "AllowOverlay": 1,
            "OpenVR": 0,
            "Devkit": 0,
            "DevkitGameID": "",
            "DevkitOverrideAppID": 0,
            "FlatpakAppID": "",
            "LastPlayTime": 0,
            "tags": {},
        }
        print(f"  Added '{name}' (app {aid})")
        next_idx += 1

    os.makedirs(os.path.dirname(vdf_path), exist_ok=True)
    with open(vdf_path, "wb") as f:
        vdf.binary_dump(data, f)

    return app_ids


def set_compat_tool(steam_dir, app_ids, tool_name):
    config_path = os.path.join(steam_dir, "config", "config.vdf")
    if not os.path.exists(config_path):
        print(f"  config.vdf not found — set {tool_name} manually")
        return

    with open(config_path) as f:
        data = vdf.load(f)

    node = data
    for key in ["InstallConfigStore", "Software", "Valve", "Steam"]:
        node = node.setdefault(key, {})
    mapping = node.setdefault("CompatToolMapping", {})

    modified = False
    for aid in app_ids:
        key = str(aid)
        if key not in mapping:
            mapping[key] = {"name": tool_name, "config": "", "priority": "250"}
            print(f"  Set {tool_name} for app {key}")
            modified = True

    if modified:
        shutil.copy2(config_path, config_path + ".bak")
        with open(config_path, "w") as f:
            vdf.dump(data, f, pretty=True)


def main():
    p = argparse.ArgumentParser(description="Add Warcraft III shortcuts to Steam")
    p.add_argument("gamedir", help="Directory containing game files")
    p.add_argument("--proton", required=True, help="GE-Proton name")
    p.add_argument("--steam-dir", help="Steam directory (auto-detected if omitted)")
    args = p.parse_args()

    steam_dir = args.steam_dir or find_steam_dir()
    if not steam_dir:
        print("ERROR: Steam not found", file=sys.stderr)
        return 1

    vdf_path = find_shortcuts_vdf(steam_dir)
    if not vdf_path:
        print("ERROR: No Steam userdata found", file=sys.stderr)
        return 1

    games = [
        ("Warcraft III: RoC", os.path.join(args.gamedir, "Warcraft III.exe"), args.gamedir),
        ("Warcraft III: TFT", os.path.join(args.gamedir, "Frozen Throne.exe"), args.gamedir),
    ]

    print("Adding shortcuts...")
    app_ids = add_shortcuts(vdf_path, games)

    print("Configuring compatibility tool...")
    set_compat_tool(steam_dir, app_ids, args.proton)

    print(f"ROC_APPID:{app_ids[0]}")
    print(f"TFT_APPID:{app_ids[1]}")

    print("OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
