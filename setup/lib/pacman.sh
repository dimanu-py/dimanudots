#!/bin/bash

is_installed() {
    pacman -Qq "$1" >/dev/null 2>&1
}

is_in_official_repos() {
    pacman -Si "$1" >/dev/null 2>&1
}

pacman_install() {
    run_installer "sudo pacman -Syu --needed" "$@"
}