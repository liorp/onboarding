#!/bin/bash

enable_tap_to_click() {
    echo "Enabling tap-to-click for trackpads..."
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
}

apply_macos_settings() {
    echo "Applying macOS system settings..."
    enable_tap_to_click
    echo "macOS settings applied. A logout/login may be required for some changes."
}

apply_macos_settings
