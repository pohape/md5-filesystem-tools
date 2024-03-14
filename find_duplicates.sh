#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

process_checksums_file "$1"

for hash in "${!file_hash_map[@]}"; do
  files="${file_hash_map[$hash]}"
  if [[ $(grep -c . <<< "$files") -gt 1 ]]; then
    echo -e "\n$hash:"
    echo "$files" | while IFS= read -r file; do
      echo "$file"
    done
  fi
done
