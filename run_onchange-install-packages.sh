#!/bin/bash

set -e

cat "$(realpath "$0")"

echo "=== Checking Homebrew installation ==="
if ! command -v brew &> /dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
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
  fnm \
  fzf \
  gh \
  git \
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
sudo chsh -s "$zsh_path" "${USER}"

echo "=== Installing Node.js via fnm ==="
eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
fnm install 22
fnm use 22

echo "=== Linking tmux config ==="
ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf

echo "=== Installation complete ==="
echo "Please log out and log back in for zsh to become your default shell"
