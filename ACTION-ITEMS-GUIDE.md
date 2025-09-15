# Action Items Guide for Lab Sheets

This guide shows how to use the special styling classes to highlight action items and important sections in your lab sheets.

## Available Action Item Classes

### 1. `.action-item` - General Action Required
Use this for general actions that students need to perform.

```html
<div class="action-item">
  <h3>Task 1: Install Required Software</h3>
  <p>Download and install the following tools:</p>
  <ul>
    <li>Nmap</li>
    <li>Wireshark</li>
    <li>Metasploit Framework</li>
  </ul>
</div>
```

### 2. `.warning-item` - Important Warnings
Use this for warnings or important notices.

```html
<div class="warning-item">
  <h3>⚠️ Important Warning</h3>
  <p>Only perform these activities in a controlled lab environment. Never attempt these techniques on systems you don't own or have explicit permission to test.</p>
</div>
```

### 3. `.danger-item` - Critical Warnings
Use this for critical warnings or dangerous operations.

```html
<div class="danger-item">
  <h3>🚨 Critical Security Notice</h3>
  <p>This lab involves creating actual malware samples. Ensure you are working in an isolated environment and have proper authorization.</p>
</div>
```

### 4. `.success-item` - Completion/Success
Use this to indicate successful completion or positive outcomes.

```html
<div class="success-item">
  <h3>✅ Lab Complete</h3>
  <p>Congratulations! You have successfully completed all tasks in this lab. Make sure to document your findings in your lab report.</p>
</div>
```

### 5. `.action-text` - Inline Action Items
Use this for inline action items within paragraphs.

```html
<p>First, <span class="action-text">open a terminal window</span> and navigate to the lab directory. Then <span class="action-text">run the setup script</span> to configure your environment.</p>
```

## Markdown Usage

Since Jekyll processes Markdown, you can also use HTML directly in your Markdown files:

```markdown
## Lab Exercise 1

<div class="action-item">
### Step 1: Network Discovery
Use Nmap to scan the target network and identify active hosts.

```bash
nmap -sn 192.168.1.0/24
```
</div>

<div class="warning-item">
### ⚠️ Legal Notice
Remember to only scan networks you own or have explicit permission to test.
</div>
```

## Color Schemes

The action items automatically adapt to both light and dark themes:

- **Light Theme**: Uses lighter backgrounds with darker text
- **Dark Theme**: Uses darker backgrounds with lighter text
- **Icons**: Each type has a distinctive emoji icon
- **Borders**: Left border in theme-appropriate colors

## Best Practices

1. **Use sparingly**: Don't overuse action items - they should highlight truly important sections
2. **Be specific**: Make action items clear and actionable
3. **Consistent language**: Use consistent terminology across your lab sheets
4. **Test both themes**: Check how your action items look in both light and dark modes

## Examples in Context

Here's how you might structure a typical lab section:

```markdown
## Network Scanning Lab

<div class="action-item">
### Task 1: Basic Network Scan
Perform a basic network scan of the target range 192.168.1.0/24.

```bash
nmap -sn 192.168.1.0/24
```
</div>

<div class="warning-item">
### Important
Only scan networks you own or have explicit permission to test.
</div>

<div class="action-item">
### Task 2: Service Detection
Once you've identified active hosts, perform service detection on the first three hosts.

```bash
nmap -sV 192.168.1.1,2,3
```
</div>

<div class="success-item">
### Completion
If you can see the services running on the target hosts, you have successfully completed this lab section.
</div>
```

This creates a visually distinct and easy-to-follow lab experience for students.

## Highlight Syntax

You can also use the `==highlight==` syntax to highlight specific text inline:

```markdown
This is normal text, but this ==important information== should be highlighted.

You can also highlight ==multiple words== in the same paragraph.
```

This will render as:
- **Light theme**: Yellow background with black text
- **Dark theme**: Darker yellow background with black text

### When to Use Highlight vs Action Items

- **Use `==highlight==`** for emphasizing important information, key terms, or concepts
- **Use action item classes** for actual tasks, warnings, or structured content blocks

### Example Usage

```markdown
## Network Security Lab

<div class="action-item">
### Task 1: Scan the Network
Use Nmap to scan the ==target network== and identify ==active hosts==.

```bash
nmap -sn 192.168.1.0/24
```
</div>

<div class="warning-item">
### Important
Only scan networks you ==own== or have explicit permission to test.
</div>
```

This combines both highlighting techniques for maximum clarity.
