#!/bin/sh

set -e

echo "🚀 Setting up dotfiles..."

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p ~/.config
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/wallpapers
mkdir -p ~/.local/share/themes
mkdir -p ~/.local/share/icons
mkdir -p ~/.local/share/fonts

# Symlink configurations
echo "🔗 Symlinking configurations..."
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Shell configs
ln -sf "$DOTFILES_DIR/zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/vimrc" ~/.vimrc
ln -sf "$DOTFILES_DIR/gitconfig" ~/.gitconfig
ln -sf "$DOTFILES_DIR/tmux.conf" ~/.tmux.conf

# XDG configs
ln -sf "$DOTFILES_DIR/config/nvim" ~/.config/
ln -sf "$DOTFILES_DIR/config/kitty" ~/.config/
ln -sf "$DOTFILES_DIR/config/hypr" ~/.config/
ln -sf "$DOTFILES_DIR/config/waybar" ~/.config/
ln -sf "$DOTFILES_DIR/config/wofi" ~/.config/
ln -sf "$DOTFILES_DIR/config/mako" ~/.config/
ln -sf "$DOTFILES_DIR/config/btop" ~/.config/
ln -sf "$DOTFILES_DIR/config/lazygit" ~/.config/
ln -sf "$DOTFILES_DIR/config/fastfetch" ~/.config/
ln -sf "$DOTFILES_DIR/config/zsh" ~/.config/

# Local data
ln -sf "$DOTFILES_DIR/local/share/applications/"* ~/.local/share/applications/
ln -sf "$DOTFILES_DIR/local/share/wallpapers/"* ~/.local/share/wallpapers/
ln -sf "$DOTFILES_DIR/local/share/themes/"* ~/.local/share/themes/
ln -sf "$DOTFILES_DIR/local/share/icons/"* ~/.local/share/icons/

# Change default shell to zsh
echo "🐚 Changing default shell to zsh..."
if [[ "$SHELL" != "$(which zsh)" ]]; then
    chsh -s $(which zsh)
fi

# Install vim plugins
echo "📦 Installing Vim plugins..."
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
vim +PluginInstall +qall

echo "Setup complete!"
echo ""
echo "🔄 Please log out and log back in to complete the setup."