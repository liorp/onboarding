#!/bin/bash

APPLICATIONS_DIR="${APPLICATIONS_DIR:-/Applications}"
# How long to wait for an App Store install to land before giving up.
APP_STORE_WAIT_SECONDS="${APP_STORE_WAIT_SECONDS:-600}"

# Mac App Store apps as "App Name<TAB>store id<TAB>launch after install".
# Installing them needs your Apple ID, so open each missing one's store page
# and let you click Get.
APP_STORE_APPS="Xcode	497799835	no
Amphetamine	937984704	yes"

launch_app() {
    echo "Launching $1..."
    open -a "$APPLICATIONS_DIR/$1.app" || echo "WARNING: could not launch $1." >&2
}

# Wait in the foreground (never in the background) for an App Store install,
# so the person sees what is happening and can skip it with Ctrl-C.
wait_for_app() {
    local name="$1" waited=0

    if [ ! -t 0 ]; then
        echo "Launch $name yourself once the App Store finishes installing it."
        return 1
    fi

    echo "Waiting for $name to finish installing (click Get in the App Store; Ctrl-C to skip)..."
    while [ ! -d "$APPLICATIONS_DIR/$name.app" ]; do
        if [ "$waited" -ge "$APP_STORE_WAIT_SECONDS" ]; then
            echo "$name is not installed yet. Launch it yourself once it is."
            return 1
        fi
        sleep 5
        waited=$((waited + 5))
    done
    # Give the App Store a moment to finish writing the bundle.
    sleep 5
}

open_missing_app_store_apps() {
    local name id launch
    # Read the list on fd 3 so stdin stays the terminal for wait_for_app.
    while IFS=$'\t' read -r name id launch <&3; do
        if [ -d "$APPLICATIONS_DIR/$name.app" ]; then
            echo "$name already installed."
        else
            echo "Opening $name in the App Store; click Get to install it."
            open "macappstore://apps.apple.com/app/id$id"
            [ "$launch" = yes ] || continue
            wait_for_app "$name" || continue
        fi
        [ "$launch" = yes ] && launch_app "$name"
    done 3<<<"$APP_STORE_APPS"
}

open_manual_apps() {
    open_missing_app_store_apps

    echo "Opening Elasticvue (Chrome Extension)..."
    open -a "Google Chrome" "https://chrome.google.com/webstore/detail/elasticvue/hkedbapjpblbodpgbajblpnlpenaebaa"
}

open_manual_apps
