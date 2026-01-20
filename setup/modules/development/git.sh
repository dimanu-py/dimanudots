#!/bin/bash

GIT_CONFIG_FILES_DIR="${DIMANUDOTS_DOTFILES}/gitconfig"

setup_git() {
  echo "Setting up Git configuration..."

  _set_username_and_email
  _copy_configuration_files
}

_set_username_and_email() {
  set -e "Enter your Git username: " git_username
  set -e "Enter your Git email: " git_email

  _config_git "user.name" "${git_username}"
  _config_git "user.email" "${git_email}"
}

_config_git() {
  local _git_parameter=$1
  local _value=$2

  git config --global "${_git_parameter}" "${_value}"
}

_copy_configuration_files() {
  sym_link_file "${GIT_CONFIG_FILES_DIR}/.gitconfig" "${HOME}/.gitconfig"
  sym_link_file "${GIT_CONFIG_FILES_DIR}/.gitignore" "${HOME}/.gitignore"
}