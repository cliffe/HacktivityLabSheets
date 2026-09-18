---
title: "Live Analysis: Investigating a Compromised Server"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Investigate a live, compromised server using standard Unix commands, statically linked binaries, and rootkit detection tools, while fending off Hackerbot's challenges."
overview: |
  In this lab, you will dive into the world of digital forensics and incident response by investigating a potentially compromised server. Security breaches and compromises are a common occurrence in the digital age, and it's essential to understand how to analyse and gather evidence from a compromised system to determine the extent of the intrusion and identify potential threats. This lab will walk you through the process of live system analysis, using both standard Unix commands and tools provided by the FIRE (Forensic and Incident Response Environment) CD/DVD ISO, in order to collect volatile data and assess the system's security.

  Throughout this hands-on lab, you will learn essential techniques for live system analysis, such as collecting information about running processes, network connections, kernel modules, and system state. You will also explore the use of static binaries to avoid potential tampering with dynamically linked executables. Additionally, you will employ tools like Chkrootkit to detect rootkits and perform offline analysis to uncover any suspicious activity or security breaches. By completing tasks such as creating a list of suspicious open ports, identifying unreported processes, and analysing the output of data collection scripts, you will gain practical experience in investigating compromised systems, a crucial skill for cyber security professionals and digital forensics experts.

  This is a Hackerbot lab. Work through the lab sheet, then interact with Hackerbot to complete the challenges.
tags: ["live-analysis", "forensics", "incident-response", "rootkits", "chkrootkit", "static-binaries", "hackerbot"]
categories: ["response_and_investigation"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "F"
    topic: "Main Memory Forensics"
    keywords: ["process information", "file information", "network connections", "artifacts and fragments", "challenges of live forensics"]
  - ka: "OSV"
    topic: "OS Hardening"
    keywords: ["anomaly detection"]
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

All of these VMs need to be running to complete the lab.

### Your login details for the VMs {#your-login-details-for-the-vms}

\==VM: On the desktop and compromised_server VMs==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the hackerbot_server, but all the VMs need to be running to complete the lab.

Take a note of the IP address of the compromised_server VM (given to you when you claimed the VMs), and ==action: set it as a variable== on the desktop VM for convenience, in any terminal you use for this lab:

```bash
export COMPROMISED_IP===edit: IP address of the compromised_server VM==
```

> Note: Because the same username exists on both the desktop and compromised_server VMs, `ssh $COMPROMISED_IP` will log you straight in without needing to specify a username.

{% include hackerbot-intro.md role="task you to investigate the system" %}

## Introduction {#introduction}

So you have reason to believe one of your servers has experienced a security compromise... What next? For this lab you investigate a server that has been compromised.

The investigation of a potential security compromise is closely related to digital forensics topics. As with forensic investigations, we also aim to maintain the integrity of our "evidence", *wherever possible* not modifying access times or other information. However, in a business incident response setting maintaining a chain of evidence may not be our highest priority, since we may be more concerned with other business objectives, such as assuring the confidentiality, integrity, and availability of data and services.

During analysis, it is good practice to follow the order of volatility (OOV): collecting the most volatile evidence first (such as the contents of RAM, details of processes running, and so on) from a live system, then collecting less volatile evidence (such as data stored on disk) using offline analysis.

## Live analysis {#live-analysis}

After suspecting a compromise, before powering down the server for offline analysis, the first step is typically to perform some initial investigation of the live system. Live analysis aims to investigate suspicions that a compromise has occurred, and gather volatile information, which may potentially include evidence that would be lost by powering down the computer.

\==VM: On the desktop VM==, ==action: ssh into the compromised server==:

```bash
ssh $COMPROMISED_IP
```

> Tip: Because the same users exist on both systems you can leave off the username (normally `ssh username@server_ip`).

\==VM: On the compromised_server VM (ssh)==: To keep a record of what we are doing on the system, start the `script` command:

```bash
mkdir evid
script -f evid/invst.log
```

> Note: *If you do this lab over multiple sessions*, be sure to save a copy of the log of your progress (`evid/invst.log`), and restart `script`.

==question: Log Book question:== Make a note of the risks and benefits associated with storing a record of what we are doing locally on the computer that we are investigating.

Consider the advantages of *handwritten* documentation of what investigators are doing.

### Using a Live CD/DVD {#using-a-live-cd-dvd}

Many of the commands used to investigate what is happening on a system are standard Unix commands. However, it is advisable to run these from a read-only source, since software on your system may have been tampered with. Also, using read-only media minimises the changes made to your local filesystem, such as executable file access times.

Next you will configure the compromised_server VM to have access to the FIRE (Forensic and Incident Response Environment) CD/DVD ISO (which is equivalent to inserting the optical disk into your server's DVD-tray). FIRE is an example of a Linux Live Disk that includes tools for forensic investigation. In addition to tools to boot to a version of Linux for offline investigation of evidence, the disk contains Linux tools for live analysis.

Add the FIRE IR CD disk:

\==action: In Hacktivity, click on the compromised_server VM's settings (gear) icon and choose 'Change CD/DVD'==.

\==action: Select the "fire-0.3.5b.iso" file== from the dropdown box. ==action: Click "Attach disk"==.

\==VM: On the compromised_server VM (ssh)==, ==action: mount the disk==, so that we can access its contents:

```bash
sudo mount /media/cdrom0/ -o exec
```

On a typical system, many binary executables are dynamically linked; that is, these programs do not physically contain all the libraries (shared code) they use, and instead load that code from shared library files when the program runs. On Unix systems the shared code is typically contained in ".so" files, while on Windows ".dll" files contain shared code. The risks associated with using dynamically linked executables to investigate security breaches is that access times on the shared objects will be updated, and the shared code may also have been tampered with. For this reason it is safest to use programs that are statically linked; that is, have been compiled to physically contain a copy of all of the shared code that it uses.

\==VM: On your desktop VM (in a separate console tab)==, ==action: look at which libraries are dynamically loaded== when you run a typical command:

```bash
ldd /bin/ls
```

Examine the output, and determine how many external libraries are involved.

\==VM: On the compromised_server VM (ssh)==: The FIRE disk contains a number of statically compiled programs to be used for investigations.

\==action: Look at the commands available:==

```bash
ls /media/cdrom0/statbins/linux2.2_x86/
```

\==action: Check that these are indeed statically linked:==

```bash
ldd /media/cdrom0/statbins/linux2.2_x86/ls
```

\==action: Compare the output to the previous command== run on your own desktop system. The output will be distinctly different, stating that the program is not dynamically compiled.

Note that, although an improvement, using statically linked programs such as these still do not guarantee that you can trust the output of the programs you run. \==action: Consider why, and make a note of this in your Log Book.==

## First look around {#first-look-around}

Run `ls` to view the contents of the home directory on the compromised_server:

```bash
cd
ls
```

Run the static version:

```bash
/media/cdrom0/statbins/linux2.2_x86/ls
```

Note the presence of a "u_r_powned" file in the output from the live disk version of `ls`! Running the local version of `ls` is not accurately reporting the files that exist! Lucky we thought to run another copy of `ls`.

## Collecting live state manually {#collecting-live-state-manually}

The next step is to use various tools to capture information about the live system, for later analysis. One approach to storing the resulting evidence is to send results over the network via Netcat or SSH, without storing them locally. This has the advantage of not changing local files, and is less likely to tip off an attacker, rather than storing the evidence you are collecting on the compromised machine itself.

\==VM: On your desktop VM (not from the console still sshed into the server)==, ==action: create a directory for the evidence you are about to collect==:

```bash
mkdir evidence
```

### Saving output from the compromised server to your desktop {#saving-output-from-the-compromised-server-to-your-desktop}

\==VM: On the desktop VM (not from the sshed server)==, ==action: test sending the results of some commands over SSH to your desktop VM==:

```bash
ssh $COMPROMISED_IP "echo this command is running on the server"

ssh $COMPROMISED_IP "echo this command is running on the server" | tee evidence/test_output

ls evidence

cat evidence/test_output
```

> Tip: Take the time to make sure you understand which system each command above is running on.
>
> Note: `tee` prints to the screen as well as saving the output to disk (you can instead redirect the output to a file with `>`, but you won't see the output while the program runs.)

### Comparing process lists {#comparing-process-lists}

Collect results of a process listing using `ps` over SSH to the compromised VM:

```bash
ssh -t $COMPROMISED_IP "sudo ps aux" | tee evidence/local_ps_output
```

\==VM: On your desktop VM==, find the newly created files and view the contents.

> Tip: you may wish to use the Dolphin graphical file browser, then navigate to `$HOME/evidence`.

Run the statically compiled version of `ls` from the incident response disk to list the contents of `/proc` (this is provided dynamically by the kernel: a directory exists for every process on the system), and once again send the results to your desktop VM.

Run the command:

```bash
ssh $COMPROMISED_IP "/media/cdrom0/statbins/linux2.2_x86/ls /proc" | tee evidence/proc_ls_static
```

\==VM: On your desktop VM==, find the newly created files and ==action: compare the list of pids (numbers representing processes) output from the previous commands==. This is the second column of output in `local_ps_output`, with the numbers in `proc_ls_static`.

> Hint: you can do the comparison manually, or using commands such as `cut` (or `awk`), `sort`, and `diff`. For example, `cat local_ps_output | awk '{ print $2 }'` will pipe the contents of the file `local_ps_output` into the `awk` command, which will split on spaces, and only display the second field. Ensure this is displaying the list of pids, if not try selecting a different field. You could pipe this through to `sort`. Then save that to a file (by appending `> pids_ps_out`). Remember `man awk`, `man sort`, and `man diff` will tell you about how to use the commands (and a search engine may also come in handy).

Are the same processes shown each time? Can you explain why the outputs from different tools are giving you a different picture of the system? If not, that is very suspicious, and likely indicates a break-in, and that we probably shouldn't trust the output of local commands.

> Note: Some changes are to be expected simply due to timing, such as short running processes, including the commands you are actually running to do your investigation. However, you wouldn't expect processes that are consistently running to not be visible in `ps`, etc.

## Gathering live state using statically compiled programs {#gathering-live-state-using-statically-compiled-programs}

Note that this section involves running a lot of commands **on your desktop VM**, that execute on the server and save state to your desktop.

Save a list of the files currently being accessed by programs:

```bash
ssh $COMPROMISED_IP "/media/cdrom0/statbins/linux2.2_x86/lsof" | tee evidence/lsof_out
```

Save a list of network connections:

```bash
ssh -t $COMPROMISED_IP "sudo netstat -apn" | tee evidence/netstat_out

ssh -t $COMPROMISED_IP "sudo /media/cdrom0/statbins/linux2.2_x86/netstat -apn" | tee evidence/netstat_static_out
```

> Note: Some commands such as this one may take a while to run, wait until the Bash prompt returns.

Save a list of the network resources currently being accessed by programs:

```bash
ssh -t $COMPROMISED_IP "sudo /media/cdrom0/statbins/linux2.2_x86/lsof -P -i -n" | tee evidence/lsof_net_out
```

Save a copy of the routing table:

```bash
ssh $COMPROMISED_IP "/media/cdrom0/statbins/linux2.2_x86/route" | tee evidence/route_out
```

Save a copy of the ARP cache:

```bash
ssh $COMPROMISED_IP "/media/cdrom0/statbins/linux2.2_x86/arp -a" | tee evidence/arp_out
```

Save a list of the kernel modules currently loaded (as reported by the kernel):

```bash
ssh -t $COMPROMISED_IP "sudo /media/cdrom0/statbins/linux2.2_x86/cat /proc/modules" | tee evidence/lsmod_out
```

Save a copy of the Bash history:

```bash
ssh -t $COMPROMISED_IP "sudo /media/cdrom0/statbins/linux2.2_x86/cat /root/.bash_history" | tee evidence/bash_history
```

**Creating images of the system state**

We can take a snapshot of the live state of the computer by dumping the entire contents of memory (what is in RAM/swap) into a file. First, check whether we are running a 32-bit or 64-bit operating system:

```bash
ssh -t $COMPROMISED_IP "uname -m"
```

On a **32-bit** Linux system `/proc/kcore` contains an ELF-formatted core dump of the kernel. Only if the compromised_server is 32-bit, save a snapshot of the kernel state:

```bash
ssh -t $COMPROMISED_IP "sudo /media/cdrom0/statbins/linux2.2_x86/dd if=/proc/kcore conv=noerror,sync" | tee evidence/kcore
```

\==action: After 10 seconds or so press Ctrl-C to stop.==

On a **64-bit** Linux system, since kernel version 4.8 we cannot dump `/proc/kcore` directly as there has been randomisation added to the start of the memory mapping. Instead we can dump the contents of live memory with an open source tool called LiME (Linux Memory Extractor) and then copy them to our desktop VM for analysis.

```bash
ssh -t $COMPROMISED_IP 'sudo insmod /root/LiME/src/lime-$(uname -r).ko "path=/home/'$USER'/lime_dump format=raw"'
sudo scp $USER@$COMPROMISED_IP:/home/$USER/lime_dump evidence/kcore
```

Next, we can copy entire partitions to our other system, to preserve the exact state of stored data, and so that we can conduct offline analysis without modifying the filesystem.

Start by identifying the device files for the partitions on the compromised system:

```bash
ssh -t $COMPROMISED_IP "df"
```

Note that on this system the root partition (mounted on "/"), is `/dev/sda1`.

> Hint: on some VMs, you may need to replace `sda1` with `hda1`.

Then **you could** copy byte-for-byte the contents of the entire root ("/") partition over the network (where `/dev/sda1` was identified from the previous command):

```bash
ssh -t $COMPROMISED_IP "sudo /media/cdrom0/statbins/linux2.2_x86/dd if=/dev/sda1 bs=1M count=5 conv=noerror,sync" | tee evidence/sda1.img
```

> Tip: Doing a full copy of the disk would take quite some time, so for demonstration purposes we are only copying 5MB of the disk.

This command could be repeated for each partition including swap partitions. For now, let's accept that we have all we need.

\==VM: On your desktop VM==, list all the files you have created:

```bash
ls -la $HOME/evidence
```

At this stage ==action: take a closer look through== some of the information you have collected.

==question: Log Book Task:== Examine the contents of the various output files and identify anything that may indicate that the computer has been compromised by an attacker. Hint: does the network usage seem suspicious?

### Collecting live state using scripts {#collecting-live-state-using-scripts}

As you may have concluded from the previous tasks, manually collecting all this information from a live system can be a fairly time consuming process. Incident response data collection scripts can automate much of this process. A common data collection script `linux-ir.sh`, is included on the FIRE disk, and is also found on the popular Helix IR disk.

\==VM: On the compromised_server VM (ssh console tab from earlier)==, have a look through the script:

```bash
less /media/cdrom0/statbins/linux-ir.sh
```

Note that this is a Bash script, and each line contains commands that you could type into the Bash shell. Bash provides the command prompt on most Unix systems, and a Bash script is an automated way of running commands. This script is quite simple, with a series of commands (similar to some of those you have already run) to display information about the running system.

Identify some commands within the script that collect information you have not already collected above.

Exit viewing the script (press q).

\==VM: On your desktop VM==, run the data collection script, redirecting output to your desktop VM:

```bash
ssh -t $COMPROMISED_IP "cd /media/cdrom0/statbins; sudo /media/cdrom0/statbins/linux-ir.sh" | tee evidence/ir_out
```

\==VM: On your desktop VM==, have a look at the output from the script:

```bash
less $HOME/evidence/ir_out
```

Use what you have learnt to spot some evidence of a security compromise.

### Checking for rootkits {#checking-for-rootkits}

An important concern when investigating an incident, is that the system (including user-space programs, libraries, and possibly even the OS kernel) may have been modified to hide the presence of changes made by an attacker. For example, the `ps` and `ls` commands may be modified, so that certain processes and files (respectively) are not displayed. The libraries used by various commands may have been modified, so that any programs using those libraries are provided with deceptive information. If the kernel has been modified, it can essentially change the behaviour of *any* program on the system, by changing the kernel's response to instructions from processes. For example, if a program attempts to *open* a file for viewing, the kernel could provide one set of content, while an attempt to *execute* the file may result in a completely different program running.

Detecting the presence of rootkits is tricky, and prone to error. However, there are a number of techniques that, while not foolproof, can detect a number of rootkits. Methods of detection include: looking for inconsistencies between different ways of gathering data about the system state, and looking for known instances of malicious files.

Chkrootkit is a Bash script that performs a number of tests for the presence of various rootkits.

\==VM: On the compromised_server VM (ssh)==, have a quick look through the script, it is much more complex than the previous `linux-ir.sh` script:

```bash
less /media/cdrom0/statbins/chkrootkit-linux/chkrootkit
```

> Tip: Exit `less` by pressing q.

Confirm that if we were to run `ls`, we would be running the local (dynamic) version, probably `/bin/ls`:

```bash
which ls
```

To understand why, look at the value of the environment variable `$PATH`, which tells Bash where to look for programs:

```bash
echo $PATH
```

Set the `$PATH` environment variable to use our static binaries wherever possible, so that when chkrootkit calls external programs it will (wherever possible) use the ones stored on the IR disk:

```bash
export PATH=/media/cdrom0/statbins/linux2.2_x86:$PATH
```

Confirm that now if we were to run `ls`, we would be running the static version:

```bash
which ls
```

This should report the path to our static binary on the FIRE disk.

It is now safe to run chkrootkit[^1]:

\==VM: On your desktop VM==, run:

```bash
ssh -t $COMPROMISED_IP 'sudo bash -c "export PATH=/media/cdrom0/statbins/linux2.2_x86:$PATH; /media/cdrom0/statbins/chkrootkit-linux/chkrootkit"' | tee evidence/chkrootkit_out
```

> Hint: you may get a message in the terminal before you type the password. You should still type the password for the script to run. The script should not take long to run.

\==VM: On your desktop VM==, have a look at the output:

```bash
less $HOME/evidence/chkrootkit_out
```

From the output, identify any files or directories reported as "INFECTED", or suspicious.

If this is an unknown rootkit there may not be anything detected by chkrootkit; however, at this stage you should be convinced that this system is compromised, and infected with some form of rootkit.

\==VM: On the compromised_server VM (ssh console tab)==

**You could**, power down the compromised system, so that we can continue analysis offline:

```bash
/media/cdrom0/statbins/linux2.2_x86/sync; /media/cdrom0/statbins/linux2.2_x86/sync
```

> Note: If you do not know what the `sync` command does, on your desktop VM, run `info coreutils 'sync invocation'` for more information.
>
> Tip: At this point you could tell Hacktivity to force a Power Off. However, you might want to wait until you finish the Hackerbot challenges.

Why might we want to force a power off (effectively "pulling the plug"), rather than going through the normal shutdown process (by running `halt` or `shutdown`)?

## Offline analysis of live data collection {#offline-analysis-of-live-data-collection}

Note that even if the `bash_history` was not saved, we can still recover commands that were run while the computer was running. This is possible by searching through the saved RAM (the kcore ELF dump we saved earlier).

\==VM: On your desktop VM==, run:

```bash
sudo -u "$USER" bash -c "strings -n 10 $HOME/evidence/kcore > $HOME/evidence/kcore_strings"
```

The above `strings` command extracts ASCII text from the binary core dump.

Open the extracted strings, and look for evidence of the commands you ran before saving the kernel core dump:

```bash
less $HOME/evidence/kcore_strings
```

Now press the '/' key, and type a regex to search for commands you previously ran to collect information about the system. For example, try searching for "statbins/linux2.2_x86" (press 'n' for next).

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Create a list of suspicious ports that are open on the compromised system, and save it to your desktop VM in the file Hackerbot gives you in the chat, under `~/evidence/`.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Hackerbot will then quiz you: "What was the full command that was used to start nc listening on the compromised server?" ==action: say 'the answer is ...'== once you know it.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Create a list of processes (PIDs) running on the system that are not reported by the local version of `ps`. Save it to your desktop VM in the file Hackerbot gives you in the chat, under `~/evidence/`.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Hackerbot will then quiz you: "What kind of malware hides processes, etc.?" ==action: say 'the answer is ...'== once you know it.

Don't forget to ==action: save and submit any flags!==

## Footnotes {#footnotes}

1. Note that it would be better to not have to include `$PATH`, and only use static versions. Unfortunately, FIRE does not include statically compiled versions of all of the commands that chkrootkit requires. [↩](#user-content-fnref-1)

