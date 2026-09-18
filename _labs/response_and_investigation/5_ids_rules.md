---
title: "IDS: Writing Rules"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Configure Snort and write custom intrusion detection rules to monitor network traffic, using tcpdump and Wireshark to analyse packets, while responding to Hackerbot's live challenges."
overview: |
  In this lab on Intrusion Detection and Prevention Systems, you will explore network security by learning how to configure and monitor a network using Snort, a popular open-source intrusion detection system. This lab will guide you through the process of setting up Snort, and creating custom intrusion detection rules.

  Throughout this lab, you will gain hands-on experience in configuring Snort to monitor network traffic. You will learn how to create custom Snort rules to detect specific network activities, and use Wireshark to capture and analyse network packets. The lab will also present you with a series of Hackerbot challenges, where you will apply your knowledge to detect and respond to various network attacks. For example, you will create Snort rules to detect attempts to access specific ports, monitor unencrypted email authentication, and more. By the end of this lab, you will have a solid understanding of intrusion detection and prevention systems, as well as practical experience in configuring and monitoring them to safeguard your network from potential threats.

  This is a Hackerbot lab. Work through the lab sheet, then when prompted interact with Hackerbot.
tags: ["ids", "snort", "intrusion-detection", "network-security", "wireshark", "tcpdump", "hackerbot"]
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
  - ka: "NS"
    topic: "Network Defence Tools"
    keywords: ["packet filters", "intrusion detection systems", "IDS rules creation"]
  - ka: "MAT"
    topic: "Malware Detection"
    keywords: ["attack detection"]
---

## Getting started {#getting-started}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- ids_monitor
- web_server (leave it running, you don't log into this)
- desktop

All of these VMs need to be running to complete the lab.

\==action: Note the IP addresses of the ids_monitor, web_server, and hackerbot_server VMs== — ==edit: given to you when you claimed the VMs==. You will need these throughout the lab.

> Warning: Ensure the ids_monitor VM is allowed promiscuous mode. If you have used SecGen to spin up VMs yourself, you need to ensure the ids_monitor VM's network adapter has permission to monitor network traffic using promiscuous mode (on VirtualBox, this is set under the Advanced network settings for the host-only network on the ids_monitor VM).

### Your login details for the "desktop" and "ids_monitor" VMs {#your-login-details-for-the-desktop-and-ids-monitor-vms}

\==VM: On the desktop and ids_monitor VMs==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the hackerbot_server or web_server, but all the VMs need to be running to complete the lab.

{% include hackerbot-intro.md role="task you to monitor the network, and will attack your systems" %}

## Getting Snort up and running {#getting-snort-up-and-running}

\==VM: On the ids_monitor VM==:

\==action: Change Snort's output== to something more readable:

```bash
sudo vi /etc/snort/snort.conf
```

> Note: Editing using vi involves pressing "i" to insert/edit text, then *Esc*, then ":wq" to write changes and quit.

\==action: Add the following line:==

```
output alert_fast
```

\==action: Change Snort's interface== to the interface with the IP address of the ids_monitor VM (likely changing eth0 to ens3), and set the local network to your IP address range (or "any"):

```bash
sudo vi /etc/snort/snort.debian.conf
```

> Tip: If you are not sure which interface to use, list the interfaces with `ifconfig` or `ip a s`. Set the interface and HOME network range, and exit vi (Esc, ":wq").

\==action: Restart Snort:==

```bash
sudo service snort stop
sudo service snort start
```

> Note: Using "reload" or "restart" may not update the interface.

Snort should now be running, monitoring network traffic for activity.

It can be helpful to monitor network traffic while writing IDS rules. You can start Wireshark with:

```bash
kdesudo wireshark
```

## Networking concepts (potentially revision) {#networking-concepts-potentially-revision}

### The Internet protocol suite {#the-internet-protocol-suite}

Modern network traffic (such as the Internet) typically uses the Internet protocol suite set of communications protocols.

The Internet protocol suite has four abstraction layers:

> * "**The application layer** is the scope within which applications create user data and communicate this data to other applications on another or the same host. The applications, or processes, make use of the services provided by the underlying, lower layers, especially the Transport Layer which provides reliable or unreliable pipes to other processes. The communications partners are characterized by the application architecture, such as the client-server model and peer-to-peer networking. This is the layer in which all higher level protocols, such as SMTP, FTP, SSH, HTTP, operate. Processes are addressed via ports which essentially represent services.
> * **The transport layer** performs host-to-host communications on either the same or different hosts and on either the local network or remote networks separated by routers. It provides a channel for the communication needs of applications. UDP is the basic transport layer protocol, providing an unreliable datagram service. The Transmission Control Protocol provides flow-control, connection establishment, and reliable transmission of data.
> * **The internet layer** has the task of exchanging datagrams across network boundaries. It provides a uniform networking interface that hides the actual topology (layout) of the underlying network connections. It is therefore also referred to as the layer that establishes internetworking, indeed, it defines and establishes the Internet. This layer defines the addressing and routing structures used for the TCP/IP protocol suite. The primary protocol in this scope is the Internet Protocol, which defines IP addresses. Its function in routing is to transport datagrams to the next IP router that has the connectivity to a network closer to the final data destination.
> * **The link layer** defines the networking methods within the scope of the local network link on which hosts communicate without intervening routers. This layer includes the protocols used to describe the local network topology and the interfaces needed to effect transmission of Internet layer datagrams to next-neighbor hosts."
(https://en.wikipedia.org/wiki/Internet_protocol_suite#Abstraction_layers)

### Common services and (application layer) protocols {#common-services-and-application-layer-protocols}

In order to make sense of network traffic, it is important to be aware of common protocols and port numbers.

| TCP/UDP | Port(s) | Service |
|---------|---------|---------|
| tcp     | 20/21   | File Transfer Protocol (FTP) (RFC 959) |
| tcp     | 22      | Secure Shell (SSH) (RFC 4250-4256) |
| tcp     | 23      | Telnet (RFC 854) |
| tcp     | 25      | Simple Mail Transfer Protocol (SMTP) (RFC 5321) |
| tcp/udp | 53      | Domain Name System (DNS) (RFC 1034-1035) |
| udp     | 69      | Trivial File Transfer Protocol (TFTP) (RFC 1350) |
| tcp     | 80      | Hypertext Transfer Protocol (HTTP) (RFC 2616) |
| tcp     | 110     | Post Office Protocol (POP) version 3 (RFC 1939) |
| tcp/udp | 137/138/139 | NetBIOS (RFC 1001-1002) |
| tcp     | 143     | Internet Message Access Protocol (IMAP) (RFC 3501) |
| tcp/udp | 161/162 | Simple Network Management Protocol (SNMP) (RFC 1901-1908, 3411-3418) |
| tcp/udp | 389     | Lightweight Directory Access Protocol (LDAP) (RFC 4510) |
| tcp     | 443     | Hypertext Transfer Protocol over SSL/TLS (HTTPS) (RFC 2818) |
| tcp/udp | 636     | Lightweight Directory Access Protocol over TLS/SSL (LDAPS) (RFC 4513) |
| tcp     | 989/990 | FTP over TLS/SSL (RFC 4217) |
| tcp     | 6660-6669 | Internet Relay Chat (IRC) |

Please ensure you understand what each of these ports are used for. If you are not aware of what these protocols are, do some online reading.

> Tip: This may be a useful overview resource: http://www.pearsonitcertification.com/articles/article.aspx?p=1868080

Keep in mind that in recent years more and more network based functionality is moving to be hosted via Web protocols (HTTP and HTTPS).

### Using Wireshark {#using-wireshark}

Note that in Wireshark you can view individual packets, including IP and TCP headers. Wireshark also has support for viewing TCP streams, so that you can view the traffic at the application layer as it is sent between the two computers (such as, client and server). (Simply right-click on a TCP entry and select *Follow > TCP Stream*.)

\==VM: On the ids_monitor VM==:

\==action: Start Wireshark:==

```bash
kdesudo wireshark
```

> Note: For this exercise you can ignore the warnings about running Wireshark as root, or read online to learn to use setcap to grant Wireshark more specific privileges.

\==action: Start capturing==, listening to the interface with the IP address of the ids_monitor VM.

> Tip: If you are not sure, list the interfaces with `ifconfig` or `ip a s`.

\==VM: On the desktop VM==:

While Wireshark is listening, \==action: access a web page from Firefox, browse to the web_server's IP address== (in a new tab).

\==VM: On the ids_monitor VM==:

Note that Wireshark uses colouring to make it easier to view traffic at a glance. \==action: View the colouring rules== via *View > Coloring Rules*.

In Wireshark \==action: use display filters== to narrow down the packets displayed. At the top of the Wireshark window, enter `tcp.port == 80`, and press Enter.

Right click the Web traffic, and select *Follow TCP Stream*.

> Note: The website request starts with the client sending "GET /"...

Note that you can also view the unzipped version of the content in Wireshark. In the view below the list of packets, \==action: expand the "Line-based text data: text/html" heading==.

\==question: Log Book Question: What is the difference between these views?==

Also experiment with using Wireshark display filters of `http` and `irc`.

## Writing your own Snort rules {#writing-your-own-snort-rules}

Snort is primarily designed as a signature-based IDS. Snort monitors the network for matches to rules that indicate activity that should trigger an alert. You have now seen Snort detect a few types of activity. Next you will apply more complicated rules, and create your own.

You may find external reference guides to writing Snort rules helpful. See the resources section below, and Google may come in handy (from outside the VMs).

In general, rules are defined on one line (although, they can break over lines by using `\`), and take the form of:

**header** (**body**)

where header = "**action** (such as *log* or *alert*) **protocol** (*ip*,*tcp*,*udp*,*icmp*,*any*) **source_IP** **source_port** **direction** (->,<>) **destination_IP** **destination_port**"

> Tip: For example: `alert tcp any any -> any any` to make an alert for *any* TCP traffic, or `alert tcp any any -> WEBSERVER-IP 80` to make an alert for connections to unencrypted Web on the web_server VM's IP address.

and body = "**option; option: "parameter"; ...**"

The most common options are:

> `msg: "message to display"`

and, to search the packet's content:

> `content: "some text to search for"`

To set the type of alert:

> `classtype:misc-attack`
>
> (where *misc-attack* is defined in `/etc/snort/classification.config`)

To give a unique identifier and revision version number:

> `sid:1000001; rev:1`

So for example the body could be:

> `msg: "Website access"; content: "GET"; sid:1000001; rev:1;`

And bringing all this together a Snort rule could read:

> `alert tcp any any -> WEBSERVER-IP 80 (msg: "Website access abc123"; content: "GET /"; sid:1000001; rev:1;)`

\==VM: On the ids_monitor VM==:

\==action: Add this rule== to `/etc/snort/rules/local.rules` (substituting the web_server's IP address, and any short random string of your choosing in place of `abc123`):

```bash
alert tcp any any -> WEBSERVER-IP 80 (msg: "Website access abc123"; content: "GET /"; sid:1000001; rev:1;)
```

> Tip: Run `vi /etc/snort/rules/local.rules`. Remember press 'i' to enter insert mode, make your changes, press Esc, then type ':wq' to write your changes and quit vi.

\==action: Restart snort:==

```bash
sudo service snort restart
```

\==action: Test the new rule...==

\==VM: On the desktop VM==:

While Wireshark is listening, \==action: access a web page from Firefox, browse to the web_server's IP address== (in a new tab).

\==VM: On the ids_monitor VM==:

\==action: View the Snort alert file, to confirm your new rule generated an alert:==

```bash
sudo tail /var/log/snort/alert
```

> Note: The output should include the alert, with your random string. Note that Hackerbot will instruct you to include random strings such as this, in the alerts.
>
> In this case, the website may have resulted in a few HTTP connections, therefore triggering the rule a few times. If you do not see the alert, try creating a rule that triggers on all IP traffic, to confirm Snort is working correctly.

To view the alerts in real-time you can run this command in a console tab:

```bash
sudo tail -f /var/log/snort/alert
```

> Tip: -f outputs appended data as the file grows.

\==question: Log Book Question: Browse the existing rules in `/etc/snort/rules` and describe how one of the existing rules works.==

> Tip: Don't forget to reload Snort each time you change your rules. Use unique sid values for each rule.

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Your webserver is about to be scanned/attacked. Use Tcpdump and/or Wireshark to view the behaviour of the attacker. There is a flag to be found over the wire.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

> Note: Watch the traffic between Hackerbot and your web_server VM using Wireshark or tcpdump on the ids_monitor VM — the flag is hidden in the network traffic of the attack itself.

Don't forget to \==action: save and submit any flags!==

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Create a Snort rule that detects any TCP connection attempt to a TCP port on the web_server. The alert must include a message.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will tell you the exact port number to detect, and the exact message your alert must include. Your rule should fire exactly once (for the connection attempt, not more), so it should not require content inspection.

Don't forget to \==action: save and submit any flags!==

#### Hackerbot Attack #3 {#hackerbot-attack-3}

You can skip the bot to here, by saying **goto 3**.

> Hackerbot: Create a Snort rule that detects any packet with specific contents sent to the web_server. The alert must include a message.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will tell you the exact packet content to detect, and the exact message your alert must include. This time your rule needs to inspect packet content, not just detect a connection attempt — it must trigger exactly once.

Don't forget to \==action: save and submit any flags!==

#### Hackerbot Attack #4 {#hackerbot-attack-4}

You can skip the bot to here, by saying **goto 4**.

> Hackerbot: Create a Snort rule that detects any TCP connection attempt to a named service (just the connection attempt, does not require content inspection) on the web_server. The alert must include a message.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will name a service (such as FTP, Telnet, SMTP, HTTP, POP3, IMAP, SNMP, LDAP, HTTPS, or LDAPS) and give you the exact message your alert must include. Look up the port number(s) for that service.

Don't forget to \==action: save and submit any flags!==

#### Hackerbot Attack #5 {#hackerbot-attack-5}

You can skip the bot to here, by saying **goto 5**.

> Hackerbot: Create a Snort rule that detects any TCP connection attempt to a named service (just the connection attempt, does not require content inspection) on the web_server. The alert must include a message.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

> Note: As with the previous attack, Hackerbot will name a different service and give you a new message to include.

Don't forget to \==action: save and submit any flags!==

#### Hackerbot Attack #6 {#hackerbot-attack-6}

You can skip the bot to here, by saying **goto 6**.

> Hackerbot: Create a Snort rule that detects any TCP connection attempt to a named service (just the connection attempt, does not require content inspection) on the web_server. The alert must include a message.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

> Note: As with the previous two attacks, Hackerbot will name a different service and give you a new message to include.

Don't forget to \==action: save and submit any flags!==

#### Hackerbot Attack #7 {#hackerbot-attack-7}

You can skip the bot to here, by saying **goto 7**.

> Hackerbot: Create a Snort rule that detects any unencrypted POP3 email *user authentication attempt* (someone trying to log in), to a mail server on the web_server. The alert must include a message. Up to three flags will be awarded, based on the quality of the rule.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

> Hint: Hackerbot will connect twice — once with a valid username and password, once with an invalid one. Your rule should fire only on the genuine login attempt, and should fire exactly once. Consider case sensitivity, and whether the rule should also classify the alert (see `classtype` above) to detect user authentication specifically, rather than just any POP3 traffic.

Don't forget to \==action: save and submit any flags!==

#### Hackerbot Attack #8 {#hackerbot-attack-8}

You can skip the bot to here, by saying **goto 8**.

> Hackerbot: Create a Snort rule that detects access to the web_server's website, but NOT access to its `/contact.html` page. The alert must include a message.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

> Hint: Hackerbot will access the site's home page, then `/contact.html`. Your rule needs to inspect the request content to distinguish between the two, and should fire exactly once.

Don't forget to \==action: save and submit any flags!==

## Resources {#resources}

Martin Roesch (n.d.) **Chapter 2:** Writing Snort Rules - How to Write Snort Rules and Keep Your Sanity. In: *Snort Users Manual*. Available from: <http://www.snort.org.br/documentacao/SnortUsersManual.pdf>

