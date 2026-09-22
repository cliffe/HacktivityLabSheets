---
title: "Log management, Security Information and Event Management (SIEM), and Elastic (ELK) Stack"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Learn Linux logging with journald and syslog, then centralise and visualise security events using the Elastic (ELK) Stack as a SIEM, and use it to track down Hackerbot's changes."
overview: |
  This lab provides an overview of logging and security information and event management (SIEM) concepts, with an emphasis on the context of Linux systems. Logging is an important aspect of system administration and security, enabling the monitoring of system events and providing insight into system activities. The lab covers the fundamentals of logging, including the systemd journal and traditional syslog, and introduces the Elastic (ELK) Stack as a SIEM solution. It also explores the usage of Auditbeat to monitor system audit information and highlights the role of a Security Operations Centre (SOC) in managing and responding to security incidents.

  In this lab, you will learn how to use various logging tools and commands, such as journalctl and syslog, to access and analyse system logs. You will gain practical experience in configuring logging rules, using regular expressions to filter log data, and exploring log rotation for efficient log management. Additionally, you will set up Auditbeat to monitor system activities and visualise the collected data using Elastic Stack. By the end of the lab, you will have a foundation in log management and SIEM, and be equipped to improve the security and monitoring capabilities of Linux systems.

  This is a Hackerbot lab. Work through the lab sheet, then when prompted interact with Hackerbot.
tags: ["logging", "syslog", "journald", "systemd", "siem", "elastic", "elk", "kibana", "auditbeat", "logrotate", "regex", "hackerbot"]
categories: ["response_and_investigation"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "SOIM"
    topic: "Fundamental Concepts"
    keywords: ["workflows and vocabulary", "PURPOSE OF LOGGING AND AUDITING"]
  - ka: "SOIM"
    topic: "Monitor: Data Sources"
    keywords: ["system and kernel logs", "Syslog", "Linux Journal and SystemD", "EVENTS - LOGGING", "LOG FILES - CENTRALIZED LOGGING", "LOG FILES - EVENT SOURCE CONFIGURATION", "LOGGING AND AUDITING OF CHANGES", "MONITORING - INTEGRITY", "AuditBeat"]
  - ka: "SOIM"
    topic: "Analyse: Analysis Methods"
    keywords: ["contribution of SIEM to analysis and detection", "EVENTS - ANALYSIS"]
  - ka: "SOIM"
    topic: "Plan: Security Information and Event Management"
    keywords: ["data collection", "alert correlation", "LOG FILES - INCIDENT RESPONSE", "MONITORING - INCIDENT RESPONSE"]
  - ka: "SOIM"
    topic: "Execute: Mitigation and Countermeasures"
    keywords: ["SIEM platforms and countermeasures", "SECURITY INFORMATION AND EVENT MANAGEMENT (SIEM)", "Configuring Elastic Stack for centralised logging and SIEM"]
---

## Getting started {#getting-started}

### VMs in this lab {#vms-in-this-lab}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop
- siem_management

All of these VMs need to be running to complete the lab.

### Your login details for the "desktop" and "siem_management" VMs {#your-login-details}

\==VM: On the desktop and siem_management VMs==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the hackerbot_server, but the VM needs to be running to complete the lab.

> Tip: If you are not sure of your username, ==action: open a terminal and run `whoami`==.

### Note the IP address of your siem_management VM {#note-the-ip-address}

Kibana, the web interface to Elastic Stack, runs on the siem_management VM. You will need its IP address.

\==VM: On the siem_management VM==, ==action: open a terminal and run:==

```bash
ip -4 -o a s
```

> Note: Note the IP address — this is your **siem_management IP address**. Kibana listens on port 5601, so its address is `http://<siem_management IP address>:5601`. Firefox on that VM is already set to open it for you.

{% include hackerbot-intro.md role="attack your system, and task you with tracking down what changed using a SIEM" chat="full" %}

## An introduction to logging and systemd {#an-introduction-to-logging-and-systemd}

Until relatively recently, most Linux systems used text based log files for everything. This has changed due to the introduction of systemd. Systemd is a suite of tools responsible for starting and managing a system and its services. It replaces the old init system and does much more.

Systemd provides a system for collecting and monitoring logs called **journal**. The journald daemon handles all messages produced by the kernel, services, and so on, and stores them together in a binary format that can be quickly manipulated.

The `journalctl` command is provided to manipulate and interrogate the logs. The `systemctl` command is provided to enable a systemd controlled machine to manage services.

## Journald basics {#journald-basics}

\==VM: On the desktop VM:==

The `journalctl` command searches and manipulates the journal log files that are managed and updated by journald. ==action: View the whole of the log contents:==

```bash
sudo journalctl
```

You should have noticed that journald displayed all the log information using the `less` pager. The paging facility can be disabled using the `--no-pager` switch. You may need this if you want to send the output of `journalctl` to a file or another process.

\==action: Use the `--no-pager` switch to send the contents to a file, and view the file size:==

```bash
sudo journalctl --no-pager > journalroot.txt
ls -lh journalroot.txt
```

You may have noticed that the contents of the logs are displayed with the earliest date first and the most recent last. This can be reversed using the `-r` or `--reverse` switches:

```bash
sudo journalctl -r
```

Another useful switch is `-n` or `--lines=`, where we can tell journalctl to list the n most recent messages. ==action: List the 20 most recent messages:==

```bash
sudo journalctl -n 20
```

A time range can be used to reduce the amount of information displayed. ==action: List all log information generated today== (since 00:00:00):

```bash
sudo journalctl --since today
```

\==action: Display all the log information generated yesterday and today== (from yesterday at 00:00:00 until now):

```bash
sudo journalctl --since yesterday
```

\==action: Display all the log information generated on a specific day:==

```bash
sudo journalctl --since "2016-09-18 00:00:00" --until "2016-09-18 23:59:59"
```

> Tip: ==edit: Adjust the date to suit your data== if required to get output.

\==action: Display all the log information generated this boot:==

```bash
sudo journalctl -b
```

\==action: Display all the log information generated in the last boot:==

```bash
sudo journalctl -b -1
```

> Note: You may find that the system is not currently configured to store a persistent journal, but it is worth being aware of the functionality.

\==action: List every time the machine was booted:==

```bash
sudo journalctl --list-boots
```

\==action: List all the log entries for a particular service:==

```bash
sudo journalctl -u ssh
```

\==action: Filter log entries by service and a time range:==

```bash
sudo journalctl -u ssh --since today
```

\==action: Use the `-k` or `--dmesg` switches to find log messages about the kernel:==

```bash
sudo journalctl -k
```

\==action: Display kernel log messages from a previous boot:==

```bash
sudo journalctl -k -b -2
```

Journalctl can list all messages generated by a process id number. ==action: Use `ps` or `ps aux` to find a process on your system, then find any messages generated by that process:==

```bash
sudo journalctl _PID=<your process id number>
```

Journal entries can be filtered by message priority. ==action: List all error messages since the system was last booted:==

```bash
sudo journalctl -p err -b
```

> Tip: If you get no error messages, try the above command without the `-b` to show all logged error messages on the system.

The following priorities may be used to filter in place of "err". The priority number can also be used after the `-p` switch.

- 0: emerg
- 1: alert
- 2: crit
- 3: err
- 4: warning
- 5: notice
- 6: info
- 7: debug

You can also revert to the old methods of searching log files, by using journalctl to list the full log contents and piping the output to other commands such as `grep`.

\==action: List all the attempts to gain root privileges:==

```bash
sudo journalctl --no-pager \| grep "root"
```

\==action: Open a new Konsole tab, and run any command using sudo, typing the wrong password 3 times.==

\==action: List just the failed attempts to gain root privileges:==

```bash
sudo journalctl --no-pager \| grep "incorrect password attempts"
```

It is sometimes very helpful to use the `-f` or `--follow` switches, which show only the most recent journal entries, and continuously print new entries as they are added to the journal.

```bash
sudo journalctl -f
```

\==action: Open another terminal and run sudo with any command== to generate some log messages, for example:

```bash
sudo ls
```

In the terminal where `journalctl -f` is running, ==action: press Ctrl+Z to quit== (Help: Ctrl+C if this fails).

## Syslog basics {#syslog-basics}

Syslog uses the traditional method of storing log messages in separate log files. Syslog is still used today on many legacy systems, and on modern Linux systems that interact with legacy systems. A popular version of syslog is called rsyslog, and can be used alongside journald on modern systems.

\==action: Check the rsyslog service:==

```bash
sudo systemctl status rsyslog
```

\==action: Open a terminal console== (such as Konsole from KDEMenu → System → Terminal → Konsole).

Start by having a look at the logs that are available on a Unix/Linux system. These are typically stored in `/var/log`.

\==action: List the various log files:==

```bash
ls /var/log
ls /var/log/*/*
```

Have a look through the various files present, and try to identify the purpose of as many as possible. You may wish to open these using `sudo less /var/log/`... followed by a filename.

> Tip: Try typing `less /var/log/` then, without pressing enter, press TAB twice. This will list all the files in /var/log that you could complete the command argument with.

Depending on the version of Unix or distribution of Linux you are using, and the system's configuration, there will be slightly different log files present. Most Unix systems will have a `/var/log/messages` file (or `/var/log/syslog`), which is the main location for various logs received by Syslog (and newer Syslog replacements such as Rsyslog). Syslog-like loggers are one of the most commonly deployed log mechanisms.

> Note: You should notice a journal directory that is used to hold the files maintained by the journald service. Journald will rotate (compress and archive) old data as instructed in its configuration file. Journald has been deliberately designed to work in parallel with syslog on the same system until the transition to journald is complete.

\==action: View the contents of your messages log file:==

```bash
sudo less /var/log/messages
```

> Note: Press "q" to exit, when you are done.

Depending on how long your system has been running for (and, as you will soon see, how long ago the logs were rotated), this log file may be very long, with many various kinds of events recorded. Obviously not all of these logs describe security events; however, these logs can be very useful when troubleshooting many kinds of system behaviour, including when investigating a security breach.

Using your own judgement, ==action: attempt to find security relevant details within your messages log file.==

As an example, one of my own older `/var/log/messages` files contains the lines:

```
Jan 21 16:52:22 linux-leedsbeckett SuSEfirewall2: Setting up rules from /etc/sysconfig/SuSEfirewall2 ...
Jan 21 16:52:22 linux-leedsbeckett SuSEfirewall2: using default zone 'ext' for interface vmnet1
Jan 21 16:52:22 linux-leedsbeckett SuSEfirewall2: using default zone 'ext' for interface vmnet8
Jan 21 16:52:22 linux-leedsbeckett SuSEfirewall2: Firewall rules successfully set
Jan 21 17:16:26 linux-leedsbeckett pppd[32076]: Script /etc/ppp/ip-down finished (pid 342), status = 0x0
Jan 21 17:16:26 linux-leedsbeckett pppd[32076]: Exit.
```

This activity was triggered when I disabled the VPN I was using, which triggered a reload of the firewall rules.

As is typical, each Syslog entry starts with a timestamp: for example, "Jan 21 17:16:26". This is followed by the name of the computer, in my case "linux-leedsbeckett". The next part is the name of the service that sent the log event. In the above example this includes logs sent by "SuSEfirewall2" and "pppd". In the case of pppd, a process id (pid) is also included. Following this is the actual log event (message) that was sent to Syslog.

## Watching for file changes {#watching-for-file-changes}

Since keeping an eye on log files is a common security and sys-admin task, it is worth exploring a few methods.

`tail` is a command that prints the last few lines of a text file:

```bash
sudo tail /var/log/user.log
```

A simple method of keeping an eye on a file is to follow the end of a text file. ==action: Run:==

```bash
sudo tail -f /var/log/user.log
```

This will block waiting for input, and when new lines are added, they will be displayed.

Similarly, the `less` program can "follow" the end of a file. ==action: Run:==

```bash
sudo less /var/log/user.log
```

Then ==action: press Shift+F.==

> Note: Press Ctrl-C, then Q, to exit when you are done.

Another useful technique is to watch for changes in the output of a command using `watch`. ==action: Run:==

```bash
watch -d ls -la /var/log/user.log
```

> Note: Press Ctrl-C to exit when you are done.

This will continuously display the output of the `ls` command, and highlight any changes, such as if the file size changes because new entries are logged.

## Writing to Syslog from the command line {#writing-to-syslog}

It is important to realise that most local programs (that is, programs running on your computer) can send messages to the Syslog daemon to log.

\==action: From the shell prompt run:==

```bash
logger Hello, world!
```

Now, ==action: have another look at the end of your user.log file.== You will find your message, as reported by your username.

Any program can decide how to name its Syslog entries.

```bash
logger -t some-program Hello, World!
```

> Note: ==edit: Replace "some-program" with something including your name==, for example `logger -t cliffes-program Hello, World!`

As this implies, you can not necessarily trust all log entries, since an attacker on your system could craft their own log entries, to make them look like they are coming from other programs on your system.

## Understanding Syslog {#understanding-syslog}

Not all Syslog messages end up in `/var/log/messages`.

\==action: Run:==

```bash
logger -t user.info Doing something interesting!
```

Events logged by "user.\*" end up logged to `/var/log/user.log`. ==action: You will find your new message here:==

```bash
sudo tail /var/log/user.log
```

Also, emergencies and warnings are treated differently.

Each Syslog event has a priority, which is made up of a facility (auth, user, and so on), and a level (alert, crit, and so on). See `man logger` for a list of facilities and levels.

\==action: Run this to generate an emergency event:==

```bash
logger -p user.emerg Oh no!
```

This message will typically be sent to *every* terminal, and will generally even generate a popup notification.

## Writing Syslog configuration rules {#writing-syslog-configuration-rules}

The behaviour is configured in `/etc/rsyslog.conf` (or `/etc/syslog`, depending on the version of Syslog you are using).

\==action: Open the Syslog configuration file for editing:==

```bash
sudo vi /etc/rsyslog.conf
```

> Note: Editing using vi involves pressing "i" to insert/edit text, then Esc, then ":wq" to write changes and quit.

Read through the configuration file, to understand how the behaviour is configured. Try to understand how the logs are sent to virtual terminal 10 (as you previously accessed via Ctrl-Alt-F10).

\==action: Add a rule that sends all messages from the program "mymonitor" to /var/log/mymonitor==, by adding these lines:

```
if ($programname == 'mymonitor') \
then    /var/log/mymonitor
```

\==action: Restart Syslog so that it re-reads its configuration:==

```bash
sudo systemctl restart rsyslog
```

\==action: Write to Syslog to test your new rule:==

```bash
sudo logger -t mymonitor Hello, World!
```

\==action: Check that it has written to your new log file:==

```bash
sudo tail /var/log/mymonitor
```

> Question: Use what you have learned to add a rule so that any sudo command generates a message to all users (which would typically be sent on terminals and as a popup notification). Hint: look at how the existing emergency messages rule works, and combine that method of output with the rule above, modified to be triggered by sudo. Remember to reload Syslog.

\==warning: Remove the rule you added above, before continuing.==

## Regular expressions (refresher) {#regular-expressions}

As you have seen, log files can be large and detailed. Looking for the details you are interested in can be tedious. Use of regular expressions (also known as regexp or regex) can be very helpful, and make this much easier — they can help you to cut through the noise.

A regex is a pattern describing some text. A regex can be used to filter for matching text, or capture parts of matching text. There are lots of tools that accept regex patterns, such as the Unix commands `grep`, `awk`, `sed`, `less`, and `vi`. Regex are a powerful way of processing text, and as such regex are available in most programming languages, to make processing text much easier. (Programming languages such as Perl have regex as a core component of the language, while others such as C, Java, C#, and C++ have libraries that can provide regex processing.)

For the sake of explanation, the following examples show how regex can be used to search log files.

As mentioned earlier, my messages log file includes:

```
Jan 21 16:52:22 linux-leedsbeckett SuSEfirewall2: Setting up rules from /etc/sysconfig/SuSEfirewall2 ...
Jan 21 16:52:22 linux-leedsbeckett SuSEfirewall2: using default zone 'ext' for interface vmnet1
Jan 21 16:52:22 linux-leedsbeckett SuSEfirewall2: using default zone 'ext' for interface vmnet8
Jan 21 16:52:22 linux-leedsbeckett SuSEfirewall2: Firewall rules successfully set
Jan 21 17:16:26 linux-leedsbeckett pppd[32076]: Script /etc/ppp/ip-down finished (pid 342), status = 0x0
Jan 21 17:16:26 linux-leedsbeckett pppd[32076]: Exit.
```

The simplest form of regex can search for standard characters, so the following regex:

```
leedsbeckett
```

would find matches in all of those lines. We can see this in action by using `grep`, which is a standard Unix command that searches through files for lines containing matches to a regex. The `--color` argument asks grep to highlight in colour the part of the lines that match.

> Note: Don't run this exact command yourself. On my computer I could search for the text "leedsbeckett" with `sudo grep --color 'leedsbeckett' /var/log/messages`, and the output would include the lines described above.

\==action: Try searching through your own log file, for matches to a specific query. Run:==

```bash
sudo grep --color 'kernel' /var/log/messages
```

The above should output all of the log entries that were sent by the kernel.

If we want to find something more complicated, we can use *regex special characters* to create patterns that match multiple texts. ==action: Run:==

```bash
sudo grep --color 'sudo:\\|su:' /var/log/auth.log
```

> Tip: If at this point you see a long list of messages sent to the screen, you likely forgot to remove the Syslog rule you created earlier.

> Tip: Some versions of grep do not enable regex by default, so you either need to use the `-E` flag or use `egrep` instead.

This will show all of the log entries created by a user attempting a `su` or `sudo`. This would be a security sensitive action that would be worth checking for.

This is achieved by the use of the "|" (pipe) character, which describes *alternative* patterns. Note that (somewhat confusingly) grep required a "\\" (the escape character) before the special character. Usually it is the other way around, where special characters always have their special meaning ***unless*** they are escaped.

Another way of searching for the same thing would be:

```bash
sudo grep --color 'su\(do\)*:' /var/log/messages
```

This works by grouping with "( )" (parentheses); the "\*" character states that the preceding group must appear zero-or-more times. So "su" or "sudo" both match the above regex.

These special characters are used to state how many times the preceding "atom" (section) occurs:

- `*`: zero or more
- `+`: one or more
- `?`: zero or one
- `{n}`: n times: for example, `a{2}` would match `aa`
- `{n,m}`: min n, max m times

Some other special characters:

- `[a-z]`: a range of characters (defined in the square brackets), in this case any *one* lowercase character
- `.`: any character
- `\|`: as in the example above, allows alternative values to match

Note that there are a few subtle varieties of regex (as we have seen, grep requires escape slashes before certain special characters), but for the most part the above rules apply.

\==action: Run:==

```bash
sudo grep --color 'su\(do\)*:.*USER=root.*grep' /var/log/messages
```

Figure out what the above is matching, and make sure you understand how every section of the above regex works.

You can also do all kinds of neat tricks such as matching repeating text (using backreferences), and changing how "greedy" your matches are.

There are plenty of good tutorials available. You can learn more about regex matching from sources such as `man grep`, and http://gnosis.cx/publish/programming/regular_expressions.html

> Question: Using what you have learned, write a grep command that performs a regex on /var/log/messages for log entries sent by the kernel. Once that is working, extend your regex to only match log events sent in the afternoon (12:00) today (hint: consider the date).

## Logrotate {#logrotate}

A busy server may have a very large number of log entries. For this reason Unix has a `logrotate` tool, which moves old log events into a separate file, and compresses them so that they take up less space.

Logrotate typically runs daily, and as such a script for running logrotate may be present in:

```bash
ls /etc/cron.daily/
```

> Note: Note the presence of a logrotate script.

\==action: Open /etc/logrotate.conf:==

```bash
sudo less /etc/logrotate.conf
```

As you can see, this file refers to the `/etc/logrotate.d` directory, which contains rules for managing logs. Press "Q" to quit less.

\==action: Look at the logrotate configuration for syslog:==

```bash
less /etc/logrotate.d/rsyslog
```

\==action: Check whether there are any compressed messages files on your system:==

```bash
ls /var/log/messages*
```

If you only see the file `/var/log/messages`, then ==action: force logrotate to happen now:==

```bash
sudo /usr/sbin/logrotate -f /etc/logrotate.d/rsyslog
```

Now ==action: try `ls /var/log/messages*` again.==

Depending on how long your system has been running, you will probably notice the presence of many compressed log files over time.

\==action: Figure out how to decompress one of the previous log files, and inspect its contents.==

## Network logging {#network-logging}

Note that it is not uncommon for a Syslog log file (such as `/var/log/messages`) to contain entries originating from other systems on the network. There are many benefits of logging to a central server: if an attacker compromises one of the systems (so long as the computer that has been broken into is not the log server!), they cannot delete or alter existing logs; also, it simplifies log management and monitoring if the various logs can be accessed from a central location. Consequently the security of the log server becomes increasingly important.

One of the benefits of logging to a remote system is that you have a backup of your logs, since they will be recorded on both machines. It is also wise to maintain a separate backup, in case both systems are compromised. Also, note that a spool can be configured, so that if there are network problems a system sending log messages will re-attempt to send them.

## Security information and event management (SIEM) {#siem}

Security information and event management (SIEM) systems provide valuable points of centralisation, analysis, and management of large amounts of data about a network of systems.

A SIEM system collects and aggregates data from servers (such as web, email, ftp, logs), network devices (proxies, routers), security devices (firewalls, IDS, DLP, vulnerability scanners), and workstations (antimalware, logs).

A SIEM will typically provide dashboard views and ways of querying all this data (either manually or generating reports) to get a picture of the state of your network.

Many SIEM systems also integrate detection of threats or anomalies in behaviour, using rule sets and/or machine learning.

Some provide a way of managing and tracking response to incidents.

![An overview of the data sources a SIEM collects from][siem-overview]

Image source: https://www.splunk.com/en_us/data-insider/what-is-siem.html

## Security Operations Centre (SOC) and SIEM {#soc-and-siem}

A (well implemented) SIEM provides a comprehensive view of the state of your systems, and is an important component of a Security Operations Centre (SOC), where Cyber Security staff can monitor and respond to incidents.

The National Cyber Security Centre publishes a list of recommended security monitoring requirements: https://www.ncsc.gov.uk/files/NCSC_SOC_Feeds.pdf

Many smaller organisations out-source SOC, to a remote team and service — sometimes referred to as SOC-as-a-Service (SOCaaS). In this case you set up your devices to forward critical information to the remote service for a remote outside team to monitor, and be available to deal with incidents when they occur. A good outsourced SOC will cater rulesets to unique business or organisational needs, although standard rulesets are often applied in the first instance.

## Elastic (ELK) Stack as a SIEM {#elastic-stack-as-a-siem}

The core of a SIEM solution is the ability to collect, aggregate, and analyse a huge amount of data, in the form of event logs and other status information.

Elastic (ELK) Stack is open source, and one of the most popular search and analytics platforms, and can be used as the backbone of a SIEM solution; although other similar solutions exist (such as Splunk), including some that are more out-of-the-box ready SIEM solutions (such as Wazuh, which itself is based on Elastic Stack).

The core technologies that make up Elastic Stack are:

- Elasticsearch — search and analysis engine
- Logstash — server-side collection point for all kinds of data, such as logs
- Kibana — dashboard, visualisation, and query web interface
- Beats — various agents, which run on devices, feeding data to Logstash

![The components of the Elastic Stack][elastic-stack-components]

Elastic Stack has security features, including incident response management.

![Elastic Security detections view][elastic-security-1]

![Elastic Security timeline view][elastic-security-2]

![Elastic Security overview dashboard][elastic-security-3]

Image source: https://www.elastic.co/siem/

Many organisations make use of Elastic Stack as a SIEM, including Barclays' Cyber Security and defence platform.

As an introduction to ELK, in this lab we will look at how to centralise data sources, such as logs and security events, and query them (without the Security module, which you can explore further if you are interested).

## Using Auditbeat to ship system audit information {#using-auditbeat}

Auditbeat can be installed on servers and workstations to monitor the activities of users and processes. Auditbeat can detect changes to and access of critical and sensitive files, including programs and configurations.

Auditbeat can feed those events to Logstash in real time.

Auditbeat has modules for feeding/shipping various kinds of data:

- Auditd: this is Linux specific, using the Linux Audit Framework kernel feature to monitor activity
- System: monitors processes running, packages installed, users changing passwords
- File Integrity: detect file content changing

\==VM: On the desktop VM==, ==action: run:==

```bash
sudo less /etc/auditbeat/auditbeat.yml
```

> Note: Note that the auditd module is loaded, and looking for config files.

\==action: Create a rule file:==

```bash
sudo vi /etc/auditbeat/audit.rules.d/monitor.conf
```

\==action: Add a rule to the file to monitor for any change directly in the /etc/ directory:==

```
-w /etc/ -p wa -k config_change
```

\==action: Save and exit vi.==

\==action: Reload auditbeat:==

```bash
sudo service auditbeat restart
sudo service auditbeat status
```

\==action: Create a file /etc/test, and add some content.==

> Tip: `sudo vi /etc/test`

\==VM: On the siem_management VM:==

\==action: Open Firefox, and view the Kibana page== (`http://<siem_management IP address>:5601`, the IP address of the siem_management VM itself).

\==action: Click "Explore on my own".==

\==action: Click the Hamburger Menu== (![Kibana hamburger menu icon][kibana-hamburger-menu]) ==action: then "Discover".==

![The Kibana navigation menu][kibana-menu]

\==action: Click "Create index pattern".==

\==action: Enter:==

- Name: `auditbeat*`
- Timestamp field: `@timestamp`

![Creating an index pattern in Kibana][kibana-create-index-pattern]

\==action: Click "Create index pattern".==

\==action: Click the Hamburger Menu== (![Kibana hamburger menu icon][kibana-hamburger-menu]) ==action: then "Discover".==

You will be presented with a view of all the audit messages that have been collected.

\==action: Navigate through the page.==

\==action: Experiment by clicking on items in the timeline graph, and expanding the details below.==

\==VM: On the desktop VM==, ==action: edit or create some more files in /etc/.==

\==VM: On the siem_management VM==, ==action: refresh, and view the audit messages.==

### Monitoring identity and access {#monitoring-identity-and-access}

\==VM: On the desktop VM==, ==action: edit the audit rules:==

```bash
sudo vi /etc/auditbeat/audit.rules.d/monitor.conf
```

\==action: **Above** the existing rule, add some rules to monitor for identity related activity:==

```
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/shadow -p rwa -k identity
```

> Note: The format for these rules is `-w`, the file or directory to monitor, followed by `-p` for monitoring access with specific permissions (read, write, append), and `-k` to specify the key used to group these audit logs together.

\==action: Also add:==

```
# Unauthorized access attempts to files (unsuccessful).
-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -F key=access
-a always,exit -F arch=b32 -S open,creat,truncate,ftruncate,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -F key=access
-a always,exit -F arch=b64 -S open,truncate,ftruncate,creat,openat,open_by_handle_at -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 -F key=access
-a always,exit -F arch=b64 -S open,truncate,ftruncate,creat,openat,open_by_handle_at -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 -F key=access
```

> Note: `-a` specifies to monitor system calls, and in this case any failed access attempts will be logged, such as a user trying to access files they do not have permission to access.

\==action: Also add:==

```
# Executions.
-a always,exit -F arch=b64 -S execve,execveat -k exec

# External access (warning: these can be expensive to audit).
-a always,exit -F arch=b64 -S accept,bind,connect -F key=external-access
```

\==action: Reload auditbeat:==

```bash
sudo service auditbeat restart
sudo service auditbeat status
```

> Note: Restarting auditbeat can take a while (a few minutes).

\==action: Generate some audit logs:==

- Run some commands
- Attempt to access files you are not authorised to access, without sudo
- Read the shadow file (using sudo)
- Try using sudo and enter incorrect passwords (all 3 times)

### Visualising the data {#visualising-the-data}

\==VM: On the siem_management VM==, in the Discover view, ==action: navigate through your audit logs.==

\==action: Click the Hamburger Menu== (![Kibana hamburger menu icon][kibana-hamburger-menu]) ==action: then "Dashboard".==

![The Kibana navigation menu][kibana-menu]

It is helpful to visualise the audit data to make sense of what is happening in your logs.

\==action: Click "Create new dashboard", then "Create visualisation".==

\==action: Create a chart displaying an overview of the hosts that are being logged:== select the field `agent.hostname.keyword` and drag it onto the chart, then set the chart type from the dropdown to "Pie".

\==action: Click "Save and return"== (top right).

\==action: Create a chart displaying an overview of the types of events being logged:== select the field `event.category.keyword` and drag it onto the chart, then set the chart type from the dropdown to "Pie".

\==action: Click "Save and return"== (top right).

\==action: Experiment by dropping more than one field, and by applying filters.==

> Question: Design a helpful dashboard with a number of visualisations that highlight the security related events we have started to log. Show a screenshot of your dashboard, and document how and why you selected those fields and visualisation approaches.

### File integrity monitoring {#file-integrity-monitoring}

\==VM: On the desktop VM==, ==action: run:==

```bash
sudo vi /etc/auditbeat/auditbeat.yml
```

\==action: Add these lines to the end of the file== (exactly as is, including spacing):

```yaml
auditbeat.modules:
- module: file_integrity
  paths:
  - /bin
  - /usr/bin
  - /sbin
  - /usr/sbin
  - /etc
```

\==action: Restart the auditbeat service.==

\==action: Edit some files, and view the hashes as they are automatically logged.==

## Hackerbot {#hackerbot}

Once you have completed the above Elastic Stack tasks (with events being logged to Elastic Stack), interact with **Hackerbot**.

> Tip: You have to add rules to recursively monitor directories.

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Configure Elastic Stack to monitor /etc/ recursively for changes, then let the attack happen. Use Kibana to work out which config file was altered, and find the flag that was written into it.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once you have identified the file, ==action: answer with "answer *the full path of the file*"==.

Don't forget to ==action: save and submit any flags!==

## Additional challenges {#additional-challenges}

If you want to build on these skills and concepts further, here are some additional (unmarked) challenges for you to attempt:

- Configure filebeat to send changes to /var/log/messages to the siem_management VM. Here is a good resource: https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation-configuration.html
- Configure the siem_management VM to enable the xpack Security module, and explore creating incident detection rules (note that this requires changes to the way the ELK server is configured, and could take some considerable effort and self-directed troubleshooting).

## Conclusion {#conclusion}

In this lab you have experienced and learned a lot about:

- How log events are generated, processed and stored (especially on Linux systems, using Journal and Syslog).
- Practised some regular expressions.
- How audit information can be centralised, using a search stack such as Elastic Stack.
- Started to get familiar with the advantages of SIEM systems, and how they can be configured to collect important security events (including changes to files, attempts to access resources, user identity changes, and network connections), to present meaningful views and visualisations of what's happening across systems.

Well done! That's it for now!

[siem-overview]: {{ site.baseurl }}/assets/images/response_and_investigation/9_siem/siem-overview\.png [elastic-stack-components]: {{ site.baseurl }}/assets/images/response_and_investigation/9_siem/elastic-stack-components.png [elastic-security-1]: {{ site.baseurl }}/assets/images/response_and_investigation/9_siem/elastic-security-1.png [elastic-security-2]: {{ site.baseurl }}/assets/images/response_and_investigation/9_siem/elastic-security-2.png [elastic-security-3]: {{ site.baseurl }}/assets/images/response_and_investigation/9_siem/elastic-security-3.png [kibana-hamburger-menu]: {{ site.baseurl }}/assets/images/response_and_investigation/9_siem/kibana-hamburger-menu.png [kibana-menu]: {{ site.baseurl }}/assets/images/response_and_investigation/9_siem/kibana-menu.png [kibana-create-index-pattern]: {{ site.baseurl }}/assets/images/response_and_investigation/9_siem/kibana-create-index-pattern.png
