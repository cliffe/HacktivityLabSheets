#!/bin/bash

# Start Jekyll server script for Hacktivity Lab Sheets
# This script sets up the proper environment and starts the Jekyll server

echo "🚀 Starting Hacktivity Lab Sheets server..."

# Change to project directory
cd "$(dirname "$0")"

# Check if vendor directory exists
if [ ! -d "vendor/bundle" ]; then
    echo "❌ Vendor directory not found. Please run bundle install first."
    echo "   Try running: ./test-jekyll.sh"
    exit 1
fi

# Check if Jekyll executable exists
if [ ! -f "vendor/bundle/ruby/3.2.0/bin/jekyll" ]; then
    echo "❌ Jekyll executable not found in vendor directory."
    echo "   Try running: ./test-jekyll.sh"
    exit 1
fi

echo "✅ Environment set up successfully"
echo "📱 Starting Jekyll server..."
echo "🌐 Site will be available at: http://localhost:4000"
echo "🌐 Also available at: http://0.0.0.0:4000"
echo "🛑 Press Ctrl+C to stop the server"
echo ""

# Use the vendor bundle with proper Ruby environment
exec env GEM_HOME="$(pwd)/vendor/bundle" GEM_PATH="$(pwd)/vendor/bundle" PATH="$(pwd)/vendor/bundle/ruby/3.2.0/bin:$PATH" vendor/bundle/ruby/3.2.0/bin/jekyll serve --host 0.0.0.0 --port 4000 --livereload
