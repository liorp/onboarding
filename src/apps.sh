#!/bin/bash

# Print each third-party tap the Brewfile relies on as "name<TAB>url": explicit
# `tap` lines, plus taps implied by fully-qualified entries like "user/repo/pkg".
brewfile_taps() {
    local brewfile="$1"

    sed -nE 's/^tap "([^"]+)"[[:space:]]*,[[:space:]]*"([^"]+)".*/\1	\2/p' "$brewfile"
    sed -nE 's/^tap "([^"]+)"[[:space:]]*$/\1/p' "$brewfile"
    sed -nE 's/^(brew|cask) "([^"/]+\/[^"/]+)\/[^"]+".*/\2/p' "$brewfile"
}

# Resolve the list from brewfile_taps into unique "name<TAB>url" pairs,
# defaulting to GitHub's homebrew-<repo> convention when no URL is given.
# (awk rather than associative arrays: macOS ships Bash 3.2.)
resolve_taps() {
    awk -F '\t' '
        NF == 0 || $1 == "" { next }
        {
            if (!($1 in url)) order[++n] = $1
            if ($2 != "") url[$1] = $2
            else if (!($1 in url) || url[$1] == "") {
                split($1, parts, "/")
                url[$1] = ""
                fallback[$1] = "https://github.com/" parts[1] "/homebrew-" parts[2]
            }
        }
        END {
            for (i = 1; i <= n; i++) {
                name = order[i]
                printf "%s\t%s\n", name, (url[name] != "" ? url[name] : fallback[name])
            }
        }'
}

tap_reachable() {
    local name="$1" url="$2"
    local tap_dir
    tap_dir="$(brew --repository)/Library/Taps/${name%%/*}/homebrew-${name#*/}"

    # Already tapped: brew bundle will not clone it again.
    [ -d "$tap_dir" ] && return 0

    # Never let git prompt for credentials; GitHub asks for them on missing repos.
    GIT_TERMINAL_PROMPT=0 GIT_ASKPASS=/bin/false \
        git ls-remote --quiet --exit-code "$url" HEAD >/dev/null 2>&1
}

tap_if_missing() {
    local name="$1" url="$2"
    [ -d "$(brew --repository)/Library/Taps/${name%%/*}/homebrew-${name#*/}" ] && return 0
    brew tap "$name" "$url"
}

# Homebrew 7+ refuses to load packages from non-official taps until they are
# trusted. Trust exactly the fully-qualified packages the Brewfile names, not
# whole taps, so nothing else from those taps becomes loadable.
trust_brewfile_packages() {
    local brewfile="$1"
    local formulae casks

    brew trust --help >/dev/null 2>&1 || return 0

    formulae="$(sed -nE 's/^brew "([^"/]+\/[^"/]+\/[^"]+)".*/\1/p' "$brewfile")"
    casks="$(sed -nE 's/^cask "([^"/]+\/[^"/]+\/[^"]+)".*/\1/p' "$brewfile")"

    # shellcheck disable=SC2086  # one package name per word
    [ -z "$formulae" ] || brew trust --quiet --formula $formulae
    # shellcheck disable=SC2086
    [ -z "$casks" ] || brew trust --quiet --cask $casks
}

# Xcode needs its license accepted and extra components installed on first
# launch before command-line tools can use it.
finish_xcode_setup() {
    local xcode="${XCODE_APP:-/Applications/Xcode.app}"
    local xcodebuild="$xcode/Contents/Developer/usr/bin/xcodebuild"

    [ -x "$xcodebuild" ] || return 0
    "$xcodebuild" -checkFirstLaunchStatus >/dev/null 2>&1 && return 0

    if [ -t 0 ]; then
        echo "Finishing Xcode setup (license and components; requires your password)..."
        sudo "$xcodebuild" -runFirstLaunch && return 0
    fi

    echo "WARNING: Xcode is installed but not set up yet. Finish it with:" >&2
    echo "  sudo \"$xcodebuild\" -runFirstLaunch" >&2
}

# Menu bar apps that do nothing until launched once; start them right away.
LAUNCH_AFTER_INSTALL="Maccy CodexBar"

launch_installed_apps() {
    local apps_dir="${APPLICATIONS_DIR:-/Applications}" app
    for app in $LAUNCH_AFTER_INSTALL; do
        if [ -d "$apps_dir/$app.app" ]; then
            echo "Launching $app..."
            open -a "$apps_dir/$app.app" || echo "WARNING: could not launch $app." >&2
        fi
    done
}

install_apps() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local brewfile="$script_dir/../Brewfile"

    if ! command -v brew >/dev/null 2>&1; then
        echo "Homebrew is required to install apps. Run the brew step first." >&2
        return 1
    fi

    if [ ! -f "$brewfile" ]; then
        echo "Brewfile not found at $brewfile." >&2
        return 1
    fi

    # A single unreachable tap makes `brew bundle` abort before installing
    # anything, so drop such taps (and their packages) and install the rest.
    local filtered name url escaped
    local skipped=()
    filtered="$(mktemp)"
    cp "$brewfile" "$filtered"

    while IFS=$'\t' read -r name url; do
        if tap_reachable "$name" "$url"; then
            tap_if_missing "$name" "$url"
            continue
        fi
        skipped+=("$name ($url)")
        escaped="$(printf '%s' "$name" | sed 's/[.[\*^$/]/\\&/g')"
        sed -i.bak -E "/^tap \"$escaped\"/d; /^(brew|cask) \"$escaped\//d" "$filtered"
    done < <(brewfile_taps "$brewfile" | resolve_taps)
    rm -f "$filtered.bak"

    trust_brewfile_packages "$filtered"

    local status=0
    brew bundle --file="$filtered" || status=$?
    rm -f "$filtered"
    finish_xcode_setup
    launch_installed_apps

    if [ "${#skipped[@]}" -gt 0 ]; then
        echo "" >&2
        echo "WARNING: skipped unreachable Homebrew taps and the apps they provide:" >&2
        printf '  - %s\n' "${skipped[@]}" >&2
        echo "Update the tap URL in the Brewfile, then re-run the apps step." >&2
        [ "$status" -ne 0 ] || status=1
    fi

    return "$status"
}

install_apps
