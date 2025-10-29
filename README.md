# Chezmoi Server Dotfiles

Streamlined dotfiles for Ubuntu 24 LTS and AlmaLinux 10 servers using Homebrew as universal package manager.

## Features

- **Shell**: Zsh with Oh-My-Zsh, Powerlevel10k theme, autosuggestions, syntax highlighting
- **Editor**: Neovim (HEAD) with full LazyVim configuration
- **Terminal multiplexer**: Tmux with gpakosz/.tmux config
- **Tools**: bat, fd, fzf, ripgrep, lazygit, lazydocker, jq, yq, ncdu, gh

## Quick Start

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Initialize with this repo
chezmoi init --apply https://github.com/YOUR_USERNAME/chezmoi-public.git
```

The installation script will:
1. Install Homebrew if not present
2. Install all packages via Homebrew
3. Set zsh as default shell
4. Setup tmux and neovim configs

## Requirements

- Sudo access (for installing Homebrew dependencies and changing shell)
- curl
- git

## Supported Systems

- Ubuntu 24.04 LTS
- AlmaLinux 10
- Any Linux with Homebrew support

## Manual Steps

After installation completes, log out and log back in for zsh to become your default shell.
