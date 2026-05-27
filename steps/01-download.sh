#!/usr/bin/env bash
# Step 1: Download all installers, patches, and mods.
source "$(dirname "${BASH_SOURCE[0]}")/config.sh"

step "STEP 1 — Downloading"
mkdir -p "$STAGING"

dl() {
    local dest="$1" url="$2" tag="$3"
    if [ -s "$dest" ]; then
        echo "  [$tag] already downloaded, skip"
        return
    fi
    echo "  [$tag] downloading..."
    local tmp="${dest}.part"
    if wget -O "$tmp" "$url"; then
        mv "$tmp" "$dest"
    else
        rm -f "$tmp"
        echo "  [$tag] download FAILED"
        return 1
    fi
}

dl "$STAGING/w3roc_digital.exe" \
    "https://us.battle.net/download/getLegacy?product=WAR3&locale=enUS&os=WIN" \
    "1/5 RoC installer"

dl "$STAGING/w3roc_update.exe" \
    "http://ftp.blizzard.com/pub/war3x/patches/pc/War3ROC_127b_English.exe" \
    "2/5 RoC 1.27b patch"

dl "$STAGING/w3tft_digital.exe" \
    "https://us.battle.net/download/getLegacy?product=W3XP&locale=enUS&os=WIN" \
    "3/5 TFT installer"

dl "$STAGING/w3tft_update.exe" \
    "http://ftp.blizzard.com/pub/war3x/patches/pc/War3TFT_127b_English.exe" \
    "4/5 TFT 1.27b patch"

dl "$STAGING/RenderEdge_Widescreen.mix" \
    "https://github.com/legluondunet/MyLittleLutrisScripts/raw/master/Warcraft%20III%20-%20Reign%20of%20Chaos/RenderEdge_Widescreen.mix" \
    "5/5 Widescreen mod"

# Registry file from template (skip if resolution unchanged)
RES_W_HEX=$(printf '%08x' "$RES_W")
RES_H_HEX=$(printf '%08x' "$RES_H")
REG_FILE="$STAGING/warcraft_iii.reg"
REG_MARKER="$STAGING/.reg_${RES_W}x${RES_H}"
REG_TEMPLATE="$TEMPLATEDIR/warcraft_iii.reg.tpl"

if [ -f "$REG_MARKER" ] && [ -f "$REG_FILE" ]; then
    echo "  Registry already generated for ${RES_W}x${RES_H}."
else
    rm -f "$STAGING"/.reg_*
    sed -e "s/%%RES_W_HEX%%/${RES_W_HEX}/g" \
        -e "s/%%RES_H_HEX%%/${RES_H_HEX}/g" \
        "$REG_TEMPLATE" > "$REG_FILE"
    touch "$REG_MARKER"
    echo "  Registry generated for ${RES_W}x${RES_H}."
fi

echo ""
ls -lh "$STAGING"
echo ""
echo "Step 1 complete."
