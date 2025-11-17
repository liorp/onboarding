#!/bin/bash

configure_vscode() {
    local settings_dir="$HOME/Library/Application Support/Code/User"
    local settings_file="$settings_dir/settings.json"

    if ! command -v python3 >/dev/null 2>&1; then
        echo "python3 is required to update VS Code settings; please install it and re-run."
        return 1
    fi

    mkdir -p "$settings_dir"

    if [ ! -f "$settings_file" ]; then
        echo "{}" > "$settings_file"
    fi

    SETTINGS_FILE="$settings_file" python3 <<'PY'
import json
import os
from pathlib import Path

settings_path = Path(os.environ["SETTINGS_FILE"])

try:
    data = json.loads(settings_path.read_text())
except json.JSONDecodeError:
    data = {}

changed = False

if data.get("files.autoSave") != "afterDelay":
    data["files.autoSave"] = "afterDelay"
    changed = True

if data.get("files.autoSaveDelay") != 1000:
    data["files.autoSaveDelay"] = 1000
    changed = True

if changed:
    settings_path.write_text(json.dumps(data, indent=4))
    print(f"Updated VS Code settings at {settings_path}.")
else:
    print(f"VS Code autosave already set in {settings_path}.")
PY
}

configure_vscode
