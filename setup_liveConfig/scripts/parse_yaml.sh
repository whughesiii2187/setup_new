#!/usr/bin/env bash

# Function to parse YAML into arrays
parse_yaml() {
  local yaml_file="$1"
  local current_section=""

  # Declare globals if you expect specific arrays
  pacpkg=()
  aurpkg=()
  nvim=()
  brewpkg=()
  brewcask=()

  while IFS= read -r line; do
    # Skip comments or empty lines
    [[ "$line" =~ ^[[:space:]]*$ ]] && continue
    [[ "$line" =~ ^# ]] && continue

    # Detect section name (like packpkg:, aurpkg:)
    if [[ "$line" =~ ^([a-zA-Z0-9_-]+):[[:space:]]*$ ]]; then
      current_section="${BASH_REMATCH[1]}"
      continue
    fi

    # Detect list items starting with "- "
    if [[ "$line" =~ ^[[:space:]]*-[[:space:]]*(.*)$ ]]; then
      local item="${BASH_REMATCH[1]}"

      case "$current_section" in
      pacpkg)
        pacpkg+=("$item")
        ;;
      aurpkg)
        aurpkg+=("$item")
        ;;
      nvim)
        nvim+=("$item")
        ;;
      brewpkg)
        brewpkg+=("$item")
        ;;
      brewcask)
        brewcask+=("$item")
        ;;
      esac
    fi
  done < <(sed 's/#.*//' "$yaml_file" | awk 'NF') # remove comments and blank lines
}
