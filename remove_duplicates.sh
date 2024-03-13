#!/bin/bash
source functions.sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/checksums.md5"
    exit 1
fi

checksums_file="$1"

if [ ! -f "$checksums_file" ]; then
  echo "$checksums_file not found."
  exit 1
fi

directory_path=$(dirname "$checksums_file")
generate_hash_map "$checksums_file"

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
