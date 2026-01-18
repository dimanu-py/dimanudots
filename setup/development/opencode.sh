#!/bin/bash

set -euo pipefail

OPENCODE_INSTALL_COMMAND="curl -fsSL https://opencode.ai/install | bash"

install_opencode() {
    eval "$OPENCODE_INSTALL_COMMAND"
    
    verify-command-exists opencode
}

install_opencode