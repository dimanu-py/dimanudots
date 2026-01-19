#!/bin/bash

is_empty() {
    [[ -z "$1" ]]
}

remove_comments_and_trim() {
    local line="$1"
    echo "$line" | sed 's/#.*//' | xargs
}

is_valid_package_line() {
    local line="$1"
    ! is_empty "$line"
}

extract_package_from_line() {
    local line="$1"
    remove_comments_and_trim "$line"
}

was_already_seen() {
    local -n seen_ref="$1"
    local item="$2"
    [[ -n "${seen_ref[$item]:-}" ]]
}

mark_as_seen() {
    local -n seen_ref="$1"
    local item="$2"
    seen_ref["$item"]=1
}

add_to_unique_list() {
    local -n seen_ref="$1"
    local -n unique_ref="$2"
    local item="$3"
    
    was_already_seen seen_ref "$item" && return 0
    mark_as_seen seen_ref "$item"
    unique_ref+=("$item")
}

remove_duplicate_packages_preserving_order() {
    local -A seen=()
    local -a unique_items=()

    for item in "$@"; do
        is_empty "$item" && continue
        add_to_unique_list seen unique_items "$item"
    done

    printf '%s\n' "${unique_items[@]}"
}

process_file_line() {
    local line="$1"
    local -n packages_ref="$2"
    local cleaned_line

    cleaned_line="$(extract_package_from_line "$line")"
    
    if is_valid_package_line "$cleaned_line"; then
        packages_ref+=("$cleaned_line")
    fi
}

read_packages_from_file() {
    local package_file="$1"
    local -a file_packages=()
    local line

    while IFS= read -r line || [[ -n "$line" ]]; do
        process_file_line "$line" file_packages
    done < "$package_file"

    echo "${file_packages[@]}"
}

validate_packages_not_empty() {
    local -n packages_ref="$1"
    local file="$2"
    [[ ${#packages_ref[@]} -gt 0 ]] || die "No packages found in file: $file"
}

collect_packages() {
    local package_file="$1"
    local -a file_packages=()
    local -a unique_packages=()

    validate_file_exists "$package_file"

    mapfile -t file_packages < <(read_packages_from_file "$package_file")
    mapfile -t unique_packages < <(remove_duplicate_packages_preserving_order "${file_packages[@]}")

    validate_packages_not_empty unique_packages "$package_file"

    printf '%s\n' "${unique_packages[@]}"
}