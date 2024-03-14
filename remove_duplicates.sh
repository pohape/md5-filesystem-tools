#!/bin/bash
source "$(dirname "${BASH_SOURCE[0]}")/functions.sh"

process_checksums_file "$1"
remove_duplicates $hash_string
