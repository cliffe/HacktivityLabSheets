---
layout: default
title: Hacktivity Lab Sheets
---

# Hacktivity Lab Sheets

Welcome to the Hacktivity SecGen lab sheets repository. This site contains hands-on cybersecurity lab exercises designed for educational purposes.

## Available Labs

{% if site.labs.size > 0 %}
<div class="lab-list">
  {% for lab in site.labs %}
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

<style>
.lab-list {
  margin: 2rem 0;
}

.lab-item {
  border: 1px solid #e1e4e8;
  border-radius: 6px;
  padding: 1.5rem;
  margin-bottom: 1rem;
  background-color: #f8f9fa;
}

.lab-item h3 {
  margin-top: 0;
  margin-bottom: 0.5rem;
}

.lab-item h3 a {
  text-decoration: none;
  color: #0366d6;
}

.lab-item h3 a:hover {
  text-decoration: underline;
}

.lab-description {
  margin-bottom: 1rem;
  color: #586069;
}

.lab-meta {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  font-size: 0.875rem;
}

.difficulty, .duration {
  color: #586069;
  font-weight: 500;
}

.tags {
  display: flex;
  gap: 0.25rem;
}

.tag {
  background-color: #f1f8ff;
  color: #0366d6;
  padding: 0.125rem 0.5rem;
  border-radius: 12px;
  font-size: 0.75rem;
  border: 1px solid #c8e1ff;
}

.no-labs {
  text-align: center;
  padding: 2rem;
  background-color: #f8f9fa;
  border: 1px solid #e1e4e8;
  border-radius: 6px;
  margin: 2rem 0;
}

.no-labs p {
  margin: 0.5rem 0;
  color: #586069;
}
</style>