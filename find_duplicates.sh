#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/checksums.md5"
    exit 1
fi

checksums_file="$1"

if [ ! -f "$checksums_file" ]; then
  echo "$checksums_file not found."
  exit 1
fi

declare -A file_hash_map

while read -r line; do
  hash=$(echo "$line" | awk '{print $1}')
  file=$(echo "$line" | cut -d ' ' -f 2-)

  if [[ -n ${file_hash_map[$hash]} ]]; then
    file_hash_map[$hash]+=$'\n'"$file"
  else
    file_hash_map[$hash]=$file
  fi
done < "$checksums_file"

for hash in "${!file_hash_map[@]}"; do
  files="${file_hash_map[$hash]}"
  if [[ $(grep -c . <<< "$files") -gt 1 ]]; then
    echo -e "\n$hash:"
    echo "$files" | while IFS= read -r file; do
      echo "$file"
    done
  fi
done
