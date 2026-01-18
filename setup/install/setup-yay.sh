#!/bin/bash

set -euo pipefail

YAY_BUILD_DIR="/tmp/yay"
YAY_GIT_REPO_URL="https://aur.archlinux.org/yay.git"

yay_is_installed() {
    verify-command-exists "yay"
}

clean_up_existing_build_directory() {
    local build_dir="$1"
    
    if [ -d "$build_dir" ]; then
        rm -rf "$build_dir"
    fi
}

set_build_dir_owner_to_current_user() {
    local build_dir="$1"
    local current_user

    current_user=$(logname || echo "$SUDO_USER")
    if [[ -n "$current_user" ]]; then
        chown "$current_user:$current_user" "$build_dir"
    fi
}

create_build_directory() {
    local build_dir="$1"

    clean_up_existing_build_directory "$build_dir"
    create-directory-with-permissions "$build_dir" 0755
    set_build_dir_owner_to_current_user "$build_dir"
}

clone_yay_repository() {
    local build_dir="$1"
    
    cd "$build_dir"
    git clone "$YAY_GIT_REPO_URL" .
}

build_and_install_yay() {
    makepkg -si
}

cleanup_build_directory() {
    local build_dir="$1"
    
    cd /
    rm -rf "$build_dir"
}

verify_yay_installation() {
    if yay_is_installed; then
        echo "yay installed successfully"
        return 0
    else
        echo "yay installation failed" >&2
        return 1
    fi
}

setup_yay() {
    if yay_is_installed; then
        echo "yay is already installed"
        exit 0
    fi
    
    echo "yay not found, installing yay..."
    
    create_build_directory "$YAY_BUILD_DIR"
    clone_yay_repository "$YAY_BUILD_DIR"
    build_and_install_yay
    cleanup_build_directory "$YAY_BUILD_DIR"
    verify_yay_installation
}

setup_yay "$@"