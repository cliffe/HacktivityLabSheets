# HacktivityLabSheets

**Contribute to Hacktivity Cyber Security Labs** - This repository contains the source lab sheets for [Hacktivity Cyber Security Labs](https://hacktivity.co.uk), a comprehensive cyber security education platform.

## 🎯 About This Repository

This repository serves as the **contribution hub** for lab content used by [Hacktivity Cyber Security Labs](https://hacktivity.co.uk). The lab sheets are designed to work with SecGen (Security Scenario Generator) to create vulnerable virtual machines for hands-on cybersecurity education.

## 🌐 Live Sites

- **Hacktivity Cyber Security Labs**: [https://hacktivity.co.uk](https://hacktivity.co.uk) - The main platform where students access and complete labs
- **Lab Sheets Preview**: [https://cliffe.github.io/HacktivityLabSheets](https://cliffe.github.io/HacktivityLabSheets) - Preview of lab content for contributors

## 📚 Available Labs

This repository contains practical cyber security lab exercises designed for educational purposes, covering topics from Linux fundamentals to advanced exploitation techniques.

## 🚀 Getting Started

### For Leaners/Hackers
1. Visit [Hacktivity Cyber Security Labs](https://hacktivity.co.uk) to access the full platform
2. Sign up for an account to start completing labs
3. Use the lab sheets in this repository as reference material

### For Contributors
1. Fork this repository to contribute lab sheet improvements (and see SecGen for the software components of challenges)
2. Follow the contribution guidelines below
3. Use the automated setup script (`./start-server-github-pages.sh`) for easy local development
4. Submit pull requests to improve existing labs or add new ones

## 🛠 Local Development

To run the site locally for development:

### Quick Start (Recommended)
```bash
# Clone the repository
git clone https://github.com/cliffe/HacktivityLabSheets.git
cd HacktivityLabSheets

# Run the automated setup script (GitHub Pages compatible)
./start-server-github-pages.sh

# Visit http://localhost:4000 in your browser
```

### Manual Setup
```bash
# Install Jekyll (if not already installed)
gem install bundler jekyll

# Clone the repository
git clone https://github.com/cliffe/HacktivityLabSheets.git
cd HacktivityLabSheets

# Install dependencies
bundle install

# Serve the site locally
bundle exec jekyll serve

# Visit http://localhost:4000 in your browser
```

## 📝 Contributing to Hacktivity Labs

We welcome contributions to improve and expand the lab content used by Hacktivity Cyber Security Labs! You can:

- **Improve existing labs**: Fix errors, clarify instructions, add better explanations
- **Add new labs**: Create new exercises covering additional cybersecurity topics
- **Update content**: Keep lab content current with latest tools and techniques

### How to Contribute

#### For New Labs
1. Create a new markdown file in the `_labs/` directory
2. Use the following front matter template:

```yaml
---
title: "Lab X: Your Lab Title"
description: "Brief description of what the lab covers"
tags: ["tag1", "tag2", "tag3"]
---
```

3. Write your lab content using markdown
4. Test locally before submitting a pull request

#### For Improving Existing Labs
1. Browse existing labs in the `_labs/` directory
2. Make improvements to content, clarity, or accuracy
3. Test your changes locally
4. Submit a pull request with a clear description of improvements

### Lab Content Guidelines

- **Clear Objectives**: Start with what students will learn
- **Step-by-Step Instructions**: Provide detailed, testable steps
- **Questions and Analysis**: Include thought-provoking questions
- **Proper Highlighting**: Use the highlighting system for better readability

### Highlighting System

This repository uses a special highlighting system to make lab content more readable and actionable. See the [Example Highlighting Guide](_labs/example_highlighting_guide.md) for comprehensive instructions on:

- How to properly highlight actions, tips, hints, and warnings
- Formatting commands and code blocks
- Using VM context indicators
- Creating effective question and flag blocks
- Best practices for lab sheet formatting

**Important**: When contributing to existing labs, follow the highlighting patterns established in the guide to maintain consistency across all lab sheets.

## 📄 License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support & Community

### For Learners / Hackers
- Visit [Hacktivity Cyber Security Labs](https://hacktivity.co.uk) for the full learning platform
- Check lab instructions carefully before seeking help
- Join the Hacktivity Discord server for community support

### For Contributors
- Open an issue on GitHub for bugs or feature requests
- Join discussions about lab improvements

## 🎯 About SecGen

Hacktivty is powerd by our open source [SecGen (Security Scenario Generator)](https://github.com/cliffe/SecGen), which creates vulnerable virtual machines for security education and training.

