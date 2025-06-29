#!/bin/bash

# Desktop entry creation script

create_desktop_entries() {
    if [[ "$OS_TYPE" != "Linux" ]]; then
        log_debug "Desktop entries are only created on Linux"
        return 0
    fi

    log_step "Creating desktop entries"

    # Create directories
    setup_desktop_directories

    # Create application desktop entries
    create_application_entries

    # Create PWA entries for web applications
    create_pwa_entries

    # Create session files for display managers
    create_session_files

    # Configure MIME types
    configure_mime_types

    # Update desktop database
    update_desktop_database

    log_success "Desktop entries created successfully"
}

setup_desktop_directories() {
    log_info "Setting up desktop directories..."

    # Create user application directory
    mkdir -p "$HOME/.local/share/applications"

    # Create user desktop entries directory
    mkdir -p "$HOME/.local/share/desktop-directories"

    # Create MIME directory
    mkdir -p "$HOME/.local/share/mime/packages"

    log_success "Desktop directories created"
}

create_application_entries() {
    log_info "Creating application desktop entries..."

    # Kitty terminal with custom config
    create_kitty_entry

    # Neovim desktop entry
    create_neovim_entry

    # Development workspace launcher
    create_dev_workspace_entry

    # Hyprland configuration editor
    create_config_editor_entry

    log_success "Application desktop entries created"
}

create_pwa_entries() {
    log_info "Creating PWA desktop entries..."

    # Determine browser command
    local browser_cmd=""
    if command_exists "google-chrome"; then
        browser_cmd="google-chrome"
    elif command_exists "chromium"; then
        browser_cmd="chromium"
    elif command_exists "firefox"; then
        browser_cmd="firefox"
    else
        log_warn "No supported browser found for PWAs"
        return 1
    fi

    # Create PWA entries for various web applications
    create_gmail_pwa "$browser_cmd"
    create_google_calendar_pwa "$browser_cmd"
    create_youtube_music_pwa "$browser_cmd"
    create_whatsapp_pwa "$browser_cmd"
    create_google_photos_pwa "$browser_cmd"
    create_chatgpt_pwa "$browser_cmd"
    create_gemini_pwa "$browser_cmd"

    log_success "PWA desktop entries created"
}

create_gmail_pwa() {
    local browser="$1"
    local desktop_file="$HOME/.local/share/applications/gmail-pwa.desktop"
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Gmail
Comment=Google Gmail web application
Icon=mail-client
Exec=$browser --app=https://mail.google.com --class=gmail-pwa
Categories=Network;Email;
Keywords=email;mail;google;gmail;
StartupWMClass=gmail-pwa
StartupNotify=true
EOF

    log_debug "Created Gmail PWA entry"
}

create_google_calendar_pwa() {
    local browser="$1"
    local desktop_file="$HOME/.local/share/applications/google-calendar-pwa.desktop"
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Calendar
Comment=Google Calendar web application
Icon=office-calendar
Exec=$browser --app=https://calendar.google.com --class=google-calendar-pwa
Categories=Office;Calendar;
Keywords=calendar;google;schedule;appointments;
StartupWMClass=google-calendar-pwa
StartupNotify=true
EOF

    log_debug "Created Google Calendar PWA entry"
}

create_youtube_music_pwa() {
    local browser="$1"
    local desktop_file="$HOME/.local/share/applications/youtube-music-pwa.desktop"
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=YouTube Music
Comment=YouTube Music web application
Icon=multimedia-audio-player
Exec=$browser --app=https://music.youtube.com --class=youtube-music-pwa
Categories=AudioVideo;Audio;Music;
Keywords=music;youtube;streaming;audio;
StartupWMClass=youtube-music-pwa
StartupNotify=true
EOF

    log_debug "Created YouTube Music PWA entry"
}

create_whatsapp_pwa() {
    local browser="$1"
    local desktop_file="$HOME/.local/share/applications/whatsapp-pwa.desktop"
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=WhatsApp
Comment=WhatsApp web application
Icon=network-chat
Exec=$browser --app=https://web.whatsapp.com --class=whatsapp-pwa
Categories=Network;InstantMessaging;
Keywords=chat;messaging;whatsapp;communication;
StartupWMClass=whatsapp-pwa
StartupNotify=true
EOF

    log_debug "Created WhatsApp PWA entry"
}

create_google_photos_pwa() {
    local browser="$1"
    local desktop_file="$HOME/.local/share/applications/google-photos-pwa.desktop"
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Google Photos
Comment=Google Photos web application
Icon=camera-photo
Exec=$browser --app=https://photos.google.com --class=google-photos-pwa
Categories=Graphics;Photography;
Keywords=photos;google;images;gallery;
StartupWMClass=google-photos-pwa
StartupNotify=true
EOF

    log_debug "Created Google Photos PWA entry"
}

create_chatgpt_pwa() {
    local browser="$1"
    local desktop_file="$HOME/.local/share/applications/chatgpt-pwa.desktop"
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=ChatGPT
Comment=OpenAI ChatGPT web application
Icon=text-editor
Exec=$browser --app=https://chat.openai.com --class=chatgpt-pwa
Categories=Development;Utility;Education;
Keywords=ai;chatgpt;openai;assistant;chat;
StartupWMClass=chatgpt-pwa
StartupNotify=true
EOF

    log_debug "Created ChatGPT PWA entry"
}

create_gemini_pwa() {
    local browser="$1"
    local desktop_file="$HOME/.local/share/applications/gemini-pwa.desktop"
    
    cat > "$desktop_file" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Gemini
Comment=Google Gemini AI web application
Icon=text-editor
Exec=$browser --app=https://gemini.google.com --class=gemini-pwa
Categories=Development;Utility;Education;
Keywords=ai;gemini;google;assistant;chat;
StartupWMClass=gemini-pwa
StartupNotify=true
EOF

    log_debug "Created Gemini PWA entry"
}

create_kitty_entry() {
    local desktop_file="$HOME/.local/share/applications/kitty-dotfiles.desktop"
    
    cat > "$desktop_file" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Kitty (Dotfiles)
Comment=Fast, feature-rich, cross-platform, GPU-based terminal
Icon=kitty
Exec=kitty --config=%h/.config/kitty/kitty.conf
Categories=System;TerminalEmulator;
Keywords=shell;prompt;command;commandline;cmd;
StartupWMClass=kitty
StartupNotify=true
EOF

    log_debug "Created Kitty desktop entry"
}

create_neovim_entry() {
    local desktop_file="$HOME/.local/share/applications/neovim-dotfiles.desktop"
    
    cat > "$desktop_file" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Neovim (Dotfiles)
Comment=Vim-based text editor with custom configuration
Icon=nvim
Exec=kitty --class=neovim nvim %F
NoDisplay=false
Categories=Utility;TextEditor;Development;
Keywords=text;editor;vim;neovim;
MimeType=text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;text/x-chdr;text/x-csrc;text/x-java;text/x-moc;text/x-pascal;text/x-tcl;text/x-tex;application/x-shellscript;text/x-c;text/x-c++;text/markdown;text/x-python;text/x-go;text/x-rust;application/json;text/x-yaml;text/x-toml;
StartupWMClass=neovim
StartupNotify=true
EOF

    log_debug "Created Neovim desktop entry"
}

create_dev_workspace_entry() {
    local desktop_file="$HOME/.local/share/applications/dev-workspace.desktop"
    
    cat > "$desktop_file" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Development Workspace
Comment=Launch development environment with tmux
Icon=utilities-terminal
Exec=kitty --title="Development" tmux new-session -s dev
Categories=Development;System;
Keywords=development;tmux;workspace;terminal;
StartupWMClass=kitty
StartupNotify=true
EOF

    log_debug "Created Development Workspace desktop entry"
}

create_config_editor_entry() {
    local desktop_file="$HOME/.local/share/applications/dotfiles-config.desktop"
    
    cat > "$desktop_file" << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Dotfiles Configuration
Comment=Edit dotfiles configuration
Icon=text-editor
Exec=kitty --title="Dotfiles Config" nvim %h/.config
Categories=Settings;Development;
Keywords=dotfiles;config;configuration;settings;
StartupWMClass=kitty
StartupNotify=true
EOF

    log_debug "Created Dotfiles Configuration desktop entry"
}

create_session_files() {
    log_info "Creating session files for display managers..."

    # Only create session files if we have the window managers installed
    create_hyprland_session
    create_sway_session

    log_success "Session files created"
}

create_hyprland_session() {
    if command_exists "hyprland"; then
        local session_file="/usr/share/wayland-sessions/hyprland-dotfiles.desktop"
        
        # Create session file with sudo
        sudo tee "$session_file" > /dev/null << EOF
[Desktop Entry]
Name=Hyprland (Dotfiles)
Comment=Hyprland compositor with custom dotfiles configuration
Exec=hyprland
Type=Application
DesktopNames=Hyprland
EOF

        log_debug "Created Hyprland session file"
    else
        log_debug "Hyprland not installed, skipping session file"
    fi
}

create_sway_session() {
    if command_exists "sway"; then
        local session_file="/usr/share/wayland-sessions/sway-dotfiles.desktop"
        
        # Create session file with sudo
        sudo tee "$session_file" > /dev/null << EOF
[Desktop Entry]
Name=Sway (Dotfiles)
Comment=Sway compositor with custom dotfiles configuration
Exec=sway
Type=Application
DesktopNames=sway
EOF

        log_debug "Created Sway session file"
    else
        log_debug "Sway not installed, skipping session file"
    fi
}

configure_mime_types() {
    log_info "Configuring MIME type associations..."

    local mimeapps_file="$HOME/.config/mimeapps.list"
    
    # Create MIME associations file
    cat > "$mimeapps_file" << 'EOF'
[Default Applications]
text/plain=neovim-dotfiles.desktop
text/x-shellscript=neovim-dotfiles.desktop
application/json=neovim-dotfiles.desktop
text/x-python=neovim-dotfiles.desktop
text/x-go=neovim-dotfiles.desktop
text/x-rust=neovim-dotfiles.desktop
text/markdown=neovim-dotfiles.desktop
text/x-yaml=neovim-dotfiles.desktop
text/x-toml=neovim-dotfiles.desktop
text/x-makefile=neovim-dotfiles.desktop
application/x-shellscript=neovim-dotfiles.desktop
text/x-c=neovim-dotfiles.desktop
text/x-c++=neovim-dotfiles.desktop
text/x-javascript=neovim-dotfiles.desktop
text/x-typescript=neovim-dotfiles.desktop

[Added Associations]
text/plain=neovim-dotfiles.desktop;
text/x-shellscript=neovim-dotfiles.desktop;
application/json=neovim-dotfiles.desktop;
text/x-python=neovim-dotfiles.desktop;
text/x-go=neovim-dotfiles.desktop;
text/x-rust=neovim-dotfiles.desktop;
text/markdown=neovim-dotfiles.desktop;
text/x-yaml=neovim-dotfiles.desktop;
text/x-toml=neovim-dotfiles.desktop;
EOF

    log_success "MIME type associations configured"
}

update_desktop_database() {
    log_info "Updating desktop database..."

    # Update desktop database
    if command_exists "update-desktop-database"; then
        update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
        log_debug "Updated desktop database"
    fi

    # Update MIME database
    if command_exists "update-mime-database"; then
        update-mime-database "$HOME/.local/share/mime" 2>/dev/null || true
        log_debug "Updated MIME database"
    fi

    # Update icon cache
    if command_exists "gtk-update-icon-cache"; then
        gtk-update-icon-cache -f -t "$HOME/.local/share/icons" 2>/dev/null || true
        log_debug "Updated icon cache"
    fi

    log_success "Desktop database updated"
}

# Configure default applications
configure_default_applications() {
    log_info "Configuring default applications..."

    # Set default terminal
    set_default_terminal

    # Set default editor
    set_default_editor

    log_success "Default applications configured"
}

set_default_terminal() {
    if command_exists "kitty"; then
        # Create terminal alternatives entry
        sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$(which kitty)" 50 2>/dev/null || true
        log_debug "Set kitty as terminal alternative"
    fi
}

set_default_editor() {
    if command_exists "nvim"; then
        # Set environment variables for default editor
        local editor_config="$HOME/.config/environment.d/editor.conf"
        mkdir -p "$(dirname "$editor_config")"
        
        cat > "$editor_config" << 'EOF'
EDITOR=nvim
VISUAL=nvim
EOF

        log_debug "Set neovim as default editor"
    fi
}

# Install additional desktop utilities
install_desktop_utilities() {
    log_info "Installing additional desktop utilities..."

    # Install xdg-utils for proper desktop integration
    install_package_if_missing "xdg-utils" "$OS_NAME"

    # Install desktop file utilities
    case "$OS_NAME" in
        "Ubuntu"|"Debian")
            install_package_if_missing "desktop-file-utils" "$OS_NAME"
            ;;
        "Arch")
            install_package_if_missing "desktop-file-utils" "$OS_NAME"
            ;;
        "Fedora")
            install_package_if_missing "desktop-file-utils" "$OS_NAME"
            ;;
    esac

    log_success "Desktop utilities installed"
}