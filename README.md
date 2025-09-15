# HacktivityLabSheets

Lab sheets for Hacktivity SecGen labs - A collection of hands-on cybersecurity lab exercises.

## 🌐 Live Site

Visit the lab sheets at: **https://cliffe.github.io/HacktivityLabSheets**

## 📚 Available Labs

This repository contains practical cybersecurity lab exercises designed for educational purposes. Each lab includes:

- Step-by-step instructions
- Learning objectives
- Prerequisites
- Expected duration
- Hands-on exercises with real tools
- Analysis questions
- Additional challenges

### Current Lab Topics

- **Network Scanning**: Learn reconnaissance techniques with Nmap
- **Web Application Security**: Vulnerability assessment with OWASP ZAP
- **Digital Forensics**: Incident response and evidence analysis
- More labs are continuously being added!

## 🚀 Using the Labs

1. Visit the [live site](https://cliffe.github.io/HacktivityLabSheets) to browse available labs
2. Click on any lab title to view detailed instructions
3. Follow the setup and execution steps provided
4. Complete the exercises and answer the analysis questions

## 🛠 Local Development

To run the site locally for development:

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

## 📝 Contributing New Labs

We welcome contributions of new lab exercises! To add a new lab:

1. Create a new markdown file in the `_labs/` directory
2. Use the following front matter template:

```yaml
---
title: "Lab X: Your Lab Title"
description: "Brief description of what the lab covers"
difficulty: "Beginner/Intermediate/Advanced"
duration: "X minutes"
prerequisites: "Required background knowledge"
tags: ["tag1", "tag2", "tag3"]
---
```

3. Write your lab content using markdown
4. Test locally before submitting a pull request

### Lab Content Guidelines

- **Clear Objectives**: Start with what students will learn
- **Prerequisites**: List required background knowledge
- **Step-by-Step Instructions**: Provide detailed, testable steps
- **Questions and Analysis**: Include thought-provoking questions
- **Safety Warnings**: Always emphasize ethical use and authorization
- **Resources**: Link to additional learning materials

## ⚠️ Ethical Use

All lab exercises are designed for educational purposes in controlled environments. Users must:

- Only practice on systems they own or have explicit permission to test
- Follow all applicable laws and regulations
- Respect terms of service and acceptable use policies
- Use knowledge gained responsibly and ethically

## 📄 License

This project is licensed under the GPL-3.0 License - see the [LICENSE](LICENSE) file for details.

## 🤝 Support

If you encounter issues or have questions:

1. Check the lab instructions carefully
2. Review the prerequisites
3. Open an issue on GitHub with detailed information
4. Join the discussion in our community forums

## 🎯 About SecGen

These labs are designed to work with [SecGen (Security Scenario Generator)](https://github.com/cliffe/SecGen), which creates vulnerable virtual machines for security education and training.
