---
title: "Live Analysis: Memory Forensics of a Compromised Server"
author: ["Z. Cliffe Schreuders", "Tom Shaw"]
license: "CC BY-SA 4.0"
description: "Capture and analyse the RAM of a compromised Linux server with Volatility 3: recover a hidden backdoor, a process whose executable has been deleted, and secrets that never touched disk."
overview: |
  A server on your network has been compromised. The intruder has planted a backdoor, is running processes they would rather you did not see, and has loaded a rootkit that lies to the usual command-line tools (ps, ss and the like), so the live system hides its own compromise. Your job is to find out what is really running on that machine and to recover the evidence the attacker tried to conceal. You will do it with memory forensics. RAM holds what the disk and the live tools do not. It is the complete working state of every process on the machine, including the code it is running, the data it holds, the connections it has open, and the secrets it decrypted and never wrote to disk. Capturing live memory provides a rich source of forensically valuable information for incident responders to analyse and gain an understanding of what occurred during an attack.

  The main lab works from a capture of the compromised server's memory that was taken atomically, with the virtual machine paused from the hypervisor so every kernel structure in it is from the same instant. You analyse it with Volatility 3 and recover what the attacker hid: the backdoor and its listener, the processes the rootkit lies about, a process running from a deleted binary, and secrets that never touched disk. An optional section at the end has you take your own capture of the live memory of the system you are operating on, which is not as reliable but is sometimes the only available approach. You can take an image of the memory from inside the running server with LiME, try the same analysis on it, and see where it falls short.

  This is a Hackerbot lab. Work through the lab sheet, then interact with Hackerbot to complete the challenges.
tags: ["live-analysis", "memory-forensics", "volatility", "forensics", "incident-response", "rootkits", "hackerbot"]
categories: ["response_and_investigation"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "F"
    topic: "Main Memory Forensics"
    keywords: ["process information", "file information", "network connections", "artifacts and fragments", "challenges of live forensics"]
  - ka: "AAA"
    topic: "Accountability"
    keywords: ["The fallibility of digital evidence to tampering"]
  - ka: "MAT"
    topic: "Malware Detection"
    keywords: ["identifying the presence of malware"]
---

## Getting started {#getting-started}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop
- compromised_server

All three VMs need to be running to complete the lab.

### Your login details for the VMs {#your-login-details-for-the-vms}

\==VM: On the desktop and compromised_server VMs==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the hackerbot_server, but all the VMs need to be running to complete the lab.

The same username exists on the desktop and on the compromised_server. ==VM: On the desktop VM==, ==action: confirm your username==:

```bash
whoami
```

Take a note of the IP address of the compromised_server VM (given to you when you claimed the VMs), and ==action: set it as a variable== on the desktop VM, in any terminal you use for this lab:

```bash
# replace the middle two octets with the IP address on your systems
export COMPROMISED_IP=10.x.x.4
```

> Note: Because the same username exists on both VMs, `ssh $COMPROMISED_IP` does not ask you for a username. It still asks for the password (`tiaspbiqe2r`), and so do `sudo` and `scp` later in the lab. Commands below use `~` and `$USER` for your home directory and username; your own shell expands them.

{% include hackerbot-intro.md role="task you to investigate a compromised server and recover evidence from its memory" %}

## Introduction {#introduction}

So you have reason to believe one of your servers has experienced a security compromise... What next? For this lab you investigate a server that has been compromised whilst it is still running.

The investigation of a potential security compromise is closely related to digital forensics topics. As with forensic investigations, we also aim to maintain the integrity of our "evidence", *wherever possible* not modifying access times or other information. However, in a business incident response setting maintaining a chain of evidence may not be our highest priority, since we may be more concerned with other business objectives, such as assuring the confidentiality, integrity, and availability of data and services.

During analysis, it is good practice to follow the order of volatility (OOV): collecting the most volatile evidence first (such as the contents of RAM, details of processes running, and so on) from a live system, then collecting less volatile evidence (such as data stored on disk) using offline analysis.


## Live analysis {#live-analysis}

After suspecting a compromise, before powering down the server for offline analysis, the first step is typically to perform some initial investigation of the live system. Live analysis aims to investigate suspicions that a compromise has occurred, and gather volatile information, which may potentially include evidence that would be lost by powering down the computer.

A rootkit changes what the live tools report. If the kernel, the shell, or the libraries behind `ps`, `ss` and `ls` have been tampered with, then those tools tell you whatever the attacker wants you to hear, and nothing in their output lets you know you are being lied to. You will see that first-hand on this server: the ordinary tools report a clean machine, a trusted toolkit the attacker never touched shows the compromise, and a memory capture shows it again where no running-system tampering can reach.

\==VM: On the desktop VM==, ==action: ssh into the compromised server==:

```bash
ssh $COMPROMISED_IP
```

Before you touch anything, start a record of the session. In forensics and in incident response you have to be able to show afterwards exactly what you did and when, so that your own actions can be told apart from the attacker's. The `script` command keeps that record for you: it writes every command you run, and everything the machine prints back, to a log file.

\==VM: On the compromised_server VM (ssh)==, ==action: start recording your session==:

```bash
mkdir -p ~/evidence
script -a ~/evidence/investigation.log
```

Everything you do from now on is appended to `investigation.log`. Type `exit` when you have finished the investigation to close the log.

> Note: If you come back to the lab in a later sitting, your commands are appended to the same file, so nothing already in it is lost. Copy the log somewhere safe once you are done.

> Log Book Question: What are the risks and the benefits of keeping this log on the compromised machine itself, rather than on a separate machine or on paper? When might a handwritten note of what you did be worth more than a file on the system you are investigating?

### A first look with the live tools {#a-first-look-with-the-live-tools}

\==VM: On the compromised_server VM (ssh)==, ==action: look at the running processes and the listening ports==:

```bash
ps aux
netstat -tln
```

Nothing here looks obviously wrong, and that is the point. The system has been tampered with to hide the intrusion from exactly these tools. Make a note of the listening ports you see; you are about to run the same check through a trusted tool and compare.

> Log Book Question: Why can you not rely on `ps` and `netstat`, run on the compromised machine itself, to tell you what is really running on it?


### Trusted tools: how far they get you {#trusted-tools}

A first principle of live investigation is that you do not trust the compromised machine's own programs. If an attacker can change what `ps`, `netstat` or `ls` report, those tools tell you whatever the attacker wants you to hear, and nothing in their output lets you know you are being lied to. So a responder does not run the target's own copies. They bring known-good tools on read-only media and run those instead.

This machine already has such a toolkit on it: BusyBox, a single statically linked binary that carries its own `ps`, `netstat`, `cat`, `ls` and dozens of other applets, none of which the attacker has touched. You run an applet by naming it after the binary. ==VM: On the compromised_server VM (ssh)==, ==action: run a trusted tool through BusyBox==:

```bash
busybox uname -a
```

That reads the kernel version straight through BusyBox. Make a note of it; you need the exact kernel to analyse the memory capture later. `uname` is not one of the tampered commands, so this only shows you how BusyBox is invoked.

Now run the same two checks you ran a moment ago, but through BusyBox, so the applets the attacker never touched do the reporting. ==VM: On the compromised_server VM (ssh)==, ==action: list the processes and listening ports through BusyBox==:

```bash
busybox ps
busybox netstat -tln
```

> Log Book Question: Compare this output with the `ps` and `netstat` you ran before. What appears here that the machine's own tools left out? You should be able to see a listening TCP port, and a process bound to it, that the first look hid from you. You have caught the machine lying to you.

Those two differences are the next two things Hackerbot asks you for. Read them off the BusyBox output you just produced.

\==action: save and submit any flags!== as you go.

#### Challenge 1: the backdoor's hidden port {#challenge-1}

`busybox netstat -tln` listed a listening TCP port that the host's own `netstat` did not, and `busybox ps` shows a process bound to it. That port is the backdoor's listener. Read the port number off the output (the one listening port that was not in the first-look list).

##### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Using the trusted BusyBox tools on the live server, find the TCP port the hidden backdoor is listening on.

When you are ready for the bot to quiz you, ==action: say 'ready'== to Hackerbot. It asks you for the port; ==action: answer with the port number== once you have it.

Don't forget to ==action: save and submit any flags!==

#### Challenge 2: the backdoor's session marker {#challenge-2}

Look again at the backdoor's line in `busybox ps`. The listener was started with a marker on its command line of the form `BACKDOOR_SESSION_ID=<token>`, which the attacker uses to recognise its own shells. A process can be renamed, but the full command line it was launched with stays in the process's argument vector, where a misleading name cannot hide it. Read the value after `BACKDOOR_SESSION_ID=`.

> Note: that same argument vector also survives into a memory capture, where Volatility's `linux.psaux` can recover it later. That is why Hackerbot frames it around the image. You can read it now, straight off the live BusyBox output.

##### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Recover the backdoor listener's session marker, the value after `BACKDOOR_SESSION_ID=` on its command line.

When you are ready for the bot to quiz you, ==action: say 'ready'== to Hackerbot. It asks you for the marker; ==action: answer with the value after the `=` sign== (that part on its own, not the whole command line).

Don't forget to ==action: save and submit any flags!==

BusyBox was enough to see through the deception here, and that it is statically linked is a deliberate choice. A normal program like `/usr/bin/ps` loads the system's shared C library when it runs, and obeys the dynamic loader while it does so. That gives an attacker a second place to hide. Setting `LD_PRELOAD`, or writing a library into `/etc/ld.so.preload`, makes every dynamically linked program load an attacker's library first, and that library can strip a process from the output of every tool at once without changing a single binary on disk. Real userland rootkits such as Jynx and Azazel work this way. A statically linked tool carries its own copy of that library and never consults the loader, so neither trick reaches it.

You could not have known BusyBox would be enough before you looked, and a deeper rootkit would defeat it. Even trusted static tools have a limit, and knowing where it lies is the point of the rest of this lab. Every tool, static or not, still asks the kernel for its information through system calls. If the attacker has loaded a kernel rootkit that hooks those calls, the lie moves below the C library, and the kernel hands even a trusted static tool the same edited answers it hands everything else. Nothing running on the live machine can be trusted then, because the component answering all of them is the one that has been subverted. What remains is to read the machine's memory from outside and analyse it somewhere safe. Before you do, take your own capture of this running server.

## Capture the live memory now {#capture-live-memory}

Take a capture of the running server yourself, and set it copying to your analyst VM while you work. In a real incident this is often the only capture you can get: you usually cannot pause a production server, so you read its RAM from inside while it keeps running. You will come back to this capture at the very end of the lab and analyse it.

On a modern 64-bit Linux system you cannot simply read `/proc/kcore`. Instead you capture RAM with a kernel module, [LiME](https://github.com/504ensicsLabs/LiME) (Linux Memory Extractor), which is already built on the compromised server. Loading it writes the contents of RAM straight to a file.

\==VM: On the compromised_server VM (ssh)==, ==action: capture the live memory==:

```bash
sudo insmod /root/LiME/src/lime-$(uname -r).ko "path=$HOME/evidence/live_capture.raw format=raw"
sudo rmmod lime
sudo chown $USER:$USER ~/evidence/live_capture.raw
ls -lh ~/evidence/live_capture.raw
```

> Note: `sudo` asks for your password (`tiaspbiqe2r`). The capture is roughly the size of the server's RAM (about 1.5 GB), so the file is large.

The evidence should not stay on the machine you are investigating, and the copy is large, so start it now and leave it running while you get on with the analysis. ==VM: On the desktop VM (a separate terminal tab, not the ssh session)==, ==action: start copying the capture to your desktop==:

```bash
scp $COMPROMISED_IP:evidence/live_capture.raw ~/evidence/live_capture.raw
```

Leave that copy running in its tab. Capturing from inside a running machine has a cost: the kernel keeps scheduling, allocating and freeing while LiME reads RAM, so the bytes come from many slightly different instants rather than one. That inconsistency is called **smear**, and it is why a live capture cannot be fully trusted. The clean alternative exists only when you can stop the machine while you read it, which on a virtual machine means pausing the guest from the hypervisor so every structure is from the same instant: an **atomic** capture. We have already taken one of this server that way and left it in your evidence directory as `compromised_server.raw`. Analyse that now, and come back to your own live capture at the very end to see the difference for yourself.

## Why atomic acquisition matters {#why-atomic-acquisition-matters}

Reading memory from outside the machine only helps if what you read is coherent. The atomic capture you are about to analyse is: it was taken with the virtual machine paused, so every pointer and every kernel structure in it is from the same instant, and the plugins that walk the kernel's linked lists can follow those pointers cleanly. The live capture you just started is not coherent in that way. The kernel rewrote those same pointers while LiME copied them, so a list-walking plugin on a smeared image can follow a pointer into a structure that has since moved or been freed. That is the practical cost of smear, and you will watch it happen at the end of the lab.

> Note (how Volatility knows the layout): Volatility needs a **symbol table** (an ISF, Intermediate Symbol Format) that matches the exact kernel of the captured machine. The offsets of fields inside kernel structures change from one kernel build to the next. The ISF is generated from the kernel's debug symbols with a tool called `dwarf2json`, and the one matching this server's kernel ships with the lab, so `vol` finds it automatically. If you ever analyse a capture and Volatility reports it cannot find a matching symbol table, that is the problem to fix first.

## Analyse the atomic capture {#part-2-analyse-the-atomic-capture}

You analyse the capture with Volatility 3, run on your desktop VM as `vol`. Each kind of analysis is a plugin; the Linux plugins are named `linux.<something>` (for example `linux.pslist`). You point `vol` at an image with `-f` and name the plugin to run.

\==VM: On the desktop VM==, ==action: confirm the atomic capture is present==:

```bash
ls -lh ~/evidence/compromised_server.raw
```

\==action: List the processes from the atomic capture==:

```bash
vol -f ~/evidence/compromised_server.raw linux.pslist
```

The list comes back clean and complete. Everything from here uses `~/evidence/compromised_server.raw`.

> Tip: Volatility plugins are slow: they parse a lot of memory. Each one takes a little while to run; let it finish. To avoid re-running a slow plugin, save its output to a file, for example `vol -f ~/evidence/compromised_server.raw linux.psscan > ~/evidence/psscan.txt`, and then read or `grep` the file.

Now work through the rest of Hackerbot's challenges. For each one, you recover a piece of evidence from the capture, save it to a file on your desktop VM under `~/evidence/` (Hackerbot tells you the exact filename in the chat), and then say `ready`.

### Challenge 3: the hidden processes {#challenge-3}

The rootkit hides some processes from the live tools. The memory capture shows them all, so the hidden ones are those present in the capture but missing from the live `ps`.

\==VM: On the desktop VM==, ==action: get the full process list from the capture==:

```bash
vol -f ~/evidence/compromised_server.raw linux.psscan
```

\==VM: On the compromised_server VM (ssh)==, ==action: get the process list the live machine admits to==:

```bash
ps -e
```

\==action: Compare the two.== The processes that appear in the capture but not in the live `ps` are the ones the rootkit is hiding. Save **only those PIDs** (the process ID numbers) to the file Hackerbot names, under `~/evidence/`.

> Note (a common slip): save only the hidden PIDs, not the whole process list. In particular do not include the low-numbered kernel threads (PIDs 2, 3, 4 and so on). They are not hidden, and listing them tells Hackerbot your list is wrong.

#### Hackerbot Attack #3 {#hackerbot-attack-3}

You can skip the bot to here, by saying **goto 3**.

> Hackerbot: List the PIDs of the processes that are running on the system but are not reported by the live `ps`, and save them to the file Hackerbot names, under `~/evidence/`.

When you are ready for the bot to check your work, ==action: say 'ready'== to Hackerbot.

Hackerbot will then quiz you on what kind of malware hides processes. ==action: say 'the answer is ...'== once you know it.

Don't forget to ==action: save and submit any flags!==

### Challenge 4: the deleted binary's real name {#challenge-4}

One process is running from a binary that has been deleted from disk. In the live process list it is disguised to look like a kernel worker thread, shown as `[kworker/...]`. That disguise is only the argument vector the live tools print. The kernel's own name for the task, its `comm` field, still holds the name the binary was launched under.

\==VM: On the desktop VM==, ==action: scan the processes and read their real names==:

```bash
vol -f ~/evidence/compromised_server.raw linux.psscan
```

`linux.psscan` reads each task's `comm` directly, so it is not fooled by the `[kworker/...]` argv disguise. Find the task that the live tools show as `[kworker/...]`; its `comm` in the scan is the deleted binary's real name. ==action: Save that name== to the file Hackerbot names, under `~/evidence/`.

> Note (a common slip): `[kworker/...]` is the disguise, shown by argument-based views like `linux.psaux`. The answer is the `comm` value from `linux.psscan`, not the `[kworker/...]` string. The backdoor process also has an unusual `comm`; that one is the next challenge, not this one.

#### Hackerbot Attack #4 {#hackerbot-attack-4}

You can skip the bot to here, by saying **goto 4**.

> Hackerbot: Recover the real process name (the `comm` field) of the process running from a deleted binary, and save it to the file Hackerbot names, under `~/evidence/`.

When you are ready for the bot to check your work, ==action: say 'ready'== to Hackerbot.

Hackerbot will then quiz you on why this program's executable cannot be recovered from the server's filesystem. ==action: say 'the answer is ...'== once you know it.

Don't forget to ==action: save and submit any flags!==

### Challenge 5: the backdoor process's name {#challenge-5}

The backdoor whose port and marker you found in Challenges 1 and 2 runs as a process, and the rootkit hides that process from `ps` and `top` just as it hid the port from the live tools. The memory image is not fooled. This is the same listener you fingerprinted by its `BACKDOOR_SESSION_ID` marker; now read the name the kernel knows it by.

\==VM: On the desktop VM==, ==action: find the backdoor process in the scan==:

```bash
vol -f ~/evidence/compromised_server.raw linux.psscan
```

Identify the backdoor process, the listener you already fingerprinted by its `BACKDOOR_SESSION_ID` marker, and read its `comm` (its process name). ==action: Save that name== to the file Hackerbot names, under `~/evidence/`.

> Tip: To tie a listening socket to the process that owns it, `vol -f ~/evidence/compromised_server.raw linux.sockstat` lists sockets with their owning process, which helps confirm you have the right one.

#### Hackerbot Attack #5 {#hackerbot-attack-5}

You can skip the bot to here, by saying **goto 5**.

> Hackerbot: Recover the process name (the `comm` field) of the hidden backdoor process from the memory image, and save it to the file Hackerbot names, under `~/evidence/`.

When you are ready for the bot to check your work, ==action: say 'ready'== to Hackerbot.

Hackerbot will then quiz you on why this process is missing from the live `ps` and `top` yet visible in the capture. ==action: say 'the answer is ...'== once you know it.

Don't forget to ==action: save and submit any flags!==

### Challenge 6: the secret in the environment {#challenge-6}

A daemon on the server holds a secret in its process environment: an environment variable named `TELEMETRY_TOKEN`. It was never written to a file, so it lives only in the process's memory. That memory is in the capture.

You can read it two ways. ==VM: On the desktop VM==, ==action: read the process environments with Volatility==:

```bash
vol -f ~/evidence/compromised_server.raw linux.envars | grep -a TELEMETRY_TOKEN
```

Or search the raw bytes directly:

```bash
strings -a ~/evidence/compromised_server.raw | grep -a 'TELEMETRY_TOKEN='
```

Find the `TELEMETRY_TOKEN` entry and read its value. ==action: Save the token== to the file Hackerbot names, under `~/evidence/`.

> Note (a common slip): there is no file on disk to find this in. It is in the daemon's environment in memory. If you went looking in `/etc` or a config file on the server, that is why you came up empty.

#### Hackerbot Attack #6 {#hackerbot-attack-6}

You can skip the bot to here, by saying **goto 6**.

> Hackerbot: Recover the value of the `TELEMETRY_TOKEN` environment variable from the memory image, and save it to the file Hackerbot names, under `~/evidence/`.

When you are ready for the bot to check your work, ==action: say 'ready'== to Hackerbot.

Hackerbot will then quiz you on where a running Linux process keeps its environment variables. ==action: say 'the answer is ...'== once you know it.

Don't forget to ==action: save and submit any flags!==

### Challenge 7: the shell command that was never saved {#challenge-7}

An interactive shell is still running on the server. One command it ran carries a token, but the shell was started with its history writing turned off (its `HISTFILE` points at `/dev/null`), so the command is in no `~/.bash_history` file. It is still in the shell's in-memory history, inside the capture.

\==VM: On the desktop VM==, ==action: recover the shell history from memory==:

```bash
vol -f ~/evidence/compromised_server.raw linux.bash
```

`linux.bash` reconstructs the command history held in the memory of running `bash` processes. Find the command that carries the token and read the token out of it. (A raw `strings` search of the image works too, if you know roughly what the token looks like.)

\==action: Save the token== to the file Hackerbot names, under `~/evidence/`.

> Note (a common slip): `cat ~/.bash_history` on the server shows nothing useful: the history was never written there. That is the whole reason you go to memory for it.

#### Hackerbot Attack #7 {#hackerbot-attack-7}

You can skip the bot to here, by saying **goto 7**.

> Hackerbot: Recover the token from the running shell's in-memory command history, and save it to the file Hackerbot names, under `~/evidence/`.

When you are ready for the bot to check your work, ==action: say 'ready'== to Hackerbot.

Hackerbot will then quiz you on why this command is absent from the on-disk `~/.bash_history` yet recoverable from memory. ==action: say 'the answer is ...'== once you know it.

Don't forget to ==action: save and submit any flags!==

## Wrapping up {#wrapping-up}

You have now reconstructed the compromise from memory alone: a hidden backdoor with its port and session marker, the processes the rootkit lied about, a process running from a deleted binary, a secret held only in a daemon's environment, and a command a shell was told to forget. None of it was reliable from the live tools on the machine itself, and the deleted binary and the unsaved history were never on disk to begin with.

Keep in mind the limitation behind all of this. The clean recoveries you just made came from an atomic capture, taken with the machine paused. A capture taken from a running server is smeared: the list-walking plugins cannot be trusted on it, and even signature scanning and string search cannot promise to find a given artefact in it. In an incident where you cannot pause the machine, that is the trade-off you work with. You take the capture you can get, and you treat what it gives you with suspicion. The live capture you started earlier lets you see that for yourself.

> Log Book Question: You recovered the same kind of evidence in two ways in this lab: with a Volatility plugin that understands kernel structures, and with a plain `strings` search. When would you reach for each, and what can the structured plugin tell you that `strings` cannot?

## Come back to your live capture {#back-to-live-capture}

Earlier in the lab you took a capture of the running server with LiME and set it copying to your desktop. Now analyse it, and compare it with the clean atomic image you have been working from. Check the copy you started has finished first.

### Try to analyse the live capture {#try-to-analyse-the-live-capture}

Volatility reconstructs the kernel's data structures from the raw bytes. Ask this capture for the same process list you pulled cleanly from the atomic image.

\==VM: On the desktop VM==, ==action: list the processes from your live capture==:

```bash
vol -f ~/evidence/live_capture.raw linux.pslist
```

`linux.pslist` walks the kernel's linked list of processes, following one pointer to the next. ==action: Look closely at the output.== It may stop short, repeat entries, or miss processes you know are running. Run it twice and you may not get the same list. This is not a bug in Volatility. You captured RAM while the kernel kept scheduling, allocating and freeing: the pointers the plugin follows were being rewritten underneath it, so the snapshot is not one consistent moment. This is the **smear** you read about earlier, now in front of you.

Some tools degrade more gracefully than `linux.pslist` on a smeared capture. `linux.psscan` scans memory for the signature of a process structure instead of following the list, and a plain `strings` search ignores kernel structures and reads the bytes directly, so neither depends on one pointer leading cleanly to the next. Where list-walking fails outright, they can still return something.

They are still working on a broken source, though. A capture taken while the kernel keeps running is incomplete: a page you need may not be in it at all, or may be frozen half-written. Whichever tool you reach for, you cannot count on recovering any particular piece of evidence from it. That is the difference you have now seen from both sides: the clean recoveries in the challenges came from a capture taken with the machine paused, and this one, taken while the machine ran, cannot promise you the same. On a running server you can nearly always take a capture, but what comes back is partial and has to be treated with suspicion.

> Log Book Question: Your `live_capture.raw` was taken while the server kept running. Why does that make it an unreliable source of evidence, and which kind of analysis suffers the most from it?

Once you have finished, you can power off the VMs from Hacktivity.
