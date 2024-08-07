#!/bin/bash

# Update hellofrag /Users/kuro/Documents/Code/JS/vsfragments/hellofrag/scripts/

# npm outdated to check new versions available

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

echo "Updated version to $new_version and updated CHANGELOG.md"


rm -rf ../package-lock.json ../node_modules 

cd ..

npm i 

if npm test; then
    echo "Tests Successfully Ran"

    # Attempt to build the package
    if npm pack; then
        echo "Package built successfully."

        # Publish the package
        npm publish
        echo "Package published successfully."
    else
        echo "Failed to build the package."
    fi
else 
    echo "Tests Failed"
fi



