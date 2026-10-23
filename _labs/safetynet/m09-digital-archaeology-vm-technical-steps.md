---
title: "Digital Archaeology: VM Technical Steps"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Technical companion to the Digital Archaeology walkthrough, for the lab network: step-by-step hints for the catalogue server and the Tomb Beta server, the two unauthenticated footholds, the sudo escalations to root, and the two drop stations, plus command-line practice."
overview: "A getting-started guide to the lab network, the server concepts behind each flag, and stage-by-stage hints for the two targets."
tags: ["apache-druid", "nostromo", "unauthenticated-rce", "nmap", "cve", "ssh", "sudo", "privilege-escalation", "break-escape"]
categories: ["safetynet"]
type: ["game-based-learning", "lab-sheet"]
difficulty: "advanced"
source: "https://github.com/cliffe/BreakEscape/blob/main/scenarios/m09_digital_archaeology/labsheet_vm_steps.md"
cybok:
  - ka: "NS"
    topic: "Networking Applications"
    keywords: ["NMAP", "Port scanning"]
  - ka: "WAM"
    topic: "Server-Side Vulnerabilities and Mitigations"
    keywords: ["Server-side misconfiguration and vulnerable components", "Injection vulnerabilities"]
  - ka: "SS"
    topic: "Categories of Vulnerabilities"
    keywords: ["CVEs and CWEs"]
  - ka: "SOIM"
    topic: "Fundamental Concepts"
    keywords: ["Vulnerability analysis", "Penetration testing software tools"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["Privilege escalation"]
  - ka: "AAA"
    topic: "Authentication"
    keywords: ["User authentication"]
---

> Note: This is the technical companion to the [Digital Archaeology walkthrough](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/m09-digital-archaeology/). Play the game there first, and come here when you reach a server and want the hints.

## The Training Network {#network}

This is the Season 1 finale, and it has two servers to take, not one.

The reading room holds a **Field Laptop**. It opens a Kali attack box on the archive network. The salvage cage, at the end of the night's chain, holds a **Field Kit Link** wired into the Tomb Beta rack. Both launchers open the **same** Kali session, so you work from one box all night.

Two targets sit on that network:

- **The catalogue server.** The archive's own catalogue service, exposed with no login on a high port. It holds flag 1 (the catalogue index) and flag 2 (the Insider Threat Initiative's ledger, under root).
- **The Tomb Beta server.** One of the Architect's closed workshops, racked in the tape room and never signed back in. An old, lightweight web server runs on it. It holds flag 3 (a staff credential that proves who owns the machine) and flag 4 (the mirror job and the defences list, under root).

You submit the flags at two stations, and each station takes only its own machine's flags:

- The **SAFETYNET Drop Terminal** in the reading room takes the catalogue server's two flags (1 and 2).
- The **Tomb Beta Drop Link** in the salvage cage takes the Tomb Beta server's two flags (3 and 4).

> Warning: Flags 3 and 4 are refused at the reading-room drop terminal. That terminal belongs to the catalogue server. Submit the Tomb Beta flags at the drop link in the salvage cage.

Each flag value is generated for each game, so this sheet never gives one. It says where each flag sits and how to reach it.

## Concepts {#concepts}

You do not need to read all of this before you start. Come back to it when a stage leaves you unsure what a tool or a result is telling you.

### Network Mapping and Reconnaissance {#recon}

Before you attack anything, you map the network. Your own address tells you the subnet you are on, and a host-discovery scan finds the other machines sharing it. The number after the slash in an address is the **prefix length**, and it says how many addresses the subnet holds. A `/24` keeps the first three numbers fixed and lets the last vary, so it covers 256 addresses.

Worked example, run on your own machine:

```bash
python3 -c "print('a /24 holds', 2**(32-24), 'addresses')"
```

That prints `a /24 holds 256 addresses`. So from an address like `172.16.0.3/24`, the subnet to sweep is `172.16.0.0/24`.

Once you know the subnet, a **ping sweep** lists the live hosts on it. The two you did not start are your targets.

### Web-Service Fingerprinting and CVEs {#cve}

A port scan of a target lists its open ports and often names the software and version behind each one. This is **fingerprinting**. A version is a lead: a published **CVE** (Common Vulnerabilities and Exposures) entry names the affected versions of a piece of software and describes the flaw. You match the version the service reports against the CVE's affected range before you try anything.

Both targets here run a service with a known, published flaw:

- the catalogue service is **Apache Druid**, with an unauthenticated remote-code-execution flaw;
- the Tomb Beta web server is **Nostromo** (nhttpd), a small, old web server with its own unauthenticated remote-code-execution flaw.

A **remote code execution** (RCE) flaw lets an attacker run commands on the server. **Unauthenticated** means no login is needed first.

### Getting a Shell from an Unauthenticated RCE {#rce}

An unauthenticated RCE turns a web request into a command on the server. You confirm it with a harmless command first (`id` or `hostname`), read what account you landed as, then work from there. The account you get is usually the service's own account, with its own limited rights, not root.

> Note: Run a public proof of concept only after you have read it and understand what it does on the target. Code written for a different version may fail or behave in ways you did not intend.

### SSH and the Linux Shell {#ssh}

**SSH** (Secure Shell) gives you a command line on another machine over an encrypted connection. You give it an account name, a host, and a password or a key. If the credentials match an account, you get a shell that runs as that account, and it can read and write only what that account may.

A Linux shell works on a set of directories and files. Each file has an owner and permissions. An account's **home directory** is the part of the disk it owns. Files outside it, such as the logs and records root keeps, usually belong to root.

Worked example, on a practice machine of your own:

```bash
ssh alice@192.0.2.10
alice@host:~$ ls -la
alice@host:~$ cat /root/secret.txt
cat: /root/secret.txt: Permission denied
```

A file you may not read answers the same way whoever you are, so "Permission denied" is a signal to look at whose rights you need, not a dead end.

### Sudo and Privilege Escalation {#sudo}

**Privilege escalation** means moving from a low-rights account to a higher one, usually root. **sudo** lets an account run a command as another user, if the sudo rules allow it. Running `sudo -l` lists what your account may run.

A rule that lets an account run a tool which can start a shell, or run another program, is a misconfiguration. A **pager**, the kind of program that shows a long file a screen at a time, is a common example: at its prompt you can type `!/bin/sh` and drop to a shell running with the pager's privileges. Both targets here escalate through a sudo rule on a pager.

Worked example, with made-up output:

```bash
sudo -l
User archivist may run the following commands:
    (root) NOPASSWD: /usr/bin/more
```

A rule like that hands out a root shell, because the pager can escape to one.

## Stuck? Hints, Stage by Stage {#hints}

Find the stage you are on. Read the hint, then go back and try. If you are still stuck, open **Nudge**. Open **Recipe** last. The Recipe names the tools and the steps, never a flag value.

> Tip: Before you open any hint, ask three things. What version is this service? What does it say when you connect? What can this account do once you are on the box?

### Getting Onto the Attack Box {#hints-vm-attack-box}

**Where:** the Field Laptop in the reading room (or the Field Kit Link in the salvage cage; both open the same Kali). **Goal:** a working terminal on the attack box, and the addresses of the two targets.

> Hint: The launcher opens the attack box, not a target. Before you aim anything, find your own address and the subnet, then sweep it for the other hosts.

<details markdown="1">
<summary>Nudge</summary>

The attack box and both targets share one subnet. Your own address and its prefix length tell you the range to sweep. A ping sweep of that range lists the live hosts; the two that are not your own box are the catalogue server and the Tomb Beta server. Note both addresses now, because you will come back to the second one later in the night.

**Learn it:** ==action: Work out the subnet by hand== from an address and a prefix length, then check it against the sweep.

**To learn more in game:** ask the phone for the Reconnaissance and Network Mapping field guide.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Run `ip -4 addr` in the attack box's terminal==, and note your address and the prefix length on the lab interface.
2. \==action: Sweep the subnet for live hosts with `nmap -sn <subnet>`==, using the range from step 1.
3. \==action: Record both target addresses==. One is the catalogue server, one is the Tomb Beta server; a full port scan of each in the next stages tells you which is which.

</details>

> Warning: Do not aim the exploits at your own Kali address. Confirm which address is a target with a port scan before you fire anything at it.

### Stage 1: The Catalogue Index (Flag 1) {#hints-vm-catalogue-foothold}

**Where:** the attack box's terminal, against the catalogue server. **Goal:** get code running on the catalogue service with no login, read the flag, and submit it at the reading-room drop terminal.

> Hint: Scan the catalogue server and read what software and version the catalogue service reports. Work out which public CVE describes that software and that version, and what the attacker controls.

<details markdown="1">
<summary>Nudge</summary>

Fingerprint the catalogue service and note the name (Apache Druid) and its version. Look that version up in the CVE database and read the affected range and the description. Find a public proof of concept for the Druid flaw, read it, and run it from the attack box. A harmless command such as `id` confirms it works and shows which account you landed as. The flag sits in that service account's home.

**Learn it:** ==action: Write down the version and the CVE number before you run anything==, then check the proof of concept against the CVE description.

**To learn more in game:** ask the phone for the Scanning and Exploitation field guide.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Port-scan the catalogue server with service detection: `nmap -sV -p- <catalogue server>`==, and note the Druid port and version.
2. \==action: Search the CVE database for the Druid version==, and read the affected versions and the description.
3. \==action: Find a public proof of concept for the Druid RCE, read it, and run it against the catalogue server from the attack box==. Confirm with a harmless command first.
4. \==action: Read the flag from the service account's home, and submit it at the SAFETYNET Drop Terminal in the reading room==.

</details>

> Note: The exact route to this flag may change under a pending design decision. The plan keeps the Druid exploit as the way onto the box, but the exploit may land you without the rights to read the flag file, so reading it would then need a login with a password you find in the game. If your shell cannot open the flag file, look for that login in the game and come back. Treat the steps above as the current route and adjust if the box behaves this way.

> Warning: A proof of concept written for another Druid version may fail, or do something you did not expect. Check its version notes against the version you found in step 1.

### Stage 2: The Initiative's Ledger (Flag 2) {#hints-vm-ledger}

**Where:** the attack box's terminal, from the foothold you got in Stage 1. **Goal:** escalate to root on the catalogue server, read the Insider Threat Initiative's ledger, and submit the flag at the reading-room drop terminal.

> Hint: Ask what the account you landed on may run as root before you look for anything else. The ledger belongs to root, so you need root to read it.

<details markdown="1">
<summary>Nudge</summary>

Run `sudo -l` from the foothold account. If it may run a pager as root, that pager can escape to a root shell. Once you are root, the ledger file sits in root's home. The ledger names placements, candidates and a legacy section; read it, do not change it.

**Learn it:** ==action: Before you run a command as root, write down what it will do and what it could change==.

**To learn more in game:** ask the phone for the Privilege Escalation field guide.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Run `sudo -l` as the foothold account==. Note which tool may run as root, and whether it asks for a password.
2. \==action: Open the Privilege Escalation guide at "Method 4: Escaping an Allowed Command to a Shell (GTFOBins)", and find the entry for the pager you were granted==. At its prompt, type `!/bin/sh` to escape to a root shell.
3. \==action: Confirm you are root with `id`==.
4. \==action: Read the ledger in root's home, and submit the flag at the SAFETYNET Drop Terminal==.

</details>

> Warning: You are root on a server that matters to the story. Read the ledger, but do not change, delete or move it.

> Tip: A natural stopping point for a 60-minute class is here, with the catalogue server's two flags submitted. The Tomb Beta server comes later in the night, after the salvage cage opens.

### Stage 3: Tomb Beta's Owner (Flag 3) {#hints-vm-tomb-foothold}

**Where:** the attack box's terminal, against the Tomb Beta server, once you have reached the salvage cage and used the Field Kit Link. **Goal:** get code running on the Tomb Beta web server with no login, read the flag, and submit it at the Tomb Beta Drop Link in the cage.

> Hint: Scan the Tomb Beta server. A small, old web server runs on it, on a high port. Match its name and version to a public CVE the same way you did for the catalogue.

<details markdown="1">
<summary>Nudge</summary>

Fingerprint the web server and note that it is Nostromo (nhttpd), with its version. Look the version up in the CVE database and read the flaw. Find a public proof of concept for the Nostromo RCE, read it, and run it from the attack box. The web service account's home holds the flag, a staff credential that proves who owns the server, a memo about a control-equipment flaw, and an unsent vendor notice. Read all four.

**Learn it:** ==action: Name the web server and its version, and the CVE, before you run anything==.

**To learn more in game:** ask the phone for the Scanning and Exploitation field guide.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Port-scan the Tomb Beta server with service detection: `nmap -sV -p- <tomb beta server>`==, and note the Nostromo port and version.
2. \==action: Search the CVE database for the Nostromo version==, and read the affected versions and the description.
3. \==action: Find a public proof of concept for the Nostromo RCE, read it, and run it against the Tomb Beta server==. Confirm with a harmless command first.
4. \==action: Read the flag and the documents in the web service account's home, and submit the flag at the Tomb Beta Drop Link in the salvage cage==.

</details>

> Note: The exact route to this flag may change under the same pending design decision as Stage 1. The plan keeps the Nostromo exploit as the way onto the box, but the exploit may land you without the rights to read the flag file, so reading it would then need a login with a password you find in the game (the plan points at a record in the salvage cage). If your shell cannot open the flag file, look for that login in the game and come back. Treat the steps above as the current route and adjust if the box behaves this way.

> Warning: Submit this flag at the Tomb Beta Drop Link, not the reading-room terminal. The reading-room terminal refuses it.

### Stage 4: Tomb Beta's Control (Flag 4) {#hints-vm-tomb-root}

**Where:** the attack box's terminal, from the foothold you got in Stage 3. **Goal:** escalate to root on the Tomb Beta server, read the scheduled mirror job and the defences list, and submit the flag at the Tomb Beta Drop Link.

> Hint: Ask what the web service account may run as root. The same kind of pager rule that worked on the catalogue server is here too.

<details markdown="1">
<summary>Nudge</summary>

Run `sudo -l` from the web service account. If it may run a pager as root, escape it to a root shell the same way as on the catalogue server. Root's home holds the scheduled job that mirrors to Tomb Gamma, the publication hour, the cells' head start and the defences list. Read it.

**Learn it:** ==action: Compare this server's sudo rule with the catalogue server's== and note that the same class of flaw appears on both.

**To learn more in game:** ask the phone for the Privilege Escalation field guide.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Run `sudo -l` as the web service account==. Note the pager it may run as root.
2. \==action: Escape the pager to a root shell with `!/bin/sh` at its prompt==, as in Stage 2.
3. \==action: Confirm you are root with `id`==.
4. \==action: Read the mirror job and defences file in root's home, and submit the flag at the Tomb Beta Drop Link==.

</details>

> Warning: This is the last server of the finale. Read the file, but do not change it. The story reads what you leave behind.

### Submitting the Four Flags {#hints-vm-submit}

> Tip: Submit each flag as soon as you find it. The reading-room drop terminal takes the catalogue server's two flags; the salvage-cage drop link takes the Tomb Beta server's two.

Copy each flag exactly as it appears in the output.

## Try It on the Command Line (Optional) {#command-line}

These exercises use your own machine and made-up data. Do not run them against the lab servers.

### Working out a subnet by hand {#cli-subnet}

Take an address and a prefix length, and count the addresses the subnet holds.

```bash
python3 -c "p=24; print('a /%d holds %d addresses' % (p, 2**(32-p)))"
```

\==action: Change the prefix length to `16` and run it again==, then say how the host range widens. A `/24` fixes the first three numbers; a `/16` fixes only the first two.

### Reading your own sudo rules {#cli-sudo}

On your own Kali box, run `sudo -l` and read the output line by line.

```bash
sudo -l
```

\==action: For each command the output lists, write one sentence saying what it can do when it runs as root==. Ask whether any of them is a pager, an editor or a tool that can run another program. This exercise is reading only. Do not escalate on the lab servers beyond what the stages need.

## After the Game: Questions and Exercises {#questions}

### Attacking the Server {#questions-server}

> Question: Both footholds needed no login. Name one change the archive could have made to each service that would have stopped the foothold, and say what would still be exposed after it.

> Question: The same class of sudo flaw escalated both servers to root. Why is a sudo rule on a pager a privilege-escalation flaw, when the pager was only meant to show a file?

> Question: The Tomb Beta server was signed out years ago and never signed back in. What does an abandoned, still-running server cost its owner, beyond the files on it?

> Action: Write a short checklist for whoever runs these two servers. Give one line per flag, naming the control that would have stopped that stage. Hand in the checklist.

## Further Reading {#further-reading}

- [SAFETYNET Field Guide: Reconnaissance and Network Mapping](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/reconnaissance-and-network-mapping/)
- [SAFETYNET Field Guide: Scanning and Exploitation](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/scanning-and-exploitation/)
- [SAFETYNET Field Guide: Apache Druid RCE](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/apache-druid-rce/)
- [SAFETYNET Field Guide: SSH Access and Linux System Navigation](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/ssh-access-and-linux-basics/)
- [SAFETYNET Field Guide: Privilege Escalation via Sudo](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/privilege-escalation/)
- [GTFOBins](https://gtfobins.github.io/)
