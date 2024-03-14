#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/checksums.md5"
    echo "Or: $0 /path/to/"
    exit 1
fi

checksums_file="$1"

if [[ "$checksums_file" != *.md5 ]]; then
    checksums_file="${checksums_file%/}/checksums.md5"
fi

echo "Checksums file: $checksums_file"

if [ ! -f "$checksums_file" ]; then
  echo "$checksums_file not found."
  exit 1
fi

generate_hash_map "$checksums_file"
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
