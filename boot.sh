#!/bin/bash

set -euo pipefail

_install_git() {
    sudo pacman -Syu --noconfirm --needed git
}

_clone_dotfiles_repo() {
    local repo_url="https://github.com/dimanu-py/dimanudots.git"
    local clone_dir="$HOME/.local/share/dimanudots"
    git clone "$repo_url" "$clone_dir"
}

_begin_dotfiles_installation() {
    _install_git
    _clone_dotfiles_repo
    echo -e "\nInstallation of dimanudots starting..."
    source $HOME/.local/share/dimanudots/install.sh
}

_begin_dotfiles_installation