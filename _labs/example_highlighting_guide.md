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
Use `==type: content==` where `type` is one of: `action`, `tip`, `hint`, `warning`, `VM`, `question`, `edit`

### Command Formatting
All bash/terminal commands should be properly formatted with markdown code blocks:

**Before:**
```
msfvenom -l payload | less
```

**After:**
```bash
msfvenom -l payload | less
```

**Important**: Always use `bash` language tag for terminal commands and escape pipe characters (`|` becomes `\|`) within code blocks.

### Inline Code Formatting
Within text, inline code should be enclosed using backticks and any markdown artifacts removed:

**Before:**
```
"push ebp" becomes `push ebp`
```

**After:**
```
`push ebp`
```

**Important**: Remove any escaped characters, quotes, or markdown artifacts from inline code. Use single backticks for inline code within sentences.

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

**Question Highlights:**
```markdown
==question: Self-study Question:==
==question: Log Book Question:==
==question: Reflection Question:==
==question: Discussion Question:==
```

**Edit Highlights:**
```markdown
==edit: Replace with your IP address==
==edit: Change to your target IP==
==edit: Update with your network range==
==edit: Modify as needed==
```

## 📦 Block-Level Highlighting Syntax

### Basic Format
Use `> Type: content` where `Type` is one of: `Action`, `Tip`, `Warning`, `Hint`, `Note`, `Question`, `Flag`

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

**Question Blocks:**
> Question: What are the key differences between bind shells and reverse shells? Consider the network connectivity requirements for each approach.

> Question: How does the Metasploit framework help in penetration testing? What are the advantages of using a standardized exploitation framework?

**Flag Blocks:**
> Flag: Find the flag hidden in the victim's home directory and submit it to Hacktivity to complete this challenge.

> Flag: There is a flag to be found on a user's Desktop! Find and submit it to Hacktivity.

**When to Use Question Blocks:**
Use `> Question:` for clear self-study or log book questions where students are expected to answer for themselves. Do NOT use for rhetorical questions that are answered later in the lab.

**When to Use Flag Blocks:**
Use `> Flag:` for CTF challenge tasks where students need to find and submit flags. This highlights the competitive/assessment aspect of the task.

**Important**: Since the "Note:", "Tip:", "Hint:", "Question:", and "Flag:" labels are not visible in the rendered output, always capitalize the first word after the colon to make the content clear and readable.

## 🤖 AI Instructions for Lab Sheet Editing

### Step 0: Format Commands and Code Properly
Before applying highlighting, ensure all bash/terminal commands, C code, and assembly code are properly formatted:

**Command Formatting Rules:**
- All terminal commands must be in markdown code blocks with `bash` language tag
- Escape pipe characters: `|` becomes `\|` within code blocks
- Commands should be on their own lines, not inline with text

**Code Formatting Rules:**
- All C code must be in markdown code blocks with `c` language tag
- All assembly code must be in markdown code blocks with `nasm` language tag
- Remove escaped characters and markdown artifacts from code
- Ensure proper syntax highlighting for better readability

**Inline Code Formatting Rules:**
- Within text, inline code should be enclosed using single backticks: `code`
- Remove any escaped characters, quotes, or markdown artifacts from inline code
- Examples: `push ebp`, `mov eax, 0x1`, `DWORD PTR [ebp-0x4]`

**Examples:**
```markdown
# Before (incorrect):
Run the command msfvenom -l payload | less

# After (correct):
==action: Run the command:==

```bash
msfvenom -l payload \| less
```

# Before (incorrect):
mov eax, 0x1a
mov ebx, [0x00a7800f]

# After (correct):
```nasm
mov eax, 0x1a
mov ebx, [0x00a7800f]
```
```

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

### Step 7: Identify Self-Study and Log Book Questions
Look for:
- Clear questions where students are expected to provide their own answers
- Self-study questions for reflection and learning
- Log book questions for documentation and record-keeping
- Questions that require student analysis or research

**Convert to:** `> Question: [question content]` for block-level questions

### Step 8: Identify CTF Flag Tasks
Look for:
- Tasks that ask students to find and submit flags
- CTF challenge completion requirements
- Assessment tasks that involve finding specific information
- Competitive elements in the lab

**Convert to:** `> Flag: [flag task content]` for block-level flag tasks

**Important Guidelines for Question Blocks:**
- **USE** `> Question:` for self-study questions, log book questions, and reflection questions where students answer for themselves
- **DO NOT USE** `> Question:` for rhetorical questions that are answered later in the lab
- **DO NOT USE** `> Question:` for questions immediately followed by the answer in the text

**Important Guidelines for Flag Blocks:**
- **USE** `> Flag:` for CTF challenge tasks where students need to find and submit flags
- **DO NOT USE** `> Flag:` for general information gathering tasks

**Important**: Always capitalize the first word after "Note:", "Tip:", "Hint:", "Question:", or "Flag:" since these labels are not visible in the rendered output.


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
Run the command msfvenom -l payload | less to see available payloads.
```
### After (Highlighted):
```
==action: Run the command:==

```bash
msfvenom -l payload \| less
```

to see available payloads.
```

### Before (Plain Text):
```
Ping your own Kali VM from Kali itself (with the IP address you noted earlier):

ping *Kali-IP-address*
```

### After (Highlighted):
```
==action: Ping your own Kali VM from Kali itself (with the IP address you noted earlier):==

```bash
ping ==edit:Kali-IP-address==
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
- **Question highlights**: Teal background with ❓ icon
- **Edit highlights**: Yellow background with ✏️ icon

Block-level highlights will appear as styled boxes with appropriate colors and icons:
- **Note blocks**: Light gray background with 📝 icon (for troubleshooting and explanations)
- **Question blocks**: Teal background with ❓ icon (for self-study, log book, and reflection questions)
- **Flag blocks**: Purple background with 🏁 icon (for CTF challenge tasks)

## ✅ Quality Checklist

Before finalizing a lab sheet, ensure:

1. **All action items are highlighted** - Every step students need to perform
2. **Tips are properly marked** - Helpful information that saves time or provides shortcuts
3. **Important hints are highlighted** - Critical information students need to know
4. **Warnings are clearly marked** - Any potential dangers or important cautions
5. **VM/Environment context is marked** - Clear indication of which system/VM to use
6. **Consistency** - Use the same highlighting style throughout the document
7. **Appropriate level** - Don't over-highlight; only highlight truly important information
8. **TOC links are working** - Check that all headings in the Table of Contents have proper markdown links that don't contain any special characters

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
- [ ] **Format all commands** - ensure all bash/terminal commands use proper markdown code blocks with `bash` language tag
- [ ] **Escape pipe characters** - convert `|` to `\|` in all command code blocks
- [ ] **Format all C code** - ensure all C code uses proper markdown code blocks with `c` language tag
- [ ] **Format all assembly code** - ensure all assembly code uses proper markdown code blocks with `nasm` language tag
- [ ] **Remove markdown artifacts** - clean up escaped characters and formatting artifacts from all code
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

### Before (Plain Text):
```
Self-study Question: What are the key differences between bind shells and reverse shells? Consider the network connectivity requirements for each approach.

Log Book Question: Document your findings from the vulnerability assessment, including which exploits were successful and why.

There is a flag to be found on a user's Desktop! Find and submit it to Hacktivity.
```

### After (Highlighted):
```
> Question: What are the key differences between bind shells and reverse shells? Consider the network connectivity requirements for each approach.

> Question: Document your findings from the vulnerability assessment, including which exploits were successful and why.

> Flag: There is a flag to be found on a user's Desktop! Find and submit it to Hacktivity.
```

### Common Processing Errors to Avoid

1. **Over-highlighting**: Don't highlight every instruction - focus on critical actions only
2. **Breaking TOC links**: Be careful not to modify heading text that affects anchor links
3. **Inconsistent formatting**: Use the same highlighting patterns throughout the document
4. **Missing VM context**: Always highlight when switching between different VMs or systems
5. **Ignoring warnings**: Ensure all safety warnings and important cautions are highlighted
6. **Poor tip placement**: Tips should be genuinely helpful, not obvious information
7. **Missing troubleshooting formatting**: Don't forget to format troubleshooting text after commands as note blocks
8. **Improper command formatting**: Always use `bash` code blocks for terminal commands and escape pipe characters
9. **Improper code formatting**: Always use `c` code blocks for C code and `nasm` code blocks for assembly code
10. **Markdown artifacts in code**: Remove escaped characters and formatting artifacts from all code blocks
11. **Improper inline code formatting**: Use single backticks for inline code and remove markdown artifacts
12. **Uncapitalized block content**: Always capitalize the first word after "Note:", "Tip:", or "Hint:" since these labels are not visible in the rendered output

### Image Caption Formatting

For proper CSS styling, image captions should be formatted as follows:

**Format:**
```markdown
![][image_reference]
*Caption text here*
```

**Examples:**
```markdown
![][binary_output]
*Output of "xxd -b simple" showing binary representation of the "simple" executable file*
```

```markdown
![][assembly_code]
*Disassembly of main() function of the "simple" executable in gdb*
```

**Important Guidelines:**
- Place the caption on the line directly below the image (no blank line between)
- Use italics (`*text*`) for the caption
- Identify existing captions by looking for descriptive text that explains what the image shows (often incomplete sentences or phrases), rather than assuming any text following an image is a caption

**Example:**
```markdown
![][image-11]

#### **Examining the contents of a memory address containing an unsigned integer** 
```

**After (correct):**
```markdown
![][image-11]
*Examining the contents of a memory address containing an unsigned integer*
```

### C Code Formatting

When working with C programming content, ensure all C code is properly formatted:

**Format:**
```markdown
```c
// C code here
```
```

**Important Guidelines:**
- Place any C code into C code blocks using ` ```c ` and ` ``` `
- Remove any special characters from Markdown that may interfere with C syntax
- Ensure C code is syntactically correct and readable
- Common issues to fix:
  - Remove escaped characters like `\*` and `\<` that were used for Markdown emphasis
  - Remove backslashes before special characters that are part of C syntax
  - Ensure proper C syntax without Markdown formatting artifacts

**Examples:**

**Before (incorrect):**
```markdown
\#include \<stdio.h\>

int main (void) {
   printf("Hello, world\!\\n");
   return 0;
}
```

**After (correct):**
```markdown
```c
#include <stdio.h>

int main (void) {
   printf("Hello, world!\n");
   return 0;
}
```
```

### Assembly Code Formatting

When working with assembly language content, ensure all assembly code is properly formatted:

**Format:**
```markdown
```nasm
; Assembly code here
```
```

**Important Guidelines:**
- Place any assembly code into NASM code blocks using ` ```nasm ` and ` ``` `
- Remove any special characters from Markdown that may interfere with assembly syntax
- Ensure assembly code is syntactically correct and readable
- Common issues to fix:
  - Remove escaped characters like `\*` and `\<` that were used for Markdown emphasis
  - Remove backslashes before special characters that are part of assembly syntax
  - Ensure proper assembly syntax without Markdown formatting artifacts
  - Use semicolons (`;`) for comments in assembly code

**Examples:**

**Before (incorrect):**
```markdown
mov eax, 0x1a

mov ebx, \[0x00a7800f\]

mov eax, \[ebx \+ 8\]
```

**After (correct):**
```markdown
```nasm
mov eax, 0x1a

mov ebx, [0x00a7800f]

mov eax, [ebx + 8]
```
```

### Inline Code Formatting

**Before (incorrect):**
```markdown
The instructions "push ebp" and "mov ebp, esp" appear in most functions.
```

**After (correct):**
```markdown
The instructions `push ebp` and `mov ebp, esp` appear in most functions.
```

### File Structure Requirements

Ensure lab sheets maintain proper structure:

- **YAML front matter** with all required fields (title, author, description, etc.)
- **Proper heading hierarchy** (h1 for title, h2 for main sections, h3 for subsections)
- **Working TOC** with functional anchor links
- **Consistent code block formatting** using proper language tags
- **Valid markdown syntax** throughout the document
- **Proper image caption formatting** using italics on the line directly below images

---

*This guide should be used as a reference when editing any lab sheet to ensure consistent and effective use of the highlighting system.*
