#!/bin/bash

# Test script for Jekyll installation and site building

echo "🔍 Checking Ruby installation..."
if command -v ruby &> /dev/null; then
    echo "✅ Ruby is installed: $(ruby --version)"
else
    echo "❌ Ruby is not installed. Please install Ruby first."
    echo "   See INSTALL.md for installation instructions."
    exit 1
fi

echo ""
echo "🔍 Checking Bundler installation..."
if command -v bundle &> /dev/null; then
    echo "✅ Bundler is installed: $(bundle --version)"
else
    echo "❌ Bundler is not installed. Installing..."
    gem install bundler
fi

echo ""
echo "🔍 Installing dependencies..."
bundle install

echo ""
echo "🔍 Building Jekyll site..."
if bundle exec jekyll build; then
    echo "✅ Site built successfully!"
    echo ""
    echo "🔍 Starting Jekyll server..."
    echo "📱 Site will be available at: http://localhost:4000"
    echo "🛑 Press Ctrl+C to stop the server"
    echo ""
    bundle exec jekyll serve --livereload
else
    echo "❌ Site build failed. Check the error messages above."
    exit 1
fi
