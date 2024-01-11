#!/bin/bash

modified_files=$(git status --porcelain | awk '$1 ~ /^(M|\?\?)/ {print $2}')

# Initialize an array to store first-level folders
modified_folders=()

for file in $modified_files; do
    # Check if the file is in a folder
    if [ -d "$(dirname "$file")" ]; then
        folder=$(dirname "$file")
        folder_name=$(echo "$folder" | awk -F'/' '{print $1}')

        # Check if the folder does not start with a dot
        if [[ "$folder_name" != .* ]]; then
            # Check  if the folder is not already in the array
            if  [[ ! " ${modified_folders[@]} " =~ " $folder_name " ]]; then
                # Add the folder to the array
                modified_folders+=("$folder_name")
            fi
        fi
    fi
done

# Iterate through the list of unique first-level folders
for folder in "${modified_folders[@]}"; do
    file_path="${folder}/__manifest__.py"
    # Check if the folder contains "__manifest__.py"
    if [ -e "$file_path" ]; then
        # Check if the manifest file has a line starting with "version" or 'version'
        if grep -qE '^ *('\''version'\''|"version") *:' "${file_path}"; then
            # Get the current version
            version=$(grep -Eo '^ *('\''version'\''|"version") *: *['\''"]([^'\''"]+)['\''"],' "${file_path}" | awk -F'[:,]' '{print $2}' | tr -d ' ')
            # Check if the version value exists
            if [ -n "$version" ]; then
                # Remove quotes from value
                version="${version//\"/}"
                # Increment the last number by one
                LAST_NUMBER=$(echo $version | awk -F. '{print $NF}')
                NEW_LAST_NUMBER=$((LAST_NUMBER + 1))
                NEW_VERSION=$(echo $version | awk -F. -v OFS=. -v NEW_LAST_NUMBER="$NEW_LAST_NUMBER" '{$NF=""; print $0 NEW_LAST_NUMBER}')
                # Change the version line with new version
                sed -i -E 's/^ *('\''version'\''|"version") *: *['\''"]([^'\''"]+)['\''"],/    "version"'\:' "'$NEW_VERSION'",/' "$file_path"
                  
            else
                # If version value does not exits then add a default value (currently "15.0.0.0")

                echo "Failed to extract version value from $file_path. Adding a default value"
                sed -i -E 's/^ *('\''version'\''|"version") *:.*/    "version"'\:' "15.0.0.0",/' "$file_path"
            fi
        fi
    fi
done


# Add all changes in the repository to the staging area
git add .
# Commit all changes
git commit -m "Update version in __manifest__.py files by $USER"
