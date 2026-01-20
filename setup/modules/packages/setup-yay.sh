#!/bin/bash

YAY_BUILD_DIR="/tmp/yay"
YAY_GIT_REPO_URL="https://aur.archlinux.org/yay-git.git"

setup_yay() {
  if _yay_is_installed "false"; then
      echo "yay is already installed"
      return 0
  fi

  echo "yay not found, installing yay..."

  _create_build_directory "$YAY_BUILD_DIR"
  _clone_yay_repository "$YAY_BUILD_DIR"
  _build_and_install_yay
  _cleanup_build_directory "$YAY_BUILD_DIR"
  _verify_yay_installation
}

_yay_is_installed() {
  local should_die="${1:-false}"
  verify_command_exists "yay" --die "$should_die"
}

_create_build_directory() {
  local build_dir="$1"

  _clean_up_existing_build_directory "$build_dir"
  create_directory_with_permissions "$build_dir" 0755
  _set_build_dir_owner_to_current_user "$build_dir"
}

_clean_up_existing_build_directory() {
  local build_dir="$1"

  if [ -d "$build_dir" ]; then
      rm -rf "$build_dir"
  fi
}

_set_build_dir_owner_to_current_user() {
  local build_dir="$1"
  local current_user

  current_user=$(logname || echo "$SUDO_USER")
  if [[ -n "$current_user" ]]; then
      set_owner "$current_user" "$build_dir"
  fi
}

_clone_yay_repository() {
  local build_dir="$1"

  cd "$build_dir"
  git clone "$YAY_GIT_REPO_URL" .
}

_build_and_install_yay() {
  makepkg -si --noconfirm
}

_cleanup_build_directory() {
  local build_dir="$1"

  cd /
  rm -rf "$build_dir"
}

_verify_yay_installation() {
  if _yay_is_installed "true"; then
      echo "yay installed successfully"
      return 0
  else
      die "yay installation failed"
  fi
}