#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

directory_path="$1"
echo "Directory Path: $directory_path"

find_duplicates_recursively "$directory_path"
remove_duplicates "$global_hash_string"
