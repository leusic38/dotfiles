#!/usr/bin/env bash

# PhpStorm URL Handler (fixed)
# phpstorm://open?url=file://@file&line=@line
# phpstorm://open?file=@file&line=@line
# phpstorm://open?url=file://@file:@line
# phpstorm://open?file=@file:line
#
# Based on /usr/bin/phpstorm-url-handler (pkg phpstorm-url-handler 1.5.0-1),
# fixed for PhpStorm 2026.2's native launcher which now rejects "--line"
# unless preceded by a project directory argument.

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

arg=$(urldecode "${1}")
pattern=".*file(:\/\/|\=)(.*)(:|&line=)(.*)"

# Get the file path.
file=$(echo "${arg}" | sed -r "s/${pattern}/\2/")

# Get the line number.
line=$(echo "${arg}" | sed -r "s/${pattern}/\4/")

# Find the project root by walking up looking for .git first (the
# reliable top-level marker), then .idea, falling back to the file's
# own directory. .git is checked in its own full pass before .idea:
# a stray/nested .idea (e.g. a subfolder once opened standalone in
# PhpStorm) must not shadow the real repo root found further up.
function find_project_root() {
    local dir marker
    for marker in .git .idea; do
        dir=$(dirname "${1}")
        while [ "${dir}" != "/" ]; do
            if [ -d "${dir}/${marker}" ]; then
                echo "${dir}"
                return
            fi
            dir=$(dirname "${dir}")
        done
    done
    dirname "${1}"
}

project=$(find_project_root "${file}")

if type phpstorm > /dev/null 2>&1; then
    /usr/bin/env phpstorm "${project}" --line "${line}" "${file}"
elif type pstorm > /dev/null 2>&1; then
    /usr/bin/env pstorm "${project}" --line "${line}" "${file}"
fi

if type wmctrl > /dev/null 2>&1; then
    filename=$(basename "${file}")
    /usr/bin/env wmctrl -i -a $(wmctrl -l | grep "${filename}" | tail -n 1 | cut -d ' ' -f1)
fi

exit 0
