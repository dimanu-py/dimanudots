#!/bin/bash

CONFIG_THEMES_DIR="$HOME/.config/themes"

setup_themes() {
  _setup_gtk_themes
  _setup_config_themes
}

_setup_gtk_themes() {
  _set_config_param "gtk-theme" "Catppuccin-Mocha-Standard-Rosewater-Dark"
  _set_config_param "color-scheme" "prefer-dark"
  _set_config_param "icon-theme" "Yaru-blue"
  _update_icon_cache
}

_set_config_param() {
  local param="$1"
  local value="$2"

  gsettings set org.gnome.desktop.interface "$param" "$value"
}

_update_icon_cache() {
  sudo gtk-update-icon-cache /usr/share/icons/Yaru-blue
}

_setup_config_themes() {
  create_directory "$CONFIG_THEMES_DIR"
  _symlink_themes_to_config_directory
  _set_initial_theme
  _set_btop_theme
}

_symlink_themes_to_config_directory() {
  local themes_dir="$DIMANUDOTS_PATH/themes"

  for theme in $(themes_dir/*); do
    local theme_name
    theme_name=$(basename "$theme")
    sym_link_file "$theme" "$CONFIG_THEMES_DIR/$theme_name"
  done
}

_set_initial_theme() {
  create_directory "$CONFIG_THEMES_DIR/active"
  sym_link_file "$CONFIG_THEMES_DIR/osaka-jade" "$CONFIG_THEMES_DIR/active/theme"
  sym_link_file "$CONFIG_THEMES_DIR/osaka-jade/2-osaka-jade-bg.jpg" "$CONFIG_THEMES_DIR/active/background"
}

_set_btop_theme() {
  create_directory "$HOME/.config/btop/themes"
  sym_link_file "$CONFIG_THEMES_DIR/active/theme/btop.theme" "$HOME/.config/btop/themes/active.theme"
}