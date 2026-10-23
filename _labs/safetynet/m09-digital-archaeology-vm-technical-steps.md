---
title: "Digital Archaeology: VM Technical Steps"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Technical companion to the Digital Archaeology walkthrough, for the lab network: step-by-step hints for the two archive servers, the catalogue server reached with a recovered login and the Tomb Beta server reached by an unauthenticated web exploit, the sudo escalations to root, and the two drop stations, plus command-line practice."
overview: "A getting-started guide to the lab network, the server concepts behind each flag, and stage-by-stage hints for the two targets: one entered with a recovered credential, one by unauthenticated remote code execution."
tags: ["credentialed-access", "ssh", "nostromo", "unauthenticated-rce", "nmap", "cve", "sudo", "privilege-escalation", "break-escape"]
categories: ["safetynet"]
type: ["game-based-learning", "lab-sheet"]
difficulty: "advanced"
source: "https://github.com/cliffe/BreakEscape/blob/main/scenarios/m09_digital_archaeology/scenario.json.erb"
cybok:
  - ka: "NS"
    topic: "Networking Applications"
    keywords: ["NMAP", "Port scanning"]
  - ka: "AAA"
    topic: "Authentication"
    keywords: ["Authentication", "Credential management"]
  - ka: "WAM"
    topic: "Server-Side Vulnerabilities and Mitigations"
    keywords: ["Server-side misconfiguration and vulnerable components"]
  - ka: "SS"
    topic: "Categories of Vulnerabilities"
    keywords: ["CVEs and CWEs"]
  - ka: "SOIM"
    topic: "Fundamental Concepts"
    keywords: ["Vulnerability analysis", "Penetration testing software tools"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["Privilege escalation"]
---

> Note: This is the technical companion to the [Digital Archaeology walkthrough](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/m09-digital-archaeology/). Play the game there first, and come here when you reach a server and want the hints.

## The Training Network {#network}

This is the Season 1 finale, and it has two servers to take, not one. They are reached in two different ways, and that is the lesson of the night: one server opens to a login you recover in the game, the other only to an exploit.

The reading room holds a **Field Laptop**. It opens a Kali attack box on the archive network. The salvage cage, at the end of the night's chain, holds a **Field Kit Link** wired into the Tomb Beta rack. Both launchers open the **same** Kali session, so you work from one box all night.

Two targets sit on that network:

- **The catalogue server.** The archive's own catalogue. The public catalogue is open to anyone, but the restricted index is reachable only by signing in as the catalogue service account. The game hands you that account's login on the reading-room duty-desk slip, so you go in with a recovered credential, not an exploit. It holds flag 1 (the restricted catalogue index) and flag 2 (the Insider Threat Initiative's ledger, under root).
- **The Tomb Beta server.** One of the Architect's closed workshops, racked in the tape room and never signed back in. An old, lightweight web server still answers on it, and it has no login you can recover. You get in through an unauthenticated flaw in that web server. It holds flag 3 (a staff credential that proves who owns the machine) and flag 4 (the mirror job and the defences list, under root).

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

Once you know the subnet, a **ping sweep** lists the live hosts on it. The two you did not start are your targets. A full port scan of each then tells you which is the catalogue server and which is Tomb Beta.

### Two Ways In: Credential and Exploit {#two-routes}

The two servers teach the two most common ways an attacker gets a foothold.

- **Credentialed access** is logging in with an account name and password you have come by, exactly as the real user would. There is no exploit: the server does what it is built to do. The catalogue server works this way. The game recovers the catalogue service account's login for you (the duty-desk slip), and you sign in with it.
- **Unauthenticated remote code execution** needs no account at all. A flaw in a running service turns a request into a command on the server. Tomb Beta's old web server works this way.

A pen tester tries a credential they already hold before anything louder, because a valid login is the quietest and most reliable way in. Only when there is no credential do you reach for an exploit.

### Credentialed Access with a Recovered Login {#credentialed}

When you have an account name, a host and a password, you connect with **SSH** (Secure Shell), which gives you a command line on another machine over an encrypted connection. If the credentials match an account, you get a shell that runs as that account, and it can read and write only what that account may.

The catalogue service account's login is the slip you find in the game: a host, a username and a password. You use it as it stands.

Worked example, on a practice machine of your own:

```bash
ssh archivist@192.0.2.10
archivist@host:~$ id
uid=1001(archivist) gid=1001(archivist) groups=1001(archivist)
archivist@host:~$ ls -la
```

The restricted index you are after is in the service account's own home directory, which that account is allowed to read.

> Note: For a step-by-step on confirming a service is reachable and signing in with a credential you hold, ask Agent HaX in game for the catalogue server field guide, or read the published [SSH Access and Bruteforce](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/ssh-access-and-bruteforce/) guide.

### Web-Service Fingerprinting and CVEs {#cve}

A port scan of a target lists its open ports and often names the software and version behind each one. This is **fingerprinting**. A version is a lead: a published **CVE** (Common Vulnerabilities and Exposures) entry names the affected versions of a piece of software and describes the flaw. You match the version the service reports against the CVE's affected range before you try anything.

Tomb Beta runs an old, lightweight web server, **Nostromo** (nhttpd), on a high port. Nostromo has a published, unauthenticated remote-code-execution flaw. **Remote code execution** (RCE) lets an attacker run commands on the server; **unauthenticated** means no login is needed first.

### Getting a Shell from an Unauthenticated RCE {#rce}

An unauthenticated RCE turns a web request into a command on the server. You confirm it with a harmless command first (`id` or `hostname`), read what account you landed as, then work from there. The account you get is the web server's own service account, with its own limited rights, not root.

> Note: Run a public proof of concept only after you have read it and understand what it does on the target. Code written for a different version may fail or behave in ways you did not intend.

### The Linux Shell and Filesystem {#shell}

A Linux shell works on a set of directories and files. Each file has an owner and permissions. An account's **home directory** is the part of the disk it owns. Files outside it, such as the logs and records root keeps, usually belong to root.

```bash
archivist@host:~$ cat /root/secret.txt
cat: /root/secret.txt: Permission denied
```

A file you may not read answers the same way whoever you are, so "Permission denied" is a signal to look at whose rights you need, not a dead end.

### Sudo and Privilege Escalation {#sudo}

**Privilege escalation** means moving from a low-rights account to a higher one, usually root. **sudo** lets an account run a command as another user, if the sudo rules allow it. Running `sudo -l` lists what your account may run.

A rule that lets an account run a tool which can start a shell, or run another program, is a misconfiguration. A **pager**, the kind of program that shows a long file a screen at a time, is a common example: at its prompt you can type `!/bin/sh` and drop to a shell running with the pager's privileges. Both targets here escalate through a sudo rule on a pager, and they use two different pagers, so read your own `sudo -l` output rather than assuming.

Worked example, with made-up output:

```bash
sudo -l
User archivist may run the following commands:
    (root) NOPASSWD: /bin/more /root/notes.txt
```

A rule like that hands out a root shell, because the pager can escape to one. You run the exact command it allows, then escape from the pager's prompt.

## Stuck? Hints, Stage by Stage {#hints}

Find the stage you are on. Read the hint, then go back and try. If you are still stuck, open **Nudge**. Open **Recipe** last. The Recipe names the tools and the steps, never a flag value.

> Tip: Before you open any hint, ask three things. Have I got a login for this box, or do I need an exploit? What version is any service it runs? What can my account do once I am on it?

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

> Warning: Do not aim anything at your own Kali address. Confirm which address is a target with a port scan before you work on it.

### Stage 1: The Catalogue Index (Flag 1) {#hints-vm-catalogue-foothold}

**Where:** the attack box's terminal, against the catalogue server. **Goal:** sign in to the catalogue service account with the login the game recovered, read the restricted index, and submit the flag at the reading-room drop terminal.

> Hint: This box is not an exploit. The game hands you the catalogue service account's login on a slip. Find that slip, then use the host, username and password as they stand.

<details markdown="1">
<summary>Nudge</summary>

The reading-room duty-desk slip carries the catalogue service account's login: a host, a username and a password, written for the overnight index run. Sign in to that host over SSH as that account. Once you are in, the restricted catalogue index sits in the account's own home directory. Read it there. It lists a restricted series and a cage bay.

**Learn it:** ==action: Before you connect, confirm the login port is open on the catalogue server with a quick scan==, so you know SSH is answering.

**To learn more in game:** ask Agent HaX for the catalogue server field guide.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Read the duty-desk slip in the reading room== and note the host, the username and the password it gives for the catalogue service account.
2. \==action: Port-scan the catalogue server with service detection: `nmap -sV -p- <catalogue server>`==, and confirm the login service is open.
3. \==action: Sign in over SSH as the catalogue service account with the slip's password==, then run `id` to confirm which account you are.
4. \==action: Read the restricted catalogue index in that account's home directory, and submit the flag at the SAFETYNET Drop Terminal in the reading room==.

</details>

> Warning: Flag 1 needs the slip. If you have not found and read the duty-desk slip in game yet, you do not have the login, and nothing you do on the box will hand it to you. Go back for the slip first.

### Stage 2: The Initiative's Ledger (Flag 2) {#hints-vm-ledger}

**Where:** the attack box's terminal, from the login you used in Stage 1. **Goal:** escalate to root on the catalogue server, read the Insider Threat Initiative's ledger, and submit the flag at the reading-room drop terminal.

> Hint: Ask what the service account may run as root before you look for anything else. The ledger belongs to root, so you need root to read it.

<details markdown="1">
<summary>Nudge</summary>

Run `sudo -l` from the catalogue service account. It may run a pager as root against a file in root's home. That pager can escape to a root shell. Run the exact command the rule allows, then drop to a shell from the pager's prompt. The ledger names placements, candidates and a legacy section, and a source-file reference; read it, do not change it.

**Learn it:** ==action: Before you run a command as root, write down what it will do and what it could change==.

**To learn more in game:** ask Agent HaX for the field guide on the ledger (privilege escalation).

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Run `sudo -l` as the catalogue service account==. Note the pager it may run as root, the file it is allowed to open, and that it needs no password.
2. \==action: Run that exact allowed command==, for example `sudo /bin/more /root/<the file it names>`. The ledger opens in the pager.
3. \==action: Escape the pager to a root shell by typing `!/bin/sh` at its prompt==, then confirm with `id`. (See the Privilege Escalation guide, "Escaping an Allowed Command to a Shell (GTFOBins)".)
4. \==action: Read the ledger and submit the flag at the SAFETYNET Drop Terminal==.

</details>

> Warning: You are root on a server that matters to the story. Read the ledger, but do not change, delete or move it.

> Tip: A natural stopping point for a 60-minute class is here, with the catalogue server's two flags submitted. The Tomb Beta server comes later in the night, after the salvage cage opens.

### Stage 3: Tomb Beta's Owner (Flag 3) {#hints-vm-tomb-foothold}

**Where:** the attack box's terminal, against the Tomb Beta server, once you have reached the salvage cage and used the Field Kit Link. **Goal:** get code running on the Tomb Beta web server with no login, read the flag, and submit it at the Tomb Beta Drop Link in the cage.

> Hint: This box has no login to recover. Scan it. A small, old web server answers on a high port. Match its name and version to a public CVE, then exploit it.

<details markdown="1">
<summary>Nudge</summary>

Fingerprint the web server and note that it is Nostromo (nhttpd), with its version. Look the version up in the CVE database and read the flaw. Find a public proof of concept for the Nostromo RCE, read it, and run it from the attack box. A harmless command such as `id` confirms it works and shows you landed as the web service account. That account's home holds the flag, a staff credential that proves who owns the server, a memo about a control-equipment flaw, an unsent vendor notice, and a holdings record. Read all of them.

**Learn it:** ==action: Name the web server and its version, and the CVE, before you run anything==.

**To learn more in game:** ask Agent HaX for the field guide for Tomb Beta's box, or the Scanning and Exploitation field guide.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Port-scan the Tomb Beta server with service detection: `nmap -sV -p- <tomb beta server>`==, and note the Nostromo port and version.
2. \==action: Search the CVE database for the Nostromo version==, and read the affected versions and the description.
3. \==action: Find a public proof of concept for the Nostromo RCE, read it, and run it against the Tomb Beta server==. Confirm with a harmless command first and read which account you landed as.
4. \==action: Read the flag and the documents in the web service account's home, and submit the flag at the Tomb Beta Drop Link in the salvage cage==.

</details>

> Warning: Submit this flag at the Tomb Beta Drop Link, not the reading-room terminal. The reading-room terminal refuses it and points you to the cage.

### Stage 4: Tomb Beta's Control (Flag 4) {#hints-vm-tomb-root}

**Where:** the attack box's terminal, from the foothold you got in Stage 3. **Goal:** escalate to root on the Tomb Beta server, read the scheduled mirror job and the defences list, and submit the flag at the Tomb Beta Drop Link.

> Hint: Ask what the web service account may run as root. The same kind of pager rule that worked on the catalogue server is here too, with a different pager.

<details markdown="1">
<summary>Nudge</summary>

Run `sudo -l` from the web service account. If it may run a pager as root against a file in root's home, escape it to a root shell the same way as on the catalogue server. Root's home holds the scheduled job that mirrors to Tomb Gamma, the publication hour, the cells' head start and the defences list. Read it.

**Learn it:** ==action: Compare this server's sudo rule with the catalogue server's== and note that the same class of flaw appears on both, with a different tool.

**To learn more in game:** ask Agent HaX for the field guide for Tomb Beta's box (privilege escalation).

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Run `sudo -l` as the web service account==. Note the pager it may run as root and the file it is allowed to open.
2. \==action: Run that exact allowed command==, for example `sudo /bin/less /root/<the file it names>`, then escape to a root shell with `!/bin/sh` at its prompt, as in Stage 2.
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

> Question: One server opened to a login you recovered, the other only to an exploit. For the catalogue server, where did the weakness actually sit, if the login worked exactly as designed?

> Question: Tomb Beta's foothold needed no login at all. Name one change its owner could have made to the web server that would have stopped the foothold, and say what would still be exposed after it.

> Question: The same class of sudo flaw escalated both servers to root, through two different pagers. Why is a sudo rule on a pager a privilege-escalation flaw, when the pager was only meant to show a file?

> Question: The Tomb Beta server was signed out years ago and never signed back in. What does an abandoned, still-running server cost its owner, beyond the files on it?

> Action: Write a short checklist for whoever runs these two servers. Give one line per flag, naming the control that would have stopped that stage: the recovered login, the web RCE, and the two sudo rules. Hand in the checklist.

## Further Reading {#further-reading}

- [SAFETYNET Field Guide: Reconnaissance and Network Mapping](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/reconnaissance-and-network-mapping/)
- [SAFETYNET Field Guide: SSH Access and Bruteforce](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/ssh-access-and-bruteforce/)
- [SAFETYNET Field Guide: SSH Access and Linux System Navigation](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/ssh-access-and-linux-basics/)
- [SAFETYNET Field Guide: Scanning and Exploitation](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/scanning-and-exploitation/)
- [SAFETYNET Field Guide: Privilege Escalation via Sudo](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/privilege-escalation/)
- [GTFOBins](https://gtfobins.github.io/)
