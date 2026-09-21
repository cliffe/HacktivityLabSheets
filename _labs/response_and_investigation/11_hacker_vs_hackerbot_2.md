---
title: "Hacker vs Hackerbot 2"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "A combined Hackerbot test spanning file permission and integrity protection, network intrusion detection and Snort rules, exfiltration detection, and live and dead forensic analysis."
overview: |
  This is a combined assessment covering several detection and response topics in one sitting: protecting files with permissions and file attributes, detecting tampering using backups and file integrity checkers, monitoring the network and writing Snort intrusion detection rules, detecting the exfiltration of sensitive data, and performing live and dead (offline) forensic analysis of a compromised web server.

  Hackerbot will run a series of attacks against your systems. Each attack draws from a pool of possible challenges covering the same technique, so the exact details (filenames, ports, services, messages) will differ each time you run the lab — Hackerbot will tell you exactly what it needs in the chat. Work through each attack as it is presented.

  This is a Hackerbot lab. Work through the lab sheet, then when prompted interact with Hackerbot.
tags: ["hackerbot", "permissions", "integrity", "backups", "ids", "snort", "exfiltration", "live-analysis", "dead-analysis", "forensics"]
categories: ["response_and_investigation"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AAA"
    topic: "Authorisation"
    keywords: ["access control", "protecting integrity"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["Linux read only protections: ro mounts, file attributes"]
  - ka: "F"
    topic: "Artifact Analysis"
    keywords: ["cryptographic hashing"]
  - ka: "SOIM"
    topic: "Monitor: Data Sources"
    keywords: ["network traffic"]
  - ka: "SOIM"
    topic: "Analyse: Analysis Methods"
    keywords: ["misuse detection", "anomaly detection", "exfiltration detection / data loss prevention"]
  - ka: "NS"
    topic: "Network Defence Tools"
    keywords: ["packet filters", "intrusion detection systems", "IDS rules creation"]
  - ka: "F"
    topic: "Main Memory Forensics"
    keywords: ["process information", "file information", "network connections", "challenges of live forensics"]
  - ka: "F"
    topic: "Operating System Analysis"
    keywords: ["storage forensics", "data recovery and file content carving", "timeline analysis"]
  - ka: "AAA"
    topic: "Accountability"
    keywords: ["the fallibility of digital evidence to tampering"]
  - ka: "MAT"
    topic: "Malware Detection"
    keywords: ["identifying the presence of malware", "attack detection"]
---

## Troubleshooting during the test {#troubleshooting-during-the-test}

In the unlikely event you experience technical issues with the infrastructure during the test, which you believe to be outside your control, make sure to record evidence (such as screenshots) and let your tutor know as soon as possible, the same day.

However, keep in mind no hints will be given for the actual test challenges while the test is available.

## Getting started {#getting-started}

### VMs in this test {#vms-in-this-test}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- ids_monitor
- web_server (leave it running, you don't log into this)
- compromised_server (leave it running, you don't log into this)
- desktop

All of these VMs need to be running to complete the test.

\==action: Note the IP addresses of the ids_monitor, web_server, hackerbot_server and compromised_server VMs== — ==edit: given to you when you claimed the VMs==. You will need these throughout the test.

### Your login details for the "desktop" and "ids_monitor" VMs {#your-login-details}

\==VM: On the desktop and ids_monitor VMs==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the hackerbot_server, web_server or compromised_server VMs, but all the VMs need to be running to complete the test.

### For marks in the module {#for-marks-in-the-module}

\==action: You need to submit flags==. Note that the flags and the challenges in your VMs are different to other students' in the class. Flags will be revealed to you as you complete challenges throughout the test. Flags look like this: `flag{`==edit: something random==`}`. Follow the link on the module page to submit your flags.

{% include hackerbot-intro.md role="task you to complete challenges and will attack your systems" %}

Some commands you may find useful in this test:

`rsync`, `chattr`, `lsattr`, `chmod`, `hashdeep`, `shasum`, `mount`, `umount`, `diff`, `tcpdump`, `wireshark`, `sudo`, `ssh`, `snort`, `netstat`, `ps`, `lsof`, `top`.

```bash
sudo service snort stop
sudo service snort start
```

\==tip: Remember you can learn more about a command by running:==

```bash
man command
```

## What this test covers {#what-this-test-covers}

This test presents a randomised selection of challenges drawn from the topics covered in the earlier labs in this series. ==edit: revise the labs listed below== if you want to prepare:

1. Integrity Management: Protecting Against Change
2. Integrity Management: Detecting Change
3. Backing Up and Recovering from Disaster: SSH/SCP, Deltas, and Rsync
4. Intrusion Detection and Prevention Systems: Configuration and Monitoring using Snort
5. IDS: Writing Rules
6. Exfiltration Detection: Data Loss Prevention with Snort
7. Live Analysis: Investigating a Compromised Server
8. Analysis of a Compromised System: Offline Analysis
9. Log management, Security Information and Event Management (SIEM), and Elastic (ELK) Stack

##

Don't forget to ==action: save and submit any flags!==

---
