#!/bin/bash

_maybe_sudo() {
    local use_sudo="$1"
    shift
    if [[ "$use_sudo" == "--sudo" ]]; then
        sudo "$@"
    else
        "$@"
    fi
}

ensure_file_exists() {
    local file_path="$1"
      if [[ ! -f "$file_path" ]]; then
        echo "Error: file not found: $file_path" >&2
        return 1
      fi
}

create_directory() {
    local dir_name="$1"
    local sudo_flag="$2"

    _maybe_sudo "$sudo_flag" mkdir -p "$dir_name"
}

set_permissions() {
    local dir_name="$1"
    local permissions="$2"
    local sudo_flag="$3"

    _maybe_sudo "$sudo_flag" chmod "$permissions" "$dir_name"
}

create_directory_with_permissions() {
    local dir_name="$1"
    local permissions="$2"
    local sudo_flag="$3"

    create_directory "$dir_name" "$sudo_flag"
    set_permissions "$dir_name" "$permissions" "$sudo_flag"
}

sym_link_file() {
    local source_file="$1"
    local target_file="$2"
    local sudo_flag="$3"

    _maybe_sudo "$sudo_flag" ln -sf "$source_file" "$target_file"
}

set_owner() {
    local user="$1"
    local group="${2:-$user}"
    local file_path="$3"
    local sudo_flag="$4"

    _maybe_sudo "$sudo_flag" chown "$user:$group" "$file_path"
}

create_file() {
    local file_path="$1"
    local sudo_flag="$2"

    _maybe_sudo "$sudo_flag" touch "$file_path"
}