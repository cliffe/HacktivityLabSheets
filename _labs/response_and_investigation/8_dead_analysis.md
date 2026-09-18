---
title: "Analysis of a Compromised System: Offline Analysis"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Perform dead (offline) forensic analysis of a compromised Linux server image using Autopsy/Sleuth Kit, uncovering trojanised binaries, rootkits, and deleted evidence."
overview: |
  In this lab, you will delve into the world of digital forensics and offline analysis by examining a compromised system to uncover evidence of a security breach. This lab provides a hands-on experience with various forensic tools and techniques to investigate a compromised server. You will explore key theoretical concepts such as integrity management, log analysis, file recovery, and timeline reconstruction to piece together the events leading to the system compromise.

  You will learn how to mount a disk image read-only, analyse file integrity using MD5 hashes, use Autopsy on Kali to examine file types and check for trojanised executables, conduct timeline analysis to reconstruct the sequence of events, and examine deleted files for hidden clues. You will also investigate log files, identify attempted SSH and Telnet logins, and recover email addresses used in communication. By the end of the lab, you will have gained valuable practical experience in forensic analysis and incident response, equipping you with skills to identify and understand security breaches in real-world scenarios.

  This is a Hackerbot lab. Work through the lab sheet, then when prompted interact with Hackerbot.
tags: ["forensics", "offline-analysis", "dead-analysis", "file-integrity", "log-analysis", "timeline-analysis", "autopsy", "sleuthkit", "rootkit", "hackerbot"]
categories: ["response_and_investigation"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "F"
    topic: "Operating System Analysis"
    keywords: ["storage forensics", "data recovery and file content carving", "Timeline analysis"]
  - ka: "MAT"
    topic: "Malware Detection"
    keywords: ["identifying the presence of malware"]
  - ka: "AAA"
    topic: "Accountability"
    keywords: ["The fallibility of digital evidence to tampering"]
---

## Getting started {#getting-started}

### VMs in this lab {#vms-in-this-lab}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- kali (user: `kali`, password: `kali`)

All of these VMs need to be running to complete the lab.

Analysis is done on the kali VM.

{% include hackerbot-intro.md role="task you to investigate the evidence from a compromised server" %}

## Introduction to dead (offline) analysis {#introduction-to-dead-offline-analysis}

Once you have collected information from a compromised computer (as you have done in the previous lab), you can continue analysis offline. There are a number of software environments that can be used to do offline analysis. We will be using Kali Linux, which includes a number of forensic tools. Another popular toolset is the Helix incident response environment, which you may want to also experiment with.

This lab reinforces what you have learned about integrity management and log analysis, and introduces a number of new concepts and tools.

## IMG of a compromised server {#img-of-a-compromised-server}

\==VM: On the kali VM==:

In `/root/evidence/` you will find a copy of an image copied from a live system, that was connected to the Internet and attacked. The image is a few years old, but is still an excellent example of the kinds of evidence you can find.

## Mounting the image read-only {#mounting-the-image-read-only}

It is possible to mount the partition image directly as a [*loop device*](http://en.wikipedia.org/wiki/Loop_device), and access the files directly. However, doing so should be done with caution (and is generally a bad idea, unless you are very careful), since there is some chance that it may result in changes to your evidence, and you risk infecting the analysis machine with any malware on the system being analysed. However, this technique is worth exploring, since it does make accessing files particularly convenient.

\==action: Create a directory to mount our evidence onto:==

```bash
sudo mkdir /mnt/compromised
```

\==action: Mount the image== that we previously captured of the state of the main partition on the compromised system:

```bash
sudo mount -O ro -o loop /root/evidence/hda1.img /mnt/compromised
```

Confirm that you can now see the files that were on the compromised system:

```bash
ls /mnt/compromised
```

## Preparing for analysis of the integrity of files {#preparing-for-analysis-of-the-integrity-of-files}

Fortunately the system administrator of the Red Hat server had run a file integrity tool to generate hashes before the system was compromised.

`/root/evidence/md5s` contains the md5 hashes of the system before it was compromised.

\==action: View the file==:

```bash
less /root/evidence/md5s
```

> Note: 'q' to quit.

As you have learned in the Integrity Management lab, this information can be used to check whether files have changed.

## Starting Autopsy {#starting-autopsy}

Autopsy is a front-end for the Sleuth Kit (TSK) collection of forensic analysis command line tools. There is a version of Autopsy included in Kali Linux (a newer desktop-based version is also available for Windows).

\==action: Create a directory== for storing the evidence files from Autopsy:

```bash
sudo mkdir /root/evidence/autopsy
```

Start Autopsy. You can do this using the program menu. \==action: Click Applications / Forensics / autopsy.==

A terminal window should be displayed.

\==action: Open Firefox, and visit [http://localhost:9999/autopsy](http://localhost:9999/autopsy)==

\==action: Click "New Case".==

\==action: Enter a case name==, such as "RedHatCompromised", and \==action: a description==, such as "Compromised Linux server", and \==action: enter your name==. \==action: Click "New Case".==

\==action: Click the "Add Host" button.==

In section "6. Path of Ignore Hash Database", \==action: enter /root/evidence/md5s==

\==action: Click the "Add Host" button== at the bottom of the page.

\==action: Click "Add Image".==

\==action: Click "Add Image File".==

For section "1. Location", \==action: enter /root/evidence/hda1.img==

For "2. Type", \==action: select "Partition".==

For "3. Import Method", \==action: select "Symlink".==

\==action: Click "Next".==

\==action: Click "Add".==

\==action: Click "Ok".==

## File type analysis and integrity checking {#file-type-analysis-and-integrity-checking}

Now that you have started and configured Autopsy with a new case and hash database, you can view the categories of files, while ignoring files that you know to be safe.

\==action: Click "Analyse".==

\==action: Click "File Type".==

\==action: Click "Sort Files by Type".==

Confirm that "Ignore files that are found in the Exclude Hash Database" is selected.

\==action: Click "Ok"==, **this analysis takes quite some time, wait for the output to update with results**.

Once complete, \==action: view the "Results Summary".==

The output shows that over 16000 files have been ignored because they were found in the md5 hashes ("Hash Database Exclusions"). This is good news, since what it leaves us with are the interesting files that have changed or been created since the system was in a clean state. This includes archives, executables, and text files (amongst other categories).

\==action: Click "View Sorted Files".==

Copy the results file location as reported by Autopsy, and \==action: open the report in a new tab within Firefox:==

> `/var/lib/autopsy/RedHatCompromised/host1/output/sorter-vol1/`
>
> (Without the index.html. Paste this path into the Firefox address bar inside the kali VM.)

\==action: Click "compress"==, to view the compressed files. You are greeted with a list of two compressed file archives, "/etc/opt/psyBNC2.3.1.tar.gz", and "/root/sslstop.tar.gz".

\==action: Figure out what `psyBNC2.3.1.tar.gz` is used for.==

> Tip: The VMs have no internet access, so search from your host machine's browser for the file name, or part thereof.

Browse the evidence in `/mnt/compromised/etc/opt` (on the Kali Linux system, using a file browser, such as Dolphin) and look at the contents of the archive (in `/etc/opt`, and you may find that the attacker has left an uncompressed version which you can assess in Autopsy). Remember, don't execute any files from the compromised system on your analysis machine: you don't want to end up infecting your analysis machine. For this reason, it is safer to assess these files via Autopsy. \==action: Browse to the directory by clicking back to the Results Summary tab of Autopsy, and clicking "File Analysis"==, then browse to the files from there (in `/etc/opt`). Read the psyBNC README file, and \==action: note what this software package is used for.==

> Help: if the README file did not display as expected, click on the inode (meta) number at the right-hand side of the line containing the README file. You will need to click each direct block link in turn to see the content of the README file. The direct block links are displayed at the bottom left-hand side of the webpage.

Next, we investigate what sslstop.tar.gz is used for. A search reveals a CGSecurity.org page, which reports that this script modifies httpd.conf to disable SSL support from Apache. Interesting... Why would an attacker want to disable SSL support? This should soon become clear.

\==action: Return to the page where "compress" was accessed== (`/root/evidence/autopsy/RedHatCompromised/host1/output/sorter-vol1/index.html`), and \==action: click "exec"==. This page lists a fairly extensive collection of new executables on our compromised server.

\==action: Make a list of all the executables that are likely trojanised.==

> Hint: for now ignore the "relocatable" objects left from compiling the PSYBNC software, and focus on "executable" files, especially those in `/bin/` and `/usr/bin/`.

---

Two of these have particularly interesting file names: `/usr/bin/smbd -D` and `/usr/bin/(swapd)`. These names are designed to be deceptive: for example, the inclusion of ` -D` is designed to trick system administrators into thinking that any processes were started with the "-D" command line argument flag.

Note that `/lib/.x/` contains a number of new executables, including one called "hide". These are likely part of a rootkit.

> Hint: to view these files you will have to look in `/mnt/compromised/lib/.x`. The `.x` folder is a hidden folder (all folders and files in Linux that begin with a "." are hidden files). Therefore, you will have to use the `-a` switch when using the `ls` command in a terminal, or tell the graphical file manager to display hidden files (View / Show Hidden Files or Ctrl+H).

\==action: Using Autopsy "File Analysis" mode, browse to "/lib/.x/"==. **Explicit language warning: if you are easily offended, then skip this next step.** View the contents of "install.log".

> Help: if the install.log file did not display as expected, click on the inode (meta) number at the right-hand side of the line containing the file. You will need to click the direct block link to see the content of the install.log file. The direct block links are displayed at the bottom left-hand side of the webpage.

This includes the lines:

```
############################
# SucKIT version 1.3b by Unseen < unseen@broken.org > #
############################
```

SuckIT is a rootkit that tampers with the Linux kernel directly via `/dev/kmem`, rather than the usual approach of loading a loadable kernel module (LKM). The lines in the log may indicate that the rootkit had troubles loading.

SuckIT and the rootkit technique is described in detail in Phrack issue 58, article 0x07 "Linux on-the-fly kernel patching without LKM":

> [*http://www.textfiles.com/magazines/PHRACK/PHRACK58*](http://www.textfiles.com/magazines/PHRACK/PHRACK58)

\==action: Using Autopsy "File Analysis", view the file /lib/.x/.boot==

> Help: again you may need to view the block directly that contains the .boot file. Make a note of the file's access times, this will come in handy soon.

This shell script starts an SSH server (s/xopen), and sends an email to a specific email address to inform them that the machine is available. View the script, and \==action: determine what email address it will email the information to.==

Return to the file type analysis (presumably still open in a Firefox tab), still viewing the "exec" category, also note the presence of "adore.o". Adore is another rootkit (and worm), this one loads via an LKM (loadable kernel module).

Here is a concise description of a version of Adore:

> [*http://lwn.net/Articles/75990/*](http://lwn.net/Articles/75990/)

This system is well and truly compromised, with multiple kernel rootkits installed, and various trojanised binaries.

---

## Timeline analysis {#timeline-analysis}

It helps to reconstruct the timeline of events on the system, to get a better understanding. Software such as Sleuth Kit (either using the Autopsy frontend or the mactime command line tool) analyses the MAC times of files (that is, the most recent modification, most recent access, and most recent inode change[1](#user-content-fn-1)) to reconstruct a sequence of file access events.

In another Firefox tab, \==action: visit [http://localhost:9999/autopsy](http://localhost:9999/autopsy), click "Open Case", "Ok", "Ok".==

\==action: Click "File Activity Timelines".==

\==action: Click "Create Data File".==

\==action: Select "/1/ hda1.img-0-0 ext".==

\==action: Click "Ok".==

\==action: Click "Ok".==

For "2. Enter the starting date" \==action: select "Specify" and enter July 1 2003.==

> Note: The access date you previously recorded (for `/lib/.x/.boot`) was in August 2003, so this is probably a good place to start.

For "5. Select the UNIX image that contains the /etc/passwd and /etc/group files", \==action: select "hda1.img-0-0".==

Wait while a timeline is generated.

Make a note/copy of the URL to the .txt file version, which can come in handy if the HTML version has any issues.

\==action: Click "Ok".==

Once analysis is complete, the timeline is presented.

> Note: If you get an error message rather than a table, you can simply view the .txt file version, or review the options selected and rerun the analysis.

\==action: Click "Summary".==

\==action: Browse through the history.== Note that it is very detailed, and it is easy to get lost (and waste time) in irrelevant detail.

\==action: Browse to August 2003 on the timeline==, and follow along:

Note that on the 6th of August it seems many files were accessed, and not altered (displayed as ".a.."[2](#user-content-fn-2)). This is probably the point at which the md5 hashes of all the files on the system were collected.

On 9th August a number of config files were accessed including "/sbin/runlevel", "/sbin/ipchains", and "/bin/login". This indicates that the system was likely rebooted at this time.

On 10th August, a number of files that have since been deleted were accessed.

Shortly thereafter the inode data was changed (displayed as "..c.") for many files. Then many files owned by the *apache* user were last modified before they were deleted. The apache user goes on to access some more files, and then a number of header files (.h) were accessed, presumably in order to compile a C program from source. Directly after, some files were created, including "/usr/lib/adore", the Adore rootkit.

At 23:30:54 `/root/.bash_history` and `/var/log/messages` were symlinked to `/dev/null`.

Next more header files were accessed, this time Linux kernel headers, presumably to compile a kernel module (or perhaps some code that tries to tamper with the kernel). This was followed by the creation of the SuckIT rootkit files, which we previously investigated.

Note that a number of these files are again owned by the "apache" user.

> Question: What does this tell you about the likely source of the compromise?

Further down, note the creation of the `/root/sslstop.tar.gz` file which was extracted (files created), then compiled and run. Shortly after, the Apache config file (`/etc/httpd/conf/httpd.conf`) was modified.

> Question: Why would an attacker, after compromising a system, want to stop SSL support in Apache?

Meanwhile the attacker has accidentally created a `/.bash_history`, which has not been deleted.

Further down we see wget accessed and used to download the `/etc/opt/psyBNC2.3.1.tar.gz` file, which we investigated earlier.

This file was then extracted, and the program compiled. This involved accessing many header (.h) files. Finally, the `/etc/opt/psybnc/psybnc.conf` file is modified, presumably by the attacker, in order to configure the behaviour of the program.

---

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Create a list of the potentially trojanised executables on the compromised system, and save it to your Kali VM at `/home/kali/evidence/`, in a file with the name Hackerbot gives you in the chat. Create an evidence directory, and a file with that name within it. List full pathnames, one per line.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

Don't forget to \==action: save and submit any flags!==

## Logs analysis {#logs-analysis}

The most common logging system on Unix systems is Syslog, which is typically configured in `/etc/syslog.conf` (or similar, such as rsyslog). Within the Autopsy File Analysis browser, \==action: navigate to this configuration file and view its contents.== Note that most logging is configured to go to `/var/log/messages`. Some security messages are logged to `/var/log/secure`. Boot messages are logged to `/var/log/boot.log`.

\==action: Make a note of where mail messages are logged==, you will use this later.

Within Autopsy, browse to `/var/log`. Note that you cannot view the messages file, which would have contained many helpful log entries. Click the inode number to the right (47173):

As previously seen in the timeline, this file has been symlinked to `/dev/null`. If you are not familiar with `/dev/null`, search the Internet (from your host machine) for an explanation.

For now, we will continue by investigating the files that are available, and later investigate deleted files.

Using Autopsy, \==action: view the /var/log/secure file==, and identify any IP addresses that have attempted to log in to the system using SSH or Telnet.

\==action: Determine the country of origin for each of these connection attempts:==

> Tip: The VMs have no internet access. On a typical Unix system with internet access you could look this up using `whois *IP-address*`, but here it's easier to use a lookup service from your host machine's browser, such as:
>
> [*http://whois.domaintools.com/*](http://whois.domaintools.com/)
>
> You may also run a traceroute to determine what routers lie between your system and the remote system.
>
> Additionally, software and websites exist that will graphically approximate the location of the IP, such as:
>
> [*http://www.iplocationfinder.com/*](http://www.iplocationfinder.com/)

---

Within Autopsy, \==action: view the /var/log/boot.log file==. At the top of this file Syslog reports starting at August 10 at 13:33:57.

> Question: Given what we have learned about this system during timeline analysis, what is suspicious about Syslog restarting on August 10th? Was the system actually restarted at that time?

Note that according to the log, Apache fails to restart. Why can't Apache restart? Do you think the attacker intended to do this?

\==action: Open the mail log file==, which you recorded the location of earlier. \==action: Identify the email addresses that messages were sent to.==

---

Another valuable source of information are records of commands that have been run by users. One source of this information is the `.bash_history` file. As noted during timeline analysis, the `/root/.bash_history` file was symlinked to `/dev/null`, meaning the history was not saved. However, the attacker did leave behind a Bash history file in the root of the filesystem ("/"). \==action: View this file.==

Towards the end of this short Bash session the attacker downloads sslstop.tar.gz, then the attacker runs:

```bash
ps aux | grep apache

kill -9 21510 21511 23289 23292 23302
```

> Question: What is the attacker attempting to do with these commands?

Apache has clearly played an important role in the activity of the attacker, so it is natural to investigate Apache's configuration and logs.

Still in Autopsy, \==action: browse to /etc/httpd/conf/, and view httpd.conf.==

Note that the Apache config has been altered by sslstop, by changing the "HAVE_SSL" directive to "HAVE_SSS" (remember, this file was shown in the timeline to be modified after sslstop was run).

This configuration also specifies that Apache logs are stored in `/etc/httpd/logs`, and upon investigation this location is symlinked to `/var/log/httpd/`. This is a common Apache configuration.

Unfortunately the `/var/log/httpd/` directory does not exist, so clearly the attacker has attempted to cover their tracks by deleting Apache's log files.

---

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Create a list of IP addresses you believe have attempted to log in to the system using SSH or Telnet. Save it to your Kali VM at `/home/kali/evidence/`, in the file with the name Hackerbot gives you in the chat.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

There is a quiz to complete. Once Hackerbot asks you the question, \==action: answer 'YOURANSWER'==.

Don't forget to \==action: save and submit any flags!==

#### Hackerbot Attack #3 {#hackerbot-attack-3}

You can skip the bot to here, by saying **goto 3**.

> Hackerbot: Save the email addresses that messages were sent to. Save them to your Kali VM at `/home/kali/evidence/`, in the file with the name Hackerbot gives you in the chat.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

Don't forget to \==action: save and submit any flags!==

## Deleted files analysis {#deleted-files-analysis}

Autopsy can be used to view files that have been deleted. Simply click "All Deleted Files", and browse through the deleted files it has discovered. Some of the deleted files will have known filenames, others will not.

However, this is not an efficient way of searching through content to find relevant information.

Since we are primarily interested in recovering lost log files (which are ASCII human-readable), one of the quickest methods is to extract all unallocated data from our evidence image, and search that for likely log messages. Autopsy has a keyword search. However, manual searching can be more efficient.

\==VM: In a terminal console in Kali Linux==, \==action: run:==

```bash
blkls -A evidence/hda1.img | strings > evidence/unallocated
```

This will extract all unallocated blocks from the partition, and run this through strings, which reduces it to text only (removing any binary data), and the results are stored in `evidence/unallocated`.

Open the extracted information for viewing:

```bash
less evidence/unallocated
```

Scroll down, and \==action: find any deleted email message logs.==

> Hint: try pressing ":" then type "/To:".

> Question: What sorts of information was emailed?

To get the list of all email recipients quit less (press 'q'), and \==action: run:==

```bash
grep "To:.*@" evidence/unallocated
```

Once again, \==action: open the extracted deleted information== for viewing:

```bash
less evidence/unallocated
```

Scroll down until you notice some Bash history. What files have been downloaded using wget? Quit less, and write a grep command to search for wget commands used to download files.

---

\==action: Write a grep command to search for commands used by the attacker to delete files from the system.==

Once again, open the extracted deleted information for viewing:

```bash
less evidence/unallocated
```

Press ":" and type "/shellcode". There are quite a few exploits on this system, not all of which were used in the compromise.

\==action: Search for the contents of log files==, that were recorded on the day the attack took place:

```bash
grep "Aug[/ ]10" evidence/unallocated
```

Note that there is an error message from Apache that repeats many times, complaining that it cannot hold a lockfile. This is caused by the attacker having deleted the logs directory, which Apache is using.

If things have gone extremely well the output will include further logs from Apache, including error messages with enough information to search for information about the exploit that was used to take control of Apache to run arbitrary code (do this search from your host machine's browser, since the VMs have no internet access). If not, then at some point during live analysis you may have clobbered some deleted files. This is the important piece of information from unallocated disk space:

```
[Sun Aug 10 13:24:29 2003] [error] mod_ssl: SSL handshake failed (server localhost.localdomain:443, client 213.154.118.219) (OpenSSL library error follows)

[Sun Aug 10 13:24:29 2003] [error] OpenSSL: error:1406908F:SSL routines:GET_CLIENT_FINISHED:connection id is different
```

This may indicate the exploitation of this software vulnerability:

> OpenSSL SSLv2 Malformed Client Key Remote Buffer Overflow Vulnerability
>
> [*http://www.securityfocus.com/bid/5363*](http://www.securityfocus.com/bid/5363)

---

#### Hackerbot Attack #4 {#hackerbot-attack-4}

You can skip the bot to here, by saying **goto 4**.

> Hackerbot: Save the wget commands used to download rootkits. Save them to your Kali VM at `/home/kali/evidence/`, in the file with the name Hackerbot gives you in the chat.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

There is a quiz to complete. Once Hackerbot asks you the question, \==action: answer 'YOURANSWER'==.

Don't forget to \==action: save and submit any flags!==

## Footnotes {#footnotes}

1. Note that the specifics of the times that are recorded depend on the filesystem in use. A typical Unix filesystem keeps a record of the most recent modification, most recent access, and most recent inode change. On Windows filesystems a creation date may be recorded in place of the inode change date. [↩](#user-content-fnref-1)
2. [*http://wiki.sleuthkit.org/index.php?title=Mactime_output*](http://wiki.sleuthkit.org/index.php?title=Mactime_output) [↩](#user-content-fnref-2)
