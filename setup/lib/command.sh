#!/bin/bash

verify_command_exists() {
    local command="$1"

    command -v "$command" >/dev/null 2>&1 || die "$command command not found"
}

run_installer() {
    local cmd="$1"
    shift
    $cmd ${NEEDED_FLAG:+$NEEDED_FLAG} -- "$@"
    echo
}