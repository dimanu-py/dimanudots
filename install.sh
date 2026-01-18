#!/bin/bash

set -euo pipefail

export DIMANUDOTS_PATH="$HOME/.local/share/dimanudots"
export DIMANUDOTS_SCRIPTS="$DIMANUDOTS_PATH/setup"

source "$DIMANUDOTS_SCRIPTS/lib/main.sh"
source "$DIMANUDOTS_SCRIPTS/modules/main.sh"
source "$DIMANUDOTS_SCRIPTS/steps/main.sh"