#!/bin/bash

# macOS system preferences configuration
# Run once on new machine setup

echo "Configuring macOS settings..."

# ===================
# Keyboard
# ===================
# Faster key repeat (current: 15/2)
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain KeyRepeat -int 2

# Disable press-and-hold for accents menu (enable key repeat)
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# ===================
# Dock
# ===================
# Auto-hide dock
defaults write com.apple.dock autohide -int 1

# Remove dock auto-hide delay
defaults write com.apple.dock autohide-delay -float 0.0

# Remove dock animation
defaults write com.apple.dock autohide-time-modifier -float 0.0

# ===================
# Finder
# ===================
# Show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Disable warning when changing file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true

# ===================
# Desktop (Sonoma+)
# ===================
# Disable click wallpaper to show desktop
defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false 2>/dev/null || true

# ===================
# Apply changes
# ===================
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

echo "macOS settings configured!"
