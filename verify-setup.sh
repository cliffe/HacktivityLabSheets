#!/bin/bash

# Verification script for Jekyll setup

echo "🔍 Verifying Jekyll setup..."
echo ""

# Check if we're in the right directory
if [ -f "_config.yml" ] && [ -d "_labs" ]; then
    echo "✅ In correct Jekyll project directory"
else
    echo "❌ Not in a Jekyll project directory"
    exit 1
fi

# Check for required files
echo "🔍 Checking required files..."
required_files=("_config.yml" "index.md" "_layouts/default.html" "_layouts/lab.html" "assets/css/hacktivity-theme.scss")
for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file exists"
    else
        echo "❌ $file is missing"
    fi
done

# Check for lab files
echo ""
echo "🔍 Checking lab files..."
lab_count=$(find _labs -name "*.md" | wc -l)
echo "📄 Found $lab_count lab files"

# Check for plugins
echo ""
echo "🔍 Checking plugins..."
if [ -f "_plugins/include_subdirectories.rb" ]; then
    echo "✅ Subdirectory inclusion plugin exists"
else
    echo "❌ Subdirectory inclusion plugin missing"
fi

# Check Gemfile
echo ""
echo "🔍 Checking Gemfile..."
if [ -f "Gemfile" ]; then
    echo "✅ Gemfile exists"
    echo "📦 Dependencies:"
    grep "gem " Gemfile | sed 's/^/   /'
else
    echo "❌ Gemfile missing"
fi

echo ""
echo "🎯 Setup verification complete!"
echo ""
echo "Next steps:"
echo "1. Install Ruby (see INSTALL.md)"
echo "2. Run: ./test-jekyll.sh"
echo "3. Open http://localhost:4000 in your browser"
