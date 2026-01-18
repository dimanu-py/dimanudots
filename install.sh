#!/bin/bash

# -e: Exit immediately if any command exits with a non-zero status
# -u: Exit if an undefined variable is referenced
# -o pipefail: Exit if any command in a pipeline fails (not just the last one)
set -euo pipefail

export DIMANUDOTS_PATH="$HOME/.local/share/dimanudots"
export DIMANUDOTS_SCRIPTS="$DIMANUDOTS_PATH/setup"

source "$DIMANUDOTS_SCRIPTS/lib/main.sh"
source "$DIMANUDOTS_SCRIPTS/modules/main.sh"
source "$DIMANUDOTS_SCRIPTS/steps/main.sh"

main() {
    step_10_packages
}

main