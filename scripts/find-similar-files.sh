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

# Create a temporary directory for grouping files
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# First pass: collect all files and group by basename
find . -name "$PATTERN" -type f ! -path "./.git/*" ! -path "./k8s-templates/*" -print0 | \
while IFS= read -r -d '' file; do
    basename_file=$(basename "$file")
    # Create a list file for each basename
    echo "$file" >> "$tmpdir/$basename_file.list"
done

# Report on groups with multiple files
echo "File groups with potential duplication:"
echo ""

for list_file in "$tmpdir"/*.list; do
    [ -f "$list_file" ] || continue
    
    # Get the basename from the list filename
    name=$(basename "$list_file" .list)
    
    # Count files in this group
    count=$(wc -l < "$list_file")
    
    if [ "$count" -gt 1 ]; then
        echo "Group: $name (${count} files)"
        
        # Show first few files as examples
        head -5 "$list_file" | while IFS= read -r file; do
            echo "  - $file"
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
find . -path "*/patches/*.yaml" ! -path "./.git/*" -print0 | while IFS= read -r -d '' file; do
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
