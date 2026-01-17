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

# ─────────────────────────────────────────────────────────────
# Main function
# ─────────────────────────────────────────────────────────────
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

    print_section_header "Done"
}

install_packages "$@"