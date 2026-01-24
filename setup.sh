#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"

# Packages
sudo apt update
sudo apt install tmux git jq redshift ttyd xsel tree python3 python3-pip python3-venv python-is-python3 ripgrep

# Basic Dev setup
GIT_DIR="$HOME/github"
mkdir -p "$HOME/github"

# NodeJS
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
\. "$HOME/.nvm/nvm.sh"
nvm install 22

# Configs
. "$DIR/copyconfigs.sh"
if [[ ! -d "$HOME/.local/share/nvim/lazy/lazy.nvim" ]]; then
  git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable ~/.local/share/nvim/lazy/lazy.nvim
fi

# Install Brave
if ! command -v brave-browser >/dev/null 2>&1; then
  curl -fsS https://dl.brave.com/install.sh | sh
fi
gsettings set org.gnome.desktop.interface font-name 'Noto Sans 11'

# Install latest Neovim via AppImage only if not already installed
mkdir -p "$HOME/Applications"
if ! command -v nvim >/dev/null 2>&1; then
  wget https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
  chmod +x nvim-linux-x86_64.appimage
  sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
fi

# Install Espanso text expander
if ! command -v espanso >/dev/null 2>&1; then
  wget https://github.com/espanso/espanso/releases/latest/download/espanso-debian-x11-amd64.deb
  sudo apt install ./espanso-debian-x11-amd64.deb
  rm espanso-debian-x11-amd64.deb
  
  # Register and start espanso service
  espanso service register
  espanso start
fi

# Install Emote (Emoji Picker) via Flatpak
if ! command -v flatpak >/dev/null 2>&1; then
  echo "Flatpak not found. Installing..."
  sudo apt install -y flatpak
fi

# Add Flathub remote if it doesn't exist
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install Emote non-interactively
# -y: automatically answer yes
flatpak install -y flathub com.tomjwatson.Emote

# Install Ollama if it doesn't exist
if ! command -v ollama >/dev/null 2>&1; then
  echo "Ollama not found. Installing..."
  curl -fsSL https://ollama.com/install.sh | sh
else
  echo "Ollama is already installed."
fi

# Install Ollama models only if they don't already exist
if command -v ollama >/dev/null 2>&1; then
  MODELS_TO_INSTALL=(
    "qwen3:0.6b-q4_K_M"
    "qwen3:1.7b-q4_K_M"
    "qwen3:4b-q4_K_M"
    "embeddinggemma:300m"
    "phi4-mini:3.8b-q4_K_M"
    "gemma3:270m-it-qat"
    "gemma3:1b-it-qat"
    "gemma3n:e2b-it-q4_K_M"
    "deepseek-r1:1.5b-qwen-distill-q4_K_M"
  )

  echo "Checking for and installing missing Ollama models..."
  for model in "${MODELS_TO_INSTALL[@]}"; do
    if ! ollama list | grep -q "^$model"; then
      echo "Model $model not found. Pulling..."
      ollama pull "$model"
    else
      echo "Model $model already exists. Skipping."
    fi
  done
else
  echo "Cannot check for models because Ollama is not installed."
fi

# Install Kiwix Server & Wikipedia ZIM
KIWIX_VER="3.8.1"
KIWIX_URL="https://download.kiwix.org/release/kiwix-tools/kiwix-tools_linux-x86_64-${KIWIX_VER}.tar.gz"
# Note: ZIM links expire/change monthly. Check https://library.kiwix.org for the latest "Wikipedia English (all) nopic" URL.
# This URL is a best-guess stable link for the 2025 snapshot.
WIKI_ZIM_URL="https://download.kiwix.org/zim/wikipedia/wikipedia_en_all_nopic_2025-12.zim"
KIWIX_DIR="$HOME/kiwix"

# 1. Install Kiwix-Serve (Server Binary)
if ! command -v kiwix-serve >/dev/null 2>&1; then
  echo "Kiwix-serve not found. Installing..."
  wget -qO kiwix-tools.tar.gz "$KIWIX_URL"
  tar -xzf kiwix-tools.tar.gz
  # Move binary to path
  sudo mv "kiwix-tools_linux-x86_64-${KIWIX_VER}/kiwix-serve" /usr/local/bin/
  # Cleanup
  rm -rf kiwix-tools*
  echo "Kiwix-serve installed."
fi

# 2. Download Wikipedia ZIM (If missing)
mkdir -p "$KIWIX_DIR"
# Check if any .zim file exists to avoid re-downloading 60GB
if ! ls "$KIWIX_DIR"/*.zim >/dev/null 2>&1; then
  echo "No local Wikipedia found. Downloading 'nopic' ZIM (WARNING: ~55GB download)..."
  # -c allows continuing a partial download if it fails
  wget -c -P "$KIWIX_DIR" "$WIKI_ZIM_URL"
else
  echo "Local Wikipedia ZIM already exists in $KIWIX_DIR."
fi

# 3. Usage Instructions (Commented out)
# To run the server for your agents:
# kiwix-serve --port=8080 --daemon --library "$KIWIX_DIR"/*.zim
# Then search via: http://localhost:8080/search?pattern=Linux+Mint
