#!/bin/bash

APPLICATIONS_DIR="${APPLICATIONS_DIR:-/Applications}"

# Mac App Store apps as "App Name<TAB>store id". Installing them needs your
# Apple ID, so open each missing one's store page and let you click Get.
APP_STORE_APPS="Xcode	497799835
Amphetamine	937984704"

open_missing_app_store_apps() {
    local name id
    while IFS=$'\t' read -r name id; do
        if [ -d "$APPLICATIONS_DIR/$name.app" ]; then
            echo "$name already installed. Skipping."
            continue
        fi
        echo "Opening $name in the App Store; click Get to install it."
        open "macappstore://apps.apple.com/app/id$id"
    done <<<"$APP_STORE_APPS"
}

open_manual_apps() {
    open_missing_app_store_apps

    echo "Opening Elasticvue (Chrome Extension)..."
    open -a "Google Chrome" "https://chrome.google.com/webstore/detail/elasticvue/hkedbapjpblbodpgbajblpnlpenaebaa"
}

open_manual_apps
