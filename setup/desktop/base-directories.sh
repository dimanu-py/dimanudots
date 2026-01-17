#!/bin/bash

set -euo pipefail

create_directory_with_permissions() {
    local dir_name="$1"
    local permissions="$2"

    mkdir -p "$dir_name"
    chmod "$permissions" "$dir_name"
}

create_base_directories() {
    create_directory_with_permissions "$HOME/Documents" 0755
    create_directory_with_permissions "$HOME/Downloads" 0755
    create_directory_with_permissions "$HOME/Pictures" 0755
    create_directory_with_permissions "$HOME/Developer" 0755
    create_directory_with_permissions "$HOME/.config" 0755
}

create_base_directories