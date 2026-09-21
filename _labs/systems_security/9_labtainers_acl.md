---
title: "Access Controls: Labtainers ACL Lab"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Work through the Labtainers 'acl' exercise on Linux file permissions and access control lists, then have Hackerbot check your work and issue flags."
overview: |
  This lab uses Labtainers, a Docker-based platform for hands-on security exercises developed by the Naval Postgraduate School, to teach Linux discretionary access control: standard file permissions and POSIX Access Control Lists (ACLs).

  You will work through the Labtainers "acl" exercise on the desktop VM. Once you tell Hackerbot you are ready, she checks your completed work directly on the VM and issues flags for what you have finished.
tags: ["acl", "access-control-lists", "linux-permissions", "labtainers", "setfacl", "getfacl", "hackerbot"]
categories: ["systems_security"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AAA"
    topic: "Authorisation"
    keywords: ["access control", "enforcing access control", "ACCESS CONTROL - DAC (DISCRETIONARY ACCESS CONTROL)", "Vulnerabilities and attacks on access control misconfigurations"]
  - ka: "MAT"
    topic: "MALCODE/MALWARE"
    keywords: ["trojan", "backdoor", "TROJANS - BACKDOOR"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["Access controls and operating systems", "Linux security model", "Unix File Permissions", "filesystems, inodes, and commands", "umask", "Linux Extended Access Control Lists (facl)"]
  - ka: "OSV"
    topic: "Role of Operating Systems"
    keywords: ["mediation"]
---

## Getting started {#getting-started}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop

The desktop VM needs to be running to complete the lab; the hackerbot_server VM needs to be running afterwards, to obtain flags.

### Your login details for the "desktop" VM {#your-login-details-for-the-desktop-vm}

\==VM: On the desktop VM==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

### For marks in the module {#for-marks-in-the-module}

1. **You need to submit flags**. Note that the flags and the challenges in your VMs are different to other's in the class. Flags will be revealed to you as you complete challenges throughout the module. Flags look like this: `flag{somethingrandom}`. Submit your flags in Hacktivity to register your progress in the lab.
2. **You need to document the work and your solutions in a Log Book**. This needs to include screenshots (including the flags) of how you solved each Hackerbot challenge and a writeup describing your solution to each challenge. The Log Book will be submitted later in the semester.

### Working through the Labtainers exercise {#working-through-the-labtainers-exercise}

\==VM: On the desktop VM==, ==action: open a terminal and start the Labtainers "acl" lab==, then ==action: open the lab sheet linked from the terminal== (often a PDF you can right-click and open).

> Tip: You can skip the Labtainers instructions about installing and controlling Labtainers, and about sending results to an instructor — Hacktivity and Hackerbot handle all of that for you automatically.

{% include hackerbot-intro.md role="check your completed Labtainers work and give you flags once you're done" %}

Work through the Labtainers "acl" lab tasks on the desktop VM, covering standard Unix file permissions and POSIX Access Control Lists.

> Tip: Labtainers can be picky about exactly how you complete a task, including the specific commands used. If it doesn't give you flags you believe you've earned, try the task again using the full, or different, commands.

> Note: Sometimes a single task earns you more than one flag — submit each one separately to Hacktivity.

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Once you say you're ready, Hackerbot logs into the desktop VM, checks your completed Labtainers work, and issues flags for what you've finished.

\==action: Do any necessary preparation, then when you are ready for the bot to complete the attack, say 'ready'.==

Don't forget to ==action: save and submit any flags!==
