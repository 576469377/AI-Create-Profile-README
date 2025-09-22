#!/bin/bash

# Template Validation Script
# Validates template files for consistency and completeness

echo "🔍 GitHub Profile README Template Validator"
echo "==========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
total_templates=0
valid_templates=0
warnings=0
errors=0

# Validation functions
validate_template() {
    local template_file="$1"
    local template_name=$(basename "$template_file" .md)
    local category=$(basename $(dirname "$template_file"))
    
    echo -e "${BLUE}Validating:${NC} $category/$template_name"
    
    total_templates=$((total_templates + 1))
    local template_valid=true
    local template_warnings=0
    
    # Check if file exists and is not empty
    if [ ! -f "$template_file" ] || [ ! -s "$template_file" ]; then
        echo -e "  ${RED}❌ Error: Template file is missing or empty${NC}"
        errors=$((errors + 1))
        return
    fi
    
    # Check for required sections
    local content=$(cat "$template_file")
    
    # Check for markdown code block
    if ! echo "$content" | grep -q '```markdown'; then
        echo -e "  ${RED}❌ Error: Missing markdown code block${NC}"
        template_valid=false
        errors=$((errors + 1))
    fi
    
    # Check for closing markdown block
    if ! echo "$content" | grep -q '^```$'; then
        echo -e "  ${RED}❌ Error: Missing closing markdown code block${NC}"
        template_valid=false
        errors=$((errors + 1))
    fi
    
    # Check for customization guide
    if ! echo "$content" | grep -qi "customization guide\|customization\|setup\|tips"; then
        echo -e "  ${YELLOW}⚠️  Warning: Missing customization guide${NC}"
        template_warnings=$((template_warnings + 1))
        warnings=$((warnings + 1))
    fi
    
    # Check for placeholder replacement instructions
    if ! echo "$content" | grep -q "YOUR_USERNAME\|YOUR_NAME\|\[Your"; then
        echo -e "  ${YELLOW}⚠️  Warning: No placeholders found for customization${NC}"
        template_warnings=$((template_warnings + 1))
        warnings=$((warnings + 1))
    fi
    
    # Check for contact information template
    if ! echo "$content" | grep -qi "email\|linkedin\|twitter\|github\|portfolio"; then
        echo -e "  ${YELLOW}⚠️  Warning: Missing contact information template${NC}"
        template_warnings=$((template_warnings + 1))
        warnings=$((warnings + 1))
    fi
    
    # Check for GitHub stats integration
    if echo "$content" | grep -q "github-readme-stats\|github-readme-streak"; then
        if ! echo "$content" | grep -q "YOUR_USERNAME"; then
            echo -e "  ${YELLOW}⚠️  Warning: GitHub stats found but no YOUR_USERNAME placeholder${NC}"
            template_warnings=$((template_warnings + 1))
            warnings=$((warnings + 1))
        fi
    fi
    
    # Check template structure (title)
    if ! echo "$content" | head -1 | grep -q "^# "; then
        echo -e "  ${YELLOW}⚠️  Warning: Template should start with # title${NC}"
        template_warnings=$((template_warnings + 1))
        warnings=$((warnings + 1))
    fi
    
    # Check for description after title
    if ! echo "$content" | sed -n '3p' | grep -q "."; then
        echo -e "  ${YELLOW}⚠️  Warning: Missing template description${NC}"
        template_warnings=$((template_warnings + 1))
        warnings=$((warnings + 1))
    fi
    
    # Check line length (warn if any line is extremely long)
    local max_line_length=$(echo "$content" | wc -L)
    if [ "$max_line_length" -gt 200 ]; then
        echo -e "  ${YELLOW}⚠️  Warning: Some lines are very long (>200 chars)${NC}"
        template_warnings=$((template_warnings + 1))
        warnings=$((warnings + 1))
    fi
    
    # Success message
    if [ "$template_valid" = true ]; then
        valid_templates=$((valid_templates + 1))
        if [ "$template_warnings" -eq 0 ]; then
            echo -e "  ${GREEN}✅ Template is valid${NC}"
        else
            echo -e "  ${GREEN}✅ Template is valid${NC} (with $template_warnings warnings)"
        fi
    fi
    
    echo ""
}

# Check README consistency in categories
validate_category_readme() {
    local category_dir="$1"
    local category_name=$(basename "$category_dir")
    local readme_file="$category_dir/README.md"
    
    echo -e "${BLUE}Validating category:${NC} $category_name"
    
    if [ ! -f "$readme_file" ]; then
        echo -e "  ${RED}❌ Error: Category README.md missing${NC}"
        errors=$((errors + 1))
        return
    fi
    
    # Check if all templates in directory are listed in README
    local templates_in_dir=$(find "$category_dir" -name "*.md" ! -name "README.md" -type f)
    local readme_content=$(cat "$readme_file")
    
    for template_file in $templates_in_dir; do
        local template_name=$(basename "$template_file" .md)
        if ! echo "$readme_content" | grep -q "$template_name"; then
            echo -e "  ${YELLOW}⚠️  Warning: Template '$template_name' not listed in category README${NC}"
            warnings=$((warnings + 1))
        fi
    done
    
    echo -e "  ${GREEN}✅ Category README validated${NC}"
    echo ""
}

# Main validation
echo "Starting template validation..."
echo ""

# Validate each category
for category_dir in templates/*/; do
    if [ -d "$category_dir" ]; then
        validate_category_readme "$category_dir"
        
        # Validate each template in category
        for template_file in "$category_dir"*.md; do
            if [ -f "$template_file" ] && [ "$(basename "$template_file")" != "README.md" ]; then
                validate_template "$template_file"
            fi
        done
    fi
done

# Summary report
echo ""
echo "========================================="
echo "📊 VALIDATION SUMMARY"
echo "========================================="
echo -e "Total templates validated: ${BLUE}$total_templates${NC}"
echo -e "Valid templates: ${GREEN}$valid_templates${NC}"
echo -e "Templates with errors: ${RED}$((total_templates - valid_templates))${NC}"
echo -e "Total warnings: ${YELLOW}$warnings${NC}"
echo -e "Total errors: ${RED}$errors${NC}"
echo ""

# Exit status
if [ $errors -eq 0 ]; then
    echo -e "${GREEN}✅ All templates passed validation!${NC}"
    if [ $warnings -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Note: $warnings warnings found. Consider addressing them for better quality.${NC}"
    fi
    exit 0
else
    echo -e "${RED}❌ Validation failed with $errors errors.${NC}"
    exit 1
fi