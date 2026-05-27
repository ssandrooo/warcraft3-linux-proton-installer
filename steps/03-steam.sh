#!/usr/bin/env bash
# Step 3: Add Warcraft III shortcuts to Steam via Python vdf tool.
# Requires: pip install vdf
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

step "STEP 3 — Add to Steam"

ROC_APPID=$(load_state ROC_APPID)
TFT_APPID=$(load_state TFT_APPID)

if [ -n "$ROC_APPID" ] && [ -n "$TFT_APPID" ]; then
    echo "App IDs already saved: RoC=$ROC_APPID  TFT=$TFT_APPID"
    read -p "Re-run? [y/N] " R; echo
    [[ "${R:-}" =~ [yY] ]] || { echo "Step 3 complete."; exit 0; }
    ROC_APPID=""; TFT_APPID=""
fi

python3 -c "import vdf" 2>/dev/null || { echo "ERROR: pip install vdf"; exit 1; }

if pgrep -xi steam &>/dev/null; then
    echo "Steam must be closed to modify shortcuts."
    read -p "Close Steam and press Enter... "
    pgrep -xi steam &>/dev/null && { echo "ERROR: Steam still running."; exit 1; }
fi

OUT=$(python3 "$TOOLSDIR/steam_shortcuts.py" "$GAMEDIR" \
    --proton "$GE_PROTON_NAME" --steam-dir "$STEAM_DIR" 2>&1) || {
    echo "$OUT"
    exit 1
}
echo "$OUT"

ROC_APPID=$(echo "$OUT" | grep "^APPID:" | sed -n '1s/^APPID://p')
TFT_APPID=$(echo "$OUT" | grep "^APPID:" | sed -n '2s/^APPID://p')

[ -n "$ROC_APPID" ] && [ -n "$TFT_APPID" ] || { echo "ERROR: Missing app IDs."; exit 1; }
[ "$ROC_APPID" != "$TFT_APPID" ] || { echo "ERROR: App IDs must differ."; exit 1; }

save_state ROC_APPID "$ROC_APPID"
save_state TFT_APPID "$TFT_APPID"

echo ""
echo "  RoC: $ROC_APPID"
echo "  TFT: $TFT_APPID"
echo "Step 3 complete."
