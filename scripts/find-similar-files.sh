#!/bin/bash
#
# Find similar files that might be candidates for refactoring
# Usage: ./scripts/find-similar-files.sh [pattern]
#
# This script helps identify duplicated code by finding files with similar content

set -e

PATTERN="${1:-*.yaml}"

echo "Finding similar files matching pattern: $PATTERN"
echo "---"

# Group files by name pattern
declare -A file_groups

# Use proper file handling with null delimiters
while IFS= read -r -d '' file; do
    basename_file=$(basename "$file")
    
    # Group by filename (vs.yaml, volume.yaml, etc.)
    if [[ ! -v file_groups["$basename_file"] ]]; then
        file_groups["$basename_file"]=""
    fi
    file_groups["$basename_file"]+="$file "
done < <(find . -name "$PATTERN" -type f ! -path "./.git/*" ! -path "./k8s-templates/*" -print0 | sort -z)

# Report on groups with multiple files
echo "File groups with potential duplication:"
echo ""

for name in "${!file_groups[@]}"; do
    # Read files into array safely
    IFS=' ' read -r -a files_array <<< "${file_groups[$name]}"
    count=${#files_array[@]}
    
    if [ "$count" -gt 1 ]; then
        echo "Group: $name (${count} files)"
        
        # Show first few files as examples
        display_count=$((count < 5 ? count : 5))
        for ((i=0; i<display_count; i++)); do
            echo "  - ${files_array[$i]}"
        done
        
        if [ "$count" -gt 5 ]; then
            echo "  ... and $((count - 5)) more"
        fi
        
        echo ""
    fi
done

# Report patches with similar patterns
echo "---"
echo "Patch files (potential for consolidation):"
find . -path "*/patches/*.yaml" ! -path "./.git/*" | while read -r file; do
    basename_file=$(basename "$file")
    echo "  - $file ($basename_file)"
done | sort -k3

echo ""
echo "---"
echo "Recommendations:"
echo "1. Review file groups with multiple instances"
echo "2. Consider using k8s-templates/ for common patterns"
echo "3. Use Kustomize patches for minor variations"
echo "4. Document patterns in k8s-templates/README.md"
