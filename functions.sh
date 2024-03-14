generate_hash_string() {
    local checksums_file_path=$1
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
                hash_string+=$'!!__DELIMITER2__!!'  # Добавляем новую строку перед началом нового хеша
            fi
            hash_string+="${hash}${delimiter}${full_path_file}"
        else
            hash_string+="${delimiter}${full_path_file}"
        fi
        previous_hash="$hash"
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

    generate_hash_string "$input_path"
}

remove_duplicates() {
    local serialized_map=$1
    local -A deserialized_map
    IFS=';' read -ra pairs <<< "$serialized_map"
    for pair in "${pairs[@]}"; do
        IFS='=' read -r key value <<< "$pair"
        deserialized_map["$key"]="$value"
    done

    for hash in "${!deserialized_map[@]}"; do
        IFS=' ' read -r -a files <<< "${deserialized_map[$hash]}"

        if [ "${#files[@]}" -gt 1 ]; then
            # Сортировка файлов по длине имени и выбор самого короткого
            shortest_file=$(printf "%s\n" "${files[@]}" | awk '{print length, $0}' | sort -n | cut -d' ' -f2- | head -n 1)
            echo "The file with the shortest name will be preserved:"
            echo "$shortest_file"
            echo

            # Удаление файлов, которые не являются самым коротким
            for file in "${files[@]}"; do
                if [ "$file" != "$shortest_file" ]; then
                    echo "Removing: $file"
                    # Вот здесь должен быть вызов функции delete_file или команда удаления
                    # delete_file "$file"
                fi
            done
        fi
    done
}
