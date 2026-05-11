#!/bin/bash

# =============================================================
# mac_setup.sh — macOS defaults configuration script
# Run with: bash mac_setup.sh
# =============================================================

echo "🍎 Applying macOS settings..."

# ======================
# TRACKPAD
# ======================
echo "→ Configuring Trackpad..."

# Disable natural scroll direction
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Two-finger tap for secondary click (right-click)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# ======================
# SPOTLIGHT — disable shortcut
# ======================
echo "→ Disabling Spotlight shortcut..."

defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 64 "
  <dict>
    <key>enabled</key><false/>
    <key>value</key>
    <dict>
      <key>parameters</key>
      <array><integer>65535</integer><integer>65535</integer><integer>0</integer></array>
      <key>type</key><string>standard</string>
    </dict>
  </dict>
"

# ======================
# DOCK
# ======================
echo "→ Configuring Dock..."

# Position: left
defaults write com.apple.dock orientation -string "left"

# Size: small
defaults write com.apple.dock tilesize -int 32

# Magnification: off
defaults write com.apple.dock magnification -bool false

# Auto-hide
defaults write com.apple.dock autohide -bool true

# Remove all default Apple apps from Dock
defaults write com.apple.dock persistent-apps -array

# ======================
# STAGE MANAGER — disable
# ======================
echo "→ Disabling Stage Manager..."

defaults write com.apple.WindowManager GloballyEnabled -bool false

# ======================
# WIDGETS — disable on desktop & stage manager
# ======================
echo "→ Disabling Widgets..."

defaults write com.apple.WindowManager StandardHideWidgets -int 1
defaults write com.apple.WindowManager StageManagerHideWidgets -int 1

# ======================
# DESKTOP — hide volumes/drives
# ======================
echo "→ Hiding volumes from Desktop..."

defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false

# ======================
# FINDER
# ======================
echo "→ Configuring Finder..."

# Default to list view
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Open home folder by default
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

# ======================
# APPLY ALL CHANGES
# ======================
echo "→ Restarting affected services..."

killall Dock
killall Finder
killall SystemUIServer
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

echo ""
echo "✅ Done! You may need to log out and back in for all trackpad settings to take effect."
