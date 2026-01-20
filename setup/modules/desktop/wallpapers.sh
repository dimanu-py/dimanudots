#!/bin/bash

install_wallpapers() {
  _go_to_pictures_directory
  _clone_wallpapers_repository
}

_go_to_pictures_directory() {
  local pictures_dir="$HOME/Pictures"

  cd "$pictures_dir"
}

_clone_wallpapers_repository() {
  local wallpapers_repo_url="https://github.com/dimanu-py/wallpapers.git"
  local wallpapers_dir="wallpapers"

  if _is_empty $wallpapers_dir; then
      echo "Wallpapers directory already exists. Skipping clone."
      return 0
  fi

  git clone "$wallpapers_repo_url" "$wallpapers_dir"
}

_is_empty() {
  [ -d "$1" ]
}