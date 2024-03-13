# MD5 filesystem tools
Harness the power of MD5 checksums for your filesystem with our toolkit of MD5 filesystem tools designed for managing and analyzing file integrity across nested directories. Features include recursive checksum file creation, duplicate file detection based on checksum comparison, and automated duplicate removal using checksum validation.

## generate_checksums_recursively.sh
This script is designed to recursively find all directories within a specified root directory, calculate the number of files in each directory (excluding subdirectories and any 'checksums.md5' files), and generate a 'checksums.md5' file containing the MD5 checksums for each file within the directory. It also provides feedback on its progress and the results of its operations.

### Usage
This command will process the 'Photos' directory, showing the progress and results for each subdirectory found:
```
./generate_checksums_recursively.sh ~/Photos
```
