#!/bin/bash

ensure_file_exists() {
    local file_path="$1"
      if [[ ! -f "$file_path" ]]; then
        echo "Error: file not found: $file_path" >&2
        return 1
      fi
}

create_directory() {
    local dir_name="$1"

    mkdir -p "$dir_name"
}

set_permissions() {
    local dir_name="$1"
    local permissions="$2"

    chmod "$permissions" "$dir_name"
}

create_directory_with_permissions() {
    local dir_name="$1"
    local permissions="$2"

    create_directory "$dir_name"
    set_permissions "$dir_name" "$permissions"
}