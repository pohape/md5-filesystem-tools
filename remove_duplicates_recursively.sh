#!/bin/bash
source functions.sh

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
  files=()
  while IFS= read -r file; do
    files+=("$file")
  done <<< "${file_hash_map[$hash]}"

  if [ "${#files[@]}" -gt 1 ]; then
    # Найти файл с самым коротким именем
    shortest_file=$(printf "%s\n" "${files[@]}" | awk '{print length, $0}' | sort -n | cut -d' ' -f2- | head -n 1)
    
    # Удалить все файлы, кроме файла с самым коротким именем
    for file in "${files[@]}"; do
      if [ "$file" != "$shortest_file" ]; then
        delete_file "$file"
      fi
    done
  fi
done