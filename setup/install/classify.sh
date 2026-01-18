#!/bin/bash

is_installed() {
    pacman -Qq "$1" >/dev/null 2>&1
}

is_in_official_repos() {
    pacman -Si "$1" >/dev/null 2>&1
}

is_in_aur() {
    yay -a -Ss --color=never -- "$1" 2>/dev/null | grep -qE "aur/${1}\b"
}

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
    local -a installed=("$1") 
    local -a pacman_packages=("$2") 
    local -a aur_packages=("$3") 
    local -a unknown=("$4")

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

case "$1" in
  plan) print_plan "${@:2}" ;;
  print) print_plan "${@:2}" ;;
  *) exit-with-error "Unknown action: $1" ;;
esac
