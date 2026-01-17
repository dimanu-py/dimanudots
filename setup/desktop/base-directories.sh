#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../common/create-directory-with-permissions.sh"

create_base_directories() {
    create_directory_with_permissions "$HOME/Documents" 0755
    create_directory_with_permissions "$HOME/Downloads" 0755
    create_directory_with_permissions "$HOME/Pictures" 0755
    create_directory_with_permissions "$HOME/Developer" 0755
    create_directory_with_permissions "$HOME/.config" 0755
}

create_base_directories