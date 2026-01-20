#!/bin/bash

classify_packages() {
  local -n packages="$1"
  local -n out_installed="$2"
  local -n out_pacman="$3"
  local -n out_yay="$4"
  local -n out_unknown="$5"

  local pkg
  for pkg in "${packages[@]}"; do
    if is_installed "$pkg"; then
      out_installed+=("$pkg")
      continue
    fi

    if is_available_in_pacman "$pkg"; then
      out_pacman+=("$pkg")
      continue
    fi

    if is_available_in_yay "$pkg"; then
      out_yay+=("$pkg")
      continue
    fi

    out_unknown+=("$pkg")
  done
}

is_available_in_pacman() {
  local pkg="$1"
  is_in_official_repos "$pkg"
}

is_available_in_yay() {
  local pkg="$1"
  verify_command_exists "yay" --die false || return 1
  is_in_aur "$pkg"
}

print_package_summary() {
  local -n _installed="$1"
  local -n _pacman_targets="$2"
  local -n _yay_targets="$3"
  local -n _unknown="$4"

  print_list "Already installed" _installed
  print_list "Will install with pacman" _pacman_targets
  print_list "Will install with yay" _yay_targets
  print_list "Unknown package (skipped)" _unknown
}

print_list() {
  local title="$1"
  local -n _items="$2"

  echo "==> $title:"
  if (( ${#_items[@]} == 0 )); then
    echo "  (none)"
    return 0
  fi

  local item
  for item in "${_items[@]}"; do
    echo "  - $item"
  done
}
