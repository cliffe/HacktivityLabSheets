# Hacktivity Lab Sheets Setup

This Jekyll site is designed to display cybersecurity lab exercises organized by category.

## Features

- **Organized by Category**: Labs are grouped by their directory structure (e.g., "Introducing Attacks", "Network Security", etc.)
- **Hacktivity Theme**: Custom theme matching the Hacktivity platform with light/dark mode toggle (dark mode default)
- **Google Fonts**: Uses Do Hyeon for headings and Source Code Pro for code, with Helvetica Neue for body text
- **GitHub Pages Compatible**: Ready for deployment on GitHub Pages
- **Responsive Design**: Works on desktop and mobile devices

## Local Development Setup

### Prerequisites

- Ruby 3.1 or later
- Bundler gem

### Installation

1. Install Ruby and Bundler:
   ```bash
   # Ubuntu/Debian
   sudo apt install ruby ruby-bundler
   
   # Or using snap
   sudo snap install ruby
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Run the development server:
   ```bash
   bundle exec jekyll serve
   ```

4. Open your browser to `http://localhost:4000`

## GitHub Pages Deployment

### Option 1: GitHub Actions (Recommended)

The repository includes a GitHub Actions workflow (`.github/workflows/jekyll.yml`) that will automatically build and deploy your site when you push to the main branch.

1. Push your changes to the main branch
2. GitHub Actions will automatically build and deploy the site
3. Your site will be available at `https://yourusername.github.io/HacktivityLabSheets`

### Option 2: Manual GitHub Pages

1. Switch to GitHub Pages compatible setup:
   ```bash
   ./switch-to-github-pages.sh
   ```

2. Commit and push your changes:
   ```bash
   git add .
   git commit -m "Update for GitHub Pages"
   git push origin main
   ```

3. Enable GitHub Pages in your repository settings

## Lab Organization

Labs are organized in the `_labs` directory with the following structure:

```
_labs/
├── introducing_attacks/
│   ├── 1_intro_linux.md
│   └── 2_malware_msf_payloads.md
├── lab1-network-scanning.md
├── lab2-web-vulnerability-assessment.md
└── lab3-digital-forensics.md
```

Each lab file should include the following front matter:

```yaml
---
title: "Lab Title"
description: "Brief description of the lab"
difficulty: "Beginner|Intermediate|Advanced"
duration: "XX minutes"
prerequisites: "Required knowledge"
tags: ["tag1", "tag2", "tag3"]
category: "category_name"  # This determines the grouping
---
```

## Adding New Labs

1. Create a new markdown file in the appropriate directory under `_labs/`
2. Add the required front matter (see above)
3. Set the `category` field to group labs together
4. Write your lab content in Markdown

## Theme Customization

The theme uses CSS custom properties (variables) defined in `assets/css/hacktivity-theme.scss`. You can customize colors, fonts, and other styling by modifying these variables.

## Troubleshooting

### GitHub Pages Build Issues

If you encounter build issues with GitHub Pages:

1. Check that your Gemfile is compatible with GitHub Pages
2. Ensure all plugins are whitelisted for GitHub Pages
3. Use the GitHub Actions workflow instead of the traditional GitHub Pages build

### Local Development Issues

If Jekyll won't start locally:

1. Check Ruby version: `ruby --version`
2. Update Bundler: `gem update bundler`
3. Clear Jekyll cache: `bundle exec jekyll clean`
4. Reinstall dependencies: `rm Gemfile.lock && bundle install`
