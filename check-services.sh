#!/bin/bash

# External Service Health Checker
# This script checks the availability of external services used in templates

echo "🔍 Checking external service availability..."
echo "==========================================="

# Services to check
declare -A services=(
    ["readme-typing-svg.demolab.com"]="Typing SVG animation service"
    ["streak-stats.demolab.com"]="GitHub streak stats service"
    ["github-readme-stats.vercel.app"]="GitHub stats service"
    ["komarev.com"]="Profile view counter service"
    ["shields.io"]="Badge generation service"
    ["skillicons.dev"]="Skill icons service"
    ["capsule-render.vercel.app"]="Header image generation service"
)

# Function to check service availability
check_service() {
    local service_url="$1"
    local service_name="$2"
    
    echo -n "  🌐 $service_name ($service_url): "
    
    # Check with timeout
    if curl -s --max-time 10 --head "https://$service_url" > /dev/null 2>&1; then
        echo "✅ Available"
        return 0
    else
        echo "❌ Unavailable"
        return 1
    fi
}

# Function to suggest fallback content
suggest_fallback() {
    local service="$1"
    
    case "$service" in
        *"typing-svg"*)
            echo "    💡 Fallback: Use static text with emojis or regular headers"
            ;;
        *"streak-stats"*)
            echo "    💡 Fallback: Use regular GitHub stats or activity graph"
            ;;
        *"github-readme-stats"*)
            echo "    💡 Fallback: Use native GitHub contribution graph"
            ;;
        *"shields.io"*)
            echo "    💡 Fallback: Use simple text badges or GitHub default badges"
            ;;
        *)
            echo "    💡 Fallback: Consider using static alternatives"
            ;;
    esac
}

# Check all services
unavailable_services=0
total_services=${#services[@]}

echo ""
for service_url in "${!services[@]}"; do
    service_name="${services[$service_url]}"
    
    if ! check_service "$service_url" "$service_name"; then
        ((unavailable_services++))
        suggest_fallback "$service_url"
        echo ""
    fi
done

echo ""
echo "📊 Service Health Summary:"
echo "  Total services: $total_services"
echo "  Available: $((total_services - unavailable_services))"
echo "  Unavailable: $unavailable_services"

if [ $unavailable_services -eq 0 ]; then
    echo "  🎉 All services are operational!"
else
    echo "  ⚠️  Some services are down. Templates may show broken images/badges."
    echo ""
    echo "🛠️  Recommended actions:"
    echo "  1. Update templates with fallback content"
    echo "  2. Consider using more reliable service alternatives"
    echo "  3. Add offline-friendly template versions"
fi

echo ""
echo "💡 Pro tip: Run this script before major releases to ensure all external"
echo "   dependencies are working properly."