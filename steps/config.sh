#!/usr/bin/env bash
# Shared configuration — sourced by each step script and the master installer.

set -euo pipefail

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." 2>/dev/null && pwd)"
BASEDIR="${W3_BASEDIR:-$(dirname "$SCRIPTDIR")}"
STAGING="$BASEDIR/staging"
GAMEDIR="$BASEDIR/game"
STATEFILE="$BASEDIR/.w3-state"
TOOLSDIR="$SCRIPTDIR/tools"
TEMPLATEDIR="$SCRIPTDIR/templates"

# ── Steam ──

STEAM_DIR=""
for _d in "$HOME/.local/share/Steam" "$HOME/.steam/steam"; do
    [ -d "$_d/steamapps" ] && { STEAM_DIR="$_d"; break; }
done
if [ -z "$STEAM_DIR" ]; then
    echo "ERROR: Steam not found (checked ~/.local/share/Steam, ~/.steam/steam)"
    exit 1
fi
COMPATDATA="$STEAM_DIR/steamapps/compatdata"

# ── GE-Proton ──

GE_PROTON_DIR=$(find "$HOME/.steam/root/compatibilitytools.d" \
    -maxdepth 1 -name "GE-Proton*" -type d 2>/dev/null | sort -V | tail -1)
if [ -z "$GE_PROTON_DIR" ]; then
    echo "ERROR: GE-Proton not found. Install via protonup-qt."
    exit 1
fi
PROTON="$GE_PROTON_DIR/proton"
GE_PROTON_NAME=$(basename "$GE_PROTON_DIR")

# ── Resolution (env override > xrandr > 1920x1080) ──

if [ -n "${RES_W:-}" ] && [ -n "${RES_H:-}" ]; then
    :
else
    RES_W=1920; RES_H=1080
    if command -v xrandr &>/dev/null; then
        _RES=$(xrandr --current 2>/dev/null \
            | grep -oP '\d+x\d+(?=\+0\+0)' | head -1 || true)
        if [ -n "$_RES" ]; then
            RES_W="${_RES%x*}"; RES_H="${_RES#*x}"
        fi
    fi
fi

# ── State persistence ──

save_state() {
    local key="$1" val="$2"
    touch "$STATEFILE"
    local tmp="${STATEFILE}.tmp"
    grep -v "^${key}=" "$STATEFILE" > "$tmp" 2>/dev/null || true
    printf '%s=%s\n' "$key" "$val" >> "$tmp"
    mv "$tmp" "$STATEFILE"
}

load_state() {
    local key="$1" default="${2:-}"
    if [ -f "$STATEFILE" ]; then
        local val
        val=$(grep "^${key}=" "$STATEFILE" 2>/dev/null | tail -1 | cut -d= -f2-)
        [ -n "$val" ] && echo "$val" && return
    fi
    echo "$default"
}

# ── Helpers ──

step() {
    printf '\n════════════════════════════════════════\n  %s\n════════════════════════════════════════\n\n' "$1"
}
