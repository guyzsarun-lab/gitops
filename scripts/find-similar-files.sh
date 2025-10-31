#!/bin/bash
#
# Find similar files that might be candidates for refactoring
# Usage: ./scripts/find-similar-files.sh [pattern]
#
# This script helps identify duplicated code by finding files with similar content

set -e

PATTERN="${1:-*.yaml}"
MIN_SIMILARITY=70  # Minimum similarity percentage to report

echo "Finding similar files matching pattern: $PATTERN"
echo "Minimum similarity threshold: ${MIN_SIMILARITY}%"
echo "---"

# Find all matching files
FILES=$(find . -name "$PATTERN" -type f ! -path "./.git/*" ! -path "./k8s-templates/*" | sort)

# Function to calculate simple similarity based on line overlap
# This is a simplified approach - for production use, consider using proper diff tools
compare_files() {
    local file1="$1"
    local file2="$2"
    
    # Get total lines in both files (excluding empty lines)
    local lines1=$(grep -c ^ "$file1" || echo 0)
    local lines2=$(grep -c ^ "$file2" || echo 0)
    
    if [ "$lines1" -eq 0 ] || [ "$lines2" -eq 0 ]; then
        echo 0
        return
    fi
    
    # Count common lines
    local common=$(comm -12 <(sort "$file1") <(sort "$file2") | grep -c ^ || echo 0)
    local avg_lines=$(( (lines1 + lines2) / 2 ))
    
    # Calculate similarity percentage
    if [ "$avg_lines" -gt 0 ]; then
        local similarity=$(( (common * 100) / avg_lines ))
        echo "$similarity"
    else
        echo 0
    fi
}

# Group files by name pattern
declare -A file_groups

for file in $FILES; do
    basename_file=$(basename "$file")
    
    # Group by filename (vs.yaml, volume.yaml, etc.)
    if [[ ! -v file_groups["$basename_file"] ]]; then
        file_groups["$basename_file"]=""
    fi
    file_groups["$basename_file"]+="$file "
done

# Report on groups with multiple files
echo "File groups with potential duplication:"
echo ""

for name in "${!file_groups[@]}"; do
    files_array=(${file_groups[$name]})
    count=${#files_array[@]}
    
    if [ "$count" -gt 1 ]; then
        echo "Group: $name (${count} files)"
        
        # Show first few files as examples
        for ((i=0; i<${count} && i<5; i++)); do
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
