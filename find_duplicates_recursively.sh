#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

directory_path="$1"
echo "Directory Path: $directory_path"
find_duplicates_recursively "$directory_path"

echo

while IFS= read -r item1; do
    while IFS= read -r item2; do
        echo $item2
    done < <(echo "$item1" | awk -v RS='!!__DELIMITER1__!!' '{print $0}')
done < <(echo "$global_hash_string" | awk -v RS='!!__DELIMITER2__!!' '{print $0}')
