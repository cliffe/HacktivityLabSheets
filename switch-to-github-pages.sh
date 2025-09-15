#!/bin/bash

# Script to switch to GitHub Pages compatible setup

echo "Switching to GitHub Pages compatible setup..."

# Backup current Gemfile
cp Gemfile Gemfile.local-dev

# Use GitHub Pages compatible Gemfile
cp Gemfile.github-pages Gemfile

echo "✅ Switched to GitHub Pages compatible setup"
echo "📝 Your local development Gemfile has been backed up as Gemfile.local-dev"
echo ""
echo "To switch back to local development:"
echo "  cp Gemfile.local-dev Gemfile"
echo "  bundle install"
echo ""
echo "To deploy to GitHub Pages:"
echo "  git add ."
echo "  git commit -m 'Update for GitHub Pages'"
echo "  git push origin main"
