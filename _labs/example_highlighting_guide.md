---
title: "Lab Sheet Highlighting Guide (AI Instructions)"
author: "AI Assistant"
license: "CC BY-SA 4.0"
description: "A comprehensive guide for AI assistants on how to properly highlight lab sheets using the new highlighting system. This guide contains examples and instructions for converting plain text lab sheets into properly highlighted versions."
difficulty: "AI Guide"
duration: "Reference"
prerequisites: "Understanding of Markdown and the highlighting system"
tags: ["ai-guide", "highlighting", "lab-formatting", "documentation"]
categories: ["documentation"]
type: ["guide", "reference"]
---

# Sheet Highlighting Guide (AI Instructions)

This guide provides comprehensive instructions for AI assistants on how to properly highlight lab sheets using the new highlighting system. Follow these patterns and examples when editing any lab sheet.

## 🎯 Overview

The highlighting system supports two main types of highlighting:
1. **Inline highlights** - for short phrases within sentences
2. **Block highlights** - for standalone action items, tips, warnings, and notes

## 📝 Inline Highlighting Syntax

### Basic Format
Use `==type: content==` where `type` is one of: `action`, `tip`, `hint`, `warning`, `VM`

### Examples

**Action Highlights:**
```markdown
==action: Open a terminal window==
==action: Run the command sudo apt update==
==action: Navigate to the /home directory==
```

**Tip Highlights:**
```markdown
==tip: Use Tab for auto-completion==
==tip: Press Ctrl+C to cancel a running command==
==tip: Use the up arrow to repeat previous commands==
```

**Hint Highlights:**
```markdown
==hint: The flag is hidden in the /home/victim directory==
==hint: Try using the sudo command to access restricted files==
==hint: The password might be in the common passwords list==
```

**Warning Highlights:**
```markdown
==warning: This command will delete files permanently==
==warning: Only run this in a test environment==
==warning: This may trigger antivirus software==
```

**VM Highlights:**
```markdown
==VM: On Kali==
==VM: On Windows==
==VM: On Ubuntu==
==VM: Interact with the Desktop VM==
==VM: Switch to the target VM==
==VM: On the Windows target machine==
```

## 📦 Block-Level Highlighting Syntax

### Basic Format
Use `> Type: content` where `Type` is one of: `Action`, `Tip`, `Warning`, `Hint`, `Note`

### Examples

**Action Blocks:**
> Action: Open a terminal and navigate to your home directory. Create a new folder called "lab_exercise" and change into it.

> Action: Download the required files using wget. Verify the download completed successfully by listing the directory contents.

**Tip Blocks:**
> Tip: If you encounter permission errors, try using sudo before the command. Be careful with sudo as it gives you administrative privileges.

> Tip: You can use the history command to see all previously executed commands. Use the up and down arrows to navigate through command history.

**Warning Blocks:**
> Warning: This lab involves using security tools that may be detected as malicious software. Ensure you're working in an isolated environment and consider disabling real-time antivirus protection temporarily.

> Warning: The commands in this section will modify system files. Make sure you understand what each command does before executing it.

**Hint Blocks:**
> Hint: The flag is located in a hidden file in the victim's home directory. Look for files starting with a dot.

> Hint: The password for the victim account is one of the most common passwords. Try the rockyou.txt wordlist.

**Note Blocks:**
> Note: If you get an error, try running it with sudo. The output may vary depending on your system configuration.

> Note: This command lists all processes running on the system. The "aux" flags provide detailed information about each process.

## 🤖 AI Instructions for Lab Sheet Editing

### Step 1: Identify Action Items
Look for sentences that describe actions students need to perform:
- Commands to run
- Steps to follow
- Tasks to complete
- Procedures to execute

**Convert to:** `==action: [action description]==` for inline actions or `> Action: [detailed action]==` for block-level actions

### Step 2: Identify Tips and Helpful Information
Look for:
- Helpful hints
- Time-saving suggestions
- Best practices
- Shortcuts or tricks

**Convert to:** `==tip: [tip content]==` for inline tips or `> Tip: [detailed tip]==` for block-level tips

### Step 3: Identify Important Hints
Look for:
- Clues that point towards challenge answers
- Direction on where to find flags or solutions
- Guidance on which tools or techniques to use
- Hints about passwords, file locations, or attack vectors

**Convert to:** `==hint: [hint content]==` for inline hints or `> Hint: [detailed hint]==` for block-level hints

### Step 4: Identify Warnings
Look for:
- Potential dangers
- Security considerations
- Destructive operations
- Important cautions

**Convert to:** `==warning: [warning content]==` for inline warnings or `> Warning: [detailed warning]==` for block-level warnings

### Step 5: Identify VM/Environment Context
Look for:
- VM interaction instructions (e.g., "Interact with the Desktop VM")
- VM switching instructions (e.g., "Switch to the target VM")

**Convert to:** `==VM: [environment name or interaction]==` for inline VM references

**Examples:**
- "On Kali" → `==VM: On Kali==`
- "Interact with the Desktop VM" → `==VM: Interact with the Desktop VM==`
- "Switch to the Windows target" → `==VM: Switch to the Windows target==`
### Step 6: Identify Troubleshooting and Brief Explanations
Look for:
- Troubleshooting information that directly follows commands
- Brief explanations of what commands do that directly follows commands
- Additional context about command output
- Clarifications about expected results

**Convert to:** `> Note: [troubleshooting or explanation content]` for block-level notes


## 📋 Conversion Examples

### Before (Plain Text):
```
Open a terminal window. Navigate to your home directory using the cd command. Create a new directory called "security_lab" and change into it. Be careful not to delete any existing files.
```

### After (Highlighted):
```
==action: Open a terminal window==. ==action: Navigate to your home directory using the cd command==. ==action: Create a new directory called "security_lab" and change into it==. ==warning: Be careful not to delete any existing files==.
```

### Before (Plain Text):
```
On Kali, open a terminal and run the following commands. Make sure you're connected to the lab network.
```

### After (Highlighted):
```
==VM: On Kali==, ==action: open a terminal and run the following commands==. ==hint: Make sure you're connected to the lab network==.
```

### Before (Plain Text):
```
Interact with the Desktop VM. Click the icon after the VMs have started. Then switch to the target VM and run the scan.
```

### After (Highlighted):
```
==VM: Interact with the Desktop VM==. ==action: Click the icon after the VMs have started==. Then ==VM: switch to the target VM== and ==action: run the scan==.
```

### Before (Plain Text):
```
If you get lost in the file system, you can always return to your home directory by typing "cd" without any arguments. This is a useful shortcut to remember.
```

### After (Highlighted):
```
==tip: If you get lost in the file system, you can always return to your home directory by typing "cd" without any arguments==. This is a useful shortcut to remember.
```

### Before (Plain Text):
```
This lab requires root access to modify system files. Make sure you understand the implications of running commands with elevated privileges.
```

### After (Highlighted):
```
> Hint: This lab requires root access to modify system files.

> Warning: Make sure you understand the implications of running commands with elevated privileges.
```


### Before (Plain Text):
```
Interact with the Desktop VM. (Click ![][image2] after the VMs have started).
```
### After (Highlighted):
```
==VM: Interact with the Desktop VM==. (Click ![][image2] after the VMs have started).
```

### Before (Plain Text):
```
On the Kali VM:
```
### After (Highlighted):
```
==VM: On the Kali VM:==
```

### Before (Plain Text):
```
From the command line run:

```bash
whoami
```
```
### After (Highlighted):
```
From the command line ==action: run:==

```bash
whoami
```
```
### Before (Plain Text):
```
Note, this is lowercase “LS”.
```
### After (Highlighted):
```
> Note: this is lowercase “LS”.
```

## 🎨 Visual Results

When properly highlighted, the content will display as:

- **Action highlights**: Blue background with ⚡ icon
- **Tip highlights**: Purple background with 💡 icon  
- **Hint highlights**: Green background with 💭 icon
- **Warning highlights**: Orange background with ⚠️ icon
- **VM highlights**: Light blue background with 🖥️ icon

Block-level highlights will appear as styled boxes with appropriate colors and icons:
- **Note blocks**: Light gray background with 📝 icon (for troubleshooting and explanations)

## ✅ Quality Checklist

Before finalizing a lab sheet, ensure:

1. **All action items are highlighted** - Every step students need to perform
2. **Tips are properly marked** - Helpful information that saves time or provides shortcuts
3. **Important hints are highlighted** - Critical information students need to know
4. **Warnings are clearly marked** - Any potential dangers or important cautions
5. **VM/Environment context is marked** - Clear indication of which system/VM to use
6. **Consistency** - Use the same highlighting style throughout the document
7. **Appropriate level** - Don't over-highlight; only highlight truly important information
8. **TOC links are working** - Check that all headings in the Table of Contents have proper markdown links that work correctly

## 🔄 Process Summary

1. **Read through the entire lab sheet**
2. **Check TOC links** - Verify all headings in the Table of Contents have proper markdown anchor links
3. **Identify each type of content** (actions, tips, hints, warnings, VM context, troubleshooting/explanations)
4. **Apply appropriate highlighting syntax**
5. **Review for consistency and completeness**
6. **Test the highlighting** by viewing the rendered page

## 📚 Additional Notes

- **Preserve original content**: Only add highlighting, don't change the actual text
- **Maintain readability**: Don't over-highlight; use highlighting to enhance, not overwhelm
- **Be consistent**: Use the same patterns throughout the document
- **Consider context**: Some content might be both an action and a tip - choose the most appropriate type
- **Test thoroughly**: Always verify the highlighting works correctly in the browser

## ⚠️ When NOT to Use Highlighting

**Important**: Don't overuse highlighting tags. Most lab sheet content should remain unhighlighted.

### ❌ Don't Highlight:
- **Regular explanatory text** - Most sentences that simply explain what students are doing
- **Standard instructions** - Common commands or procedures that are part of normal lab flow
- **Descriptive content** - Text that describes concepts, tools, or background information

### ✅ Do Highlight:
- **Critical actions** - Steps that are essential for lab completion
- **Important warnings** - Safety concerns or potential problems
- **Helpful tips** - Time-saving shortcuts or useful techniques
- **Key hints** - Important information students must remember
- **VM context** - Clear indication of which system to use




## 🔧 Additional Processing Instructions

### Table of Contents (TOC) Verification

When processing lab sheets, always verify the Table of Contents:

1. Remove any TOC/Contents section that is hardcoded, these are added automatically based on headers
   ```markdown
   [Section Name](#anchor-link)
   ```

2. **Verify Anchor Links**: Confirm that each heading in the document has a correct anchor:
   ```markdown
   ### Section Name {#anchor-link}
   ```

3. **Common TOC Issues to Fix**:
   - Missing anchor IDs in headings
   - Incorrect anchor formatting (spaces, special characters -- remove any brackets() and slashes from within anchors)

### Pre-Processing Checklist

Before applying highlighting to any lab sheet:

- [ ] **Read the entire document** to understand the structure and flow
- [ ] **Check TOC completeness** - ensure all major sections are listed
- [ ] **Verify heading hierarchy** - confirm proper use of #, ##, ###, etc.
- [ ] **Test all existing links** - both internal TOC links and external URLs
- [ ] **Identify content types** - map out where actions, tips, hints, warnings, VM context, and troubleshooting/explanations appear
- [ ] **Identify troubleshooting text** - find text that provides troubleshooting information after commands and format as note blocks
- [ ] **Plan highlighting strategy** - decide which content truly needs highlighting

### Post-Processing Verification

After applying highlighting:

- [ ] **Validate markdown syntax** - confirm no syntax errors were introduced
- [ ] **Review consistency** - ensure similar content uses similar highlighting
- [ ] **Test in browser** - view the rendered page to confirm everything displays properly

### Troubleshooting Text Formatting

When instructions are followed by troubleshooting information about the command that was just run, format the troubleshooting text as a note block:

**Before:**
```markdown
Run this command:
```bash
ls -la
```
If you get an error, try running it with sudo. The output may vary depending on your system configuration.
```

**After:**
```markdown
Run this command:
```bash
ls -la
```
> Note: If you get an error, try running it with sudo. The output may vary depending on your system configuration.
```

**Rule**: Any brief explanation and any troubleshooting text that directly follows a command instruction should be formatted as a note block using `> Note:` to visually separate the explanation/troubleshooting information from the instruction.

### Common Processing Errors to Avoid

1. **Over-highlighting**: Don't highlight every instruction - focus on critical actions only
2. **Breaking TOC links**: Be careful not to modify heading text that affects anchor links
3. **Inconsistent formatting**: Use the same highlighting patterns throughout the document
4. **Missing VM context**: Always highlight when switching between different VMs or systems
5. **Ignoring warnings**: Ensure all safety warnings and important cautions are highlighted
6. **Poor tip placement**: Tips should be genuinely helpful, not obvious information
7. **Missing troubleshooting formatting**: Don't forget to format troubleshooting text after commands as note blocks

### File Structure Requirements

Ensure lab sheets maintain proper structure:

- **YAML front matter** with all required fields (title, author, description, etc.)
- **Proper heading hierarchy** (h1 for title, h2 for main sections, h3 for subsections)
- **Working TOC** with functional anchor links
- **Consistent code block formatting** using proper language tags
- **Valid markdown syntax** throughout the document

---

*This guide should be used as a reference when editing any lab sheet to ensure consistent and effective use of the highlighting system.*
