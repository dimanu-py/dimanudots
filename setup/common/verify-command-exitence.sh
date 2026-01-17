#!/bin/bash

set -euo pipefail

verify_command_exists() {
    local command="$1"

    command -v $command >/dev/null 2>&1 || die "$command command not found after installation"
}