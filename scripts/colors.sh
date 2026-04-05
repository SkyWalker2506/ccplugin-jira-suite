#!/usr/bin/env bash
# colors.sh — Shared color codes for jira-suite scripts.
# Usage: source "$(dirname "$0")/colors.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'  # No Color

# Helper functions
err()  { echo -e "${RED}✗ $1${NC}" >&2; }
ok()   { echo -e "${GREEN}✓ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠ $1${NC}"; }
info() { echo -e "${CYAN}ℹ $1${NC}"; }
bold() { echo -e "${BOLD}$1${NC}"; }
dim()  { echo -e "${DIM}$1${NC}"; }
