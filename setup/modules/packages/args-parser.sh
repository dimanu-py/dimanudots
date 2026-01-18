#!/bin/bash

PACKAGE_FILE=""
CLI_PACKAGES=()

usage() { 
    cat << EOF
Usage:
    install-packages.sh [--file FILE] [PACKAGE...]

Options:
    --file FILE      Read package names from FILE (one per line). File supports comments.
    --help, -h       Show this help message and exit

Examples:
    install-packages.sh git ripgrep fd
    install-packages.sh --file packages.txt

EOF
}

handle_file_and_verify_is_passed() {
    PACKAGE_FILE="${1:-}"
    [[ -z "$PACKAGE_FILE" ]] && exit-with-error "--file requires a file argument"
}

print_help() {
    usage
    exit 0
}

parse_args() {
    CLI_PACKAGES=()

    while [[ $# -gt 0 ]]; do
        case $1 in
            --file)
                handle_file_and_verify_is_passed "${2:-}"
                shift 2
                ;;
            --help|-h)
                print_help
                ;;
            --*)
                exit-with-error "Unknown option: $1"
                ;;
            *)
                CLI_PACKAGES+=("$1")
                shift
                ;;
        esac
    done
}