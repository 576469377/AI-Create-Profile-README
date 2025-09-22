#!/bin/bash

# Template Comparison Tool
# Helps users compare different templates side by side

echo "🔍 Template Comparison Tool"
echo "==========================="

# Function to display template info
show_template_info() {
    local template_file="$1"
    local template_name=$(basename "$template_file" .md)
    local category=$(basename $(dirname "$template_file"))
    
    echo ""
    echo "📄 Template: $template_name"
    echo "📂 Category: $category"
    echo "📊 File size: $(wc -l < "$template_file") lines"
    
    # Get description
    local description=$(awk '/^A .* template/ {print $0; exit}' "$template_file" 2>/dev/null || echo "No description available")
    echo "📝 Description: $description"
    
    # Extract key features
    echo "✨ Features:"
    awk '/^```markdown$/,/^```$/ {
        if (/^#/) print "   • " $0
        if (/badge|img|svg|stats/) print "   • Visual elements detected"
    }' "$template_file" | head -5 | sed 's/^#*//g'
    
    # Show first few lines of content
    echo "👀 Preview:"
    awk '/^```markdown$/,/^```$/ {if (!/^```/) print "   " $0}' "$template_file" | head -8
    echo "   ..."
}

# Function to compare two templates
compare_templates() {
    local template1="$1"
    local template2="$2"
    
    echo ""
    echo "🔍 Detailed Comparison"
    echo "====================="
    
    echo ""
    echo "📊 Statistics:"
    printf "%-20s | %-10s | %-10s\n" "Metric" "Template 1" "Template 2"
    printf "%-20s | %-10s | %-10s\n" "$(printf '%*s' 20 | tr ' ' '-')" "$(printf '%*s' 10 | tr ' ' '-')" "$(printf '%*s' 10 | tr ' ' '-')"
    
    local lines1=$(wc -l < "$template1")
    local lines2=$(wc -l < "$template2")
    printf "%-20s | %-10s | %-10s\n" "Lines" "$lines1" "$lines2"
    
    local chars1=$(wc -c < "$template1")
    local chars2=$(wc -c < "$template2")
    printf "%-20s | %-10s | %-10s\n" "Characters" "$chars1" "$chars2"
    
    local images1=$(grep -c "img\|badge\|svg" "$template1" 2>/dev/null || echo "0")
    local images2=$(grep -c "img\|badge\|svg" "$template2" 2>/dev/null || echo "0")
    printf "%-20s | %-10s | %-10s\n" "Visual elements" "$images1" "$images2"
    
    local headers1=$(awk '/^```markdown$/,/^```$/ {if (/^#/) count++} END {print count+0}' "$template1")
    local headers2=$(awk '/^```markdown$/,/^```$/ {if (/^#/) count++} END {print count+0}' "$template2")
    printf "%-20s | %-10s | %-10s\n" "Sections" "$headers1" "$headers2"
    
    echo ""
    echo "🎯 Recommendations:"
    
    if [ $lines1 -gt $lines2 ]; then
        echo "   • Template 1 is more comprehensive (more content)"
    else
        echo "   • Template 2 is more comprehensive (more content)"
    fi
    
    if [ "$images1" -gt "$images2" ]; then
        echo "   • Template 1 has more visual elements"
    elif [ "$images2" -gt "$images1" ]; then
        echo "   • Template 2 has more visual elements"
    else
        echo "   • Both templates have similar visual complexity"
    fi
    
    # Check for specific features
    if grep -q "typing" "$template1" "$template2" 2>/dev/null; then
        echo "   • Animated typing effects detected"
    fi
    
    if grep -q "stats" "$template1" "$template2" 2>/dev/null; then
        echo "   • GitHub statistics integration available"
    fi
    
    if grep -q "badge" "$template1" "$template2" 2>/dev/null; then
        echo "   • Custom badges and shields included"
    fi
}

# Main script logic
if [ $# -eq 0 ]; then
    echo ""
    echo "Usage: $0 [template1] [template2]"
    echo ""
    echo "Examples:"
    echo "  $0 templates/minimalist/clean-professional.md"
    echo "  $0 templates/developer/code-warrior.md templates/gaming/rpg-character-sheet.md"
    echo ""
    echo "Available templates:"
    
    for category in templates/*/; do
        if [ -d "$category" ]; then
            category_name=$(basename "$category")
            echo ""
            echo "📂 $category_name:"
            find "$category" -name "*.md" ! -name "README.md" -type f | while read template; do
                template_name=$(basename "$template" .md)
                echo "   • templates/$category_name/$template_name.md"
            done
        fi
    done
    
    exit 0
fi

template1="$1"
template2="$2"

# Validate template files
if [ ! -f "$template1" ]; then
    echo "❌ Template file not found: $template1"
    exit 1
fi

echo "Template 1:"
show_template_info "$template1"

if [ -n "$template2" ]; then
    if [ ! -f "$template2" ]; then
        echo "❌ Template file not found: $template2"
        exit 1
    fi
    
    echo ""
    echo "Template 2:"
    show_template_info "$template2"
    
    compare_templates "$template1" "$template2"
else
    echo ""
    echo "💡 To compare with another template, run:"
    echo "   $0 \"$template1\" \"templates/category/template-name.md\""
fi

echo ""
echo "🚀 To use a template:"
echo "   ./setup.sh --username=yourusername --preset=category"
echo "   Or copy the content manually from the template file"