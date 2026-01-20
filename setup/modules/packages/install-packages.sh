#!/bin/bash

install_packages() {
  local package_file="$1"

  _ensure_file_is_passed "$package_file"

  local -a unique_packages=()
  mapfile -t unique_packages < <(collect_packages "$package_file")

  local -a installed=() pacman_targets=() yay_targets=() unknown=()
  classify_packages unique_packages installed pacman_targets yay_targets unknown

  print_package_summary installed pacman_targets yay_targets unknown

  _install_with_pacman_if_needed pacman_targets
  _install_with_yay_if_needed yay_targets
}

_ensure_file_is_passed() {
  local file_path="${1:-}"
  if _is_empty "$file_path"; then
      die "Error: missing required argument: <packages_file>"
  fi
}

_is_empty() {
  local val="${1:-}"
  [[ -z "$val" ]]
}

_install_with_pacman_if_needed() {
  local -n _packages="$1"
  _has_packages _packages || return 0
  _ensure_pacman_is_installed
  pacman_install "${_packages[@]}"
}

_install_with_yay_if_needed() {
  local -n _packages="$1"
  _has_packages "${_packages[@]}" || return 0
  _ensure_yay_is_installed
  yay_install "${_packages[@]}"
}

_has_packages() {
  local -a pkgs=("$@")
  [[ ${#pkgs[@]} -gt 0 && -n "${pkgs[*]}" ]]
}

_ensure_pacman_is_installed() {
  verify_command_exists pacman
}

_ensure_yay_is_installed() {
  verify_command_exists yay
}
