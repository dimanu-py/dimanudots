#!/bin/bash

set -euo pipefail

create_base_directories() {
    create-directory-with-permissions "$HOME/Documents" 0755
    create-directory-with-permissions "$HOME/Downloads" 0755
    create-directory-with-permissions "$HOME/Pictures" 0755
    create-directory-with-permissions "$HOME/Developer" 0755
    create-directory-with-permissions "$HOME/.config" 0755
}

create_base_directories