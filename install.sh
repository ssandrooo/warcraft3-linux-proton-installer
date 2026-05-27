#!/usr/bin/env bash
set -euo pipefail

# Warcraft III: RoC + TFT — Digital 1.27b + Widescreen
# Master installer for Steam / GE-Proton on Linux
#
# Each step can also run standalone:
#   steps/01-download.sh   Download installers, patches, widescreen mod
#   steps/02-install.sh    Install RoC + TFT via temp Wine prefix
#   steps/03-steam.sh      Add shortcuts to Steam (auto or manual)
#   steps/04-prefix.sh     Configure shared Wine prefix
#
# Prerequisites: GE-Proton (via protonup-qt)
# Optional:      pip install vdf  (automates Steam shortcut setup)
# Usage:         ./install.sh [BASEDIR]

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    cat <<'USAGE'
Usage: ./install.sh [BASEDIR]

Warcraft III: RoC + TFT — Digital 1.27b + Widescreen
Master installer for Steam / GE-Proton on Linux.

  BASEDIR  Parent directory for game files and staging (default: parent of this repo)

Steps (can also run standalone):
  steps/01-download.sh   Download installers, patches, widescreen mod
  steps/02-install.sh    Install RoC + TFT via temp Wine prefix
  steps/03-steam.sh      Add shortcuts to Steam (auto or manual)
  steps/04-prefix.sh     Configure shared Wine prefix

Prerequisites: GE-Proton (via protonup-qt)
Optional:      pip install vdf  (automates Steam shortcut setup)
USAGE
    exit 0
fi

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export W3_BASEDIR="${1:-$(dirname "$SCRIPTDIR")}"

source "$SCRIPTDIR/steps/config.sh"

echo "Warcraft III Installer"
echo ""
echo "  Base dir:    $BASEDIR"
echo "  Steam:       $STEAM_DIR"
echo "  Proton:      $GE_PROTON_NAME"
echo "  Resolution:  ${RES_W}x${RES_H}"

read -p "Change resolution? [y/N] " -n1 CHG; echo
if [[ "${CHG:-}" =~ [yY] ]]; then
    read -p "  Width [$RES_W]: " W; export RES_W="${W:-$RES_W}"
    read -p "  Height [$RES_H]: " H; export RES_H="${H:-$RES_H}"
    echo "  → ${RES_W}x${RES_H}"
fi

echo ""
read -p "Press Enter to start..."

bash "$SCRIPTDIR/steps/01-download.sh"
bash "$SCRIPTDIR/steps/02-install.sh"
bash "$SCRIPTDIR/steps/03-steam.sh"
bash "$SCRIPTDIR/steps/04-prefix.sh"

step "Installation complete!"

echo "Game files: $GAMEDIR"
echo "Prefix:     $COMPATDATA/$(load_state ROC_APPID) (shared via symlink)"
echo ""
echo "Restart Steam — both games should appear in your library."
