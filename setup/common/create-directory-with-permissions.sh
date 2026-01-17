#!/bin/bash

set -euo pipefail

create_directory_with_permissions() {
    local dir_name="$1"
    local permissions="$2"

    mkdir -p "$dir_name"
    chmod "$permissions" "$dir_name"
}
