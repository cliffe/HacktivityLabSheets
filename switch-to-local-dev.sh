#!/bin/bash

# Script to switch back to local development setup

echo "Switching to local development setup..."

# Use local development Gemfile
cp Gemfile.local-dev Gemfile

echo "✅ Switched to local development setup"
echo ""
echo "To install dependencies:"
echo "  bundle install"
echo ""
echo "To run locally:"
echo "  bundle exec jekyll serve"
