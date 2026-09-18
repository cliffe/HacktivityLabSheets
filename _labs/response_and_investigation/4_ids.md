---
title: "Intrusion Detection and Prevention Systems: Configuration and Monitoring using Snort"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Learn network monitoring and intrusion detection using Tcpdump, Wireshark, and Snort, while detecting and responding to Hackerbot's live network attacks."
overview: |
  Intrusion Detection and Prevention Systems (IDS/IPS) are important components of network security, helping organisations monitor and defend against malicious activities and unauthorised access. This lab focuses on network monitoring basics and hands-on experience with tools like Tcpdump, Wireshark, and Snort, all useful for detecting and responding to potential threats. Network monitoring is a foundational practice in cyber security, as it allows you to observe network traffic and identify any suspicious or unwanted behaviour. In this lab, you will gain practical experience by monitoring live network traffic, setting up Snort to detect network attacks, and analysing the captured data. By the end of this lab, you will have a better understanding of how IDS/IPS systems work and how to configure and use them effectively to enhance network security.

  During this hands-on lab, you will learn how to set up network monitoring tools like Tcpdump and Wireshark to observe live network traffic. You will use these tools to detect specific strings in network packets and identify port scanning attempts on a web server. Additionally, you will configure Snort, a popular IDS, to monitor network traffic to detect network activities of interest. As part of your practical exercises, you will trigger Snort alerts by sending ICMP pings and monitor the alerts generated. Throughout the lab, you will also interact with Hackerbot, which will simulate network attacks, and you will need to use the tools you've learned to detect and respond to these simulated attacks. By completing these tasks, you will develop practical skills in network monitoring and intrusion detection.

  This is a Hackerbot lab. Work through the lab sheet, then when prompted interact with Hackerbot.
tags: ["ids", "ips", "snort", "tcpdump", "wireshark", "network-monitoring", "intrusion-detection", "hackerbot"]
categories: ["response_and_investigation"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "SOIM"
    topic: "Monitor: Data Sources"
    keywords: ["network traffic"]
  - ka: "SOIM"
    topic: "Analyse: Analysis Methods"
    keywords: ["misuse detection", "anomaly detection"]
  - ka: "SOIM"
    topic: "Execute: Mitigation and Countermeasures"
    keywords: ["intrusion prevention systems"]
  - ka: "NS"
    topic: "Network Defence Tools"
    keywords: ["packet filters", "intrusion detection systems"]
  - ka: "MAT"
    topic: "Malware Detection"
    keywords: ["attack detection"]
---

## Getting started {#getting-started}

### VMs in this lab {#vms-in-this-lab}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- ids_monitor
- web_server
- desktop

All of these VMs need to be running to complete the lab.

> Note: The desktop and web_server VMs are configured to mirror their network traffic to the ids_monitor VM, so ids_monitor can see traffic that isn't destined for it, without you needing to configure promiscuous mode yourself.

### Your login details for the "desktop" and "ids_monitor" VMs {#your-login-details}

\==VM: On the desktop and ids_monitor VMs==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the hackerbot_server or web_server, but all the VMs need to be running to complete the lab.

### Note the IP addresses of your VMs {#note-the-ip-addresses-of-your-vms}

Throughout this lab you will need the IP addresses of the ids_monitor and web_server VMs.

\==VM: On the ids_monitor VM==, ==action: open a terminal and run:==

```bash
ip -4 -o a s
```

> Note: The `ip a s` command lists all local IP addresses, `-4` filters to only show IPv4, and `-o` sets one-line output mode. Note the IP address (and the name of the network interface, typically something like `ens19`) — this is your **ids_monitor IP address**.

\==VM: On the web_server VM==, ==action: run the same command== and note the IP address — this is your **web_server IP address**.

> Tip: Wherever this lab sheet says "the ids_monitor IP address" or "the web_server IP address", ==edit: substitute the address you noted down==.

{% include hackerbot-intro.md role="task you to monitor the network and will attack your systems" %}

## Network monitoring basics {#network-monitoring-basics}

It is important for an organisation to monitor their network for detecting unwanted behaviour, such as malicious attacks or organisational resources being misused.

> Note: Please take care to observe the instructions on which VM each command should be run from. There is quite a bit of switching between VMs in this lab.

### Tcpdump {#tcpdump}

This section gives a quick overview of the basics of network monitoring, using tools such as Tcpdump and Wireshark. Keep in mind that these are important foundations, and we will quickly build on these.

\==VM: On the ids_monitor VM==, to view live network traffic, ==action: start tcpdump:==

```bash
sudo tcpdump -i ens19
```

> Note: Where `ens19` is the name of the interface you identified earlier (it may be different in your environment).

With tcpdump still running, \==VM: from the desktop VM==, ==action: perform a ping to the ids_monitor VM:==

```bash
ping <ids_monitor IP address>
```

> Note: Tcpdump displays the network activity taking place, including the pings, and various TCP connections and ARP requests. Depending on your environment you might also see traffic between various other VMs.

\==action: Stop the ping== with Ctrl-C.

The ids_monitor VM's network interface has been configured so that it can view traffic destined for other systems on the network, not just traffic destined for itself.

Test this, \==VM: from the desktop VM== ==action: ping the web_server:==

```bash
ping <web_server IP address>
```

> Note: If your network is configured correctly, from the Tcpdump running on the ids_monitor you should see the pings between these separate VMs (the desktop, and the web_server). Take the time to confirm that this is working. If it is not showing this traffic, but did show the last output, you need to configure the ids_monitor to be able to view the network traffic.

\==action: Once you have seen tcpdump in action displaying these packets, press Ctrl-C to exit.==

Tcpdump can format the output in various ways, showing various levels of detail.

\==VM: On the ids_monitor VM==, ==action: run:==

```bash
sudo tcpdump -A -i ens19
```

> Note: This shows the packet **content** without the information about the source and destination. This content will contain binary data that can be difficult to understand.

When you ==action: access a web page in a browser on the desktop VM==, Tcpdump will display the content, so long as the traffic is not SSL encrypted (for example, so long as the URL doesn't start with http**s**://). Depending on the webserver and browser, the content may be compressed (but not encrypted) to save bandwidth.

\==VM: From the desktop VM==, use command line tools to ==action: view the webserver pages:==

```bash
curl <web_server IP address>
```

\==action: Ping the web_server again== and observe the output.

\==action: Stop tcpdump== (Ctrl-C) on the ids_monitor VM once you have observed the output.

\==action: Run the following== command \==VM: on the ids_monitor:==

```bash
sudo tcpdump -v -i ens19
```

> Note: The above is even more verbose, showing lots of detail about the network traffic.

\==action: Try the above again.== Note the very detailed output.

It is possible to write tcpdump network traffic to storage, so that it can be analysed later:

```bash
sudo tcpdump -w /tmp/tcpdump-output -i ens19
```

While that is running, \==VM: access a web page from Firefox on the desktop VM==, ==action: browse to== `http://<web_server IP address>` (in a new tab).

\==action: Close tcpdump== (Ctrl-C).

To view the file containing the tcpdump output on the ids_monitor VM type:

```bash
less /tmp/tcpdump-output
```

> Note: Press "y" to see the output if you are warned that it may be a binary file. You should be able to PageUp and PageDown through the file. Press "Q" to quit when ready.

\==tip: Run `man tcpdump` and read about the many options for output and filtering.==

### Tcpdump filtering and Wireshark {#tcpdump-filtering-and-wireshark}

We can also use tcpdump to do some simple monitoring of the network traffic to detect certain key words.

\==VM: On the ids_monitor VM==, ==action: run:==

```bash
kdesudo wireshark &
```

> Note: For this exercise you can ignore the warning about running Wireshark as root, or read online to learn to use setcap to grant Wireshark more specific privileges.

And in another command tab:

```bash
sudo tcpdump -A -i ens19 \| grep "GET"
```

In Wireshark, ==action: choose the network interface card== (such as ens19) then click the start icon, to ==action: start monitoring traffic==. Generate some traffic and explore how to ==action: view it using Wireshark==.

You can also open the captured network traffic in Wireshark.

\==VM: Open a web browser on the desktop VM==, and ==action: visit== `http://<web_server IP address>`. Note that tcpdump captures *most* network content, and grep can be used to filter it down to lines that are interesting to us.

> Note: If you don't see traffic generated from this, you may need to press Ctrl-F5 to force the browser not to load from a local cache.

\==action: Right click on an HTTP request in Wireshark and "Follow", "TCP Stream".==

\==action: Right click the same HTTP request in Wireshark and "Follow", "HTTP Stream".==

> Question: Explain the differences in the TCP and HTTP stream view for the same web traffic.

Note that making sense of network traffic information using tcpdump and/or Wireshark is possible (and is a common sys-admin task), but the output is too noisy to be constantly and effectively monitored by a human to detect security incidents. Therefore we can use an IDS such as Snort to monitor and analyse the network traffic to detect activity that it is configured to alert.

\==action: Make sure tcpdump is stopped== (Ctrl-C).

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Monitor the network traffic using Tcpdump or Wireshark, and look out for a string starting with the value Hackerbot gives you in the chat.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

### Watching for a port scan {#watching-for-a-port-scan}

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Monitor the network traffic, and look out for attempts to scan your webserver. You need to identify what port the connection attempt is to.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the port number*"==.

Don't forget to ==action: save and submit any flags!==

## Intrusion detection system (IDS) monitoring basics {#ids-monitoring-basics}

Continuing \==VM: on the ids_monitor VM:==

\==action: Confirm Snort's output is set to something readable:==

```bash
sudo vi /etc/snort/snort.conf
```

> Note: Editing using vi involves pressing "i" to insert/edit text, then Esc, ":wq" to write changes and quit.

\==action: Check for the following lines:==

```
output alert_fast
output log_tcpdump: tcpdump.log
```

```bash
sudo vi /etc/snort/snort.debian.conf
```

\==action: Check Snort's interface==, which will be ens19 (or as you identified earlier), and confirm the local network is set to your IP address range (or "any"). Confirm the above, and exit vi (Esc, ":wq").

\==action: Start Snort:==

```bash
sudo service snort stop
sudo service snort start
```

> Note: Using "reload" or "restart" may not update the interface.

Snort should now be running, monitoring network traffic for activity.

\==action: Do an nmap port scan of the web_server== VM (\==VM: from the desktop VM==):

```bash
sudo nmap -sX <web_server IP address>
```

This should trigger a logged alert from Snort, which is stored in an alerts log file.

\==VM: From the ids_monitor VM==, ==action: follow the Snort alert log file== by running (you may like to do this from a new tab):

```bash
sudo tail -f /var/log/snort/alert
```

> Note: The tail program will wait for new alerts to be written to the file, and will display them as they are logged. (Ctrl-C to exit).

> Question: What does the `-sX` in the nmap command mean? Does the log match what happened? Are there any false positives (alerts that describe things that did not actually happen)?

\==hint: Try another type of port scan from the desktop VM.== (Hint: `man nmap`).

\==action: Press Ctrl-C to stop the alert tail process==, if it did not do so automatically.

The Snort configuration file is also configured to output a "tcpdump" formatted network capture (`output log_tcpdump: tcpdump.log`).

\==action: Run the following command to view the contents of the log:==

```bash
sudo ls /var/log/snort/
sudo tcpdump -r /var/log/snort/tcpdump.log.XXXXX
```

> Note: Where XXXXX is one of the logs shown from the first command.

You can use tcpdump's various flags to change the way it is displayed, or you could even open the logged network activity in Wireshark.

### Configuring Snort {#configuring-snort}

\==VM: On the ids_monitor VM==, ==action: edit `/etc/snort/snort.conf`==; for example:

```bash
sudo vi /etc/snort/snort.conf
```

> Note: Editing using vi involves pressing "i" to insert/edit text, then Esc, ":wq" to write changes and quit.

Scroll through the config file and take notice of these details:

- In a production environment you would configure Snort to correctly identify which traffic is considered LAN traffic, and which IP addresses are known to run various servers (this is also configured in snort.debian.conf). In this case, we will leave these settings as is.
- Note the line `var RULE_PATH /etc/snort/rules`: this is where the IDS signatures are stored.
- Note the presence of a Back Orifice detector preprocessor "bo". Back Orifice was a Windows Trojan horse that was popular in the 90s.
- Note the "sfportscan" preprocessor (is it enabled?), which can detect various kinds of port scans.
- The "arpspoof" preprocessor is described as experimental, and is not enabled by default.
- Towards the end of the config file are "include" lines, which specify which of the rule files in RULE_PATH are in effect. As is common, lines beginning with "#" are ignored, which is used to list disabled rule files. There are rule files for detecting known exploits, attacks against services such as DNS and FTP, denial of service (DoS) attacks, and so on.

\==action: Add the following line below the other include rules (at the end of the file):==

```
include $RULE_PATH/my.rules
```

\==action: Save your changes to snort.conf.== (For example, in vi, press Esc, then type ":wq").

> Tip: You may find it easier to use Esc, then type ":w" to write your changes to disk and then type ":q" to exit (or "x" as a shorthand for "wq").

\==action: Run this command, to create your new rule file:==

```bash
sudo touch /etc/snort/rules/my.rules
```

\==action: Edit the file.== For example:

```bash
sudo vi /etc/snort/rules/my.rules
```

\==action: Add this line (with your own name), and save your changes:==

```
alert icmp any any -> any any (msg: "Your-name: ICMP Packet found"; sid:1000000; rev:1;)
```

> Note: For example, `alert icmp any any -> any any (msg: "Cliffe: ICMP Packet found"; sid:1000000; rev:1;)`.

Now that you have new rules, tell Snort to ==action: reload its configuration:==

```bash
sudo service snort stop
sudo service snort start
```

> Note: If after attempting a reload, Snort fails to start, then you have probably made a configuration mistake, so check the log for details by running: `tail /var/log/syslog`.

Due to the new rule you have just applied, sending a simple ICMP Ping (typically used to troubleshoot connectivity) will trigger a Snort alert.

\==action: Try it, from the desktop VM, ping the web_server:==

```bash
ping <web_server IP address>
```

Check for the Snort alert. You should see that the ping was detected, and our new message was added to the alerts log file.

#### Hackerbot Attack #3 {#hackerbot-attack-3}

You can skip the bot to here, by saying **goto 3**.

> Hackerbot: Your webserver is about to be scanned/attacked. Make sure you are using Wireshark and Snort to monitor your network...

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer scan"== or "answer attack", whichever it was.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #4 {#hackerbot-attack-4}

You can skip the bot to here, by saying **goto 4**.

> Hackerbot: Your webserver is about to be scanned/attacked. Make sure you are using Snort and Wireshark to monitor your network... This may take a while (a few minutes), please be patient.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the vulnerable software*"==.

\==hint: Look at the network traffic for the name of the service that was exploited.==

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #5 {#hackerbot-attack-5}

You can skip the bot to here, by saying **goto 5**.

> Hackerbot: Your webserver is about to be scanned/attacked. Make sure you are using Snort to monitor your network...

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the kind of scan*"==.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #6 {#hackerbot-attack-6}

You can skip the bot to here, by saying **goto 6**.

> Hackerbot: Your webserver is about to be scanned/attacked. Use Tcpdump and/or Wireshark to view the behaviour of the attacker.

> Flag: There is a flag to be found over the wire — watch the network traffic for it.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

## Resources {#resources}

Martin Roesch (n.d.) **Chapter 2:** Writing Snort Rules - How to Write Snort Rules and Keep Your Sanity. In: *Snort Users Manual*. Available from: [http://www.snort.org.br/documentacao/SnortUsersManual.pdf](http://www.snort.org.br/documentacao/SnortUsersManual.pdf)

