#!/bin/bash

root_dir=$(realpath "$1")

if [ -z "$root_dir" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

directory_list=$(find "$root_dir" -type d -print)
directory_count=$(echo "$directory_list" | grep -c '^')

echo -e "Directories found:\n$directory_count"
current_directory_number=0

while IFS= read -r dir; do
  ((current_directory_number++))
  cd "$dir"
  echo
  echo "Processing directory $current_directory_number/$directory_count: $dir"
  echo "The directory has this amount of files:"
  ls -p | grep -v / | grep -v checksums.md5 | wc -l

  checksums=$(md5sum * 2> /dev/null | grep -v "checksums.md5")

  if [ -n "$checksums" ]; then
    echo "$checksums" > checksums.md5
    echo "Checksums saved: "
    cat checksums.md5 | wc -l
  fi
done <<< "$directory_list"
