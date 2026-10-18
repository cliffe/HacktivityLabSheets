---
title: "First Contact: VM Technical Steps"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Technical companion to the First Contact walkthrough, for the server and VM work: the step-by-step hints for getting into the attack server, finding the flags and escalating privileges with sudo, plus the command-line attack exercises."
tags: ["linux", "ssh", "hydra", "privilege-escalation", "sudo", "base64", "rot13", "cyberchef", "lockpicking", "password-security", "break-escape"]
categories: ["safetynet"]
redirect_from:
  - /labs/introducing_attacks/m01-first-contact-vm-technical-steps/
type: ["game-based-learning", "lab-sheet"]
difficulty: "beginner"
source: "https://github.com/cliffe/BreakEscape/blob/main/scenarios/m01_first_contact/labsheet_vm_steps.md"
cybok:
  - ka: "NS"
    topic: "Network Protocols and Vulnerability"
    keywords: ["common network attacks"]
  - ka: "SOIM"
    topic: "PENETRATION TESTING"
    keywords: ["PENETRATION TESTING - SOFTWARE TOOLS"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["authentication and identification"]
  - ka: "AAA"
    topic: "Authentication"
    keywords: ["user authentication"]
  - ka: "CPS"
    topic: "Physical Security"
    keywords: ["Physical access control"]
---

> Note: This is the technical companion to the [First Contact walkthrough](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/m01-first-contact/). Play the game there first, and come here for the server work.

## Purpose

By the end of this companion you should be able to:

- run an online password-guessing attack against SSH with a wordlist, and connect once it works
- navigate a Linux filesystem from the command line, find files, and read them
- use `sudo` to act as another account, and explain what that misconfiguration gives an attacker
- explain why a short list of reused passwords is enough to break an account, and where the weakness actually is

## How to Use This Companion

The hints are layered. Read the **Hint** first, then open the **Nudge**, and open the **Recipe** only when you are stuck. Go back to the Kali terminal after each one and try the step yourself.

Every answer in this mission is generated for your game. Values such as the flags and passwords are not written in this sheet, and the hints tell you where to find them in the game.

## Getting Started: The Server Work

Your attack box is the Kali terminal in the server room. You get into the server room with Kevin's server room keycard. The target is the attack server. Its address and the username you are targeting come from the Server Access Details note in Derek's storage safe.

The game gives you the flags, and you submit each one at the SAFETYNET Drop-Site Terminal in the same room.

1. \==action: Open the VM Access Terminal in the server room==. This is the Kali box.
2. \==action: Log in using the login on the terminal's sticky note==. This sheet does not repeat it.
3. \==action: Save Derek's password list to a file on Kali== (for example `passwords.txt`), one password per line.

> Warning: The attack server is a different machine from Kali. Running a command on Kali does not change anything on the target.

## Concepts: What You Are Attacking

Each concept below has an illustrative example. Run the examples on your own Kali box or a lab VM you control, not on the game target, unless a hint tells you to.

### SSH and online password guessing

**SSH** (Secure Shell) is how you log into a Linux machine over the network. It asks for a username and password. If the password is weak and there is no lockout, an attacker can try many passwords in turn until one works. This is an **online brute force** or, more precisely, a **dictionary attack** when you use a list of likely passwords rather than every combination.

**Hydra** automates the guessing. You give it a username, a file of candidate passwords, the target address and the service:

```bash
hydra -l derek -P passwords.txt 172.16.0.2 ssh
```

Each line in `passwords.txt` is one guess. When one works, Hydra prints the username and the password it found. You then log in for real:

```bash
ssh derek@172.16.0.2
```

The attack only works because the password is weak and the list is short and well chosen. A long random password, or a lockout after a few failures, would defeat it. In this mission Derek's own password list is the perfect wordlist, because he reuses the habits on it.

> Question: Why does a list of 27 likely passwords break into this account in seconds, when guessing an arbitrary 12-character random password could take longer than the age of the universe? What does that tell you about where the weakness actually is?

### A Linux shell and where your rights stop

Once you have a shell, you explore with a handful of commands:

| Command | What it does |
| --- | --- |
| `pwd` | Prints the directory you are in |
| `ls` | Lists files; `ls -la` shows hidden files (those starting with a dot) and permissions |
| `cd somewhere` | Moves into a directory; `cd ..` goes up one; `cd` alone goes home |
| `cat file` | Prints a file's contents |

Evidence is rarely in the first place you look. Check the home directory, then any subdirectories inside it. A folder named after the operation is worth opening, and the file inside it is a second piece of evidence a step down from the top level. Moving into a subdirectory to reach a file like `operation_shatter/deployment_notes` is **directory traversal**, and it is one of the flags.

### Privilege escalation and sudo

A normal account can only read its own files. **Privilege escalation** is moving from the access you have to access you should not have. The common Linux route is `sudo`, which lets a permitted user run commands as another account, often root.

```bash
sudo -l                    # list what you are allowed to run, and as whom
sudo -u shatter cat /home/shatter/somefile   # read a file as the shatter account
sudo -u shatter bash       # open a shell as the shatter account
```

If Derek's account is allowed to act as the `shatter` account, you can read `shatter`'s files even though they are not yours. That is the misconfiguration: an operative account with sudo rights over the infrastructure account. The files it unlocks are the last two flags.

> Question: Derek's account can become the `shatter` account with one command. In a properly set up system, why would a marketing manager's login never be allowed to do that? What principle is being broken?

## Stuck? Hints: The Server Work

These four stages cover the server work in order: getting in, the SSH brute force, finding the flags, and privilege escalation. Read each hint and try, then open a Nudge, and the Recipe last.

### The VM: Getting In {#hints-vm-connect}

**Where:** the Kali terminal in the server room. **Goal:** log into Kali and find the target's details.

> Hint: The terminal is a full Kali Linux machine. Its own login is on the sticky note on it. The target you are attacking is a different machine, and its address and username came from Derek's storage safe.

<details markdown="1">
<summary>Nudge</summary>

Log into the Kali box using the login on its sticky note. The attack server is at the address on the "Server Access Details" note from the storage safe, and the username you are targeting is Derek's. You also took Derek's password list from the same safe; save it into a file on Kali, one password per line, to use as your wordlist.

**To learn more in game:** once you find Derek's password list, Agent HaX offers the SSH and Linux basics guide. Open your phone and choose **[I'd like that ops manual]**. It covers Hydra, SSH and moving around a Linux filesystem.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Log into Kali using the login on the terminal's sticky note==.
2. \==action: Save Derek's password list to a file== (for example `passwords.txt`), one password per line.
3. \==action: Note the target address and username== from the Server Access Details note.

</details>

### The VM: SSH Brute Force {#hints-vm-ssh}

**Where:** the Kali shell. **Goal:** find Derek's SSH password and log in.

> Hint: You have a username, a target and a wordlist. One tool tries each password in the list against the login until one fits.

<details markdown="1">
<summary>Nudge</summary>

Use Hydra against the SSH service on the target, with Derek's username and your password file. When it finds a match it prints the password. Then connect with `ssh` using that password. The password is generated for your game, so it is not written anywhere in this sheet; Hydra finds it for you.

**Learn it:** ==action: Before running the attack, open the wordlist and read it==. Every line is a habit Derek reuses. That is why a short list works.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Run Hydra against SSH on the target== with Derek's username and your wordlist:

```bash
hydra -l derek -P passwords.txt 172.16.0.2 ssh
```

2. \==action: Read the password Hydra prints==, then connect:

```bash
ssh derek@172.16.0.2
```

3. \==action: Find the decryption key file in Derek's home directory== and submit it to unlock the ENTROPY archive.

</details>

> Warning: If Hydra finds nothing, check you are targeting the right username and that each password is on its own line with no blank lines or stray spaces.

### The VM: Finding the Flags {#hints-vm-nav}

**Where:** logged in as Derek. **Goal:** find the two pieces of evidence in his account.

> Hint: Evidence is rarely at the top. List everything, including folders, and look inside a folder named after the operation.

<details markdown="1">
<summary>Nudge</summary>

In Derek's home directory, `ls -la` shows the files. One is the archive decryption key. Another sits inside a subdirectory named for the operation; move into it and read the file there. Reading a file one level down is the directory traversal flag. Submit the decryption key at the ENTROPY archive in the server room, and the deployment notes flag at the drop-site terminal.

**To learn more in game:** open your phone and choose **[Linux navigation tips]** for `ls`, `cd` and `cat`.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: List the home directory with `ls -la`==.
2. \==action: `cat` the decryption key file== and submit its contents at the ENTROPY archive.
3. \==action: `cd` into the operation subdirectory and `cat` the deployment notes==, then submit that flag at the drop-site.

</details>

### The VM: Privilege Escalation {#hints-vm-sudo}

**Where:** logged in as Derek. **Goal:** reach the files in the `shatter` account.

> Hint: Some files are not yours to read. Check what your account is allowed to do as other accounts.

<details markdown="1">
<summary>Nudge</summary>

Run `sudo -l` to see what Derek's account may do. It can act as the `shatter` account. Use that to read the files in `shatter`'s home directory: one is the encoded deployment configuration (Base64, submit it at the drop-site), and one is the launch authorization code (you enter that into Derek's launch device at the end).

**To learn more in game:** after your first server flag, Agent HaX offers the privilege escalation guide. Open your phone and choose **[I need the privilege escalation guide]**, or **[Privilege escalation guidance]** for a quick steer.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Run `sudo -l`== to confirm you can act as the `shatter` account.
2. \==action: Read `shatter`'s files as that account==, for example:

```bash
sudo -u shatter ls /home/shatter
sudo -u shatter cat /home/shatter/shatter_configuration
```

3. \==action: The configuration is Base64==; decode it and submit that flag at the drop-site.
4. \==action: Read the launch authorization code in the shatter account== and keep it for the launch device.

</details>

## What the Server Is Telling You

| Message or symptom | Usual cause |
| --- | --- |
| Hydra finishes with no password found | Wrong username, or the wordlist has blank lines or stray spaces |
| `ssh` says "Permission denied" | The password is mistyped, or Hydra matched a different account |
| `sudo -l` says you may run nothing | You are on the wrong account; log in as Derek, not Kali's own user |
| `Permission denied` when reading a file | Your account cannot read that file, or the file is not where you think |

## Try It on the Command Line (Optional)

### A dictionary attack you own {#cli-hydra}

Set up a throwaway account on a lab VM you control, give it a weak password that is on a list, and attack it. ==action: Build a tiny wordlist and run Hydra against your own test box==:

```bash
cat > mylist.txt << 'EOF'
summer2024
companyname
password1
letmein
EOF
hydra -l testuser -P mylist.txt 127.0.0.1 ssh
```

> Warning: Only ever run this against a machine you own or have written permission to test. Guessing passwords against anyone else's system is an offence.

### Acting as another user {#cli-sudo}

On a lab VM, ==action: look at your sudo rights and read a file as another account==:

```bash
sudo -l
sudo -u otheruser cat /home/otheruser/notes.txt
```

> Question: If `sudo -l` showed you could run any command as any user, what would that let you do on the whole machine, and why is that the same risk as being root?

## After the Game: Questions and Exercises

### Attacking the Server

> Question: The server work had three technical stages: SSH brute force, directory traversal and privilege escalation. For each, say what you did, what made it possible, and what a defender could have changed to stop you.

> Question: The wordlist that broke Derek's account was his own password list. In a real engagement you would not have that. Where do penetration testers get wordlists, and how do they tailor one to a target?

> Question: Derek's account could become the `shatter` account with `sudo`. Name the security principle this breaks, and describe how the accounts should have been separated.

> Action: On a lab VM you control, recreate the chain: create a user with a weak password, add a file in a subdirectory, and give that user sudo rights over a second account. Then attack it from another account using Hydra, navigation and sudo. Write up each command and its output.

## Further Reading

- [SAFETYNET Field Guide: SSH Access and Linux System Navigation](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/ssh-access-and-linux-basics/)
- [SAFETYNET Field Guide: Privilege Escalation via Sudo](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/privilege-escalation/)
- The Hydra and OpenSSH manual pages (`man hydra`, `man ssh`, `man sudo`).
