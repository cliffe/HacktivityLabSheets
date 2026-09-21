---
title: "Hacker vs Hackerbot: A Defensive Skills Test"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "A combined test lab where Hackerbot live-attacks your system across file permissions, file attributes, read-only mounts, backups, file integrity checking, and network monitoring."
overview: |
  This lab is a combined test that draws on several earlier topics: protecting files with Unix permissions, file attributes and read-only mounts; detecting unauthorised change using backups and file hashing; backing up and recovering files with rsync; and spotting a network scan with a packet capture tool.

  Hackerbot will attack your system live, and you must apply techniques from those topics to stop or detect each attack. Because this is a combined test, Hackerbot draws a random subset of its attacks from several pools each time a set of VMs is built, so you may not see every attack described below — work through whichever ones it presents to you.
tags: ["file-permissions", "file-attributes", "chattr", "read-only", "bind-mount", "backups", "rsync", "file-integrity", "hashing", "nmap", "network-monitoring", "hackerbot"]
categories: ["response_and_investigation"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AAA"
    topic: "Authorisation"
    keywords: ["access control", "protecting integrity"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["Linux read-only protections: ro mounts, file attributes"]
  - ka: "OSV"
    topic: "Human Factors: Incident Management"
    keywords: ["backups", "recovery"]
  - ka: "NS"
    topic: "Network Defence Tools"
    keywords: ["network monitoring", "nmap", "port scanning"]
---

## Getting started {#getting-started}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- backup_server
- desktop

All of these VMs need to be running to complete the lab.

### Your login details for the "desktop" and "backup_server" VMs {#your-login-details}

\==VM: On the desktop VM==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the backup_server directly for most of the lab, but ==action: SSH into it== when a challenge below asks you to check your remote backups. Use the same username and password on both VMs.

There is also a second account on the desktop that some of the challenges below refer to. ==action: List the accounts on the system== to find its username:

```bash
ls /home
```

\==edit: note the second username== — the challenges below refer to it as *the second user*.

### For marks in the module {#for-marks-in-the-module}

\==action: You need to submit flags==. Note that the flags and the challenges in your VMs are different to other students' in the class. Flags will be revealed to you as you complete challenges throughout the lab. Flags look like this: `flag{`==edit: something random==`}`. Follow the link on the module page to submit your flags.

{% include hackerbot-intro.md role="task you to complete challenges and will attack your systems" %}

### Useful commands {#useful-commands}

Some commands you may find useful in this lab include: `rsync`, `chattr`, `lsattr`, `chmod`, `hashdeep`, `shasum`, `mount`, `umount`, `diff`, `tcpdump`, `kdesudo`, `wireshark`.

> Tip: Remember you can learn more about a command by running `man` ==edit: command==.

## What this test covers {#what-this-test-covers}

This test presents a randomised selection of challenges drawn from the topics covered in the earlier labs in this series. ==edit: revise the labs listed below== if you want to prepare:

1. Integrity Management: Protecting Against Change
2. Integrity Management: Detecting Change
3. Backing Up and Recovering from Disaster: SSH/SCP, Deltas, and Rsync
4. Intrusion Detection and Prevention Systems: Configuration and Monitoring using Snort

##

Don't forget to ==action: save and submit any flags!==
