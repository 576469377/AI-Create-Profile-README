#!/bin/bash

# GitHub Profile README Template Setup Script
# This script helps users set up their GitHub profile README quickly

echo "🎨 GitHub Profile README Template Setup"
echo "======================================="
echo ""

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Get GitHub username
echo "📝 Please enter your GitHub username:"
read -r username

if [ -z "$username" ]; then
    echo "❌ Username cannot be empty."
    exit 1
fi

echo ""
echo "🔍 Available template categories:"
echo "1. Minimalist - Clean and professional"
echo "2. Developer - Technical and skill-focused"
echo "3. Creative - Visually striking designs"
echo "4. Gaming - Fun and interactive"
echo "5. Business - Corporate and professional"
echo "6. Animated - Dynamic and interactive"
echo "7. Statistics - Data-heavy displays"
echo ""

echo "📂 Please select a category (1-7):"
read -r category

case $category in
    1) category_name="minimalist" ;;
    2) category_name="developer" ;;
    3) category_name="creative" ;;
    4) category_name="gaming" ;;
    5) category_name="business" ;;
    6) category_name="animated" ;;
    7) category_name="statistics" ;;
    *) echo "❌ Invalid selection." && exit 1 ;;
esac

echo ""
echo "🎯 Available templates in $category_name:"

# List available templates in the category
templates_dir="templates/$category_name"
if [ -d "$templates_dir" ]; then
    template_files=($(find "$templates_dir" -name "*.md" ! -name "README.md" -type f))
    
    if [ ${#template_files[@]} -eq 0 ]; then
        echo "❌ No templates found in this category."
        exit 1
    fi
    
    for i in "${!template_files[@]}"; do
        template_name=$(basename "${template_files[$i]}" .md)
        echo "$((i+1)). $template_name"
    done
    
    echo ""
    echo "📄 Please select a template (1-${#template_files[@]}):"
    read -r template_choice
    
    if [[ $template_choice -lt 1 || $template_choice -gt ${#template_files[@]} ]]; then
        echo "❌ Invalid template selection."
        exit 1
    fi
    
    selected_template="${template_files[$((template_choice-1))]}"
    template_name=$(basename "$selected_template" .md)
    
else
    echo "❌ Template category not found."
    exit 1
fi

echo ""
echo "✅ Selected template: $template_name"
echo "👤 GitHub username: $username"
echo ""

# Create output directory
output_dir="generated-profile"
mkdir -p "$output_dir"

# Copy and customize template
if [ -f "$selected_template" ]; then
    output_file="$output_dir/README.md"
    
    # Extract the template content (everything after the markdown code block)
    sed -n '/^```markdown$/,/^```$/p' "$selected_template" | sed '1d;$d' > "$output_file"
    
    # Replace placeholders
    sed -i.bak "s/YOUR_USERNAME/$username/g" "$output_file"
    sed -i.bak "s/\[Your Name\]/$(git config user.name || echo "$username")/g" "$output_file"
    
    # Clean up backup file
    rm -f "$output_file.bak"
    
    echo "🎉 Template generated successfully!"
    echo "📁 Output file: $output_file"
    echo ""
    echo "📋 Next steps:"
    echo "1. Review and customize the generated README.md"
    echo "2. Create a repository named '$username' on GitHub"
    echo "3. Upload the README.md file to your repository"
    echo "4. Visit github.com/$username to see your new profile!"
    echo ""
    echo "📚 For detailed instructions, see: https://github.com/576469377/AI-Create-Profile-README/blob/main/USAGE.md"
    
else
    echo "❌ Template file not found: $selected_template"
    exit 1
fi