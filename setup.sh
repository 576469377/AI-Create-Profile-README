#!/bin/bash

# GitHub Profile README Template Setup Script
# This script helps users set up their GitHub profile README quickly
#
# Usage:
#   Interactive: ./setup.sh
#   Non-interactive: ./setup.sh --username=myusername --category=1 --template=1
#   Quick setup: ./setup.sh --username=myusername --preset=minimal

set -e  # Exit on any error

echo "🎨 GitHub Profile README Template Setup"
echo "======================================="
echo ""

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Parse command line arguments
username=""
category=""
template=""
preset=""
non_interactive=false

for arg in "$@"; do
    case $arg in
        --username=*)
            username="${arg#*=}"
            non_interactive=true
            ;;
        --category=*)
            category="${arg#*=}"
            ;;
        --template=*)
            template="${arg#*=}"
            ;;
        --preset=*)
            preset="${arg#*=}"
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --username=USERNAME    GitHub username"
            echo "  --category=NUMBER      Template category (1-7)"
            echo "  --template=NUMBER      Template number within category"
            echo "  --preset=PRESET        Quick preset (minimal, developer, gaming, animated)"
            echo "  --help, -h             Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                                    # Interactive mode"
            echo "  $0 --username=john --preset=minimal  # Quick minimal setup"
            echo "  $0 --username=jane --category=2 --template=1  # Specific template"
            exit 0
            ;;
    esac
done

# Handle presets
if [ -n "$preset" ]; then
    case $preset in
        minimal|min)
            category=1
            template=1
            ;;
        developer|dev)
            category=2
            template=1
            ;;
        creative)
            category=3
            template=1
            ;;
        gaming|game)
            category=4
            template=1
            ;;
        business|biz)
            category=5
            template=1
            ;;
        animated|anim)
            category=6
            template=1
            ;;
        statistics|stats)
            category=7
            template=1
            ;;
        *)
            echo "❌ Unknown preset: $preset"
            echo "Available presets: minimal, developer, creative, gaming, business, animated, statistics"
            exit 1
            ;;
    esac
fi

# Get GitHub username if not provided
if [ -z "$username" ]; then
    echo "📝 Please enter your GitHub username:"
    read -r username
    
    if [ -z "$username" ]; then
        echo "❌ Username cannot be empty."
        exit 1
    fi
fi

# Validate username format (basic check)
if [[ ! "$username" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]] && [[ ${#username} -gt 39 ]]; then
    echo "⚠️  Warning: Username '$username' may not be a valid GitHub username format."
    if [ "$non_interactive" = false ]; then
        echo "   Do you want to continue anyway? (y/N)"
        read -r confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

# Get category if not provided
if [ -z "$category" ]; then
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
fi

case $category in
    1) category_name="minimalist" ;;
    2) category_name="developer" ;;
    3) category_name="creative" ;;
    4) category_name="gaming" ;;
    5) category_name="business" ;;
    6) category_name="animated" ;;
    7) category_name="statistics" ;;
    *) echo "❌ Invalid selection: $category. Must be 1-7." && exit 1 ;;
esac

# List available templates in the category
templates_dir="templates/$category_name"
if [ ! -d "$templates_dir" ]; then
    echo "❌ Template category directory not found: $templates_dir"
    exit 1
fi

template_files=($(find "$templates_dir" -name "*.md" ! -name "README.md" -type f | sort))

if [ ${#template_files[@]} -eq 0 ]; then
    echo "❌ No templates found in category: $category_name"
    exit 1
fi

# Get template selection if not provided
if [ -z "$template" ]; then
    echo ""
    echo "🎯 Available templates in $category_name:"
    
    for i in "${!template_files[@]}"; do
        template_name=$(basename "${template_files[$i]}" .md)
        echo "$((i+1)). $template_name"
    done
    
    echo ""
    echo "📄 Please select a template (1-${#template_files[@]}):"
    read -r template
fi

if [[ $template -lt 1 || $template -gt ${#template_files[@]} ]]; then
    echo "❌ Invalid template selection: $template. Must be 1-${#template_files[@]}."
    exit 1
fi

selected_template="${template_files[$((template-1))]}"
template_name=$(basename "$selected_template" .md)

echo ""
echo "✅ Selected template: $template_name"
echo "👤 GitHub username: $username"
echo ""

# Create output directory
output_dir="generated-profile"
mkdir -p "$output_dir"

# Copy and customize template
if [ ! -f "$selected_template" ]; then
    echo "❌ Template file not found: $selected_template"
    exit 1
fi

output_file="$output_dir/README.md"

# Simple extraction - find content between ```markdown and ```
echo "📝 Extracting template content..."

# Use python for reliable extraction (most systems have python)
python3 -c "
import sys
with open('$selected_template', 'r') as f:
    lines = f.readlines()

start_found = False
content = []

for line in lines:
    if line.strip() == '\`\`\`markdown':
        start_found = True
        continue
    elif line.strip() == '\`\`\`' and start_found:
        break
    elif start_found:
        content.append(line)

with open('$output_file', 'w') as f:
    f.writelines(content)
" 2>/dev/null || {
    # Fallback to sed if python is not available
    sed -n '/^```markdown$/,/^```$/p' "$selected_template" | sed '1d;$d' > "$output_file"
}

# Verify extraction was successful
if [ ! -s "$output_file" ]; then
    echo "❌ Template extraction failed - no content found"
    exit 1
fi

echo "✅ Template extracted successfully"

# Replace placeholders safely
echo "🔄 Customizing template..."

# Create a temporary file for safe processing
temp_file=$(mktemp)
cp "$output_file" "$temp_file"

# Replace placeholders
sed "s/YOUR_USERNAME/$username/g" "$temp_file" > "$output_file"

# Try to get git user info
git_name=$(git config user.name 2>/dev/null || echo "$username")
git_email=$(git config user.email 2>/dev/null || echo "")

# Replace name placeholders
sed -i.bak "s/\\[Your Name\\]/$git_name/g" "$output_file"

# Replace email placeholders if git email is available
if [ -n "$git_email" ]; then
    sed -i.bak "s/your\\.email@example\\.com/$git_email/g" "$output_file"
    sed -i.bak "s/YOUR_EMAIL@example\\.com/$git_email/g" "$output_file"
fi

# Clean up
rm -f "$output_file.bak" "$temp_file"

# Verify final output
if [ ! -s "$output_file" ]; then
    echo "❌ Template processing resulted in empty file"
    exit 1
fi

echo "✅ Template customized successfully"
echo ""
echo "🎉 Template generated successfully!"
echo "📁 Output file: $output_file"
echo "📊 File size: $(wc -l < "$output_file") lines, $(wc -c < "$output_file") characters"
echo ""
echo "📋 Next steps:"
echo "1. Review and customize the generated README.md"
echo "2. Create a repository named '$username' on GitHub (if needed)"
echo "3. Upload the README.md file to your repository" 
echo "4. Visit github.com/$username to see your new profile!"
echo ""
echo "💡 Pro tips:"
echo "  • Test your profile: https://github.com/$username"
echo "  • Preview locally: cat '$output_file'"
echo "  • Edit template: nano '$output_file'"
echo ""
echo "📚 For detailed instructions, see: https://github.com/576469377/AI-Create-Profile-README/blob/main/USAGE.md"

# Offer to show preview
if [ "$non_interactive" = false ]; then
    echo ""
    echo "Would you like to see a preview of your generated README? (y/N)"
    read -r show_preview
    if [[ "$show_preview" =~ ^[Yy]$ ]]; then
        echo ""
        echo "📖 Preview (first 20 lines):"
        echo "────────────────────────────────────────"
        head -20 "$output_file"
        echo "────────────────────────────────────────"
        echo "Use 'cat $output_file' to see the full content."
    fi
fi

echo ""
echo "🎊 Setup completed successfully!"