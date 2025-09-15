# Jekyll Installation and Testing Guide

## Prerequisites Installation

### Option 1: Using Snap (Recommended)
```bash
sudo snap install ruby --classic
```

### Option 2: Using APT
```bash
sudo apt update
sudo apt install ruby-full build-essential
```

### Option 3: Using rbenv (For development)
```bash
# Install rbenv
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash

# Add to your shell profile (~/.bashrc or ~/.zshrc)
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

# Install Ruby
rbenv install 3.1.0
rbenv global 3.1.0
```

## Install Bundler and Dependencies

Once Ruby is installed, run these commands in the project directory:

```bash
# Install Bundler
gem install bundler

# Install project dependencies
bundle install
```

## Test the Site

### Build the Site
```bash
bundle exec jekyll build
```

### Serve Locally
```bash
bundle exec jekyll serve
```

The site will be available at `http://localhost:4000`

### Serve with Live Reload
```bash
bundle exec jekyll serve --livereload
```

## Troubleshooting

### If you get permission errors:
```bash
# Install gems to user directory
bundle config set --local path 'vendor/bundle'
bundle install
```

### If you get SSL errors:
```bash
# Update certificates
sudo apt-get update
sudo apt-get install ca-certificates
```

### If Jekyll build fails:
```bash
# Clean and rebuild
bundle exec jekyll clean
bundle exec jekyll build --verbose
```

## Expected Output

When you run `bundle exec jekyll serve`, you should see:
- Site building successfully
- Server starting on http://localhost:4000
- No errors in the output

## Features to Test

1. **Main Page**: Should show labs organized by category
2. **Dark Mode**: Should be the default theme
3. **Theme Toggle**: Should switch between dark and light modes
4. **Lab Pages**: Should display individual lab content
5. **Fonts**: Should use Do Hyeon for headings and Source Code Pro for code
6. **Responsive Design**: Should work on different screen sizes

## GitHub Pages Deployment

If you want to deploy to GitHub Pages:

```bash
# Switch to GitHub Pages compatible setup
./switch-to-github-pages.sh

# Build for production
bundle exec jekyll build
```

Then commit and push to your GitHub repository.
