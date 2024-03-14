generate_hash_map() {
    local checksums_file_path=$1
    local checksums_dir=$(dirname "$checksums_file_path")
    declare -gA file_hash_map

    while IFS= read -r line; do
        local hash=$(echo "$line" | awk '{print $1}')
        local file=$(echo "$line" | cut -d ' ' -f 2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        local full_path_file="${checksums_dir}/${file}"
        if [[ -n ${file_hash_map[$hash]} ]]; then
            file_hash_map[$hash]+=$'\n'"$full_path_file"
        else
            file_hash_map[$hash]=$full_path_file
        fi
    done < "$checksums_file_path"
}

delete_file() {
    local file_path_to_delete=$1
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
    local input_path="$1"

    if [[ "$input_path" != *.md5 ]]; then
        input_path="${input_path%/}/checksums.md5"
    fi

    echo "Checksums file: $input_path"

    if [ ! -f "$input_path" ]; then
      echo "$input_path not found."
      exit 1
    fi

    generate_hash_map "$input_path"
}