#!/bin/bash

root_dir=$1

if [ -z "$root_dir" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

find "$root_dir" -type d -print0 | while IFS= read -r -d $'\0' dir; do
  cd "$dir"
  checksums=$(md5sum * 2> /dev/null | grep -v "checksums.md5")

  if [ -n "$checksums" ]; then
    echo "$checksums" > checksums.md5
  fi
  cd - > /dev/null
done
