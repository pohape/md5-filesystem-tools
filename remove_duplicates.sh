#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

process_checksums_file "$1"
directory_path=$(dirname "$checksums_file")

for hash in "${!file_hash_map[@]}"; do
  files=()
  while IFS= read -r file; do
    files+=("$file")
  done <<< "${file_hash_map[$hash]}"

  if [ "${#files[@]}" -gt 1 ]; then
    shortest_file=$(printf "%s\n" "${files[@]}" | awk '{print length, $0}' | sort -n | cut -d' ' -f2- | head -n 1)

    for file in "${files[@]}"; do
      if [ "$file" != "$shortest_file" ]; then
        delete_file "$file"
      fi
    done
  fi
done
