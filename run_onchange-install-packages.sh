#!/bin/bash

set -e

cat "$(realpath "$0")"

CAN_USE_SUDO=false
if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
  CAN_USE_SUDO=true
fi

if [ -n "${CHEZMOI_NO_BREW:-}" ]; then
  echo "=== Skipping Homebrew installation and packages because CHEZMOI_NO_BREW is set ==="
else
  echo "=== Checking Homebrew installation ==="
  if ! command -v brew &>/dev/null; then
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
    git-delta \
    jq \
    jesseduffield/lazydocker/lazydocker \
    jesseduffield/lazygit/lazygit \
    ncdu \
    ripgrep \
    tmux \
    yq \
    zsh

  HOMEBREW_NO_ENV_HINTS=true brew install --quiet --head neovim
fi

echo "=== Setting zsh as default shell ==="
zsh_path=$(command -v zsh)
zsh_setup_status="skipped"
if [ -z "$zsh_path" ]; then
  echo "=== zsh not found in PATH; skipping default shell setup ==="
  zsh_setup_status="missing_zsh"
else
  if [ "$CAN_USE_SUDO" = true ]; then
    echo "=== Updating /etc/shells with zsh path ==="
    if ! grep -q -F "$zsh_path" /etc/shells; then
      if ! echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null; then
        zsh_setup_status="manual_shell_setup"
      fi
    fi

    current_user=$(whoami)
    echo "=== Setting login shell to $zsh_path for user $current_user ==="
    if sudo chsh -s "$zsh_path" "$current_user"; then
      zsh_setup_status="done"
    else
      zsh_setup_status="manual_shell_setup"
    fi
  else
    echo "=== Sudo not available; skipping automatic zsh shell setup ==="
    zsh_setup_status="manual_shell_setup"
  fi
fi

echo "=== Linking tmux config ==="
ln -sf ~/.tmux/.tmux.conf ~/.tmux.conf

echo "=== Loading Homebrew environment ==="
if [ -f /home/linuxbrew/.linuxbrew/bin/brew ]; then
  echo "=== Loading Homebrew environment ==="
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  echo "Homebrew binaries are now in PATH"
fi

echo "=== Installation complete ==="

if [ "$zsh_setup_status" = "done" ]; then
  echo "Please log out and log back in for zsh to become your default shell."
elif [ "$zsh_setup_status" = "manual_shell_setup" ] && [ -n "$zsh_path" ]; then
  echo "Sudo is required to set zsh as your default login shell."
  echo "Run the following command block manually when you have sudo access:"
  cat <<EOF
if ! grep -q -F "$zsh_path" /etc/shells; then
    echo "$zsh_path" | sudo tee -a /etc/shells
fi
sudo chsh -s "$zsh_path" "$(whoami)"
EOF
elif [ "$zsh_setup_status" = "missing_zsh" ]; then
  echo "zsh is not available in PATH; default shell was not changed."
fi
