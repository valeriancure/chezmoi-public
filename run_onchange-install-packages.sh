#!/bin/bash

set -e

cat "$(realpath "$0")"

echo "=== Checking Homebrew installation ==="
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add brew to PATH for this script
    if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
        eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    fi
else
    echo "Homebrew already installed"
fi

echo "=== Installing packages via Homebrew ==="
HOMEBREW_NO_ENV_HINTS=true brew install --quiet \
  bat \
  fd \
  fzf \
  gh \
  jq \
  jesseduffield/lazydocker/lazydocker \
  jesseduffield/lazygit/lazygit \
  ncdu \
  neovim \
  ripgrep \
  tmux \
  yq \
  zsh

echo "=== Setting zsh as default shell ==="
zsh_path=$(command -v zsh)
if ! grep -q -F "$zsh_path" /etc/shells; then
    echo "$zsh_path" | sudo tee -a /etc/shells
fi
current_user=$(whoami)
sudo chsh -s "$zsh_path" "$current_user"

echo "=== Linking tmux config ==="
ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf

echo "=== Loading Homebrew environment ==="
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo "Homebrew binaries are now in PATH"
fi

echo "=== Installation complete ==="
echo "Please log out and log back in for zsh to become your default shell"
