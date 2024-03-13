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
