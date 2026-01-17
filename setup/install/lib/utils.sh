#!/bin/bash

die() {
    echo "Error: $*" >&2
    exit 1
}

is_empty() {
    [[ -z "$1" ]]
}

verify_file_exists() {
    local file="$1"
    [[ -f "$file" ]] || die "File not found: $file"
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

print_section_header() {
    local title="$1"
    echo "== $title =="
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

ensure_pacman_and_yay_are_installed() {
  require_command pacman
  require_command yay
}
