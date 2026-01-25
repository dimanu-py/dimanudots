#!/bin/bash

SDDM_CONFIG_DIR="/etc/sddm.conf.d"
SDDM_THEME_CONFIG="$SDDM_CONFIG_DIR/theme.conf"

setup_display_manager() {
  _create_sddm_config_dir
  _configure_sddm_theme
  _enable_sddm_service
}

_create_sddm_config_dir() {
  create_directory_with_permissions "$SDDM_CONFIG_DIR" "0755" --sudo
}

_configure_sddm_theme() {
  create_file "$SDDM_THEME_CONFIG" --sudo
  sudo tee "$SDDM_THEME_CONFIG" > /dev/null << EOF
[Theme]
Current=sugar-candy
CursorTheme=bibata-cursor-theme
EOF
}

_enable_sddm_service() {
  enable_service "sddm.service"
}
