#!/bin/bash

is_empty() {
    [[ -z "$1" ]]
}

strip_comments_from_file_and_trim_whitespace() {
    echo "$1" | sed 's/#.*//' | xargs
}

verify_file_exists() {
    local file="$1"
    [[ -f "$file" ]] || exit-with-error "File not found: $file"
}

read_packages_from_file() {
    local file="$1"
    verify_file_exists "$file"

    local file_packages=()
    local line cleaned_line

    while IFS= read -r line || [[ -n "$line" ]]; do
        cleaned_line="$(strip_comments_from_file_and_trim_whitespace "$line")"
        if ! is_empty "$cleaned_line"; then
            file_packages+=("$cleaned_line")
        fi
    done < "$file"
    
    echo "${file_packages[@]}"
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

remove_duplicate_packages_preserving_order() {
    local -A seen=()
    local unique_items=()

    for item in "$@"; do
        is_empty "$item" && continue
        was_already_seen seen "$item" && continue

        mark_as_seen seen "$item"
        unique_items+=("$item")
    done

    printf '%s\n' "${unique_items[@]}"
}

has_package_file() {
    [[ -n "$PACKAGE_FILE" ]]
}

has_no_packages() {
    local -n packages_ref="$1"
    [[ ${#packages_ref[@]} -eq 0 ]]
}

merge_arrays() {
    local -n first="$1"
    local -n second="$2"
    printf '%s\n' "${first[@]}" "${second[@]}"
}

collect_packages() {
    local -a cli_packages=("$@")
    local -a file_packages=()
    local -a all_packages=()

    if has_package_file; then
        mapfile -t file_packages < <(read_packages_from_file "$PACKAGE_FILE")
    fi

    mapfile -t all_packages < <(merge_arrays file_packages cli_packages)
    mapfile -t all_packages < <(remove_duplicate_packages_preserving_order "${all_packages[@]}")

    if has_no_packages all_packages; then
        exit-with-error "No packages provided. Use arguments or --file FILE."
    fi

    printf '%s\n' "${all_packages[@]}"
}

collect_packages "$@"
