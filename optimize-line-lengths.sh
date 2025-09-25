#!/bin/bash

# Template Line Length Optimizer
# This script fixes overly long lines in template files to improve readability and validation

echo "📏 Optimizing template line lengths..."
echo "====================================="

# Function to wrap long URLs and image tags
optimize_template() {
    local file="$1"
    local temp_file=$(mktemp)
    
    echo "  📄 Processing: $(basename "$file")"
    
    # Create backup
    cp "$file" "$file.bak"
    
    # Process the file line by line
    while IFS= read -r line; do
        line_length=${#line}
        
        # If line is longer than 200 characters, try to optimize it
        if [ $line_length -gt 200 ]; then
            # Check if it's an img tag or URL that can be split
            if [[ "$line" =~ \<img.*src=.*\> ]]; then
                # Split long img tags with proper indentation
                echo "$line" | sed 's/\s*width=/\n    width=/g; s/\s*height=/\n    height=/g; s/\s*alt=/\n    alt=/g' >> "$temp_file"
            elif [[ "$line" =~ https?:// ]]; then
                # For lines with URLs, try to break at logical points
                echo "$line" | sed 's/&/\&\n    /g; s/?/?\n    /g' | head -1 >> "$temp_file"
                echo "$line" | sed 's/&/\&\n    /g; s/?/?\n    /g' | tail -n +2 | sed 's/^/    /' >> "$temp_file"
            elif [[ "$line" =~ ^[[:space:]]*[A-Za-z] ]] && [[ ! "$line" =~ ^\#|^\* ]]; then
                # For regular text paragraphs, try to wrap at word boundaries
                echo "$line" | fold -w 120 -s >> "$temp_file"
            else
                # For other long lines, keep as-is but warn
                echo "    ⚠️  Long line detected (${line_length} chars) but cannot auto-fix"
                echo "$line" >> "$temp_file"
            fi
        else
            # Regular line, copy as-is
            echo "$line" >> "$temp_file"
        fi
    done < "$file"
    
    # Replace original with optimized version
    mv "$temp_file" "$file"
    
    # Compare file sizes
    original_lines=$(wc -l < "$file.bak")
    new_lines=$(wc -l < "$file")
    
    if [ $new_lines -gt $original_lines ]; then
        echo "    ✅ Optimized: $original_lines → $new_lines lines"
        rm "$file.bak"
    else
        echo "    ℹ️  No optimization needed"
        mv "$file.bak" "$file"
    fi
}

# Find and process all template files
total_processed=0
total_optimized=0

echo "🔍 Scanning template files..."

# Use process substitution to avoid subshell and variable scope issues
while IFS= read -r template_file; do
    # Skip README files in category directories  
    if [[ $(basename "$template_file") != "README.md" ]]; then
        optimize_template "$template_file"
        ((total_processed++))
    fi
done < <(find templates -name "*.md" -type f)

echo ""
echo "📊 Summary:"
echo "  Templates processed: $total_processed"
echo ""
echo "💡 Note: Some long lines (like URLs) might still exceed 200 characters"
echo "   for functionality reasons. This is acceptable for template validation."