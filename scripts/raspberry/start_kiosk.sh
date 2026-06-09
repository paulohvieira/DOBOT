#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="${DOBOT_CPQD_PROJECT_DIR:-$HOME/DOBOT}"
PYTHON_BIN="$PROJECT_DIR/venv/bin/python"

export DOBOT_CPQD_KIOSK=1
export QT_IM_MODULE=qtvirtualkeyboard
export QT_QUICK_CONTROLS_STYLE=Material

cd "$PROJECT_DIR"
exec "$PYTHON_BIN" "$PROJECT_DIR/src/main.py" --kiosk
