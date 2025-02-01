#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 /path/to/directory"
    exit 1
fi

directory_path="$1"
echo "Directory Path: $directory_path"
echo

process_checksums_file "$directory_path"
echo

duplicates_found=0
group_number=1

while IFS= read -r item1; do
    files=()

    while IFS= read -r item2; do
        if [[ "$item2" == /* ]]; then
            files+=("$item2")
        fi
    done < <(echo "$item1" | awk -v RS='!!__DELIMITER1__!!' '{print $0}')

    if [ "${#files[@]}" -gt 1 ]; then
        ((duplicates_found++))

        echo "🗂️  Duplicate #$group_number:"
        echo "-----------------------------"

        for file in "${files[@]}"; do
            echo "📄 $file"
        done

        echo "-----------------------------"
        echo

        ((group_number++))
    fi

done < <(echo "$hash_string" | awk -v RS='!!__DELIMITER2__!!' '{print $0}')

if [ "$duplicates_found" -eq 0 ]; then
    echo "✅ No duplicates found."
fi
