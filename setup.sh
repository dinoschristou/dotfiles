#!/bin/sh

set -e

echo "Setting up dotfiles..."

# Create necessary directories
echo "Creating directories..."
mkdir -p ~/.config
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/wallpapers
mkdir -p ~/.local/share/themes
mkdir -p ~/.local/share/icons
mkdir -p ~/.local/share/fonts

# Symlink configurations
echo "Symlinking configurations..."
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Link bin folder
echo "Linking bin folder..."
ln -sf "$DOTFILES_DIR/bin" ~/

# Shell configs
ln -sf "$DOTFILES_DIR/zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/vimrc" ~/.vimrc
ln -sf "$DOTFILES_DIR/p10k.zsh" ~/.p10k.zsh
ln -sf "$DOTFILES_DIR/gitconfig" ~/.gitconfig

# Configs for applications
ln -sf "$DOTFILES_DIR/config/nvim" ~/.config/
ln -sf "$DOTFILES_DIR/config/kitty" ~/.config/
ln -sf "$DOTFILES_DIR/config/btop" ~/.config/
ln -sf "$DOTFILES_DIR/config/lazygit" ~/.config/
ln -sf "$DOTFILES_DIR/config/fastfetch" ~/.config/
ln -sf "$DOTFILES_DIR/config/tmux" ~/.config/
ln -sf "$DOTFILES_DIR/config/zsh" ~/.config/

# Change default shell to zsh
echo "Changing default shell to zsh..."
if [[ "$SHELL" != "$(which zsh)" ]]; then
    chsh -s $(which zsh)
fi

# Install vim plugins
echo "Installing Vim plugins..."
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
vim +PluginInstall +qall

# Install tmux plugins
echo "Installing tmux plugins..."
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi
~/.tmux/plugins/tpm/scripts/install_plugins.sh

# Install powerlevel10k
echo "Installing Powerlevel10k..."
if [ ! -d ~/powerlevel10k ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
fi

echo "Setup complete!"
echo ""
echo "Please log out and log back in to complete the setup."