generate_hash_string() {
    local checksums_file_path=$(realpath "$1")
    local checksums_dir=$(dirname "$checksums_file_path")
    hash_string=""
    local previous_hash=""
    local delimiter="!!__DELIMITER1__!!"

    while IFS= read -r line; do
        local hash=$(echo "$line" | awk '{print $1}')
        local file=$(echo "$line" | cut -d ' ' -f 2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        file=${file#./}
        local full_path_file="${checksums_dir}/${file}"

        if [[ "$hash" != "$previous_hash" ]]; then
            if [[ -n "$previous_hash" ]]; then
                hash_string+=$'!!__DELIMITER2__!!'
            fi
            hash_string+="${hash}${delimiter}${full_path_file}"
        else
            hash_string+="${delimiter}${full_path_file}"
        fi
        previous_hash="$hash"
    done < "$checksums_file_path"
}

delete_file() {
    local file_path_to_delete=$(realpath "$1")
    echo "Removing: $file_path_to_delete"
    rm "$file_path_to_delete"

    local basedir=$(dirname "$file_path_to_delete")
    checksums_file_path="$basedir/checksums.md5"

    local filename_to_delete=$(basename "$file_path_to_delete")
    local escaped_filename_to_delete=$(printf '%s\n' "$filename_to_delete" | sed 's:[][\/.^$*]:\\&:g')
    local temp_file=$(mktemp)
    grep -v "  $escaped_filename_to_delete\$" "$checksums_file_path" > "$temp_file"
    mv "$temp_file" "$checksums_file_path"
}

process_checksums_file() {
    local input_path=$(realpath "$1")

    if [[ "$input_path" != *.md5 ]]; then
        input_path="${input_path%/}/checksums.md5"
    fi

    echo "Checksums file: $input_path"

    if [ ! -f "$input_path" ]; then
      echo "$input_path not found."
      exit 1
    fi

    generate_hash_string "$input_path"
}

find_duplicates() {
    local directory_path="$1"

    if [ ! -d "$directory_path" ]; then
        echo "\"$directory_path\" is not a directory."
        exit 1
    fi

    delimiter1="!!__DELIMITER1__!!"
    delimiter2="!!__DELIMITER2__!!"

    declare -A file_hash_map
    global_hash_string=""

    mapfile -t checksum_files < <(find "$directory_path" $([ "$2" = "non-recursive" ] && echo "-maxdepth 1") -name 'checksums.md5')

    for checksums_file in "${checksum_files[@]}"; do
        echo "Processing $checksums_file"
        generate_hash_string "$checksums_file"

        while IFS= read -r item1; do
            shortest_path=""
            shortest_len=-1
            hash=""

            while IFS= read -r item2; do
                if [[ "$item2" != /* ]]; then
                    hash="$item2"
                else
                    if [[ -n ${file_hash_map[$hash]} ]]; then
                        file_hash_map[$hash]+=$'\n'"$item2"
                    else
                        file_hash_map[$hash]=$item2
                    fi
                fi
            done < <(echo "$item1" | awk -v RS=$delimiter1 '{print $0}')
        done < <(echo "$hash_string" | awk -v RS=$delimiter2 '{print $0}')
    done

    for hash in "${!file_hash_map[@]}"; do
        files="${file_hash_map[$hash]}"

        if [[ $(grep -c . <<< "$files") -gt 1 ]]; then
            if [[ -n $global_hash_string ]]; then
                global_hash_string+="$delimiter2"
            fi

            global_hash_string+="$hash"

            while IFS= read -r file; do
                global_hash_string+="$delimiter1"
                global_hash_string+="$file"
            done < <(echo "$files")
        fi
    done
}

remove_duplicates() {
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
    done < <(echo "$1" | awk -v RS='!!__DELIMITER2__!!' '{print $0}')
}
