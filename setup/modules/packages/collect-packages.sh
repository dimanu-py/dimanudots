#!/bin/bash

collect_packages() {
  local package_file="$1"

  ensure_file_exists "$package_file"

  local -a raw_packages=()
  mapfile -t raw_packages < <(_read_packages_from_file "$package_file")

  local -a unique_packages=()
  mapfile -t unique_packages < <(_dedupe_keep_first "${raw_packages[@]}")

  _ensure_there_are_packages unique_packages

  printf '%s\n' "${unique_packages[@]}"
}

_read_packages_from_file() {
  local file_path="$1"
  while IFS= read -r line || [[ -n "$line" ]]; do
    local cleaned
    cleaned="$(_strip_inline_comment_and_trim "$line")"
    if [[ -n "$cleaned" ]]; then
      printf '%s\n' "$cleaned"
    fi
  done < "$file_path"
}

_strip_inline_comment_and_trim() {
  local line="$1"

  # 1) Remove everything after the first '#'
  line="${line%%#*}"

  # 2) Trim leading/trailing whitespace
  line="$(_trim_whitespace "$line")"

  printf '%s' "$line"
}

_trim_whitespace() {
  local s="$1"
  # trim leading
  s="${s#"${s%%[![:space:]]*}"}"
  # trim trailing
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

_dedupe_keep_first() {
  # Keeps first occurrence, removes subsequent duplicates.
  declare -A seen=()
  local pkg
  for pkg in "$@"; do
    if [[ -z "${seen[$pkg]+x}" ]]; then
      seen["$pkg"]=1
      printf '%s\n' "$pkg"
    fi
  done
}

_ensure_there_are_packages() {
  local list_name="$1"
  # shellcheck disable=SC2178
  local -n list_ref="$list_name"
  if (( ${#list_ref[@]} == 0 )); then
    echo "Error: no packages found after cleaning comments/duplicates." >&2
    return 1
  fi
}