#!/bin/bash

set -euo pipefail


OPENCODE_INSTALL_COMMAND="curl -fsSL https://opencode.ai/install | bash"

verify_opencode_command_exists() {
    command -v opencode >/dev/null 2>&1 || die "opencode command not found after installation"
}

install_opencode() {
    eval "$OPENCODE_INSTALL_COMMAND"
    
    verify_opencode_command_exists
}

install_opencode