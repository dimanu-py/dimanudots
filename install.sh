#!/bin/bash

# -e: Exit immediately if any command exits with a non-zero status
# -u: Exit if an undefined variable is referenced
# -o pipefail: Exit if any command in a pipeline fails (not just the last one)
set -euo pipefail

export DIMANUDOTS_PATH="$HOME/.local/share/dimanudots"
export DIMANUDOTS_SCRIPTS="$DIMANUDOTS_PATH/setup"
export DIMANUDOTS_DOTFILES="$DIMANUDOTS_PATH/files/dotfiles"

source "$DIMANUDOTS_SCRIPTS/lib/main.sh"
source "$DIMANUDOTS_SCRIPTS/modules/main.sh"
source "$DIMANUDOTS_SCRIPTS/steps/main.sh"

run_steps() {
  local all_steps=(
    step_10_packages
    step_15_dotfiles
    step_20_desktop
    step_30_development_tools
  )
  local steps_to_run=("$@")

  if _no_steps_are_specified "${steps_to_run[@]}"; then
    steps_to_run=("${all_steps[@]}")
  fi

  for step in "${steps_to_run[@]}"; do
    _run_step "$step"
  done
}

_no_steps_are_specified() {
  [[ $# -eq 0 ]]
}

_run_step() {
  case "$step" in
      packages)
        step_10_packages
        ;;
      dotfiles)
        step_15_dotfiles
        ;;
      desktop)
        step_20_desktop
        ;;
      development-tools)
        step_30_development_tools
        ;;
      -h|--help)
        usage
        return 0
        ;;
      *)
        echo "Unknown step: $step"
        usage
        return 1
        ;;
  esac
}


run_steps