---
title: "Full Disclosure: VM Technical Steps"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Technical companion to the Full Disclosure walkthrough, for the bunker network: step-by-step hints for the command-injection foothold on the monitoring host, the credentialed staging login, the container escape to the release host and the chroot escape to the core host, plus command-line practice."
overview: "This companion holds the whole server block for Mission 10. It has the VM concepts (network mapping, command injection, found credentials and credentialed access, container and chroot confinement, privilege escalation, audit trails), stage-by-stage hints for the four flags, command-line practice on your own data, and the server reflection questions."
tags: ["maltrail", "command-injection", "nmap", "credentialed-access", "ssh", "docker", "privileged-container", "container-escape", "chroot", "privilege-escalation", "break-escape"]
categories: ["safetynet"]
type: ["game-based-learning", "lab-sheet"]
difficulty: "advanced"
source: "https://github.com/cliffe/BreakEscape/blob/main/scenarios/m10_full_disclosure/"
cybok:
  - ka: "NS"
    topic: "Network Security Tools"
    keywords: ["Network security monitoring"]
  - ka: "NS"
    topic: "Networking Applications"
    keywords: ["Nmap", "Port scanning"]
  - ka: "WAM"
    topic: "Server-Side Vulnerabilities and Mitigations"
    keywords: ["Injection vulnerabilities", "Server-side misconfiguration and vulnerable components"]
  - ka: "OSV"
    topic: "Role of Operating Systems"
    keywords: ["Isolation", "Containers", "Chroot"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["Privilege escalation"]
  - ka: "AAA"
    topic: "Authentication"
    keywords: ["User authentication"]
  - ka: "F"
    topic: "Definitions and Conceptual Models"
    keywords: ["Audit trail"]
---

> Note: This is the technical companion to the [Full Disclosure walkthrough](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/m10-full-disclosure/). Play the game there first, and come here for the bunker server hints.

## The Training Network {#network}

The raid on Tomb Gamma runs across a small network. You get one attack box, and there are three targets.

- **The attack box** is a Kali Linux machine. It is the terminal at the forward post, the only box you attack from.
- **The security monitoring host** is where the bunker's cameras and door systems report. It carries the first two flags, but on two separate accounts reached two different ways: the first by breaking into the monitoring platform, the second by a login you find in the bunker.
- **The release host** runs the release service inside a container.
- **The core host** runs a service inside an older confined area, and sits beneath Tesseract's own console.

There are four flags, one at each station, and each station takes one flag. The game opens the stations in order as you move through the bunker, so you submit each flag in the room the story reaches:

1. **The monitoring foothold** goes in at the **gate terminal**, up at the forward post.
2. **The staging schedule** goes in at the **release console** in the server hall.
3. **The release host** goes in at the **sealed section's hatch**, at the east end of the server hall.
4. **The core host** goes in at the **core host terminal**, after the clock is stopped.

The stations are gated by the bunker's room locks, so the order is fixed by the game, not by the network. Submit each flag at its own station: a flag put in at the wrong terminal is read as a hint, not an answer.

The flag values are generated for each game, so this sheet never gives one. It says where each flag sits and how to reach it.

Two of the stages hand you a **found login** inside the bunker and two make you break in. The split matters, so keep it in mind as you go. The monitoring foothold (flag 1) and both climax hosts (flags 3 and 4) are **exploitation**: a flaw lets you in, no password needed. The staging schedule (flag 2) is **credentialed**: a sign-in card you pick up in the server hall opens a separate account. On the release host a second card (the operators' duty sheet) gives you a login too, but it lands you a plain, non-admin shell that cannot read the flag, so the escape still does the real work. Root login over SSH is turned off on the release host and the core host, so there is no shortcut to root on either: the way up is the escape.

## Concepts {#concepts}

You do not need to read all of this before you start. Come back to it when a stage leaves you unsure what a tool or a result is telling you. Every worked example below uses made-up data on a practice box, never anything from the bunker.

### Network Mapping Across the Bunker Network {#recon}

The attack box and the three targets share one network. Before you aim anything, you find out which hosts are up and what each one runs. **Network mapping** is the sweep that lists live hosts; **service fingerprinting** is the follow-up that asks each open port what it is.

Your own address tells you the network to sweep. The number after the slash, the **prefix length**, says how many addresses the network holds. A `/24` keeps the first three numbers fixed and lets the last number vary, so it covers 256 addresses.

Worked example, on a practice network of your own:

```
$ ip -4 addr
    inet 192.0.2.5/24 brd 192.0.2.255 scope global eth0
$ nmap -sn 192.0.2.0/24
Nmap scan report for 192.0.2.5
Nmap scan report for 192.0.2.11
Nmap scan report for 192.0.2.12
Nmap scan report for 192.0.2.13
```

Your box is `192.0.2.5`. The other three are the targets. A service scan on one of them names the software behind each open port.

### Security Monitoring Platforms and Command Injection {#command-injection}

A **network security monitoring** platform watches traffic and raises alerts. It runs as software, with a web front end, and it has its own flaws like any other service.

A web front end often passes what a visitor types into a command the server runs. If the input is joined into that command without checks, the visitor can add their own command. This is **command injection**, a form of injection flaw. When the input reaches the command before any login check, it is **unauthenticated**: nobody has to sign in for it to work.

Worked example, a toy greeter that joins its input straight into a shell command:

```
$ cat greet.sh
#!/bin/sh
sh -c "echo Hello, $1"
$ sh greet.sh "Ada"
Hello, Ada
$ sh greet.sh "Ada; id"
Hello, Ada
uid=1000(cliffe) gid=1000(cliffe) groups=1000(cliffe),4(adm),24(cdrom),27(sudo)
```

The `; id` after the name was meant to be part of a greeting. The shell ran it as a second command. Code you run this way runs as the service's own account, so it can read whatever that account can read.

### Found Credentials and Credentialed Access {#credentials}

Not every way in is a flaw. Sometimes you find a working username and password and simply sign in. On this network two of them turn up as cards in the bunker: a staging sign-in card and an operators' duty sheet. Using a credential you were not meant to have is its own class of access, separate from exploiting a bug.

A found login matters because of **file permissions**. On Linux every file has an owner and a mode that says who may read it. A home directory set to mode `700` may be entered by its owner and by root, and by nobody else, so the files inside it follow the same rule. A file in one account's home is out of reach from a foothold on a different account, even on the same host. That is why a flag in one account's home cannot be read from a foothold on another: you need that account's login, or root.

```
$ ls -ld /home/staging
drwx------ 2 staging staging 4096 Oct 20 09:14 /home/staging
$ whoami
secmon
$ cat /home/staging/release_schedule_staging
cat: /home/staging/release_schedule_staging: Permission denied
```

The `drwx------` means only `staging` (and root) may enter that home. Signed in as `secmon`, you are refused. Signing in as `staging` with the card reads it.

A found credential is also a limit, not a master key. A non-admin login gives you only what that account may read. If what you want belongs to root, a working non-admin password does not reach it, and you are back to privilege escalation or an escape.

### Containers and a Privileged-Container Escape {#containers}

A **container** packs a service with its files and runs it in its own view of the system, apart from the host. It is a confinement control, not a wall. A container started with extra powers, a **privileged** container, keeps almost all the host's access, so a service inside it can reach the host's disk and devices. From there an attacker can read or write the host's own filesystem and step out onto the machine beneath.

The first thing to settle is whether you are inside a container at all. A Docker container usually leaves a marker file at the root, and the control-group line for process 1 names the container runtime.

Worked example, run on a plain host (so the marker is absent):

```
$ ls -la /.dockerenv
ls: cannot access '/.dockerenv': No such file or directory
$ head -1 /proc/1/cgroup
1:net_cls:/
```

Inside a Docker container the `/.dockerenv` file is present, and the cgroup line carries a long `docker` path. That is how you know the shell you landed in is the container, not the host.

### Chroot Jails and Escaping Them {#chroot}

A **chroot** moves a process's idea of the root directory `/` to some folder lower down, so the process sees only that subtree. It is an older and weaker confinement than a container. A process that still holds enough privilege can break out, because the kernel keeps the real root reachable from a process that changes its root directory again from a point outside the jail.

The tell is the same question as the container: what does `/` really contain? A jail has a thin filesystem, a handful of directories and little else. The real host root has the full set.

```
$ ls /
bin  dev  etc  lib  usr          # a thin jail: almost nothing here
$ ls /
bin  boot  dev  etc  home  lib  media  opt  proc  root  run  srv  usr  var
```

The first listing is a jail. The second is a full host. If what you see is thin, you are confined.

### The Linux Shell, sudo and Privilege Escalation {#shell}

A Linux shell works on directories and files. Each file has an owner and permissions. A **home directory** is the part of the disk an account owns; files such as system logs and **root's home** belong to root, and a normal account cannot read them.

**Privilege escalation** means moving from a low-rights account to a higher one, usually root. **sudo** lets an account run a command as another user, if the sudo rules allow it. Running `sudo -l` lists what your account may run. A rule that lets an account run a tool which can start a shell hands out a root shell, even when the tool looked harmless.

```
$ sudo -l
User ada may run the following commands:
    (root) NOPASSWD: /usr/bin/find
```

A tool like `find` can run another program, so a rule like this is a way to a root shell.

### Audit Trails {#audit}

An **audit trail** is the record a system keeps of who did what and when: the authentication log, the service logs, the shell history. It belongs to root, so a normal account cannot read or change it. Once you have root you can read it, and the trail is also where your own steps show up. On a shared box you read the trail; you do not alter it.

## Stuck? Hints, Stage by Stage {#hints}

Find the stage you are on. Read the hint, then go back and try. If you are still stuck, open **Nudge**. Open **Recipe** last. The Recipe names the tools and the steps, never a flag value.

> Tip: Before you open any hint, ask three things. Which hosts are up, and what does each one run? What does this service say when you connect? What can this account read?

> Note: HaX sends a field guide for each stage to your workstation in game. Ask her on the phone and choose **[Field guide.]**; each guide matches the box you are playing, so follow it where it differs from the Recipe here.

### Getting Onto the Attack Box {#hints-vm-attack-box}

**Where:** the gate terminal at the forward post. **Goal:** a working terminal on the attack box, and the addresses of the three targets.

> Hint: The terminal opens the attack box, not a target. Before you aim anything, find your own address and the network, then see which hosts are up.

<details markdown="1">
<summary>Nudge</summary>

The attack box and the three targets share one network. Your own address tells you the network to sweep, and the prefix length after the slash tells you its size. A host sweep lists the live hosts; the ones that are not your own box are the targets. A service scan on each names the software you will work against.

**Learn it:** ==action: Work out the network by hand== from an address and a prefix length. A `/24` keeps the first three numbers fixed and lets the last vary, so it covers 256 addresses.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Run `ip -4 addr` in the attack box's terminal==, and note your address and the prefix length on the lab interface.
2. \==action: Sweep for live hosts with `nmap -sn <network>`==, using the network from step 1. The hosts that are not your own box are the three targets.
3. \==action: Fingerprint each target with `nmap -sV <target>`==, and note which host runs the monitoring platform, which runs the release service and which runs the core service.

</details>

> Warning: Do not guess the addresses. They are generated per build, so an address from another student's game or an old write-up will point at nothing. Read your own with `ip -4 addr` and sweep from there.

### Stage 1: The Monitoring Foothold {#hints-vm-flag1}

**Where:** the attack box's terminal, against the monitoring host. **Goal:** get code running on the monitoring platform with no login, read its status note, and submit the flag at the gate terminal.

> Hint: The monitoring platform watches the bunker's cameras and doors. It is still software. Fingerprint it, name the version, and find where its login takes input it does not check.

<details markdown="1">
<summary>Nudge</summary>

Fingerprint the monitoring platform and note the software name and version. Look that name and version up, and read how its login handler takes input. The flaw is an unauthenticated command injection: input sent at the login runs as a command before any sign-in. The code you run lands as the platform's service account, and the status note it holds is the flag. Read the field guide HaX sends before you run anything, so you know what the request does on the host.

**Learn it:** ==action: Write down the platform name and version, and the one input the login handler passes to a command==, before you send anything.

**To learn more in game:** on the phone, ask HaX and choose **[Field guide.]**. She sends the guide for their monitoring host to your workstation. The published [Scanning and Exploitation](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/scanning-and-exploitation/) field guide is a second route.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Fingerprint the monitoring host's web service and read the version: `nmap -sV <monitoring host>` and `curl -i http://<monitoring host>:<port>/`==.
2. \==action: Look up the platform and version, and read how the login handler takes input==.
3. \==action: Send the unauthenticated command-injection request at the login, following the field guide, to run a command as the service account==.
4. \==action: Read the service account's status note from its home directory==, and copy the flag.
5. \==action: Submit the flag at the gate terminal==.

</details>

> Note: This stage is pure exploitation, no login. The maintenance tag you see in game names the service account (`secmon`) and the host's address only, not a password. The injection is the way in, and the code you run lands as that account, so you read the status note straight away.

> Warning: An injection request written for a different version may fail or do something you did not expect. Check the version you fingerprinted against the one the guide was written for.

### Stage 2: The Staging Schedule {#hints-vm-flag2}

**Where:** the monitoring host, as a separate account you sign in to. **Goal:** sign in with the staging card's login, read the staging copy of the release schedule from that account's own home, and submit the flag at the release console.

> Hint: The foothold from Stage 1 does not reach this one. Flag 2 is in a different account's home, and that home is readable only by its owner. You need its login, and the bunker hands you one.

<details markdown="1">
<summary>Nudge</summary>

This stage is credentialed, not an exploit. The staging schedule lives in its own account (`staging`), whose home is locked down so the Stage 1 foothold cannot read it. In the server hall, by the release console, you pick up a staging sign-in card with that account's username and password. Sign in to the monitoring host with it, and read the schedule from the account's home: the release channels, the cells' early-access orders, and the first entries by city. The flag sits beside that text in the home.

**Learn it:** ==action: From the Stage 1 foothold, try to read the `staging` account's home== and watch it refuse with `Permission denied`. That is why you need the card, not the foothold.

**To learn more in game:** on the phone, ask HaX and choose **[Field guide.]**. She sends the guide for the staging copy to your workstation, and tells you the card is on the console desk.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Collect the staging sign-in card from the console desk in the server hall==, and read the username and password off it.
2. \==action: Sign in to the monitoring host with that login, for example `ssh staging@<monitoring host>`==.
3. \==action: Read the staging copy of the release schedule from the account's home directory==.
4. \==action: Copy the flag from that account's home==, kept beside the schedule.
5. \==action: Submit the flag at the release console in the server hall==.

</details>

> Warning: The Stage 1 foothold will not read this flag. The `staging` home is set so only its owner and root may enter it, so a `Permission denied` from the `secmon` foothold is expected, not a dead end. Use the card's login instead.

> Tip: A natural stopping point for a 60-minute class is after this stage. Both of these flags are on one host, the monitoring host, but note that you reached them two different ways: a break-in for flag 1, a found login for flag 2. The next two stages are the two climax boxes and take longer.

### Stage 3: Out of the Container {#hints-vm-flag3}

**Where:** the attack box's terminal, against the release host. **Goal:** reach the service running in a container, escape onto the host beneath it, read the flag in root's home, and submit it at the sealed section's hatch.

> Hint: The release service runs in a container. A container is a boundary, not a wall. Reach the service, work out that you are inside a container, then step out onto the host under it.

<details markdown="1">
<summary>Nudge</summary>

Scan the release host and find the port the service listens on. Connect to it and you land in a shell inside the container, not on the host. No password is asked for: the service drops you straight in, so this is exploitation, not a login. Confirm where you are first: a Docker container leaves a marker file at the root, and the control-group line for process 1 names the runtime. The container is privileged, so it keeps the host's access, and from there you can reach the host's own filesystem. The flag is in root's home on the host beneath the container, next to the release service's arming and kill configuration. There is no root login over SSH here, so the escape is the only way up.

By the east racks in the server hall you may also find the operators' duty sheet, with an operative login (`relops`). That login does work over SSH, but it signs you in as a plain operator with no admin rights, so it cannot read root's home and does not give you the flag. It is worth a look to see the host from the inside, but the escape is still what gets you there. A valid password is not the same as being root.

**Learn it:** ==action: Check whether you are inside a container== with `ls -la /.dockerenv` and `head -1 /proc/1/cgroup` before you try to escape.

**To learn more in game:** on the phone, ask HaX and choose **[Field guide.]**. She sends the guide for the release service's container to your workstation. The published [Privilege Escalation](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/privilege-escalation/) field guide is a second route.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Scan the release host and find the service port: `nmap -sV <release host>`==.
2. \==action: Connect to the service with `nc <release host> <port>`==, and note that the shell is inside the container.
3. \==action: Confirm the container with `ls -la /.dockerenv` and `head -1 /proc/1/cgroup`==.
4. \==action: Use the privileged container's access to reach the host's filesystem, following the field guide==.
5. \==action: Read the flag from root's home on the host==, beside the arming and kill configuration, and submit it at the sealed section's hatch.

</details>

> Note: The `relops` login from the duty sheet is a side route, not the way to the flag. It gives a non-admin operator shell on the host, which cannot read root's home. Do not spend long on it. The container escape is what lands you as root, where the flag is.

> Warning: The flag is not in the container. The container holds no flag. If you stop as soon as you have a shell, you have not finished this stage. The flag is in root's home on the host, after the escape.

### Stage 4: Out of the Jail {#hints-vm-flag4}

**Where:** the attack box's terminal, against the core host, after the clock is stopped. **Goal:** reach the service running in a chroot jail, escape onto the host, read the flag in root's home, and submit it at the core host terminal.

> Hint: The core service runs in an older confined area, a chroot jail. It is weaker than a container. Reach the service, see that the filesystem around you is thin, and break out to the real root.

<details markdown="1">
<summary>Nudge</summary>

Scan the core host and find the service port. Connect and you land inside a chroot jail, with no password asked for, so this stage is exploitation like Stage 3. The filesystem is thin, a few directories and little else. A process that still holds enough privilege can change its root directory again from a point outside the jail and reach the real host root. The flag is in root's home on the host, not in the jail, next to the core host's file index and an unsent vendor notice for Carrow Controls. As on the release host, there is no root login over SSH, so the escape is the only route.

The access code you find in game beside Tesseract's terminal (`TSRCT-CORE-9F21`) is part of the story, not a box login. It is his invitation, and it opens nothing on the core host for you. Do not try to sign in with it: the way onto the box is the chroot escape.

**Learn it:** ==action: List `/` inside the shell you land in== and compare it with a full host's root. A thin listing means you are confined.

**To learn more in game:** on the phone, ask HaX and choose **[Field guide.]**. She sends the guide for his box to your workstation. The published [Privilege Escalation](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/privilege-escalation/) field guide is a second route.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Scan the core host and find the service port: `nmap -sV <core host>`==.
2. \==action: Connect to the service with `nc <core host> <port>`==, and note that the shell is in a jail.
3. \==action: List `/` and confirm the filesystem is thin==.
4. \==action: Escape the chroot onto the host root, following the field guide==.
5. \==action: Read the flag from root's home on the host==, beside the file index and the vendor notice, and submit it at the core host terminal.

</details>

> Note: The core access code (`TSRCT-CORE-9F21`) is a story prop, not a credential. It logs in to nothing. The chroot escape is the only route onto this box.

> Warning: The jail holds no flag either. Do not submit anything you read inside the jail. The flag is in root's home on the host, after the escape.

### Submitting the Four Flags {#hints-vm-submit}

> Tip: Submit each flag at its own station as soon as you have it: flag 1 at the gate terminal, flag 2 at the release console, flag 3 at the sealed hatch, flag 4 at the core host terminal.

Copy each flag exactly as it appears in the output. A flag put in at the wrong station is read as a hint, not an answer, so it will not count.

## Try It on the Command Line (Optional) {#command-line}

These exercises use a practice box of your own. Do not run them on the bunker VMs. They let you feel each idea once on data you control.

### Command injection in a toy service {#cli-injection}

Make a one-line service that joins its input into a shell command, then inject a second command.

```
$ cat > greet.sh <<'EOF'
#!/bin/sh
sh -c "echo Hello, $1"
EOF
$ sh greet.sh "Ada"
$ sh greet.sh "Ada; id"
```

\==action: Run both lines, and note that the second one runs `id` as well as the greeting==. Then \==action: change the toy service to quote its input (`echo "Hello, $1"` with no inner `sh -c`) and run the injected input again==, and see the injection stop working.

> Note: The service is made up. The point is to see that unchecked input joined into a command runs as a command.

### A locked-down home {#cli-permissions}

On your own box, make a file and lock its folder down, then read back what the permissions say.

```
$ mkdir -p ~/vaultdemo && echo "top secret" > ~/vaultdemo/note
$ chmod 700 ~/vaultdemo
$ ls -ld ~/vaultdemo
$ stat -c '%A %U' ~/vaultdemo
```

\==action: Run the four lines, and write one sentence on who may read `~/vaultdemo/note`== (its owner and root, nobody else). Then \==action: say why a foothold on a different, non-root account on the same machine could not read it==. This exercise is reading only.

### Am I inside a container? {#cli-container}

On your own box, which is not a container, run the two checks and see what "not confined" looks like.

```
$ ls -la /.dockerenv
$ head -1 /proc/1/cgroup
```

\==action: Run both, and write one line on what each would show differently inside a Docker container== (the marker file present, and a long `docker` path on the cgroup line). This exercise is reading only.

### Listing your own sudo rules {#cli-sudo}

On your own Kali box, run `sudo -l` and read the output line by line.

\==action: For each command the output lists, write one sentence saying what it can do when it runs as root==. Ask whether it can start a shell or run another program. This exercise is reading only. Do not try to escape a command on the bunker VMs.

## After the Game: Questions and Exercises {#questions}

### Attacking the Server {#questions-server}

> Question: The monitoring foothold needed no login. Why is a security monitoring platform a tempting first target, and what does a foothold on it give an attacker that a foothold elsewhere would not?

> Question: Flag 1 and flag 2 both sat on the one monitoring host, yet the flag-1 foothold could not read flag 2. What stopped it, and why did a working staging login reach what the foothold could not?

> Question: The duty-sheet login on the release host worked, but it still did not give you the flag. What is the difference between holding a valid account and holding root, and why is a found non-admin credential only a limited kind of access?

> Question: Flags 3 and 4 both sat on the host, not in the confined area you first landed in. What is the difference between a privileged container and a chroot jail, and why is neither a safe boundary for a service an attacker can reach?

> Question: Root login over SSH was turned off on the release host and the core host. What attack did that close off, and why was it not enough on its own?

> Question: Of the four stages, which one would the bunker's own monitoring be least likely to record, and why?

> Action: Write a short checklist for the administrator of the three bunker hosts. Give one line for each of the four stages, naming the control that would have stopped that stage: the monitoring foothold, the staging login and schedule read, the container escape and the chroot escape. Hand in the checklist.

## Further Reading {#further-reading}

- [Reconnaissance and Network Mapping](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/reconnaissance-and-network-mapping/)
- [Scanning and Exploitation](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/scanning-and-exploitation/)
- [Vulnerability Analysis and Attack Surface](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/vulnerability-analysis-and-attack-surface/)
- [Privilege Escalation](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/privilege-escalation/)
- [SSH Access and Linux Basics](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/ssh-access-and-linux-basics/)
- [Maltrail on GitHub](https://github.com/stamparm/maltrail)
- [Understanding Docker container escapes (Trail of Bits)](https://blog.trailofbits.com/2019/07/19/understanding-docker-container-escapes/)
- [GTFOBins](https://gtfobins.github.io/)

