#!/bin/bash

setup_gtk_themes() {
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