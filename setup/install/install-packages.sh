#!/bin/bash

# -e: Exit immediately if any command exits with a non-zero status
# -u: Exit if an undefined variable is referenced
# -o pipefail: Exit if any command in a pipeline fails (not just the last one)
set -euo pipefail

# ─────────────────────────────────────────────────────────────
# Global variables
# ─────────────────────────────────────────────────────────────
needed_flag = "--needed"
package_file = ""

# ─────────────────────────────────────────────────────────────
# Usage and help
# ─────────────────────────────────────────────────────────────
usage() { 
    cat << EOF
Usage:
    install-packages.sh [--no-needed] [--file FILE] [PACKAGE...]

Options:
    --no-needed      Do not use the --needed flag with pacman (install all specified packages)
    --file FILE      Read package names from FILE (one per line). File supports comments.
    --help, -h       Show this help message and exit

Examples:
    install-packages.sh git ripgrep fd
    install-packages.sh --file packages.txt
    install-packages.sh --no-needed nvim git

EOF
}

# ─────────────────────────────────────────────────────────────
# Utility functions
# ─────────────────────────────────────────────────────────────
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

# ─────────────────────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────────────────────
override_needed_flag() {
    needed_flag=""
}

handle_file_and_verify_file_is_passed() {
    package_file="${1:-}"
    [[ -z "$package_file" ]] && die "--file requires a file argument"
}

print_help() {
    usage
    exit 0
}

parse_args() {
    local arguments=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-needed)
                override_needed_flag
                shift
                ;;
            --file)
                handle_file_and_verify_file_is_passed "${2:-}"
                shift 2
                ;;
            --help|-h)
                print_help
                ;;
            --*)
                die "Unknown option: $1"
                ;;
            *)
                arguments+=("$1")
                shift
                ;;
        esac
    done
}

# ─────────────────────────────────────────────────────────────
# Package collection
# ─────────────────────────────────────────────────────────────
strip_comments_from_file_and_trim_whitespace() {
    sed 's/#.*//' "$1" | xargs
}

read_packages_from_file() {
    local file="$1"
    verify_file_exists "$file"

    local file_packages=()
    local line cleaned_line

    while IFS= read -r line; do
        cleaned_line="$(strip_comments_from_file_and_trim_whitespace "$line")"
        if ! is_empty "$cleaned_line"; then
            file_packages+=("$cleaned_line")
        fi
    done < "$file"
    echo "${file_packages[@]}"
}

was_already_seen() {
    local -n seen_ref="$1"
    local item="$2"
    [[ -n "${seen_ref[$item]:-}" ]]
}

mark_as_seen() {
    local -n seen_ref="$1"
    local item="$2"
    seen_ref["$item"]=1
}

remove_duplicate_packages_preserving_order() {
    local -A seen=()
    local unique_items=()

    for item in "$@"; do
        is_empty "$item" && continue
        was_already_seen seen "$item" && continue

        mark_as_seen seen "$item"
        unique_items+=("$item")
    done

    printf '%s\n' "${unique_items[@]}"
}

has_package_file() {
    [[ -n "$package_file" ]]
}

has_no_packages() {
    local -n packages_ref="$1"
    [[ ${#packages_ref[@]} -eq 0 ]]
}

merge_arrays() {
    local -n first="$1"
    local -n second="$2"
    printf '%s\n' "${first[@]}" "${second[@]}"
}

collect_packages() {
    local -a cli_packages=("$@")
    local -a file_packages=()
    local -a all_packages=()

    if has_package_file; then
        mapfile -t file_packages < <(read_packages_from_file "$package_file")
    fi

    mapfile -t all_packages < <(merge_arrays file_packages cli_packages)
    mapfile -t all_packages < <(remove_duplicate_packages_preserving_order "${all_packages[@]}")

    if has_no_packages all_packages; then
        die "No packages provided. Use arguments or --file FILE."
    fi

    printf '%s\n' "${all_packages[@]}"
}

# -----------------------------
# Environment checks
# -----------------------------
require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command not found: $1"
}

ensure_pacman_and_yay_are_installed() {
  require_command pacman
  require_command yay
}

# -----------------------------
# Package classification helpers
# -----------------------------
is_installed() {
  pacman -Qq "$1" >/dev/null 2>&1
}

is_in_official_repos() {
  pacman -Si "$1" >/dev/null 2>&1
}

is_in_aur() {
  yay -a -Ss --color=never -- "$1" 2>/dev/null | grep -qE "aur/${1}\b"
}

# -----------------------------
# Planning & reporting
# -----------------------------
plan_installation() {
  local -a installed=() pacman_packages=() aur_packages=() unknown=()
  local package

  for package in "$@"; do
    if is_installed "$package"; then
      installed+=("$package")
    elif is_in_official_repos "$package"; then
      pacman_packages+=("$package")
    elif is_in_aur "$package"; then
      aur_packages+=("$package")
    else
      unknown+=("$package")
    fi
  done

  printf '%s\0' "$(printf '%s\n' "${installed[@]}")"
  printf '%s\0' "$(printf '%s\n' "${pacman_packages[@]}")"
  printf '%s\0' "$(printf '%s\n' "${aur_packages[@]}")"
  printf '%s\0' "$(printf '%s\n' "${unknown[@]}")"
}

print_plan() {
  local -a installed=("$1") pacman_packages=("$2") aur_packages=("$3") unknown=("$4")

  echo "== Package plan =="

  if [[ -n "${installed[*]}" ]]; then
    echo "Already installed: ${installed[*]}"
  fi
  if [[ -n "${pacman_packages[*]}" ]]; then
    echo "Pacman repos:     ${pacman_packages[*]}"
  fi
  if [[ -n "${aur_packages[*]}" ]]; then
    echo "AUR via yay:      ${aur_packages[*]}"
  fi
  if [[ -n "${unknown[*]}" ]]; then
    echo "Not found:        ${unknown[*]}"
  fi
  echo
}

# -----------------------------
# Installation steps
# -----------------------------
has_packages() {
  local -a pkgs=("$@")
  [[ ${#pkgs[@]} -gt 0 ]]
}

print_section_header() {
  local title="$1"
  echo "== $title =="
}

run_installer() {
  local cmd="$1"
  shift
  $cmd ${needed_flag:+$needed_flag} -- "$@"
  echo
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

# -----------------------------
# Main
# -----------------------------
install_packages() {
  mapfile -t cli_packages < <(parse_args "$@")
  ensure_pacman_and_yay_are_installed
  mapfile -t all_packages < <(collect_packages "${cli_packages[@]}")

  local plan
  plan="$(plan_installation "${all_packages[@]}")"

  IFS=$'\0' read -r installed_block pacman_block aur_block unknown_block <<<"$plan" || true

  mapfile -t already_installed < <(printf '%s\n' "$installed_block" | sed '/^$/d')
  mapfile -t pacman < <(printf '%s\n' "$pacman_block"    | sed '/^$/d')
  mapfile -t aur_yay < <(printf '%s\n' "$aur_block"       | sed '/^$/d')
  mapfile -t unknown_packages < <(printf '%s\n' "$unknown_block"   | sed '/^$/d')

  print_plan "${already_installed[*]}" "${pacman[*]}" "${aur_yay[*]}" "${unknown_packages[*]}"

  pacman_install "${pacman[@]}"
  yay_install "${aur_yay[@]}"
  warn_unknown_and_exit "${unknown_packages[@]}"

  echo "== Done =="
}

install_packages "$@"