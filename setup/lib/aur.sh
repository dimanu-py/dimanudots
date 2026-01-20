#!/bin/bash

is_in_aur() {
  yay -a -Si "$pkg" >/dev/null 2>&1
}

yay_install() {
  run_installer "yay -S --noconfirm" "$@"
}