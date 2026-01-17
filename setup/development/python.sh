#!/bin/bash

set -euo pipefail

UV_INSTALL_COMMAND="curl -LsSf https://astral.sh/uv/install.sh | sh"

verify_uv_command_exists() {
    command -v uv >/dev/null 2>&1 || die "uv command not found after installation"
}

install_uv() {
    eval "$UV_INSTALL_COMMAND"
    
    source "$HOME/.cargo/env" 2>/dev/null || true
    
    verify_uv_command_exists
}

install_uv