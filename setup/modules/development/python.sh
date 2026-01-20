#!/bin/bash

UV_INSTALL_COMMAND="curl -LsSf https://astral.sh/uv/install.sh | sh"

install_uv() {
  eval "$UV_INSTALL_COMMAND"

  source "$HOME/.cargo/env" 2>/dev/null || true

  verify_command_exists uv
}