---
title: "Access Controls: Set User ID (SUID)"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Explore Set UID (SUID) and Set GID (SGID) permissions, real vs. effective identity, and the risks of privilege escalation, while completing Hackerbot's SUID challenges."
overview: |
  Special file permissions, such as Set UID (SUID) and Set GID (SGID), play a crucial role in Unix-based operating systems by enabling certain processes to run with elevated privileges. Understanding SUID and SGID provides insights into access controls and how Unix systems handle privilege escalation while maintaining control over who can execute specific operations. This lab will give you practical knowledge on the use and implications of SUID and SGID.

  Throughout this lab, you will learn about the concepts of Real UID (RUID) and Effective UID (EUID), explore SUID and SGID permissions in detail, and analyse their significance in managing system security. You will inspect processes to identify cases where RUID and EUID differ, discover SUID and SGID programs on your system, and understand why they require these special permissions. Additionally, you will compile a SUID C program, assess its security implications, and modify it to rectify vulnerabilities. By the end of this lab, you will have a comprehensive understanding of SUID and SGID, their importance in Unix system security, and practical experience working with SUID programs.

  This is a Hackerbot lab. Work through the lab sheet, then when prompted interact with Hackerbot. In the Hackerbot tasks, you'll use SUID to mediate access to a file so that it's only accessible via a specific SUID executable. There are also problem-based challenges involving hardlinks, relative paths, and combining shell programs with SGID and SUID permissions.
tags: ["suid", "sgid", "access-control", "file-permissions", "privilege-escalation", "hardlinks", "unix-permissions", "hackerbot"]
categories: ["systems_security"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AAA"
    topic: "Authorisation"
    keywords: ["access control", "Elevated privileges", "Real and effective identity", "Vulnerabilities and attacks on access control misconfigurations"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["Access controls and operating systems", "Linux security model", "Unix File Permissions", "setuid/setgid", "Hardlink protections"]
---

## Getting started {#getting-started}

### VMs in this lab {#vms-in-this-lab}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop (you can sudo to get superuser access)
- server (you can ssh to this machine, but you don't have superuser access)

### Your login details for the "desktop" and "server" VMs {#your-login-details}

\==VM: On the desktop VM==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

The same username and password work for the "server" VM.

There is a second user account on both the desktop and server VMs, used later in this lab. \==VM: On the desktop VM==, ==action: open a terminal and run:==

```bash
ls /home
```

> Note: This lists the home directories on the machine, which tells you the other username. Wherever this lab sheet says "the other user", ==edit: substitute the second username you found here==.

> Note: The other account's password is generated randomly and isn't needed for this lab — you have sudo access on the desktop, so you can act as that user with `sudo -u` instead of logging in as them directly.

### Note the IP address of the server VM {#note-the-server-ip}

\==VM: On the server VM==, ==action: open a terminal and run:==

```bash
ip -4 -o a s
```

> Note: Note the IP address (and network interface name) — this is your **server IP address**. Wherever this lab sheet says "the server IP address", ==edit: substitute the address you noted down==.

{% include hackerbot-intro.md role="present SUID and hardlink challenges and will attack your systems" %}

## Special File Permissions and Set UID (SUID) {#suid}

Sometimes a user needs to be able to do things that require permissions that they should not always have. For example, the `passwd` command is used to change your password. When it runs it needs read and write access to `/etc/shadow`. Clearly not every user should have that kind of access! Also, the `ping` command needs raw network access — again not something that every user can do. The Unix solution is *Set UID (SUID)*.

Using SUID, processes can be given permission to run as another user. For example, when you run `passwd`, the program actually runs as root (on most Unix systems).

In fact, every process has multiple identities, including:

- The real UID (RUID): the user who is running the command
- The effective UID (EUID): the way the process is treated

\==action: List all processes' real and effective UIDs/users:==

```bash
ps -eo ruser,euser,comm
```

Look through the list of running processes.

> Question: Most of the time the RUID and EUID match. Are there any cases in the output where they do not?

Take a look at how the effective UID is specified. ==action: Run:==

```bash
ls -l /usr/bin/passwd
```

`-rwsr-xr-x 1 root shadow 81792 Oct 29 18:26 /usr/bin/passwd`

The `s` in the file permissions (where you would normally see an `x` for execute permission) means that when this program is started the file's UID will be used as the effective UID.

The SUID bit is stored in the first permission octet in the inode. ==action: Run:==

```bash
stat /usr/bin/passwd
```

`Access: (4755/-rwsr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)`

> Note: Note the octet representation of the file permissions: 4755. Make sure you understand how this results in the permissions "rwsr-xr-x".

In your terminal console, ==action: open multiple tabs==.

\==action: In one tab run:==

```bash
passwd
```

> Note: Don't type anything, instead leave the prompt open.

\==action: Switch to another tab and run:==

```bash
ps -o ruser,euser,comm -C passwd
```

Or you can list all processes (`-e`) and use `awk` to filter it down to *any* lines where the first two entries (ruid and euid) don't match:

```bash
ps -eo ruser,euser,comm \| awk '$1 != $2'
```

Make sure you understand the significance of the ruser and euser outputs not matching.

\==action: Run this command to find all SUID programs on the system:==

```bash
sudo find / -type f -perm -4000 -exec ls -ldb {} \;
```

> Question: Consider why each SUID program on your desktop requires SUID permissions.

\==hint: Look up each command using `man`.==

## Set GID (SGID) {#sgid}

Set GID (SGID) is similar to SUID, except it is the effective group (EGID) that is changed. The EGID is changed to the group assigned to the executable file.

\==action: Run:==

```bash
ls -la /usr/bin/wall
```

`-rwxr-sr-x 1 root tty 27448 Mar  7  2018 /usr/bin/wall`

\==action: Start `wall` in a separate tab, and run:==

```bash
ps -o ruser,euser,rgroup,egroup,comm -C wall
```

> Question: Consider why the `wall` program requires SGID permissions.

\==action: Search for all programs on your system that have SGID set.==

\==hint: Try modifying the above command.==

## Trust boundaries and SUID risks {#trust-boundaries}

Every time SUID/SGID is used it represents a security risk, because that program acts as a **trust boundary** (where execution changes its level of "trust") since the process attains an increased privilege level. A vulnerability in a SUID/SGID program could result in the user gaining escalated privileges.

## Writing a SUID program in C {#writing-a-suid-program}

You are going to compile a SUID program, to grant access to the contents of your "mysecret" file to anyone who runs the program, without sharing direct access to the file.

Use file permissions to ==action: make "~/mysecret" only accessible by the owner==: `ls -la` should show `rw-------` for that file.

Create a SUID program by compiling "access_my_secrets.c". ==action: View the program code, and take a minute to read through it:==

```bash
vi access_my_secrets.c
```

\==action: Save any changes and quit== (Esc, ":wq").

\==action: Compile the program== (which uses the C code to create an executable):

```bash
gcc access_my_secrets.c -o access_my_secrets
```

\==action: Run the program, and make sure it prints the contents of mysecret:==

```bash
./access_my_secrets
```

\==action: Set the permissions for the file== (using `chmod`) to setuid:

```bash
chmod u+s access_my_secrets
```

\==action: Check the permissions include SUID:==

```bash
ls -l access_my_secrets
```

\==action: Run the program again:==

```bash
./access_my_secrets
```

> Note: The program outputs its real and effective identity.

\==action: Change the permissions for your home directory== to enable other users to change to this directory.

\==action: Confirm you're in your home directory, then run the program as the other user:==

```bash
cd
sudo -u ==edit: the other user's username== ./access_my_secrets
```

> Note: If you get a permission error, you may need to change the permissions on your home directory to enable other users to list your files.

> Note: The effective ID is that of the owner of the program. You should also see the contents of the mysecret file, even though the other user doesn't have access to the secrets file directly.

> Question: Think about the security of this solution. How secure is it? Would it be safe for root to be the owner of this program? Why not? (You will come back to this.)

\==hint: The system will be particularly vulnerable when `fs.protected_hardlinks = 0` (you can run `echo 0 | sudo tee /proc/sys/fs/protected_hardlinks` to disable hardlink protection, as is the case on some Unix/Linux systems).==

\==action: Recommended AFTER completing all the flags:==

\==action: It is possible to use this SUID program to get read access to **any** one of the owner user's files! Modify the program to correct the above vulnerability.==

\==action: Modify the program so that the script checks the UID and only continues for a specific user (for example, if the user is root).==

\==hint: `man getuid`==

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Add a secret string to a file in your home directory, then set things up so that file is only readable via a SUID executable — not directly by other users.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Two problem-solving challenges await on the server, using hardlink trickery against relative paths, and combining two shell programs together to reach a flag. This is the end.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

## Conclusion {#conclusion}

At this point you have:

- Learned about Set UID (SUID), become more familiar with C, and compiled a SUID C program
- Worked with C code to compile, edit, and correct security vulnerabilities

Well done!

## Resources {#resources}

[Chapter 6 "Filesystems and Security": Garfinkel, S. Spafford, G. and Schwartz, A. (2003), Practical Unix and Internet Security, O'Reilly. (ISBN-10: 0596003234)](https://www-dawsonera-com.ezproxy.leedsbeckett.ac.uk/abstract/9781449310325)
