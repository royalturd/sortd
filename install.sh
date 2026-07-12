#!/bin/sh
# install.sh — one-line installer for sortd
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/royalturd/sortd/master/install.sh | sh
#   wget -qO- https://raw.githubusercontent.com/royalturd/sortd/master/install.sh | sh

set -e

REPO="royalturd/sortd"
BINARY="sortd"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"

RED='\033[1;31m'; GREEN='\033[1;32m'; BLUE='\033[1;34m'; BOLD='\033[1m'; NC='\033[0m'
info()  { printf "%b\n" "${BLUE}$1${NC}"; }
ok()    { printf "%b\n" "${GREEN}$1${NC}"; }
die()   { printf "%b\n" "${RED}Error: $1${NC}" >&2; exit 1; }

RAW_URL="https://raw.githubusercontent.com/${REPO}/master/${BINARY}.sh"

info "Installing ${BOLD}sortd${NC}..."

if ! mkdir -p "$INSTALL_DIR"; then
    die "Cannot create install directory: $INSTALL_DIR"
fi

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$RAW_URL" -o "$INSTALL_DIR/$BINARY"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$INSTALL_DIR/$BINARY" "$RAW_URL"
else
    die "curl or wget is required."
fi

chmod +x "$INSTALL_DIR/$BINARY"

if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    printf "%b\n" "${BOLD}Note:${NC} Add the following to your shell profile to use sortd globally:"
    printf "  export PATH=\"\$PATH:%s\"\n" "$INSTALL_DIR"
fi

ok "sortd installed to $INSTALL_DIR/$BINARY"
ok "Run 'sortd --help' to get started."
