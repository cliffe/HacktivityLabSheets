---
title: SAFETYNET Field Guide - SSH Access and Bruteforce
layout: lab
description: Optional in-game guide for confirming SSH reachability, testing credentials online with Hydra, and orienting yourself after login
game_fragment: true
permalink: /labs/safetynet/ssh-access-and-bruteforce/
redirect_from:
  - /labs/m02_ransomed_trust/safetynet-field-guide-ssh-access-and-bruteforce/
---

# SAFETYNET Field Guide: SSH Access and Bruteforce

## Objective
Use this guide when you have a host running SSH and a credential you want to try, or none yet and a login you need to force. It covers three things in order: confirm the service is actually reachable, get in with a credential you already hold, and — only if that fails — test a list of guesses against the login with Hydra. The hospital's backup server (`192.168.100.50`, port 22) is your worked example. The password Gary left on the sticky note by his monitor is your first guess, not your last resort.

## Quick Reference
- Confirm port 22 is open and answering **before** you spend a single guess on it.
- Try the credential you already have first. Reused passwords are the shortest path in this building.
- One username, one password → `ssh`. A list of either → `hydra`.
- Online bruteforce is loud and slow. It is a fallback, not an opening move.
- The instant a shell opens, work out **who** you are and **where** you are before you touch anything.

## Step 1 — Confirm SSH is reachable

You cannot log into a port that is closed. Fingerprint it first.

```bash
# Is 22 open, and is it really SSH?
nmap -p 22 -sV 192.168.100.50
```

A clean result reports `22/tcp open ssh` with a version banner (for example `OpenSSH ...`). No answer on 22 means SSH is filtered or not running — stop, and go back to your scan of the host. Every guess you throw at an unreachable port is wasted.

## Step 2 — Log in with a credential you already hold

The fastest attack is the one where you already know the answer. In this hospital the credentials are reused — the same weak password Gary scrawled on the sticky note unlocks his workstation *and* the backup server over SSH. Try it before anything clever.

```bash
# Replace USER with the account name and enter the known password when prompted
ssh USER@192.168.100.50
```

If it lets you in, you are done — skip straight to Step 4. Credential reuse across systems is exactly the weakness you are here to demonstrate: one leaked password, one lanyard, one sticky note, and the blast radius is the whole estate.

## Step 3 — Force the login with Hydra (fallback only)

If you have no working credential, test a list against the login. Hydra drives many guesses through the SSH service and tells you which pair succeeds.

```bash
# -l single username   |   -L username list
# -p single password   |   -P password list
hydra -l USER -P /usr/share/wordlists/rockyou.txt ssh://192.168.100.50

# Both unknown: iterate a username list and a password list
hydra -L users.txt -P passwords.txt ssh://192.168.100.50
```

Read the output for the line reporting a valid `login:` / `password:` pair. Notes on doing this without wasting the night:

- **Narrow before you widen.** A short list of likely passwords (staff names, the hospital's founding year, obvious reuse) beats rockyou's fourteen million entries for a login this guessable.
- **Watch for lockout and throttling.** A real host may lock the account or slow responses after a run of failures. That is the defence working — and a signal to switch to a credential you can obtain by other means rather than hammering harder.
- **It is noisy.** Every failed attempt is a log line. On a live assessment, expect to be seen.

Once Hydra hands you a pair, log in with it as in Step 2.

## Step 4 — Orient before you act

A shell is a foothold, not the finish. Establish your footing before you move.

```bash
whoami        # which account did you land as?
id            # your groups — and whether you already hold anything privileged
hostname      # confirm you are on the box you meant to reach
pwd; ls -la   # where you are, and what is in reach right here
```

From here your route depends on what you find. If you are not yet the user or root that can read the target, that is a privilege-escalation problem — check your sudo rights (`sudo -l`) and see the **Privilege Escalation** field guide. The evidence and flags you are after live in files you can only reach once you are the right user in the right place.

## The Wider Lesson — Why This Works at All

SSH bruteforce is not a clever exploit. It is a bet that a human chose a weak, reused, or guessable password and that nothing in front of the login stops you testing that bet thousands of times. Every step of this attack has a one-line defence:

- **Reused passwords** — the sticky-note credential opening two systems is the whole problem. Unique credentials per system, held in a manager, not on a monitor.
- **Guessable passwords** — the founding year, a name, `Hospital1987`. Length and unpredictability beat cleverness; a passphrase a wordlist will never hold.
- **Unlimited attempts** — rate-limiting, lockout after repeated failures, and `fail2ban` turn thousands of cheap guesses into a handful of expensive ones.
- **Passwords at all** — key-based authentication with passwords disabled (`PasswordAuthentication no`) removes the thing Hydra is attacking. There is nothing to guess.

The defensive principle is one line: **a login should cost an attacker more per attempt than the secret is worth guessing.** Weak reused passwords with no throttling invert that — and that inversion is why a fourteen-year-old backup server, guarding every clinical record in the building, fell to a password on a sticky note.
