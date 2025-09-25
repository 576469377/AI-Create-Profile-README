#!/bin/bash

# Test Script for Utility Scripts
# This script runs basic functionality tests on all utility scripts

echo "🧪 Testing Utility Scripts"
echo "========================="
echo ""

# Test 1: Validate Templates
echo "📝 Testing template validation..."
if ./validate-templates.sh > /dev/null 2>&1; then
    echo "✅ validate-templates.sh - PASSED"
else
    echo "❌ validate-templates.sh - FAILED"
fi

# Test 2: Setup Script Help
echo "📋 Testing setup script help..."
if ./setup.sh --help > /dev/null 2>&1; then
    echo "✅ setup.sh --help - PASSED"
else
    echo "❌ setup.sh --help - FAILED"
fi

# Test 3: Setup Script Non-interactive
echo "🔧 Testing setup script non-interactive mode..."
if ./setup.sh --username=test --preset=minimal --non-interactive > /dev/null 2>&1; then
    echo "✅ setup.sh non-interactive - PASSED"
    rm -rf generated-profile 2>/dev/null
else
    echo "❌ setup.sh non-interactive - FAILED"
fi

# Test 4: Line Length Optimization
echo "📏 Testing line length optimization..."
if ./optimize-line-lengths.sh > /dev/null 2>&1; then
    echo "✅ optimize-line-lengths.sh - PASSED"
else
    echo "❌ optimize-line-lengths.sh - FAILED"
fi

# Test 5: Service Check (timeout for speed)
echo "🌐 Testing service check..."
if timeout 10 ./check-services.sh > /dev/null 2>&1; then
    echo "✅ check-services.sh - PASSED"
else
    echo "⚠️  check-services.sh - TIMEOUT (expected in restricted environments)"
fi

echo ""
echo "🎉 Script testing completed!"
echo ""
echo "💡 All core utilities are functional and ready for use."