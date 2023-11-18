#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: $0 package_name"
    exit 1
fi

package_name="$1"
username=$(whoami)
hostname=$(hostname)
ansiblepath="/home/$username/Github/Ansible/vars/$hostname"
yaml_file="$ansiblepath/config.yml"

# Check if the specified YAML file exists; if not, create it
if [ ! -f "$yaml_file" ]; then
    mkdir -p "$ansiblepath"
    touch "$yaml_file"
    echo "packages:" > "$yaml_file"
fi

# Check if the package is already present in the `packages:` block
if grep -q "^\s*- $package_name$" "$yaml_file"; then
    echo "$package_name is already in $yaml_file"
    exit 0
fi

# Use awk to find the `packages:` block
packages_block_start=$(awk '/^packages:$/ {print NR; exit}' "$yaml_file")

if [ -z "$packages_block_start" ]; then
    # If `packages:` block is not found, create it and add the package
    sed -i -e '2a\  - '"$package_name" "$yaml_file"
else
    # Add the new package to the `packages:` block with the correct format and indentation
    sed -i -e "$packages_block_start a\  - $package_name" "$yaml_file"
fi

echo "Added - $package_name to $yaml_file"

