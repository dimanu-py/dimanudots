#!/bin/bash

SELECTED_CONFIG_PACKAGES=(
  bat
  btop
  elephant
  fastfetch
  fcitx5
  flameshot
  ghostty
  hyprland
  ivm
  local
  nvim
#  plymouth
#  sddm
  starship
  swaync
  swayosd
  systemd
  typora
  uwsm
  vs-code
  walker
  waybar
  zsh
)

apply_dimanu_dotfiles() {
  _make_bin_folder_executable
  _symlink_dotfiles
}

_make_bin_folder_executable() {
  set_permissions "$DIMANUDOTS_DOTFILES/local/.local/bin" "+x"
}

_symlink_dotfiles() {
  local target_dir="$HOME"

  cd "$DIMANUDOTS_DOTFILES"

  for package in "${SELECTED_CONFIG_PACKAGES[@]}"; do
    if ! _try_stow_package "$target_dir" "$package"; then
      _force_override_of_existing_config_file "$target_dir" "$package"
    fi
  done
}

_try_stow_package() {
  local target_dir="$1"
  local package="$2"

  stow --target "$target_dir" "$package" 2>/dev/null
}

_force_override_of_existing_config_file() {
  local target_dir="$1"
  local package="$2"

  stow --target "$target_dir" --override='.*' "$package"
}