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
  local themes=("Theme=sugar-candy", "CursorTheme=bibata-cursor-theme")

  create_file "$SDDM_THEME_CONFIG" --sudo
  for line in "${themes[@]}"; do
    _fill_sddm_theme_config "$line"
  done
}

_fill_sddm_theme_config() {
  local line="$1"
  local key="${line%%=*}"

  if _has_key "$SDDM_THEME_CONFIG" "$key"; then
    _update_line_in_file "$SDDM_THEME_CONFIG" "$key" "$line"
  else
    _append_line_to_file "$SDDM_THEME_CONFIG" "$line"
  fi
}

_has_key() {
  local file_path="$1"
  local key="$2"

  grep -q "^${key}=" "$file_path"
}

_update_line_in_file() {
  local file_path="$1"
  local key="$2"
  local new_line="$3"

  sudo sed -i "s|^${key}=.*|${new_line}|" "$file_path"
}

_append_line_to_file() {
  local file_path="$1"
  local line="$2"

  echo "$line" | sudo tee -a "$file_path" > /dev/null
}

_enable_sddm_service() {
  enable_service "sddm.service"
}
