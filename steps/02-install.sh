#!/usr/bin/env bash
# Step 2: Install RoC + TFT + patches via a temp Wine prefix.
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

step "STEP 2 — Installing games"

if [ -f "$GAMEDIR/Warcraft III.exe" ] \
   && [ -f "$GAMEDIR/Frozen Throne.exe" ] \
   && [ -f "$GAMEDIR/RenderEdge_Widescreen.mix" ]; then
    echo "Game files already in $GAMEDIR, skipping install."
    [ -f "$STAGING/warcraft_iii.reg" ] && cp "$STAGING/warcraft_iii.reg" "$GAMEDIR/"
    exit 0
fi

TPFX="$BASEDIR/install-prefix"
TGAME="$TPFX/pfx/drive_c/Program Files (x86)/Warcraft III"
mkdir -p "$TPFX"
export STEAM_COMPAT_DATA_PATH="$TPFX"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_DIR"

if [ -d "$TPFX/pfx" ]; then
    echo "Install prefix already initialized."
else
    echo "Initializing install prefix..."
    "$PROTON" run wineboot 2>&1 | tail -3 || true
fi

# ── RoC ──

if [ -f "$TGAME/Warcraft III.exe" ]; then
    echo "RoC already installed, skip."
else
    echo ""
    echo "--- RoC Installer ---"
    echo "Press OK, use defaults, provide your CD key."
    read -p "Press Enter to launch... "
    "$PROTON" run "$STAGING/w3roc_digital.exe" || true
    [ -f "$TGAME/Warcraft III.exe" ] || { echo "ERROR: RoC installation failed."; exit 1; }
fi

if [ -f "$TPFX/.roc_patched" ]; then
    echo "RoC 1.27b already patched, skip."
else
    echo ""
    echo "--- RoC 1.27b Patch ---"
    echo "Close the updater when it finishes."
    read -p "Press Enter to launch... "
    "$PROTON" run "$STAGING/w3roc_update.exe" || true
    touch "$TPFX/.roc_patched"
fi

# ── TFT ──

if [ -f "$TGAME/Frozen Throne.exe" ]; then
    echo "TFT already installed, skip."
else
    echo ""
    echo "--- TFT Installer ---"
    echo "Press OK, use defaults, provide your CD key."
    read -p "Press Enter to launch... "
    "$PROTON" run "$STAGING/w3tft_digital.exe" || true
    [ -f "$TGAME/Frozen Throne.exe" ] || { echo "ERROR: TFT installation failed."; exit 1; }
fi

if [ -f "$TPFX/.tft_patched" ]; then
    echo "TFT 1.27b already patched, skip."
else
    echo ""
    echo "--- TFT 1.27b Patch ---"
    echo "Close the updater when it finishes."
    read -p "Press Enter to launch... "
    "$PROTON" run "$STAGING/w3tft_update.exe" || true
    touch "$TPFX/.tft_patched"
fi

# ── Extras ──

[ -f "$TGAME/RenderEdge_Widescreen.mix" ] \
    || cp "$STAGING/RenderEdge_Widescreen.mix" "$TGAME/"
cp "$STAGING/warcraft_iii.reg" "$TGAME/"

# ── Move to shared game directory ──

echo ""
echo "Copying game files to $GAMEDIR..."
mkdir -p "$GAMEDIR"
cp -a "$TGAME"/. "$GAMEDIR/"

if [ -f "$GAMEDIR/Warcraft III.exe" ] && [ -f "$GAMEDIR/Frozen Throne.exe" ]; then
    echo "Cleaning up temp prefix..."
    rm -rf "$TPFX"
else
    echo "WARNING: copy may be incomplete — keeping temp prefix at $TPFX"
fi

echo ""
echo "Game files: $GAMEDIR"
echo "Step 2 complete."
