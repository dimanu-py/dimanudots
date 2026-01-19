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
  local package_file="$1"

  ensure_file_is_passed "$package_file"

  local -a unique_packages=()
  mapfile -t unique_packages < <(collect_packages "$package_file")

  local -a installed=() pacman_targets=() yay_targets=() unknown=()
  classify_packages unique_packages installed pacman_targets yay_targets unknown

  print_package_summary installed pacman_targets yay_targets unknown

  install_with_pacman_if_needed pacman_targets
  install_with_yay_if_needed yay_targets
}

ensure_file_is_passed() {
    local file_path="${1:-}"
    if [[ -z "$file_path" ]]; then
        echo "Error: missing required argument: <packages_file>" >&2
        exit 1
    fi
}

install_with_pacman_if_needed() {
  local -n pkgs="$1"
  if (( ${#pkgs[@]} == 0 )); then
    return 0
  fi

  sudo pacman -S --needed "${pkgs[@]}"
}

install_with_yay_if_needed() {
  local -n pkgs="$1"
  if (( ${#pkgs[@]} == 0 )); then
    return 0
  fi

  yay -S --needed "${pkgs[@]}"
}
