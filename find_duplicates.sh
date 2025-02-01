#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

directory_path="$1"
echo "Directory Path: $directory_path"
process_checksums_file "$directory_path"
echo
echo

duplicates_found=0
header_printed=0

while IFS= read -r item1; do
    files=()

    while IFS= read -r item2; do
        if [[ "$item2" == /* ]]; then
            files+=("$item2")
        fi
    done < <(echo "$item1" | awk -v RS='!!__DELIMITER1__!!' '{print $0}')

    if [ "${#files[@]}" -gt 1 ]; then
        ((duplicates_found++))

        if [ "$header_printed" -eq 0 ]; then
            echo "Duplicates:"
            echo
            header_printed=1
        fi

        for ((i = 0; i < ${#files[@]}; i++)); do
            for ((j = i + 1; j < ${#files[@]}; j++)); do
                echo "${files[i]}"
                echo "${files[j]}"
                echo "-------------------"
            done
        done
    fi

done < <(echo "$hash_string" | awk -v RS='!!__DELIMITER2__!!' '{print $0}')

if [ "$duplicates_found" -eq 0 ]; then
    echo "No duplicates found."
fi
