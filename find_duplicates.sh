#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

directory_path="$1"
echo "Directory Path: $directory_path"
process_checksums_file "$directory_path"
echo
echo

while IFS= read -r item1; do
    files=()

    while IFS= read -r item2; do
        if [[ "$item2" == /* ]]; then
            files+=("$item2")
        fi
    done < <(echo "$item1" | awk -v RS='!!__DELIMITER1__!!' '{print $0}')

    if [ "${#files[@]}" -gt 1 ]; then
        echo "Duplicates:"
        echo

        for file in "${files[@]}"; do
            echo "$file"
        done

        echo "-------------------"
    fi

done < <(echo "$hash_string" | awk -v RS='!!__DELIMITER2__!!' '{print $0}')
