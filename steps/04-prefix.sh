#!/usr/bin/env bash
# Step 4: Configure Wine prefix (one shared prefix, TFT symlinked to RoC).
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

step "STEP 4 — Configuring Wine prefix"

ROC_APPID=$(load_state ROC_APPID)
TFT_APPID=$(load_state TFT_APPID)

if [ -z "$ROC_APPID" ] || [ -z "$TFT_APPID" ]; then
    echo "ERROR: App IDs not found. Run step 3 first."
    exit 1
fi

echo "  RoC: $ROC_APPID"
echo "  TFT: $TFT_APPID"
echo ""

ROC_PFX="$COMPATDATA/$ROC_APPID"
TFT_PFX="$COMPATDATA/$TFT_APPID"

if [ -d "$ROC_PFX/pfx" ]; then
    echo "Wine prefix already initialized."
else
    echo "Initializing Wine prefix..."
    mkdir -p "$ROC_PFX"
    STEAM_COMPAT_DATA_PATH="$ROC_PFX" \
    STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_DIR" \
    "$PROTON" run wineboot 2>&1 | tail -3 || true
fi

echo "Applying registry settings..."
STEAM_COMPAT_DATA_PATH="$ROC_PFX" \
STEAM_COMPAT_CLIENT_INSTALL_PATH="$STEAM_DIR" \
"$PROTON" run regedit "$GAMEDIR/warcraft_iii.reg" || true

# Symlink TFT → RoC (shared Wine env + registry)
if [ -L "$TFT_PFX" ]; then
    echo "TFT prefix already symlinked."
elif [ -d "$TFT_PFX" ]; then
    echo ""
    echo "Existing TFT prefix found at $TFT_PFX."
    echo "It will be replaced with a symlink to the shared RoC prefix."
    read -p "Continue? [Y/n] " CONT
    if [[ "${CONT:-y}" =~ [nN] ]]; then
        echo "Skipping symlink."
    else
        rm -rf "$TFT_PFX"
        ln -s "$ROC_PFX" "$TFT_PFX"
        echo "TFT prefix → RoC prefix (symlinked)."
    fi
else
    ln -s "$ROC_PFX" "$TFT_PFX"
    echo "TFT prefix → RoC prefix (symlinked)."
fi

echo ""
echo "Prefix: $ROC_PFX"
echo "Step 4 complete."
