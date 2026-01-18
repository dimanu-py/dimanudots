#!/bin/bash

OPENCODE_INSTALL_COMMAND="curl -fsSL https://opencode.ai/install | bash"

install_opencode() {
    eval "$OPENCODE_INSTALL_COMMAND"
    
    verify_command_exists opencode
}