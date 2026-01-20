#!/bin/bash

run_installer() {
  local cmd="$1"
  shift
  $cmd -- "$@"
  echo
}

verify_command_exists() {
  local command
  local should_die

  _evaluate_if_it_should_die command should_die "$@"

  if ! _command_exists "$command"; then
      _handle_command_not_found "$command" "$should_die"
  fi
}

_evaluate_if_it_should_die() {
  local -n cmd_ref=$1
  local -n die_ref=$2
  shift 2

  cmd_ref=""
  die_ref=true

  while [[ $# -gt 0 ]]; do
      case $1 in
          --die)
              die_ref="$2"
              shift 2
              ;;
          *)
              cmd_ref="$1"
              shift
              ;;
      esac
  done
}

_command_exists() {
  local command="$1"
  command -v "$command" >/dev/null 2>&1
}

_handle_command_not_found() {
  local command="$1"
  local should_die="$2"

  if [[ "$should_die" == "true" ]]; then
      die "$command command not found"
  else
      return 1
  fi
}