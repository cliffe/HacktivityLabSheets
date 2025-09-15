---
layout: default
title: Hacktivity Lab Sheets
---

# Hacktivity Lab Sheets

Welcome to the Hacktivity SecGen lab sheets repository. This site contains hands-on cybersecurity lab exercises designed for educational purposes.

## Available Labs

{% if site.labs.size > 0 %}
<div class="lab-list">
  {% assign labs_by_category = site.labs | group_by: 'category' %}
  {% for category in labs_by_category %}
    {% if category.name != blank %}
      <h2 class="category-heading">{{ category.name | replace: '_', ' ' | capitalize }}</h2>
    {% else %}
      <h2 class="category-heading">General Labs</h2>
    {% endif %}
    
    <div class="category-labs">
      {% for lab in category.items %}
      <div class="lab-item">
        <h3><a href="{{ lab.url | relative_url }}">{{ lab.title }}</a></h3>
        <p class="lab-description">{{ lab.description | default: lab.excerpt }}</p>
        <div class="lab-meta">
          {% if lab.difficulty %}
            <span class="difficulty">Difficulty: {{ lab.difficulty }}</span>
          {% endif %}
          {% if lab.duration %}
            <span class="duration">Duration: {{ lab.duration }}</span>
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
  {% endfor %}
</div>
{% else %}
<div class="no-labs">
  <p>No labs are currently available. Labs will be added as they are developed.</p>
  <p>Check back soon for new cybersecurity lab exercises!</p>
</div>
{% endif %}

## About

These lab sheets are designed to work with SecGen (Security Scenario Generator) and provide practical, hands-on experience with various cybersecurity concepts and techniques.

### How to Use

1. Browse the available labs above
2. Click on a lab title to view the detailed instructions
3. Follow the setup and execution steps provided in each lab
4. Complete the challenges and questions included in each exercise

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
</script>