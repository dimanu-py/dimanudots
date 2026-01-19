#!/bin/bash

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
    if is_empty "$file_path"; then
        die "Error: missing required argument: <packages_file>"
    fi
}

is_empty() {
    local val="${1:-}"
    [[ -z "$val" ]]
}

install_with_pacman_if_needed() {
  local -n _packages="$1"
  ensure_packages_has_values _packages
  ensure_pacman_is_installed
  pacman_install "${_packages[@]}"
}

install_with_yay_if_needed() {
  local -n _packages="$1"
  ensure_packages_has_values _packages
  ensure_yay_is_installed
  yay_install "${_packages[@]}"
}

ensure_packages_has_values() {
  local -n pkgs="$1"
  if ! has_packages "${pkgs[@]}"; then
    die "Error: no packages to install."
  fi
}

has_packages() {
    local -a pkgs=("$@")
    [[ ${#pkgs[@]} -gt 0 && -n "${pkgs[*]}" ]]
}

ensure_pacman_is_installed() {
  verify_command_exists pacman
}

ensure_yay_is_installed() {
  verify_command_exists yay
}
