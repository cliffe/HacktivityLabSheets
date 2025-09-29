---
layout: default
title: Hacktivity Lab Sheets
---

# Hacktivity Lab Sheets

Welcome to the Hacktivity SecGen lab sheets repository. This site contains hands-on cybersecurity lab exercises designed for educational purposes.

## Available Labs

{% if site.labs.size > 0 %}
<div class="lab-list">
  {% comment %} Create a collection of all unique categories {% endcomment %}
  {% assign all_categories = '' | split: '' %}
  {% for lab in site.labs %}
    {% if lab.categories %}
      {% for category in lab.categories %}
        {% unless all_categories contains category %}
          {% assign all_categories = all_categories | push: category %}
        {% endunless %}
      {% endfor %}
    {% endif %}
  {% endfor %}
  
  {% comment %} Sort categories alphabetically {% endcomment %}
  {% assign sorted_categories = all_categories | sort %}
  
  {% comment %} Display labs grouped by category {% endcomment %}
  {% for category in sorted_categories %}
    <h2 class="category-heading">{{ category | replace: '_', ' ' | capitalize }}</h2>
    
    <div class="category-labs">
      {% for lab in site.labs %}
        {% if lab.categories contains category %}
        <div class="lab-item">
          <h3><a href="{{ lab.url | relative_url }}">{{ lab.title }}</a></h3>
          <p class="lab-description">{{ lab.description | default: lab.excerpt }}</p>
          <div class="lab-meta">
            {% if lab.author %}
              <div class="author">
                <strong>{% if lab.author.first %}Authors:{% else %}Author:{% endif %}</strong> 
                {% if lab.author.first %}
                  {% assign author_count = lab.author.size %}
                  {% for author in lab.author %}
                    {% if forloop.last and author_count > 1 %}and {% endif %}{{ author }}{% unless forloop.last %}, {% endunless %}
                  {% endfor %}
                {% else %}
                  {{ lab.author }}
                {% endif %}
              </div>
            {% endif %}
            {% if lab.license %}
              <div class="license">
                <strong>License:</strong> {{ lab.license }}
              </div>
            {% endif %}
            {% if lab.cybok %}
              <div class="cybok">
                <strong>CyBOK Knowledge Areas:</strong>
                {% for cybok_item in lab.cybok %}
                  <span class="cybok-ka">{{ cybok_item.ka }}: {{ cybok_item.topic }}</span>
                {% endfor %}
              </div>
            {% endif %}
            {% if lab.tags %}
              <div class="tags">
                {% for tag in lab.tags %}
                  <span class="tag">{{ tag }}</span>
                {% endfor %}
              </div>
            {% endif %}
          </div>
        </div>
        {% endif %}
      {% endfor %}
    </div>
  {% endfor %}
  
  {% comment %} Display labs without categories {% endcomment %}
  {% assign uncategorized_labs = site.labs | where: 'categories', nil %}
  {% if uncategorized_labs.size > 0 %}
    <h2 class="category-heading">General Labs</h2>
    <div class="category-labs">
      {% for lab in uncategorized_labs %}
      <div class="lab-item">
        <h3><a href="{{ lab.url | relative_url }}">{{ lab.title }}</a></h3>
        <p class="lab-description">{{ lab.description | default: lab.excerpt }}</p>
        <div class="lab-meta">
          {% if lab.author %}
            <div class="author">
              <strong>{% if lab.author.first %}Authors:{% else %}Author:{% endif %}</strong> 
              {% if lab.author.first %}
                {% assign author_count = lab.author.size %}
                {% for author in lab.author %}
                  {% if forloop.last and author_count > 1 %}and {% endif %}{{ author }}{% unless forloop.last %}, {% endunless %}
                {% endfor %}
              {% else %}
                {{ lab.author }}
              {% endif %}
            </div>
          {% endif %}
          {% if lab.license %}
            <div class="license">
              <strong>License:</strong> {{ lab.license }}
            </div>
          {% endif %}
          {% if lab.cybok %}
            <div class="cybok">
              <strong>CyBOK Knowledge Areas:</strong>
              {% for cybok_item in lab.cybok %}
                <span class="cybok-ka">{{ cybok_item.ka }}: {{ cybok_item.topic }}</span>
              {% endfor %}
            </div>
          {% endif %}
          {% if lab.tags %}
            <div class="tags">
              {% for tag in lab.tags %}
                <span class="tag">{{ tag }}</span>
              {% endfor %}
            </div>
          {% endif %}
        </div>
      </div>
      {% endfor %}
    </div>
  {% endif %}
</div>
{% else %}
<div class="no-labs">
  <p>No labs are currently available. Labs will be added as they are developed.</p>
  <p>Check back soon for new cybersecurity lab exercises!</p>
</div>
{% endif %}

## About

These lab sheets are designed to provide practical, hands-on experience with various cybersecurity concepts and techniques.

These labs are written to be completed on VMs configured with practical hacking/security challenges.

### Option 1: Hacktivity Cyber Security Labs (Recommended)
**Visit [Hacktivity Cyber Security Labs](https://hacktivity.leeds.ac.uk)** for a fully configured, cloud-based lab environment
- No setup required - labs are pre-configured and ready to use
- Access to virtual machines and all required tools
- Perfect for students and educators

### Option 2: Manual Setup with SecGen
For advanced users who want to build their own lab environment:
- Use **SecGen (Security Scenario Generator)** to create vulnerable VMs
- Requires technical expertise in virtualization and security tools


### Contributing

If you'd like to contribute new labs or improvements to existing ones, please see the repository's contribution guidelines.

<!-- Theme Toggle Button -->
<div class="theme-toggle-container" style="position: fixed; top: 20px; right: 20px; z-index: 1000;">
  <button id="theme-toggle" class="btn btn-sm" style="background-color: var(--primary-btnbg-color); color: white; border: none; border-radius: 20px; padding: 8px 16px;">
    <i class="fas fa-moon" id="theme-icon"></i>
  </button>
</div>

<script>
// Theme toggle functionality
document.addEventListener('DOMContentLoaded', function() {
  const themeToggle = document.getElementById('theme-toggle');
  const themeIcon = document.getElementById('theme-icon');
  const body = document.body;
  
              // Check for saved theme preference or default to dark mode
              const currentTheme = localStorage.getItem('theme') || 'dark';
  body.setAttribute('data-theme', currentTheme);
  updateThemeIcon(currentTheme);
  
  themeToggle.addEventListener('click', function() {
    const currentTheme = body.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    
    body.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    updateThemeIcon(newTheme);
  });
  
  function updateThemeIcon(theme) {
    if (theme === 'dark') {
      themeIcon.className = 'fas fa-sun';
    } else {
      themeIcon.className = 'fas fa-moon';
    }
  }
});

// Process ==highlight== syntax
document.addEventListener('DOMContentLoaded', function() {
              const contentBody = document.querySelector('.lab-list');
              if (contentBody) {
                // Replace specific highlight types first
                contentBody.innerHTML = contentBody.innerHTML.replace(/==action:\s*([^=]+)==/gi, '<span class="action-highlight">⚡ $1</span>');
                contentBody.innerHTML = contentBody.innerHTML.replace(/==tip:\s*([^=]+)==/gi, '<span class="tip-highlight">💡 $1</span>');
                contentBody.innerHTML = contentBody.innerHTML.replace(/==hint:\s*([^=]+)==/gi, '<span class="hint-highlight">💭 $1</span>');
                contentBody.innerHTML = contentBody.innerHTML.replace(/==note:\s*([^=]+)==/gi, '<span class="note-highlight">$1</span>');
                contentBody.innerHTML = contentBody.innerHTML.replace(/==warning:\s*([^=]+)==/gi, '<span class="warning-highlight">⚠️ $1</span>');
                contentBody.innerHTML = contentBody.innerHTML.replace(/==VM:\s*([^=]+)==/gi, '<span class="vm-highlight">🖥️ $1</span>');
                
                // Replace generic ==text== with <mark>text</mark>
                contentBody.innerHTML = contentBody.innerHTML.replace(/==([^=]+)==/g, '<mark>$1</mark>');
                
                // Replace > TIP: patterns with tip-item divs
                contentBody.innerHTML = contentBody.innerHTML.replace(
                  /<blockquote>\s*<p>\s*<em>Tip:<\/em>\s*([^<]+(?:<[^>]+>[^<]*<\/[^>]+>[^<]*)*)<\/p>\s*<\/blockquote>/gi,
                  '<div class="tip-item">$1</div>'
                );
                
                // Handle > *Tip: ANYTHINGHERE* (entire content in italics)
                contentBody.innerHTML = contentBody.innerHTML.replace(
                  /<blockquote>\s*<p>\s*<em>Tip:\s*([^<]+(?:<[^>]+>[^<]*<\/[^>]+>[^<]*)*)<\/em>\s*<\/p>\s*<\/blockquote>/gi,
                  '<div class="tip-item">$1</div>'
                );
                
                // Also handle > TIP: without italics
                contentBody.innerHTML = contentBody.innerHTML.replace(
                  /<blockquote>\s*<p>\s*Tip:\s*([^<]+(?:<[^>]+>[^<]*<\/[^>]+>[^<]*)*)<\/p>\s*<\/blockquote>/gi,
                  '<div class="tip-item">$1</div>'
                );
                
                // Handle block-level action, warning, note, hint patterns
                contentBody.innerHTML = contentBody.innerHTML.replace(
                  /<blockquote>\s*<p>\s*Action:\s*([^<]+(?:<[^>]+>[^<]*<\/[^>]+>[^<]*)*)<\/p>\s*<\/blockquote>/gi,
                  '<div class="action-item">$1</div>'
                );
                contentBody.innerHTML = contentBody.innerHTML.replace(
                  /<blockquote>\s*<p>\s*Warning:\s*([^<]+(?:<[^>]+>[^<]*<\/[^>]+>[^<]*)*)<\/p>\s*<\/blockquote>/gi,
                  '<div class="warning-item">$1</div>'
                );
                contentBody.innerHTML = contentBody.innerHTML.replace(
                  /<blockquote>\s*<p>\s*Note:\s*([^<]+(?:<[^>]+>[^<]*<\/[^>]+>[^<]*)*)<\/p>\s*<\/blockquote>/gi,
                  '<div class="note-item">Note: $1</div>'
                );
                contentBody.innerHTML = contentBody.innerHTML.replace(
                  /<blockquote>\s*<p>\s*Hint:\s*([^<]+(?:<[^>]+>[^<]*<\/[^>]+>[^<]*)*)<\/p>\s*<\/blockquote>/gi,
                  '<div class="hint-item">Hint: $1</div>'
                );
              }
            });
</script>