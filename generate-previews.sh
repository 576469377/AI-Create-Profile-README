#!/bin/bash

# Template Preview Generator
# Generates HTML previews of all templates for easy comparison

echo "🎨 Generating template previews..."
echo "================================="

# Create preview directory
preview_dir="template-previews"
mkdir -p "$preview_dir"

# HTML template for previews
create_html_header() {
    cat > "$preview_dir/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>GitHub Profile README Template Previews</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            margin: 0;
            padding: 20px;
            background: #f8f9fa;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        .header {
            text-align: center;
            margin-bottom: 40px;
            padding: 20px;
            background: white;
            border-radius: 10px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .category {
            margin-bottom: 40px;
        }
        .category h2 {
            color: #2c3e50;
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        .template-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(400px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .template-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }
        .template-card:hover {
            transform: translateY(-5px);
        }
        .template-name {
            font-size: 1.2em;
            font-weight: bold;
            color: #2c3e50;
            margin-bottom: 10px;
            text-transform: capitalize;
        }
        .template-description {
            color: #7f8c8d;
            margin-bottom: 15px;
            font-size: 0.9em;
        }
        .template-preview {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            border-left: 4px solid #3498db;
            font-family: 'Courier New', monospace;
            font-size: 0.8em;
            overflow-x: auto;
            max-height: 300px;
            overflow-y: auto;
        }
        .template-actions {
            margin-top: 15px;
            text-align: center;
        }
        .btn {
            display: inline-block;
            padding: 8px 16px;
            background: #3498db;
            color: white;
            text-decoration: none;
            border-radius: 5px;
            font-size: 0.9em;
            transition: background 0.3s ease;
        }
        .btn:hover {
            background: #2980b9;
        }
        .stats {
            text-align: center;
            margin: 20px 0;
            color: #7f8c8d;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🎨 GitHub Profile README Template Previews</h1>
            <p>Browse and compare all available templates in one place</p>
            <div class="stats">
                <strong>Total Templates:</strong> <span id="template-count">0</span> |
                <strong>Categories:</strong> <span id="category-count">0</span>
            </div>
        </div>
EOF
}

# Function to extract template description
get_template_description() {
    local template_file="$1"
    # Get the first paragraph after the title
    awk '/^A .* template/ {print $0; exit}' "$template_file" || echo "Professional GitHub profile template"
}

# Function to extract template preview content
get_template_preview() {
    local template_file="$1"
    # Extract first 15 lines of the markdown content
    awk '/^```markdown$/{flag=1; next} /^```$/ && flag{exit} flag' "$template_file" | head -15
}

# Generate previews for each category
total_templates=0
total_categories=0

for category_dir in templates/*/; do
    if [ -d "$category_dir" ]; then
        category_name=$(basename "$category_dir")
        ((total_categories++))
        
        echo "  📂 Processing category: $category_name"
        
        # Add category section to HTML
        cat >> "$preview_dir/index.html" << EOF
        <div class="category">
            <h2>$(echo ${category_name^} | sed 's/-/ /g') Templates</h2>
            <div class="template-grid">
EOF
        
        # Process each template in the category
        for template_file in "$category_dir"*.md; do
            if [ -f "$template_file" ] && [ "$(basename "$template_file")" != "README.md" ]; then
                template_name=$(basename "$template_file" .md)
                ((total_templates++))
                
                echo "    📄 Processing template: $template_name"
                
                description=$(get_template_description "$template_file")
                preview_content=$(get_template_preview "$template_file")
                
                # Escape HTML characters in preview
                preview_content=$(echo "$preview_content" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g')
                
                cat >> "$preview_dir/index.html" << EOF
                <div class="template-card">
                    <div class="template-name">$(echo ${template_name} | sed 's/-/ /g')</div>
                    <div class="template-description">$description</div>
                    <div class="template-preview">
<pre>$preview_content</pre>
                    </div>
                    <div class="template-actions">
                        <a href="../$template_file" class="btn">View Full Template</a>
                    </div>
                </div>
EOF
            fi
        done
        
        # Close category section
        cat >> "$preview_dir/index.html" << EOF
            </div>
        </div>
EOF
    fi
done

# Close HTML and add statistics
cat >> "$preview_dir/index.html" << EOF
    </div>
    
    <script>
        document.getElementById('template-count').textContent = '$total_templates';
        document.getElementById('category-count').textContent = '$total_categories';
    </script>
</body>
</html>
EOF

echo ""
echo "✅ Preview generation completed!"
echo "📊 Statistics:"
echo "  • Templates processed: $total_templates"
echo "  • Categories: $total_categories"
echo "  • Output file: $preview_dir/index.html"
echo ""
echo "🌐 To view the previews:"
echo "  • Open $preview_dir/index.html in your web browser"
echo "  • Or serve locally: python3 -m http.server 8000"

# Add to gitignore if not already there
if ! grep -q "$preview_dir" .gitignore 2>/dev/null; then
    echo "" >> .gitignore
    echo "# Generated template previews" >> .gitignore
    echo "$preview_dir/" >> .gitignore
    echo "📝 Added $preview_dir/ to .gitignore"
fi