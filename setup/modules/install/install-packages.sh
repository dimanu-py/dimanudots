#!/bin/bash

# -e: Exit immediately if any command exits with a non-zero status
# -u: Exit if an undefined variable is referenced
# -o pipefail: Exit if any command in a pipeline fails (not just the last one)
set -euo pipefail

ensure_pacman_and_yay_are_installed() {
  verify-command-exists pacman
  verify-command-exists yay
}

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

print_section_header() {
    local title="$1"
    echo "== $title =="
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

install_packages() {
    args-parser "$@"
    ensure_pacman_and_yay_are_installed
    mapfile -t all_packages < <(collect-packages "${CLI_PACKAGES[@]}")

    local plan
    plan="$(classify plan "${all_packages[@]}")"

    IFS=$'\0' read -r installed_block pacman_block aur_block unknown_block <<<"$plan" || true

    mapfile -t already_installed < <(printf '%s\n' "$installed_block" | sed '/^$/d')
    mapfile -t pacman < <(printf '%s\n' "$pacman_block" | sed '/^$/d')
    mapfile -t aur_yay < <(printf '%s\n' "$aur_block" | sed '/^$/d')
    mapfile -t unknown_packages < <(printf '%s\n' "$unknown_block" | sed '/^$/d')

    classify print "${already_installed[*]}" "${pacman[*]}" "${aur_yay[*]}" "${unknown_packages[*]}"

    pacman_install "${pacman[@]}"
    yay_install "${aur_yay[@]}"
    warn_unknown_and_exit "${unknown_packages[@]}"
}

install_packages "$@"