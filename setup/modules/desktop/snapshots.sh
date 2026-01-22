#!/bin/bash

setup_snapshots_management() {
  _ensure_system_file_is_btrfs "/"
  _configure_timeshift
  _enable_snapshots_from_grub_menu
}

_ensure_system_file_is_btrfs() {
  local file_path="$1"

  if _file_system_is_not_btrfs $file_path; then
      die "Error: The file '$file_path' is not on a Btrfs filesystem."
  fi
}

_file_system_is_not_btrfs() {
  local file_path="$1"
  local fs_type
  fs_type=$(findmnt -n -o FSTYPE --target "$file_path")

  [[ "$fs_type" != "btrfs" ]]
}

_configure_timeshift() {
  _generate_config_file
  _configure_timeshift_schedule
}

_generate_config_file() {
  sudo timeshift --btrfs
}

_configure_timeshift_schedule() {
  local config_file="/etc/timeshift/timeshift.json"

  ensure_file_exists "$config_file"

  sudo sed -i \
    -e 's/"schedule_monthly": *"[^"]*"/"schedule_monthly": "false"/' \
    -e 's/"schedule_weekly": *"[^"]*"/"schedule_weekly": "false"/' \
    -e 's/"schedule_daily": *"[^"]*"/"schedule_daily": "true"/' \
    -e 's/"schedule_hourly": *"[^"]*"/"schedule_hourly": "false"/' \
    -e 's/"schedule_boot": *"[^"]*"/"schedule_boot": "false"/' \
    -e 's/"count_daily": *"[^"]*"/"count_daily": "3"/' \
    "$config_file"
}

_enable_snapshots_from_grub_menu() {
  _update_grub_menu
  _regenerate_grub_config
  _configure_grub_btrfsd_service_to_work_with_timeshift
  _enable_grub_btrfs_service
}

_update_grub_menu() {
  sudo /etc/grub.d/41_snapshots-btrfs
}

_regenerate_grub_config() {
  sudo grub-mkconfig -o /boot/grub/grub.cfg
}

_configure_grub_btrfsd_service_to_work_with_timeshift() {
  local service_file="/etc/systemd/system/grub-btrfsd.service"

  ensure_file_exists "$service_file"

  sudo sed -i 's|^ExecStart=.*|ExecStart=/usr/bin/grub-btrfsd --syslog --timeshift-auto|' "$service_file"
}

_enable_grub_btrfs_service() {
  enable_service "grub-btrfsd"
}