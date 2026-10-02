---
title: SAFETYNET Field Guide - NFS Shares and Open Ports
layout: lab
description: Optional in-game guide for reading an over-shared NFS export and pulling data from an unexpected open port with netcat
game_fragment: true
permalink: /labs/safetynet/nfs-and-netcat-leaks/
---

# SAFETYNET Field Guide: NFS Shares and Open Ports

## Objective

Use this guide when your scan turns up two kinds of leak on one host: a network file share that hands out files to anyone who asks, and a stray open port that answers back when you connect to it. Neither is an exploit in the memory-corruption sense. Both are a service configured to give away more than it should. Here they leak two halves of one login — the username on the file share, the password on the port — and you have to collect both before you can use either.

## Quick Reference

- **NFS** (Network File System) exports directories over the network. An over-shared export trusts anyone who can reach it, with no authentication.
- `showmount -e {TARGET_IP}` lists what a host is exporting. Mount an export and read it like any local folder.
- **netcat** (`nc`) opens a raw TCP connection to any port. A service on an odd port often just talks the moment you connect.
- An unexpected open port from your scan is an invitation: connect and see what it says before assuming it needs a protocol.
- Collect every fragment first. A username with no password, or the reverse, gets you nowhere — you need the pair.

```bash
# What is this host exporting over NFS?
showmount -e {TARGET_IP}

# Mount the export somewhere local and read it
mkdir /tmp/share
sudo mount -t nfs {TARGET_IP}:/exported/path /tmp/share
ls -la /tmp/share
cat /tmp/share/*

# Talk to the odd open port and read whatever it hands back
nc {TARGET_IP} {PORT}
```

## Core Workflow

1. Scan the host and note anything unusual — an NFS service (port 2049), and any open port that does not match a service you recognise.
2. Run `showmount -e` against the target to list its exports.
3. Mount an interesting export read-only and read the files. One half of the login is in there.
4. Connect to the odd port with `nc`. Read what it sends; the other half of the login is in the banner or message.
5. Assemble the username and password, then log in (see the **SSH Access and Bruteforce** guide) and go after the flag in the user's home directory.

## Common Failure Modes

- **`showmount` returns nothing:** the host may not run NFS, or the port is filtered. Re-check your scan for 2049; if it is closed, the leak is somewhere else.
- **`mount` is refused:** try read-only (`-o ro`), confirm you have the exact export path from `showmount`, and remember mounting usually needs root (`sudo`).
- **The port connects but says nothing:** some services wait for you to send a line first — press Enter, or send any text. Others only speak on connect; give it a moment before giving up.
- **You have one half and are stuck:** you are not meant to log in yet. Go back for the other fragment — the username and the password come from two different services on purpose.

## The Wider Lesson — Services That Trust Everyone

Both leaks here are the same mistake in two outfits: a service that assumes the network is friendly. NFS was designed for a trusted LAN and will happily export files to any host that asks unless you restrict it. A bespoke listener on a high port is often something an engineer stood up "temporarily" and never locked down. Neither checks who is on the other end.

The defences are about not trusting the network:

- **Restrict NFS exports** to specific hosts, export read-only where you can, and never share anything with secrets in it.
- **Close what you are not using.** An open port is attack surface; a service that answers anonymously is attack surface you forgot about.
- **Authenticate the connection,** not just the login it protects. A credential split across two anonymous services is still a credential anyone can collect.
- **Do not scatter secrets across services** and assume nobody will reassemble them. Reassembling them is the whole job.

The defensive principle is one line: **a service on the network should answer only the hosts and the people it was meant for — everything else is a leak.**

## Mission Application

The SCADA attack host leaks the two halves of a single operator login. The over-shared NFS export carries the username; an unusual open port, found on your scan, hands out the password to anyone who connects with netcat. Collect both, log in as that operator, and take the flag from their home directory. From there a permissive sudo rule is your route to root — work out which allowed command breaks out of its lane (see the **Privilege Escalation** guide).
