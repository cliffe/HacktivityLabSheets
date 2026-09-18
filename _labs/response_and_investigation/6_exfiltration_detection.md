---
title: "Exfiltration Detection: Data Loss Prevention with Snort"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Configure Snort to detect the exfiltration of sensitive data over the network, using text, regular expression, and hash-based matching, while fending off Hackerbot's live attacks."
overview: |
  In this lab, you will explore Data Loss Prevention (DLP) and exfiltration detection. Data loss prevention is a vital cybersecurity practice aimed at safeguarding sensitive information from unauthorised access or leakage. It is highly relevant in today's digital age, where data breaches and insider threats pose significant risks to organisations. This lab provides you with hands-on experience in setting up and configuring Snort, a popular Intrusion Detection System (IDS), to monitor network traffic and detect the unauthorised transfer of sensitive data.

  You will learn how to configure Snort to detect unauthorised data transfers and exfiltration. By editing Snort configuration files, you will set up monitoring rules that trigger alerts when sensitive data, like credit card details and national insurance numbers, are being transported over the network. You will also extend your rule to detect the transfer of a fake data file so that your rules are effective without revealing the actual sensitive content. To accomplish this, you'll explore various Snort rule techniques, such as text-based, regular expression-based, and hash-based matching, gaining an in-depth understanding of data loss prevention strategies. By the end of the lab, you'll have practical experience in setting up DLP measures using Snort, a valuable skill for protecting an organisation's sensitive data assets.

  This is a Hackerbot lab. Work through the lab sheet, then when prompted interact with Hackerbot.
tags: ["dlp", "snort", "ids", "exfiltration-detection", "network-monitoring", "regular-expressions", "hashing", "hackerbot"]
categories: ["response_and_investigation"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "F"
    topic: "Artifact Analysis"
    keywords: ["cryptographic hashing"]
  - ka: "SOIM"
    topic: "Monitor: Data Sources"
    keywords: ["network traffic"]
  - ka: "SOIM"
    topic: "Analyse: Analysis Methods"
    keywords: ["exfiltration detection / data loss prevention"]
  - ka: "NS"
    topic: "Network Defence Tools"
    keywords: ["packet filters", "intrusion detection systems", "intrusion prevention systems", "IDS rules creation"]
---

## Getting started {#getting-started}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- ids_monitor
- web_server (leave it running, you don't log into this through the GUI console; you may SSH into it later in the lab)
- desktop

All of these VMs need to be running to complete the lab.

\==action: Note the IP addresses of the ids_monitor and web_server VMs== from the VM list you were given when you claimed the VMs, or by running `ip a` inside each. You will need them below.

> Warning: **Ensure the ids_monitor VM allows promiscuous mode.** If you are completing this lab on managed infrastructure such as Leeds Beckett's oVirt, this should already be sorted, and the network mirrors all traffic between systems. If you have used SecGen to spin up VMs yourself, you need to ensure your VMs have permission to monitor networks using promiscuous mode. On VirtualBox, go to the Advanced network settings for the host-only network on the ids_monitor VM and enable promiscuous mode.

### Your login details for the "desktop" and "ids_monitor" VMs {#your-login-details}

\==VM: On the desktop and ids_monitor VMs==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the hackerbot_server or web_server through the GUI console, but all the VMs need to be running to complete the lab.

{% include hackerbot-intro.md role="task you with monitoring the network, and who will attack your systems" %}

## Getting Snort up and running {#getting-snort-up-and-running}

\==VM: On the ids_monitor VM:==

\==action: Confirm Snort's output== is set to something readable:

```bash
sudo vi /etc/snort/snort.conf
```

> Note: Editing using vi involves pressing "i" to insert/edit text, then *Esc*, ":wq" to write changes and quit.

\==action: Check for the following lines:==

```
output alert_fast
output log_tcpdump: tcpdump.log
```

```bash
sudo vi /etc/snort/snort.debian.conf
```

\==action: Check Snort's interface==, which will be ens19 (or as you identified earlier), and that the local network is set to your IP address range (or "any"):

> Note: Confirm the above, then exit vi (*Esc*, ":wq").

\==action: Restart Snort:==

```bash
sudo service snort stop
sudo service snort start
```

> Note: Using "reload" or "restart" may not update the interface.

Snort should now be running, monitoring network traffic for activity.

It can be helpful to monitor network traffic while writing IDS rules. You can start Wireshark with:

```bash
sudo wireshark &
```

Remember, you should add your rules to `/etc/snort/rules/local.rules`.

---

## Data loss prevention (DLP) {#data-loss-prevention-dlp}

Data loss prevention (DLP) involves monitoring network activity that indicates that sensitive information is being exfiltrated or handled incorrectly. Some DLP systems monitor local systems and data at rest (for example, HIDS), while others are focused on network traffic and data in motion (NIDS). Using DLP software can help to detect insecure processes in an organisation, such as storing sensitive data in unplanned or insecure places. It can also help to mitigate insider threat, and data exfiltration to remote attackers. A report by Bnet shows that 45 percent of employees take data when they change jobs, and data leakage and organisational doxing has become more frequent (for example, the Sony Pictures compromise).

Note that there is a variety of DLP solutions available, and the most robust enterprise solutions provide network monitoring (data in motion), file system monitoring (data at rest), and some DLP systems will also monitor local file transfers (for example, copying files to USB) to block exfiltration using local storage devices.

In order to be effective, an organisation must identify sensitive data in their organisation that should be monitored.

### Snort exfiltration detection (data in motion) {#snort-exfiltration-detection-data-in-motion}

#### Text-based exfiltration detection {#text-based-exfiltration-detection}

> Tip: You can include your sensitive data directly in a Snort rule. This is very closely related to the IDS rules lab, which will be a helpful resource. Consider using the `metadata:service` tag in your rule.

It is fine to monitor all ports, so long as your rule(s) detect transfer of the file.

#### Regular expression-based exfiltration detection {#regular-expression-based-exfiltration-detection}

Assuming the data you are protecting is sensitive, you likely don't want your Snort rules to contain direct copies of all your most sensitive data. For this reason, Snort rules can contain regular expressions to match against.

It is possible to write Snort rules that detect the transfer of the contents of your files, based on pattern matching, so that the Snort rule does not contain the sensitive parts of your document.

> Tip: Consider using the `pcre` keyword in your rule.

#### Hash-based exfiltration detection {#hash-based-exfiltration-detection}

Assuming the data you are protecting is sensitive, you likely don't want your Snort rules to contain direct copies of all your most sensitive data. For this reason, Snort rules can contain hashes to match against.

Using newer versions of Snort it is possible to write Snort rules that detect the transfer of the contents of your files, based on hashes (using the `protected_content` keyword), so that the Snort rule does not contain any plain text of your document.

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Write one or more Snort rules that detect the sensitive client list being transferred unencrypted, using text-based matching. Hackerbot gives you the file to protect and the alert message to use in the chat.

Do any necessary preparation, then when you are ready for the bot to complete the attack, ==action: say 'ready'==.

> Note: Add your rule to `/etc/snort/rules/local.rules` on the ids_monitor VM, using the exact alert message Hackerbot gave you in the chat.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Update your rule to use a regular expression, so that it matches the data without containing any of it. Hackerbot gives you the files to cover and the alert message to use in the chat.

Do any necessary preparation, then when you are ready for the bot to complete the attack, ==action: say 'ready'==.

There is a quiz to complete: once Hackerbot asks you the question, you can ==action: answer '*YOURANSWER*'==.

> Note: The question asks you to find where else the sensitive data is at rest across the VMs, using regular expression searches (don't use hashes). Hint: search the filesystem of a VM you can already reach for a copy of `clients.csv` left somewhere temporary.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #3 {#hackerbot-attack-3}

You can skip the bot to here, by saying **goto 3**.

> Hackerbot: Update your rule again to use hash-based matching, so that the rule holds no sensitive data at all. Hackerbot gives you the file and the alert message in the chat.

Do any necessary preparation, then when you are ready for the bot to complete the attack, ==action: say 'ready'==.

> Hint: You don't know where in the packet the protected content will be, so you can first have a `content` rule based on something you know will come first, and specify a `distance` between that and the `protected_content`.

Don't forget to ==action: save and submit any flags!==

## Resources {#resources}

Martin Roesch (n.d.) **Chapter 2:** Writing Snort Rules - How to Write Snort Rules and Keep Your Sanity. In: *Snort Users Manual*. Available from: <[http://www.snort.org.br/documentacao/SnortUsersManual.pdf](http://www.snort.org.br/documentacao/SnortUsersManual.pdf)>

