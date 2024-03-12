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

generate_hash_map "$checksums_file"

for hash in "${!file_hash_map[@]}"; do
  files="${file_hash_map[$hash]}"
  if [[ $(grep -c . <<< "$files") -gt 1 ]]; then
    echo -e "\n$hash:"
    echo "$files" | while IFS= read -r file; do
      echo "$file"
    done
  fi
done
