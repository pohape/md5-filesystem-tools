#!/bin/bash

root_dir=$1

if [ -z "$root_dir" ]; then
  echo "Usage: $0 <directory>"
  exit 1
fi

find "$root_dir" -type d -print0 | while IFS= read -r -d $'\0' dir; do
  cd "$dir"
  md5sum * > checksums.md5 2> /dev/null
  cd - > /dev/null
done
