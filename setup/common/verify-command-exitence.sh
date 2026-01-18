#!/bin/bash

set -euo pipefail

verify_command_exists() {
    local command="$1"

    command -v "$command" >/dev/null 2>&1 || exit-with-error "$command command not found"
}

verify_command_exists "$@"