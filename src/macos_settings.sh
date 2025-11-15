#!/bin/bash

SYMBOLIC_HOTKEYS_PLIST="$HOME/Library/Preferences/com.apple.symbolichotkeys.plist"
PLIST_BUDDY="/usr/libexec/PlistBuddy"

enable_tap_to_click() {
    echo "Enabling tap-to-click for trackpads..."
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
}

sync_desktop_and_documents_to_icloud() {
    echo "Syncing Desktop and Documents with iCloud Drive..."
    defaults write com.apple.finder FXICloudDriveDesktop -bool true
    defaults write com.apple.finder FXICloudDriveDocuments -bool true
    killall Finder >/dev/null 2>&1 || true
}

enable_auto_hide_dock() {
    echo "Enabling Dock auto-hide..."
    defaults write com.apple.dock autohide -bool true
    killall Dock >/dev/null 2>&1 || true
}

ensure_symbolic_hotkeys_plist() {
    if [ ! -f "$SYMBOLIC_HOTKEYS_PLIST" ]; then
        defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict
    fi
}

set_symbolic_hotkey() {
    local hotkey_id="$1"
    local key_code="$2"
    local modifier_flags="$3"
    local char_code="${4:-32}"

    ensure_symbolic_hotkeys_plist
    "$PLIST_BUDDY" -c "Delete :AppleSymbolicHotKeys:${hotkey_id}" "$SYMBOLIC_HOTKEYS_PLIST" >/dev/null 2>&1
    "$PLIST_BUDDY" -c "Add :AppleSymbolicHotKeys:${hotkey_id} dict" "$SYMBOLIC_HOTKEYS_PLIST"
    "$PLIST_BUDDY" -c "Add :AppleSymbolicHotKeys:${hotkey_id}:enabled bool true" "$SYMBOLIC_HOTKEYS_PLIST"
    "$PLIST_BUDDY" -c "Add :AppleSymbolicHotKeys:${hotkey_id}:value dict" "$SYMBOLIC_HOTKEYS_PLIST"
    "$PLIST_BUDDY" -c "Add :AppleSymbolicHotKeys:${hotkey_id}:value:type string standard" "$SYMBOLIC_HOTKEYS_PLIST"
    "$PLIST_BUDDY" -c "Add :AppleSymbolicHotKeys:${hotkey_id}:value:parameters array" "$SYMBOLIC_HOTKEYS_PLIST"
    "$PLIST_BUDDY" -c "Add :AppleSymbolicHotKeys:${hotkey_id}:value:parameters:0 integer ${char_code}" "$SYMBOLIC_HOTKEYS_PLIST"
    "$PLIST_BUDDY" -c "Add :AppleSymbolicHotKeys:${hotkey_id}:value:parameters:1 integer ${key_code}" "$SYMBOLIC_HOTKEYS_PLIST"
    "$PLIST_BUDDY" -c "Add :AppleSymbolicHotKeys:${hotkey_id}:value:parameters:2 integer ${modifier_flags}" "$SYMBOLIC_HOTKEYS_PLIST"
}

configure_keyboard_shortcuts() {
    echo "Setting language switch shortcut to Command+Space..."
    set_symbolic_hotkey 60 49 1048576

    echo "Setting Spotlight shortcut to Option+Space..."
    set_symbolic_hotkey 64 49 524288
}

apply_macos_settings() {
    echo "Applying macOS system settings..."
    enable_tap_to_click
    sync_desktop_and_documents_to_icloud
    enable_auto_hide_dock
    configure_keyboard_shortcuts
    echo "macOS settings applied. A logout/login may be required for some changes."
}

apply_macos_settings
