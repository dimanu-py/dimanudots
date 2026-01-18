#!/bin/bash

set -euo pipefail

exit_with_error() {
    echo "Error: $*" >&2
    exit 1
}

exit_with_error "$@"