#!/bin/bash

ensure_pacman_is_installed() {
  verify_command_exists pacman
}

ensure_yay_is_installed() {
  verify_command_exists yay
}

has_packages() {
    local -a pkgs=("$@")
    [[ ${#pkgs[@]} -gt 0 && -n "${pkgs[*]}" ]]
}

print_section_header() {
    local title="$1"
    echo "== $title =="
}

install_with_pacman() {
    has_packages "$@" || return 0
    ensure_pacman_is_installed
    print_section_header "Installing with pacman"
    pacman_install "$@"
}

install_with_yay() {
    has_packages "$@" || return 0
    ensure_yay_is_installed
    print_section_header "Installing with yay (AUR)"
    yay_install "$@"
}

warn_unknown_and_exit() {
    has_packages "$@" || return 0
    print_section_header "Done (with warnings)"
    echo "These packages were not found in pacman repos nor AUR:"
    printf ' - %s\n' "$@"
    exit 2
}

install_packages() {
    parse_args "$@"
    mapfile -t all_packages < <(collect_packages "${CLI_PACKAGES[@]}")

    local plan
    plan="$(plan_installation "${all_packages[@]}")"

    IFS=$'\0' read -r installed_block pacman_block aur_block unknown_block <<<"$plan" || true

    mapfile -t already_installed < <(printf '%s\n' "$installed_block" | sed '/^$/d')
    mapfile -t pacman < <(printf '%s\n' "$pacman_block" | sed '/^$/d')
    mapfile -t aur_yay < <(printf '%s\n' "$aur_block" | sed '/^$/d')
    mapfile -t unknown_packages < <(printf '%s\n' "$unknown_block" | sed '/^$/d')

    print_plan "${already_installed[*]}" "${pacman[*]}" "${aur_yay[*]}" "${unknown_packages[*]}"

    install_with_pacman "${pacman[@]}"
    install_with_yay "${aur_yay[@]}"
    warn_unknown_and_exit "${unknown_packages[@]}"
}