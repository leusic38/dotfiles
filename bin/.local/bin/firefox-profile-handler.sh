#!/usr/bin/env bash
#
# Firefox profile chooser for externally opened links.
#
# Firefox only shows its profile selector on a cold start: once an instance is
# running, `firefox <url>` hands the URL to that instance and the profile is
# never asked for. This wrapper asks every time, whatever is already running.
#
# Used as the http/https handler (see firefox-profile-handler.desktop), as
# kitty's open_url_with, and as $BROWSER.
#
# Overridable for testing:
#   PROFILES_INI  path to profiles.ini
#   FIREFOX_CMD   command standing in for firefox
#   DMENU_CMD     command standing in for the picker

set -u

PROFILES_INI="${PROFILES_INI:-${HOME}/.mozilla/firefox/profiles.ini}"
FIREFOX_CMD="${FIREFOX_CMD:-firefox}"
DMENU_CMD="${DMENU_CMD:-dmenu -i -p 'Profil Firefox:'}"

# Profile names, in profiles.ini order. Only [ProfileN] sections carry a
# usable Name=; [General] and [Install...] must not leak into the list.
list_profiles() {
    awk '
        /^\[/                { in_profile = ($0 ~ /^\[Profile[0-9]+\]/); next }
        in_profile && /^Name=/ { sub(/^Name=/, ""); print }
    ' "${PROFILES_INI}"
}

if [ "${1:-}" = "--list-profiles" ]; then
    list_profiles
    exit 0
fi

url="${1:-}"

profiles="$(list_profiles)"

# Nothing to choose between: behave like plain firefox.
if [ -z "${profiles}" ]; then
    exec ${FIREFOX_CMD} ${url:+"${url}"}
fi

# No picker installed: let Firefox ask instead. The classic profile manager
# may drop the URL, hence dmenu being the preferred path.
if ! command -v "${DMENU_CMD%% *}" >/dev/null 2>&1; then
    exec ${FIREFOX_CMD} --ProfileManager ${url:+"${url}"}
fi

profile="$(printf '%s\n' "${profiles}" | eval "${DMENU_CMD}")"

# Dismissed with Escape: opening nothing is the correct answer.
[ -z "${profile}" ] && exit 0

# No MOZ_NO_REMOTE / --new-instance here on purpose: Firefox 138+ runs
# profiles concurrently, so this attaches to the chosen profile's instance
# when it exists and starts it otherwise. Forcing a new instance would fail
# on a profile lock in the common case.
exec ${FIREFOX_CMD} -P "${profile}" ${url:+"${url}"}
