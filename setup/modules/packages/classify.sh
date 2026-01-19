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

is_installed() {
  local pkg="$1"
  pacman -Qi "$pkg" >/dev/null 2>&1
}

is_available_in_pacman() {
  local pkg="$1"
  pacman -Si "$pkg" >/dev/null 2>&1
}

is_available_in_yay() {
  local pkg="$1"
  command -v yay >/dev/null 2>&1 || return 1
  yay -Si "$pkg" >/dev/null 2>&1
}

print_package_summary() {
  local -n installed="$1"
  local -n pacman_targets="$2"
  local -n yay_targets="$3"
  local -n unknown="$4"

  print_list "Already installed" installed
  print_list "Will install with pacman" pacman_targets
  print_list "Will install with yay" yay_targets
  print_list "Unknown package (skipped)" unknown
}

print_list() {
  local title="$1"
  local -n items="$2"

  echo "==> $title:"
  if (( ${#items[@]} == 0 )); then
    echo "  (none)"
    return 0
  fi

  local item
  for item in "${items[@]}"; do
    echo "  - $item"
  done
}
