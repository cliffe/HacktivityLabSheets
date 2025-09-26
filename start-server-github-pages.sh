#!/bin/bash

echo "🚀 Starting Hacktivity Lab Sheets server (GitHub Pages compatible)..."

# Change to project directory
cd "$(dirname "$0")"

# Install bundler locally if not available
if ! command -v bundle &> /dev/null; then
    echo "📦 Installing bundler locally..."
    gem install --user-install bundler
    export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"
fi

# Install dependencies
echo "📦 Installing dependencies..."
bundle install --path vendor/bundle

# Check if installation was successful
if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies. Trying alternative approach..."
    
    # Try using system gems with local bundler
    export GEM_HOME="$HOME/.local/share/gem/ruby/3.2.0"
    export GEM_PATH="$HOME/.local/share/gem/ruby/3.2.0"
    export PATH="$HOME/.local/share/gem/ruby/3.2.0/bin:$PATH"
    
    bundle install --path vendor/bundle
fi

echo "🌐 Starting Jekyll server..."
echo "📱 Site will be available at: http://localhost:4000"
echo "🌐 Also available at: http://0.0.0.0:4000"
echo "🛑 Press Ctrl+C to stop the server"
echo ""

# Start the server with local configuration
bundle exec jekyll serve --host 0.0.0.0 --port 4000 --livereload --config _config_local.yml
