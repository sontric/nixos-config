#!/usr/bin/env bash
set -euo pipefail

log(){ printf "\n==> %s\n" "$*"; }

append_once() {
  local line="$1" file="$2"
  grep -qxF "$line" "$file" 2>/dev/null || echo "$line" >> "$file"
}

# --- Helpers: WSL + systemd detection ---
is_wsl() {
  grep -qiE "(microsoft|wsl)" /proc/version 2>/dev/null
}

has_systemd() {
  # Works for WSL and normal Linux:
  # - /run/systemd/system exists when systemd is the init system
  # - PID 1 comm is "systemd" when systemd is init
  [ -d /run/systemd/system ] || [ "$(cat /proc/1/comm 2>/dev/null || true)" = "systemd" ]
}

log "APT prerequisites + Git"
sudo apt-get update -y
sudo apt-get install -y \
  ca-certificates \
  curl \
  wget \
  gpg \
  xz-utils \
  git

log "GitHub CLI (gh) via official apt repo"
sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

sudo apt-get update -y
sudo apt-get install -y gh

log "nvm (user-local) + Node LTS"
NVM_VER="v0.40.4"
curl -fsSL "https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VER}/install.sh" | bash

export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

nvm install --lts
nvm use --lts
nvm alias default 'lts/*'

log "npm global installs to HOME (no sudo) + PATH in .bashrc"
mkdir -p "$HOME/.npm-global"
npm config set prefix "$HOME/.npm-global"

append_once 'export PATH="$HOME/.npm-global/bin:$PATH"' "$HOME/.bashrc"
export PATH="$HOME/.npm-global/bin:$PATH"

log "Install OpenAI Codex CLI (no sudo)"
npm i -g @openai/codex

log "Detecting WSL + systemd"
if is_wsl; then
  log "WSL detected"
else
  log "WSL not detected (continuing anyway)"
fi

if has_systemd; then
  log "systemd is enabled (daemon install recommended)"
  NIX_INSTALL_MODE="--daemon"
else
  log "systemd is NOT enabled (using --no-daemon single-user install)"
  NIX_INSTALL_MODE="--no-daemon"
fi

log "Install Nix if missing (mode: ${NIX_INSTALL_MODE})"
if ! command -v nix >/dev/null 2>&1; then
  # This may prompt and may use sudo (normal) to create /nix and set up services in daemon mode.
  curl -L https://nixos.org/nix/install | sh -s -- ${NIX_INSTALL_MODE}
fi

log "Load Nix into current shell (best-effort)"
# Daemon installs commonly provide /etc/profile.d/nix.sh
if [ -e "/etc/profile.d/nix.sh" ]; then
  # shellcheck disable=SC1091
  . "/etc/profile.d/nix.sh"
elif [ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
  # shellcheck disable=SC1091
  . "$HOME/.nix-profile/etc/profile.d/nix.sh"
fi

log "Enable flakes + nix-command in ~/.config/nix/nix.conf (user-local)"
mkdir -p "$HOME/.config/nix"
CONF="$HOME/.config/nix/nix.conf"

if [ -f "$CONF" ] && grep -qE '^\s*experimental-features\s*=' "$CONF"; then
  sed -i 's/^\s*experimental-features\s*=.*/experimental-features = nix-command flakes/' "$CONF"
else
  append_once "experimental-features = nix-command flakes" "$CONF"
fi

log "Ensure Nix is loaded for future bash sessions"
# Prefer /etc/profile.d for daemon installs, fallback to user profile.
append_once '[ -e "/etc/profile.d/nix.sh" ] && . "/etc/profile.d/nix.sh"' "$HOME/.bashrc"
append_once '[ -e "$HOME/.nix-profile/etc/profile.d/nix.sh" ] && . "$HOME/.nix-profile/etc/profile.d/nix.sh"' "$HOME/.bashrc"

log "Done. Versions:"
git --version || true
gh --version || true
node --version || true
npm --version || true
codex --version || true
nix --version || true

cat <<'NEXT'
Next steps:
  source ~/.bashrc

Then:
  gh auth login
  codex
  nix flake --help
NEXT
