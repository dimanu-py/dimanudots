#!/bin/bash

has_packages() {
    local -a pkgs=("$@")
    [[ ${#pkgs[@]} -gt 0 && -n "${pkgs[*]}" ]]
}

run_installer() {
    local cmd="$1"
    shift
    $cmd ${NEEDED_FLAG:+$NEEDED_FLAG} -- "$@"
    echo
}

pacman_install() {
    has_packages "$@" || return 0
    print_section_header "Installing with pacman"
    run_installer "sudo pacman -Syu" "$@"
}

yay_install() {
    has_packages "$@" || return 0
    print_section_header "Installing with yay (AUR)"
    run_installer "yay -S" "$@"
}

warn_unknown_and_exit() {
    has_packages "$@" || return 0
    print_section_header "Done (with warnings)"
    echo "These packages were not found in pacman repos nor AUR:"
    printf ' - %s\n' "$@"
    exit 2
}
