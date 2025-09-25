#!/bin/bash

# Fix deprecated Heroku services in templates
# This script replaces deprecated herokuapp.com URLs with more reliable alternatives

echo "🔧 Fixing deprecated Heroku services in templates..."
echo "======================================================"

# Function to create backup
create_backup() {
    local file="$1"
    cp "$file" "$file.bak"
    echo "  📋 Created backup: $file.bak"
}

# Function to restore from backup if needed
restore_backup() {
    local file="$1"
    if [ -f "$file.bak" ]; then
        mv "$file.bak" "$file"
        echo "  ↩️  Restored from backup: $file"
    fi
}

# Counter for changes
total_changes=0

# Find all template files
echo "🔍 Scanning template files..."
template_files=$(find templates -name "*.md" -type f)

for file in $template_files; do
    echo ""
    echo "📄 Processing: $file"
    
    # Check if file contains deprecated services
    if grep -q "herokuapp\.com" "$file"; then
        create_backup "$file"
        
        # Replace readme-typing-svg.herokuapp.com with readme-typing-svg.demolab.com
        if grep -q "readme-typing-svg\.herokuapp\.com" "$file"; then
            sed -i 's|readme-typing-svg\.herokuapp\.com|readme-typing-svg.demolab.com|g' "$file"
            echo "  ✅ Fixed readme-typing-svg service"
            ((total_changes++))
        fi
        
        # Replace github-readme-streak-stats.herokuapp.com with streak-stats.demolab.com
        if grep -q "github-readme-streak-stats\.herokuapp\.com" "$file"; then
            sed -i 's|github-readme-streak-stats\.herokuapp\.com|streak-stats.demolab.com|g' "$file"
            echo "  ✅ Fixed streak-stats service"
            ((total_changes++))
        fi
        
        # Verify changes didn't break anything
        if [ ! -s "$file" ]; then
            echo "  ❌ Error: File became empty, restoring backup"
            restore_backup "$file"
        else
            echo "  ✅ File updated successfully"
            rm -f "$file.bak"
        fi
    else
        echo "  ⏭️  No deprecated services found"
    fi
done

echo ""
echo "📊 Summary:"
echo "  Total files processed: $(echo "$template_files" | wc -l)"
echo "  Total service URLs updated: $total_changes"
echo ""

if [ $total_changes -gt 0 ]; then
    echo "✅ Service migration completed successfully!"
    echo ""
    echo "📝 Changes made:"
    echo "  • readme-typing-svg.herokuapp.com → readme-typing-svg.demolab.com"
    echo "  • github-readme-streak-stats.herokuapp.com → streak-stats.demolab.com"
    echo ""
    echo "💡 Note: These new services are more reliable and actively maintained."
else
    echo "ℹ️  No deprecated services found to update."
fi