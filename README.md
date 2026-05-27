# Warcraft III Linux Installer (GE-Proton)

Install Warcraft III: Reign of Chaos + The Frozen Throne (1.27b) on Linux using Steam and GE-Proton. Includes widescreen support and 1080p cinematics.

## What it does

1. Downloads the digital installers, 1.27b patches, and the RenderEdge widescreen mod
2. Installs RoC + TFT via a temporary Wine prefix
3. Adds non-Steam shortcuts with GE-Proton as the compatibility tool
4. Configures a shared Wine prefix with widescreen registry settings

## Prerequisites

- Steam (native or Flatpak)
- [GE-Proton](https://github.com/GloriousEggroll/proton-ge-custom) — install via [protonup-qt](https://github.com/DavidoTek/ProtonUp-Qt)
- `pip install vdf` — for automated Steam shortcut setup
- Valid CD keys for RoC and TFT

## Usage

```bash
git clone https://github.com/ssandrooo/warcraft3-linux-proton-installer.git
cd warcraft3-linux-proton-installer
./install.sh [BASEDIR]
```

`BASEDIR` is where game files and staging data go (defaults to the parent directory of this repo).

The installer detects your screen resolution automatically. You can override it at the prompt or via environment variables:

```bash
RES_W=2560 RES_H=1440 ./install.sh
```

## Running individual steps

Each step can run standalone if you need to redo something:

| Script | Purpose |
|---|---|
| `steps/01-download.sh` | Download installers, patches, widescreen mod |
| `steps/02-install.sh` | Install RoC + TFT via temp Wine prefix |
| `steps/03-steam.sh` | Add shortcuts to Steam |
| `steps/04-prefix.sh` | Configure shared Wine prefix |

After running, restart Steam — both games should appear in your library.
