#!/usr/bin/env bash
# Install everything needed to build Tabulador on macOS. Safe to re-run: steps
# whose tools are already present are skipped.

set -euo pipefail

cd "$(dirname "$0")/.."

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Unsupported OS: $(uname -s) (only macOS is supported)" >&2
  exit 1
fi

PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
# Tools installed below are not on PATH until a new shell starts
export PATH="$HOME/.cargo/bin:$PYENV_ROOT/bin:$PYENV_ROOT/shims:$HOME/.local/share/mise/shims:$PATH"

use_pyenv=0; command -v pyenv >/dev/null 2>&1 && use_pyenv=1
# nvm only works in bash and zsh, so fish users get Node from mise
use_nvm=0; [ -s "$NVM_DIR/nvm.sh" ] && [ "$(basename "$SHELL")" != fish ] && use_nvm=1
# mise is only needed for the runtimes pyenv and nvm don't provide
use_mise=$((!use_pyenv || !use_nvm))

install_macos_deps() {
  xcode-select -p >/dev/null 2>&1 || xcode-select --install || true

  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required. Install it from https://brew.sh, then run make setup again." >&2
    exit 1
  fi
  echo "Installing Homebrew packages..."
  brew install pnpm protobuf zsh bash fish shellcheck jq
  ((use_mise)) && brew install mise
  return 0
}

install_rust() {
  if ! command -v rustup >/dev/null 2>&1; then
    echo "Installing rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
  fi

  rustup default stable
  # Pinned: newer nightlies reformat the existing code
  rustup toolchain install nightly-2025-11-01 --component rustfmt
  rustup target add x86_64-apple-darwin aarch64-apple-darwin
  # rust-toolchain.toml pins an older Rust than recent typos-cli releases require
  command -v typos >/dev/null 2>&1 || cargo +stable install typos-cli

  # Tauri 1 CLI needs an older Rust to build
  if ! command -v cargo-tauri >/dev/null 2>&1; then
    echo "Installing the Tauri CLI..."
    rustup toolchain install 1.79.0
    cargo +1.79.0 install tauri-cli@1.6.0 --locked
  fi
}

add_to_shell() {
  local shell_name rc
  shell_name="$(basename "$SHELL")"
  case "$shell_name" in
    zsh) rc="${ZDOTDIR:-$HOME}/.zshrc" ;;
    bash) rc="$HOME/.bashrc" ;;
    fish)
      rc="$HOME/.config/fish/config.fish"
      mkdir -p "$(dirname "$rc")"
      if ((use_mise)); then
        grep -qxF 'mise activate fish | source' "$rc" 2>/dev/null || echo 'mise activate fish | source' >> "$rc"
      fi
      grep -qxF 'fish_add_path $HOME/.cargo/bin' "$rc" 2>/dev/null || echo 'fish_add_path $HOME/.cargo/bin' >> "$rc"
      return
      ;;
    *)
      echo "Unknown shell '$shell_name'. Add mise and ~/.cargo/bin to your shell config manually."
      return
      ;;
  esac
  touch "$rc"
  if [ -f "$HOME/.cargo/env" ]; then
    grep -qxF ". \"\$HOME/.cargo/env\"" "$rc" || echo ". \"\$HOME/.cargo/env\"" >> "$rc"
  fi
  if ((use_mise)); then
    grep -qxF "eval \"\$(mise activate $shell_name)\"" "$rc" || echo "eval \"\$(mise activate $shell_name)\"" >> "$rc"
  fi
}

setup_runtimes() {
  # pyenv and nvm users get Python and Node from .python-version and .nvmrc
  if ((use_pyenv)); then
    echo "Installing Python $(cat .python-version) with pyenv..."
    pyenv install --skip-existing "$(cat .python-version)"
    pyenv rehash
  fi
  if ((use_nvm)); then
    echo "Installing Node $(cat .nvmrc) with nvm..."
    set +u
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
    nvm install
    set -u
  fi
  if ((use_mise)); then
    mise trust
    ((use_pyenv)) || { echo "Installing Python with mise..."; mise install python; }
    ((use_nvm)) || { echo "Installing Node with mise..."; mise install node; }
    mise reshim
  fi
}

setup_precommit() {
  echo "Installing pre-commit hooks..."
  pnpm install --ignore-scripts
}

install_macos_deps
install_rust
add_to_shell
setup_runtimes
setup_precommit

echo "Setup complete. Open a new terminal (or run make check here) to continue."
