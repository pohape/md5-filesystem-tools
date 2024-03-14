#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

process_checksums_file "$1"

while IFS= read -r item1; do
    shortest_path=""
    shortest_len=-1
    files=()
    
    while IFS= read -r item2; do
        if [[ "$item2" == /* ]]; then
          files+=("$item2")
        
          if [[ $shortest_len -eq -1 || ${#item2} -lt $shortest_len ]]; then
              shortest_path="$item2"
              shortest_len=${#item2}
          fi
        fi
    done < <(echo "$item1" | awk -v RS='!!__DELIMITER1__!!' '{print $0}')

    for file in "${files[@]}"; do
        if [[ "$file" != "$shortest_path" ]]; then
            delete_file "$file"
        fi
    done
done < <(echo "$hash_string" | awk -v RS='!!__DELIMITER2__!!' '{print $0}')
