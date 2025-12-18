# Dotfiles

Personal configs managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Quick Start

```bash
# Install stow (macOS)
brew install stow

# Clone and setup
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
stow zsh tmux nvim lazygit yazi
```

## Structure

```
dotfiles/
├── zsh/           → ~/.zshrc
├── tmux/          → ~/.tmux.conf
├── nvim/          → ~/.config/nvim/
├── lazygit/       → ~/.config/lazygit/
├── nvim-vscode/   → ~/.config/nvim-vscode/
└── yazi/          → ~/.config/yazi/
```

## Adding a New Config

Example: adding yazi (config goes in `~/.config/yazi/`)

```bash
# 1. Create the folder structure
mkdir -p ~/dotfiles/yazi/.config/yazi

# 2. Create your config file
nvim ~/dotfiles/yazi/.config/yazi/yazi.toml

# 3. Stow it
cd ~/dotfiles && stow yazi

# 4. Commit
git add yazi && git commit -m "Add yazi config"
```

## Usage

```bash
stow appname      # Create symlinks
stow -D appname   # Remove symlinks
stow -R appname   # Restow after pulling
```

