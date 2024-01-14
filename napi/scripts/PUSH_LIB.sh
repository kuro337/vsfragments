#!/bin/bash

# Bump version
current_version=$(jq -r '.version' ../package.json)
base_version=${current_version%.*}
patch_version=${current_version##*.}
new_patch_version=$((patch_version + 1))
new_version="$base_version.$new_patch_version"
jq ".version = \"$new_version\"" ../package.json > temp.json && mv temp.json ../package.json

# Update changelog
current_date=$(date "+%Y-%m-%d %H:%M:%S")
new_log_entry="## Version $new_version - Released $current_date\n- Updated from $current_version to $new_version\n"

echo -e "\n$new_log_entry" >> ../CHANGELOG.md 

# # Append new log entry right after the first 4 lines (which include the header and current top)
# {
#     head -n 4 CHANGELOG.md
#     echo -e "$new_log_entry\n"
#     tail -n +5 CHANGELOG.md
# } > temp.md && mv temp.md CHANGELOG.md

echo "Updated version to $new_version and updated CHANGELOG.md"
