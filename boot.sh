#!/bin/bash

set -euo pipefail

CLONE_DIR="$HOME/.local/share/dimanudots"

_git_is_installed() {
    command -v git >/dev/null 2>&1
}

_install_git() {
    if _git_is_installed; then
        return
    fi
    sudo pacman -Syu --noconfirm --needed git
}

_repository_is_already_cloned() {
    [[ -d "$CLONE_DIR/.git" ]]
}

_clone_dotfiles_repo() {
    local repo_url="https://github.com/dimanu-py/dimanudots.git"
    
    if _repository_is_already_cloned; then
        echo "dimanudots repository is already cloned in $CLONE_DIR, updating..."
        git -C "$CLONE_DIR" pull --rebase
        return
    fi
    git clone "$repo_url" "$CLONE_DIR"
}

_begin_dotfiles_installation() {
    _install_git
    _clone_dotfiles_repo
    echo -e "\nInstallation of dimanudots starting..."
    source "$CLONE_DIR/install.sh"
}

_begin_dotfiles_installation