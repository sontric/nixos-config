#!/usr/bin/env bash
set -euo pipefail

# Install OpenAI Codex CLI on NixOS using:
#  1) nix profile install nodejs (user install, no sudo)
#  2) npm global install to a user prefix (~/.npm-global)
#  3) npm i -g @openai/codex

say() { printf "\n\033[1m%s\033[0m\n" "$*"; }

# 0) Sanity checks
command -v nix >/dev/null 2>&1 || {
  echo "ERROR: nix is not on PATH. Are you on NixOS / do you have nix installed?"
  exit 1
}

# 1) Ensure Node + npm exist (install via nix profile if missing)
if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
  say "Installing Node.js + npm via nix profile (user-level, no sudo)..."
  # Pick a reasonable default (Node 20). Change to nodejs_22 if you prefer.
  nix profile install "nixpkgs#nodejs_20" || nix profile install "nixpkgs#nodejs"
else
  say "Node.js and npm already found."
fi

# 2) Configure npm to install global packages into a user-writable prefix
#    so we never need sudo.
NPM_PREFIX="${HOME}/.npm-global"
mkdir -p "${NPM_PREFIX}"
npm config set prefix "${NPM_PREFIX}"

# Add npm global bin to PATH for this session
export PATH="${NPM_PREFIX}/bin:${PATH}"

# Persist PATH for future Bash shells (idempotent)
persist_line='export PATH="$HOME/.npm-global/bin:$PATH"'
append_if_missing() {
  local file="$1"
  local line="$2"
  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf '\n%s\n' "$line" >> "$file"
    return 0
  fi
  return 1
}

say "Persisting npm global bin in PATH for future shells..."
added_bashrc=0
added_profile=0
if append_if_missing "${HOME}/.bashrc" "${persist_line}"; then
  added_bashrc=1
fi
if append_if_missing "${HOME}/.profile" "${persist_line}"; then
  added_profile=1
fi

# 3) Install Codex CLI
say "Installing OpenAI Codex CLI with npm (global to ${NPM_PREFIX})..."
npm install -g @openai/codex

# 4) Verify
say "Verifying installation..."
if command -v codex >/dev/null 2>&1; then
  codex --version || true
  say "✅ Codex CLI installed."
else
  echo "ERROR: codex not found on PATH."
  echo "Try running: ${persist_line}"
  exit 1
fi

# 5) Next steps
cat <<EOF

Next steps:
1) Restart your terminal (or reload shell config):
   source ~/.bashrc

2) Run:
   codex

PATH updates added by this script:
- ~/.bashrc: $( [ "$added_bashrc" -eq 1 ] && echo "updated" || echo "already present" )
- ~/.profile: $( [ "$added_profile" -eq 1 ] && echo "updated" || echo "already present" )

The first run will prompt you to sign in (ChatGPT account) or use an API key. :contentReference[oaicite:1]{index=1}
(If using an API key, you can set OPENAI_API_KEY in your environment.)

EOF
