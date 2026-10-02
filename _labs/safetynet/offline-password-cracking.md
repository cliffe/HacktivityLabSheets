---
title: SAFETYNET Field Guide - Offline Password Cracking
layout: lab
description: Optional in-game guide for turning a readable shadow file into cracked account passwords with unshadow and John the Ripper
game_fragment: true
permalink: /labs/safetynet/offline-password-cracking/
---

# SAFETYNET Field Guide: Offline Password Cracking

## Objective

Use this guide once you are on a box and can read its password hashes — a world-readable `/etc/shadow`, a leaked backup, a database dump. Online guessing throws attempts at a live login and gets rate-limited and logged. Offline cracking copies the hashes to your own machine and grinds them there, as fast as your hardware allows, with nobody watching. On the HashChain backend the shadow file is readable, so the accounts are yours to crack at leisure.

## Quick Reference

- **Online** = guessing against a running service (loud, slow, throttled). **Offline** = cracking a stolen hash on your own kit (quiet, fast, unlimited).
- Linux login hashes live in `/etc/shadow`; the account names live in `/etc/passwd`.
- `unshadow` stitches the two files back together into the format a cracker expects.
- John the Ripper (`john`) and hashcat both take that file and recover the plaintext.
- A password you crack on one account is worth trying on every other account — reuse is the point.

```bash
# On the target: grab both halves
cat /etc/passwd
cat /etc/shadow

# On your machine: combine them, then crack
unshadow passwd.txt shadow.txt > hashes.txt
john --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt
john --show hashes.txt            # print what has cracked so far
```

## Core Workflow

1. Confirm you can read the hashes. If `/etc/shadow` opens as an ordinary user, that is already the finding — it should be root-only.
2. Copy `/etc/passwd` and `/etc/shadow` off the box to your own machine.
3. Run `unshadow passwd.txt shadow.txt > hashes.txt` to merge them.
4. Point John at the file with a wordlist. Weak service passwords fall in seconds.
5. Read the cracked pairs with `john --show`, then use them — and try each one against the other accounts.

Hashcat does the same job and is faster on a GPU:

```bash
# Identify the hash type first, then crack (3200 = bcrypt, 1800 = sha512crypt, ...)
hashcat -m 1800 -a 0 hashes.txt /usr/share/wordlists/rockyou.txt
```

## Common Failure Modes

- **`john` reports "No password hashes loaded":** you fed it the raw shadow file. Run `unshadow` first, or check you copied the whole line including the `$id$salt$hash` field.
- **Nothing cracks:** the wordlist is too small or the password is genuinely strong. Widen the list, or add rules (`--rules`) to mangle it — but a weak service password should not need that.
- **Cracked a password but it fails at login:** check you are using it with the right account name, and that the service you are logging into is the one the account is for.
- **It is taking forever:** you are probably on CPU against a slow hash. Switch to hashcat on a GPU, or accept that a strong hash is strong by design — that is the defence working.

## The Wider Lesson — Why Offline Cracking Wins

Once a hash leaves the system, every defence that lived at the login is gone. No lockout, no rate limit, no alert — just your hardware against the hash function, for as long as you like. That is why a readable shadow file, a hard-coded hash in source, or an unencrypted backup is so much worse than it looks: it moves the fight onto the attacker's ground.

The defences are all about keeping the hash out of reach and making it expensive to crack if it leaks:

- **Protect the hashes.** `/etc/shadow` is root-only for a reason; backups and dumps that contain hashes deserve the same guard.
- **Use a slow, salted hash.** bcrypt, scrypt, Argon2 — a per-password salt kills precomputed tables, and a deliberately slow function turns billions of guesses a second into thousands.
- **Make the password unguessable.** A long passphrase a wordlist will never hold beats any hashing choice. Length is what buys time.
- **Never reuse.** One cracked service password that also unlocks the ledger and the database is the whole lateral-movement attack, handed over for free.

The defensive principle is one line: **assume the hash will leak, and make it worthless when it does.**

## Mission Application

The HashChain Exchange's backend is your worked example. The distcc foothold drops you onto the box as a low-privilege account, and from there the shadow file reads straight out — take it, pull `/etc/passwd` with it, and crack offline rather than hammering the services live. The weak service passwords fall quickly. Then do the thing the exchange's own engineers did not expect you to: try the first cracked password on the next account, and the next. Two of those accounts share a password, and that reuse is the shortest path from the first backend flag to the financial records that name ENTROPY's funding.
