#!/bin/bash
# fix-steam-gui.sh
# Fixes missing Steam GUI update dialog on EndeavourOS / Arch-based distros
#
# Problem: Steam falls back to console-only update UI because
#          32-bit SDL3 and XRandr libraries are missing.
# Solution: Install lib32-sdl3 and lib32-libxrandr.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Steam GUI Update Dialog Fix ===${NC}"
echo ""

# --- Check current state ---
echo -e "${YELLOW}[1/4] Checking current library status...${NC}"

missing=()

if ! find /usr/lib32 -name "libSDL3.so.0" 2>/dev/null | grep -q .; then
    echo -e "  ${RED}✗${NC} lib32-sdl3 (libSDL3.so.0) — NOT FOUND"
    missing+=("lib32-sdl3")
else
    echo -e "  ${GREEN}✓${NC} lib32-sdl3 (libSDL3.so.0) — installed"
fi

if ! find /usr/lib32 -name "libXrandr.so.2" 2>/dev/null | grep -q .; then
    echo -e "  ${RED}✗${NC} lib32-libxrandr (libXrandr.so.2) — NOT FOUND"
    missing+=("lib32-libxrandr")
else
    echo -e "  ${GREEN}✓${NC} lib32-libxrandr (libXrandr.so.2) — installed"
fi

if ! find /usr/lib32 -name "libX11.so.6" 2>/dev/null | grep -q .; then
    echo -e "  ${RED}✗${NC} lib32-libx11 (libX11.so.6) — NOT FOUND"
    missing+=("lib32-libx11")
else
    echo -e "  ${GREEN}✓${NC} lib32-libx11 (libX11.so.6) — installed"
fi

echo ""

# --- Install if needed ---
if [ ${#missing[@]} -eq 0 ]; then
    echo -e "${GREEN}[2/4] All required libraries are already installed!${NC}"
else
    echo -e "${YELLOW}[2/4] Installing missing packages: ${missing[*]}${NC}"
    sudo pacman -S --needed "${missing[@]}"
    echo -e "${GREEN}      Done.${NC}"
fi

echo ""

# --- Check Steam update UI log ---
echo -e "${YELLOW}[3/4] Checking Steam's current update UI mode...${NC}"

UPDATEUI_LOG="$HOME/.local/share/Steam/logs/updateui_child.txt"
if [ -f "$UPDATEUI_LOG" ]; then
    mode=$(grep "Using update UI:" "$UPDATEUI_LOG" | tail -1 | awk '{print $NF}')
    if [ "$mode" = "console" ]; then
        echo -e "  ${RED}Current mode: console (no GUI)${NC}"
        echo -e "  ${YELLOW}After installing the packages above, restart Steam to get the GUI.${NC}"
    elif [ "$mode" = "xwin" ] || [ "$mode" = "glx" ]; then
        echo -e "  ${GREEN}Current mode: $mode (GUI is working!)${NC}"
    else
        echo -e "  Mode: $mode"
    fi
else
    echo -e "  ${YELLOW}No Steam log found yet. Run Steam once to generate it.${NC}"
fi

echo ""

# --- Summary ---
echo -e "${YELLOW}[4/4] Summary${NC}"
if [ ${#missing[@]} -eq 0 ]; then
    echo -e "  ${GREEN}Everything looks good. Just run 'steam' and let the update finish.${NC}"
else
    echo -e "  Packages were installed. Now run:"
    echo -e "    ${GREEN}rm -rf ~/.local/share/Steam && steam${NC}"
    echo -e "  The graphical update dialog should now appear."
fi

echo ""
echo -e "${YELLOW}Done!${NC}"
