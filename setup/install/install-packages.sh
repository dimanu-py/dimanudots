#!/bin/bash

# -e: Exit immediately if any command exits with a non-zero status
# -u: Exit if an undefined variable is referenced
# -o pipefail: Exit if any command in a pipeline fails (not just the last one)
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# Determine script directory and source libraries
# ─────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${SCRIPT_DIR}/lib"

source "${LIB_DIR}/utils.sh"
source "${LIB_DIR}/args.sh"
source "${LIB_DIR}/packages.sh"
source "${LIB_DIR}/classify.sh"
source "${LIB_DIR}/install.sh"

require_command() {
  command -v "$1" >/dev/null 2>&1 || exit_with_error "Required command not found: $1"
}

ensure_pacman_and_yay_are_installed() {
  require_command pacman
  require_command yay
}

has_packages() {
    local -a pkgs=("$@")
    [[ ${#pkgs[@]} -gt 0 && -n "${pkgs[*]}" ]]
}

run_installer() {
    local cmd="$1"
    shift
    $cmd ${NEEDED_FLAG:+$NEEDED_FLAG} -- "$@"
    echo
}

print_section_header() {
    local title="$1"
    echo "== $title =="
}

pacman_install() {
    has_packages "$@" || return 0
    print_section_header "Installing with pacman"
    run_installer "sudo pacman -Syu" "$@"
}

yay_install() {
    has_packages "$@" || return 0
    print_section_header "Installing with yay (AUR)"
    run_installer "yay -S" "$@"
}

warn_unknown_and_exit() {
    has_packages "$@" || return 0
    print_section_header "Done (with warnings)"
    echo "These packages were not found in pacman repos nor AUR:"
    printf ' - %s\n' "$@"
    exit 2
}

install_packages() {
    parse_args "$@"
    ensure_pacman_and_yay_are_installed
    mapfile -t all_packages < <(collect_packages "${CLI_PACKAGES[@]}")

    local plan
    plan="$(plan_installation "${all_packages[@]}")"

    IFS=$'\0' read -r installed_block pacman_block aur_block unknown_block <<<"$plan" || true

    mapfile -t already_installed < <(printf '%s\n' "$installed_block" | sed '/^$/d')
    mapfile -t pacman < <(printf '%s\n' "$pacman_block" | sed '/^$/d')
    mapfile -t aur_yay < <(printf '%s\n' "$aur_block" | sed '/^$/d')
    mapfile -t unknown_packages < <(printf '%s\n' "$unknown_block" | sed '/^$/d')

    print_plan "${already_installed[*]}" "${pacman[*]}" "${aur_yay[*]}" "${unknown_packages[*]}"

    pacman_install "${pacman[@]}"
    yay_install "${aur_yay[@]}"
    warn_unknown_and_exit "${unknown_packages[@]}"

}

install_packages "$@"