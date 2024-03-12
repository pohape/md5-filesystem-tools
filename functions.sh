generate_hash_map() {
    local checksums_file=$1
    declare -gA file_hash_map

    while read -r line; do
        local hash=$(echo "$line" | awk '{print $1}')
        local file=$(echo "$line" | cut -d ' ' -f 2- | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        if [[ -n ${file_hash_map[$hash]} ]]; then
            file_hash_map[$hash]+=$'\n'"$file"
        else
            file_hash_map[$hash]=$file
        fi
    done < "$checksums_file"
}