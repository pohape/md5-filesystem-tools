#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

directory_path="$1"

if [ ! -d "$directory_path" ]; then
  echo "$directory_path is not a directory."
  exit 1
fi

declare -A file_hash_map

mapfile -t checksum_files < <(find "$directory_path" -name 'checksums.md5')
for checksums_file in "${checksum_files[@]}"; do
  echo "Processing $checksums_file"
  generate_hash_map "$checksums_file"
done

for hash in "${!file_hash_map[@]}"; do
  files="${file_hash_map[$hash]}"
  if [[ $(grep -c . <<< "$files") -gt 1 ]]; then
    echo -e "\n$hash:"
    echo "$files" | while IFS= read -r file; do
      echo "$file"
    done
  fi
done
