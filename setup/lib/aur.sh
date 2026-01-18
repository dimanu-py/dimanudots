#!/bin/bash

is_in_aur() {
    yay -a -Ss --color=never -- "$1" 2>/dev/null | grep -qE "aur/${1}\b"
}

yay_install() {
    run_installer "yay -S" "$@"
}