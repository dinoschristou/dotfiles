#!/bin/bash

set -e

echo "🚀 Setting up Arch Linux dotfiles..."

# Update system
echo "📦 Updating system packages..."
sudo pacman -Syu --noconfirm

# Install essential packages
echo "🔧 Installing essential packages..."
sudo pacman -S --needed --noconfirm \
    base-devel git curl wget \
    zsh neovim vim \
    kitty tmux \
    hyprland hyprlock hypridle \
    waybar wofi mako swaybg \
    fastfetch btop lazygit \
    fzf ripgrep fd \
    nodejs npm \
    python python-pip \
    kubectl \
    github-cli

# Install AUR helper (yay)
if ! command -v yay &> /dev/null; then
    echo "🔨 Installing yay AUR helper..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
fi

# Install AUR packages
echo "📦 Installing AUR packages..."
yay -S --needed --noconfirm \
    google-cloud-cli \
    powerlevel10k-git \
    zsh-autosuggestions \
    zsh-fast-syntax-highlighting \
    google-chrome \
    visual-studio-code-bin \
    1password \
    obsidian

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

# Install Nerd Fonts
echo "🔤 Installing Nerd Fonts..."
cd /tmp
curl -fLo "JetBrainsMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
curl -fLo "FiraCode.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip
curl -fLo "CascadiaMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/CascadiaMono.zip
curl -fLo "iAWriter.zip" https://github.com/iaolo/iA-Fonts/archive/refs/heads/master.zip
unzip -o JetBrainsMono.zip -d ~/.local/share/fonts/
unzip -o FiraCode.zip -d ~/.local/share/fonts/
unzip -o CascadiaMono.zip -d ~/.local/share/fonts/
unzip -o iAWriter.zip -d ~/.local/share/fonts/
fc-cache -fv

# Install vim plugins
echo "📦 Installing Vim plugins..."
if [ ! -d ~/.vim/bundle/Vundle.vim ]; then
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
fi
vim +PluginInstall +qall

echo "✅ Arch Linux setup complete!"
echo ""
echo "🔄 Please log out and log back in to complete the setup."
echo "🎨 Your system is now configured with Catppuccin Macchiato theme!"