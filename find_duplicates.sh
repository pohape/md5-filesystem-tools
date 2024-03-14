#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

process_checksums_file "$1"

while IFS= read -r item1; do
    while IFS= read -r item2; do
        echo $item2
    done < <(echo "$item1" | awk -v RS='!!__DELIMITER1__!!' '{print $0}')
done < <(echo "$hash_string" | awk -v RS='!!__DELIMITER2__!!' '{print $0}')
