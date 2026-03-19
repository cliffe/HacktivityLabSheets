---
title: "Network Security Fundamentals: Network Design, Segmentation, NAT, DMZ & Firewalls"
author: ["Tom Shaw"]
license: "CC BY-SA 4.0"
description: "Learn network security fundamentals through hands-on exercises including network reconnaissance, firewall rule analysis, NAT investigation, and DMZ security assessment."
overview: |
  In this lab you will explore fundamental network security concepts through hands-on practical exercises. You will investigate how networks are structured, how segmentation and firewalling are used to isolate parts of a network, how Network Address Translation (NAT) works, and the role of a Demilitarised Zone (DMZ) in protecting internal services. 
tags: ["network-security", "iptables", "nmap", "nat", "dmz", "firewalls", "segmentation"]
categories: ["network_security"]
type: ["ctf-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "NS"
    topic: "Network Security Fundamentals"
    keywords: ["NETWORK SEGMENTATION", "DEMILITARISED ZONE (DMZ)", "NETWORK ADDRESS TRANSLATION (NAT)", "FIREWALLS", "IPTABLES", "DEFAULT DENY"]
  - ka: "NS"
    topic: "Network Defence"
    keywords: ["perimeter security", "firewall configuration", "stateful packet inspection"]
---

## General notes about the labs {#general-notes}

Often the lab instructions are intentionally open-ended, and you will have to figure some things out for yourselves. This module is designed to be challenging, as well as fun!

However, we aim to provide a well planned and fluent experience. If you notice any mistakes in the lab instructions or you feel some important information is missing, please let us know and we will try to address any issues.

## Preparation {#preparation}

> Action: For all of the labs in this module, start by logging into Hacktivity.

==action: Make sure you are signed up to the module, claim a set of VMs for the network security environment, and start all of your VMs.==

Feel free to read ahead while the VMs are starting.

==VM: Interact with the workstation VM==.

==action: Login to the workstation VM==.

## Lab environment {#lab-environment}

Your environment consists of the following VMs, spread across three separate network segments:

| VM | Hostname | Network segment | Role |
|---|---|---|---|
| **workstation** | `workstation` | Internal LAN (10.0.1.0/24) | Your starting point — a Linux desktop |
| **server** | `server` | Internal LAN (10.0.1.0/24) | An internal server running several services |
| **webserver** | `webserver` | DMZ (10.0.2.0/24) | A public-facing server in the DMZ |
| **gateway** | `gateway` | All segments | A multi-homed Linux router/firewall with iptables rules |

The **gateway** has network interfaces on each segment and routes traffic between them. It is also running iptables to control which traffic is allowed to cross between zones. This mirrors a real-world network design where a firewall sits at the boundary between the internal network, the DMZ, and the outside world.

## Network design principles {#network-design}

Before diving into the practical exercises, it is important to understand *why* networks are designed the way they are. A well-designed network is not just about connectivity — it is about controlling and limiting the flow of traffic so that a security incident in one part of the network does not automatically compromise everything else.

### Defence in depth {#defence-in-depth}

A core principle in network security is **defence in depth** — the idea that you should not rely on a single security control to protect your systems. Instead, you layer multiple controls so that if one fails, others are still in place. In network terms, this means combining techniques such as network segmentation, firewalling, intrusion detection, host hardening, and access control rather than relying on any one of them alone.

### Network segmentation {#segmentation-theory}

In a flat network — where every host is on the same subnet and can communicate directly with every other host — a single compromised machine can potentially reach everything. **Network segmentation** divides the network into separate zones, each with its own subnet, connected via routers or firewalls that enforce rules about what traffic can pass between them.

Common zones in a typical organisation include:

* **Internal LAN** — workstations, printers, file servers. This is where most employees work day-to-day.
* **Server/data zone** — databases, application servers, domain controllers. These hold sensitive data and should only be accessible to authorised hosts.
* **DMZ (Demilitarised Zone)** — public-facing services such as web servers, mail servers, and external DNS. These are exposed to the internet and are therefore at higher risk of compromise.
* **Management network** — network infrastructure devices (switches, routers, firewalls). Access should be tightly restricted.
* **Guest/BYOD network** — untrusted devices that need internet access but should not be able to reach internal systems.

The boundaries between these zones are enforced by firewalls, which inspect traffic and apply rules about what is allowed to cross from one zone to another.

### Topology and trust {#topology-trust}

When designing a network, you are essentially making decisions about **trust**. Hosts within the same zone generally trust each other more than hosts in different zones. The firewall rules at each boundary encode these trust relationships.

A key question to ask about any network design is: *if an attacker compromises a host in this zone, what else can they reach?* Good segmentation limits the answer to that question. Poor segmentation — or a flat network with no segmentation at all — means the answer is "everything."

In this lab, your environment simulates a simple three-zone design: an internal network (workstation and server), a DMZ (webserver), and a gateway that controls traffic between them.

## Network reconnaissance {#network-reconnaissance}

Before you can secure a network, you need to understand what is on it. In this section you will use standard Linux networking tools to discover hosts and services.

### Identifying your own network configuration {#identifying-network-config}

On your **workstation**, ==action: open a terminal and run:==

```bash
ip addr show
```

This shows your network interfaces and IP addresses. You should see that your workstation has an interface on the **Internal LAN** segment (10.0.1.0/24). Note your IP address and subnet mask.

==action: Now check your routing table:==

```bash
ip route
```

Note the default gateway — this is the address of the **gateway** VM on your local segment. All traffic destined for other segments (such as the DMZ) will be routed through it.

### Discovering hosts on the network {#discovering-hosts}

Use `nmap` to perform a ping sweep to discover other hosts. Start with your own subnet.

==action: Run a ping sweep of the internal LAN:==

```bash
nmap -sn 10.0.1.0/24
```

You should find the **server** and the **gateway** on this segment.

==action: Now scan the DMZ segment:==

```bash
nmap -sn 10.0.2.0/24
```

You should find the **webserver** and the gateway's DMZ-facing interface here. Notice that the gateway appears on both subnets — it is multi-homed, with an interface on each segment.

### Scanning for services {#scanning-services}

Now perform a service scan against the hosts you discovered on both segments.

==action: Run a service version scan across both subnets:==

```bash
nmap -sV 10.0.1.0/24 10.0.2.0/24
```

The `-sV` flag tells nmap to probe open ports and attempt to identify the service and version running on each one. Take note of which hosts are running which services — you will need this information later.

### Tracing network paths {#tracing-paths}

Use `traceroute` to see how traffic is routed between network segments.

==action: Trace the route to the webserver and the server:==

```bash
traceroute <webserver-ip>
traceroute <server-ip>
```

Because the webserver is on a different subnet (the DMZ), your traffic must pass through the **gateway** to reach it — you should see the gateway appear as an intermediate hop. The server, on the other hand, is on the same subnet as your workstation, so traffic goes directly.

This is network segmentation in action: the gateway sits between the zones, and all cross-zone traffic passes through it. This is what allows the firewall rules on the gateway to control traffic between zones.

## Firewall concepts {#firewall-concepts}

A firewall is a device or piece of software that monitors network traffic and enforces rules about what is allowed through. Firewalls are the primary mechanism for enforcing network segmentation — they sit at the boundaries between zones and decide, for each packet or connection, whether it should be permitted or blocked.

### Types of firewall {#firewall-types}

Not all firewalls work the same way. There are several broad categories, each offering a different trade-off between performance, granularity, and complexity:

* **Packet filtering** — the simplest type. Examines each packet individually and makes a decision based on its header fields: source/destination IP, port number, and protocol. It has no awareness of whether a packet is part of an ongoing conversation or a new request. Fast, but limited.
* **Stateful packet inspection** — tracks the state of network connections. It knows, for example, that an incoming packet on port 80 is a response to an outgoing HTTP request, rather than an unsolicited inbound connection. This allows more intelligent rules, such as "allow responses to connections our hosts initiated, but block new inbound connections." This is the type of firewalling you will work with in this lab using iptables.
* **Application layer (proxy) firewalls** — operate at the application level and understand the content of traffic, not just its headers. A web application firewall (WAF), for example, can inspect HTTP requests for signs of SQL injection or cross-site scripting. These offer the deepest inspection but are the most resource-intensive.

In practice, modern networks typically use a combination of these. A perimeter firewall might perform stateful inspection at the network boundary, while a WAF protects specific web applications.

### Host-based vs. network-based firewalls {#host-vs-network-firewalls}

Firewalls can also be categorised by *where* they run:

* **Network-based firewalls** sit at a boundary between network segments — typically on a dedicated device or a multi-homed router. All traffic between zones passes through this firewall. This is the classic "perimeter firewall" model.
* **Host-based firewalls** run on individual hosts and control traffic to and from that specific machine. On Linux, `iptables` (or its successor `nftables`) provides host-based firewalling. On Windows, the built-in Windows Firewall serves this role.

Both types are valuable. Network-based firewalls protect entire zones at once, while host-based firewalls provide an additional layer of defence on each individual machine — this is defence in depth in action.

In this lab, the **gateway** VM acts as a network-based firewall (controlling traffic between zones), and you could also configure host-based rules on the individual servers for additional protection.

### Key firewalling principles {#firewall-principles}

Regardless of the type of firewall, several principles apply:

* **Default deny** — block everything by default, and only explicitly allow traffic that is needed. This is much safer than the alternative (allow everything and try to block what is dangerous), because it means new or unexpected traffic is blocked automatically.
* **Least privilege** — only allow the minimum access required. If a web server only needs to serve HTTP and HTTPS, only allow ports 80 and 443 — do not leave other ports open "just in case."
* **Rule order matters** — most firewalls (including iptables) process rules top to bottom and stop at the first match. A permissive rule placed before a restrictive one will override it.

## Understanding firewall rules and segmentation {#firewall-rules-segmentation}

Now that you understand the theory, let's look at how firewalling works in practice. The **gateway** VM sits between the internal LAN and the DMZ, routing traffic between them. It is configured with `iptables` rules that control which traffic is allowed to cross between zones — this is network-based firewalling in action.

### Examining iptables rules {#examining-iptables}

==action: SSH into the gateway VM:==

```bash
ssh gateway
```

==action: Examine the current firewall rules:==

```bash
sudo iptables -L -v -n
```

This shows all active firewall chains (INPUT, FORWARD, OUTPUT) along with packet counters, source/destination addresses, and ports.

Take some time to read through these rules. For each rule, try to understand:

* What traffic does it match? (source IP, destination IP, port, protocol)
* Does it ACCEPT, DROP, or REJECT that traffic?
* What is the security purpose of this rule?

### Understanding chain policies and default deny {#chain-policies}

Note the **default policy** on each chain — shown in parentheses at the top of each chain's output, e.g. `Chain FORWARD (policy DROP)`.

A default policy of DROP means that any traffic not explicitly permitted by a rule is silently discarded. This is the principle of **default deny** — one of the most important concepts in network security. It means you must explicitly allow every type of traffic that should be permitted, rather than trying to enumerate and block everything that should not.

### Testing connectivity against the rules {#testing-connectivity}

Go back to your **workstation** and test what you can and cannot reach.

==action: Try connecting to various services:==

```bash
# Test HTTP on the webserver
curl http://<webserver-ip>

# Test SSH to the server
ssh <server-ip>

# Test a specific port with netcat
nc -zv <server-ip> 3306
```

Compare what succeeds and fails against the iptables rules you read on the gateway. Do the results match what you expected from reading the rules?

Because the webserver is on a different subnet, traffic from your workstation to the webserver passes through the gateway's FORWARD chain. This means the gateway's forwarding rules directly determine what you can and cannot reach across zone boundaries. Traffic to the server, however, stays on the local subnet — though the gateway may still apply rules if it is the server's default gateway.

## Network Address Translation (NAT) {#nat}

NAT allows hosts on a private internal network to communicate with external networks using a shared public IP address. It is used in virtually every network you will encounter.

### Examining NAT rules {#examining-nat-rules}

==action: On the gateway VM, examine the NAT table:==

```bash
sudo iptables -t nat -L -v -n
```

You will see rules in the PREROUTING, POSTROUTING, and OUTPUT chains. Look for:

* **MASQUERADE** or **SNAT** rules in POSTROUTING — these handle outbound NAT, replacing the source IP of internal hosts with the gateway's IP when traffic leaves the network
* **DNAT** rules in PREROUTING — these handle inbound port forwarding, redirecting incoming traffic on specific ports to internal hosts

### Observing NAT in action {#observing-nat}

Because the internal LAN and DMZ are on separate subnets, traffic between them passes through the gateway — which may apply NAT. Let's observe this.

==action: On the webserver, start a packet capture listening for HTTP traffic:==

```bash
sudo tcpdump -i any -n port 80
```

==action: From the workstation in a separate terminal, make an HTTP request to the webserver:==

```bash
curl http://<webserver-ip>
```

Look at the tcpdump output on the webserver. What source IP address do you see in the incoming packets? Is it the workstation's real IP (on the 10.0.1.0/24 subnet), or the gateway's DMZ-facing IP (on the 10.0.2.0/24 subnet)? If you see the gateway's IP, the gateway is performing NAT on traffic crossing between segments. If you see the workstation's real IP, the gateway is simply routing without NAT.

### Understanding port forwarding {#port-forwarding}

Examine the PREROUTING chain in the NAT table again. If there is a DNAT (port forwarding) rule, identify:

* What port on the gateway does it listen on?
* Which internal host and port does it forward traffic to?

==action: Try connecting to the forwarded port on the gateway's IP address and confirm it reaches the expected backend service.==

## DMZ concepts {#dmz-concepts}

A DMZ (Demilitarised Zone) is a network segment that sits between the internal network and the outside world. It hosts public-facing services — web servers, mail servers, public DNS — while keeping them isolated from the internal network. If a DMZ host is compromised, the attacker should not be able to pivot into the internal network.

### Key DMZ traffic flow principles {#dmz-principles}

A properly configured DMZ enforces the following traffic policy:

| Direction | Policy | Rationale |
|---|---|---|
| External → DMZ | Allow specific services (e.g. HTTP/HTTPS) | Public needs to reach these services |
| External → Internal | **Block** | Internal network must not be directly exposed |
| Internal → DMZ | Allow | Staff need to manage DMZ services |
| Internal → External | Allow (via NAT) | Users need internet access |
| DMZ → Internal | **Block** | Critical — prevents pivot after compromise |
| DMZ → External | Limited | Only what the service requires |

The most important rule here is that the **DMZ must not be able to initiate connections to the internal network**. This is what prevents an attacker who has compromised a web server from reaching your database servers, domain controllers, and other sensitive internal systems.

### Assessing the current configuration {#assessing-config}

Based on the iptables rules you examined earlier, assess whether the gateway's configuration properly implements these DMZ principles:

* Can the webserver (DMZ) initiate connections to the server (internal)?
* Can the workstation (internal) reach the webserver?
* Are there any rules that violate the principles in the table above?

You will need this analysis for the challenges that follow.

## Assessed challenges {#assessed-challenges}

Work through the following challenges and submit your flags. Some challenges require you to find a flag by discovering information on the network. Others require you to fix a configuration — Hackerbot will connect to your VMs via SSH and verify your changes.

> Flag: **The flags collected from these challenges should be entered into Hacktivity. These flags will form part of the module assessment.**

### Challenge 1: Service discovery {#challenge-1}

Perform a scan of the network and identify the service running on port **[RANDOMISED_PORT]** on the **server** VM. Connect to this port to retrieve the flag.

==hint: Some services return a banner or message when you connect. Try using netcat:==

```bash
nc <server-ip> [RANDOMISED_PORT]
```

<!-- SecGen: Place a flag-returning service (e.g. a simple TCP banner service) on a randomised high port on the server VM. Randomise the port number per student. -->

### Challenge 2: Reading the ruleset {#challenge-2}

Examine the iptables rules on the **gateway**. One of the firewall rules contains a comment with a flag embedded in it.

==hint: Look carefully at the full output of iptables -L. Rule comments appear alongside the rule they are attached to.==

==action: On the gateway, run:==

```bash
sudo iptables -L -v -n
```

<!-- SecGen: Add a randomised flag string as an iptables rule comment (using -m comment --comment "FLAG{...}") on one of the rules. Randomise which rule carries the comment. -->

### Challenge 3: Finding the misconfiguration {#challenge-3}

The gateway's firewall has a misconfiguration that violates DMZ principles — the **webserver** (DMZ) can access a service on the **server** (internal) that it should not be able to reach.

==action: SSH into the webserver and find the service on the server that is improperly accessible from the DMZ.== The flag is the content returned by that service.

==hint: From the webserver, try scanning the server to find which ports are reachable:==

```bash
ssh webserver
nmap -sV <server-ip>
```

Compare this to what DMZ principles say should be allowed.

<!-- SecGen: Place a flag-returning service on a randomised port on the server. Configure iptables on the gateway to intentionally allow the webserver to reach this port (the misconfiguration). Randomise the port and service per student. -->

### Challenge 4: NAT port forwarding {#challenge-4}

A service running on the internal **server** has been made externally accessible via a port forwarding rule on the **gateway**. Find the forwarded port and connect to it on the gateway's IP address to retrieve the flag.

==hint: Examine the PREROUTING chain in the NAT table on the gateway:==

```bash
sudo iptables -t nat -L -v -n
```

Look for a DNAT rule — it will tell you which port on the gateway maps to which internal service.

<!-- SecGen: Configure a DNAT rule on the gateway forwarding a randomised external port to a flag-returning service on the server. Randomise both the external port and internal target port per student. -->

### Challenge 5: Fix the firewall {#challenge-5}

In Challenge 3 you found that the webserver could improperly access a service on the server. Now fix it.

==action: Add an iptables rule to the **gateway** that blocks the webserver from reaching that service, while ensuring that the workstation can still access it.==

Hackerbot will verify that:

1. The webserver **cannot** connect to the identified port on the server
2. The workstation **can** still connect to the server normally

==hint: You need to insert a DROP rule that matches traffic from the webserver's IP to the server's IP on the specific port. Think about which chain this rule belongs in (INPUT? FORWARD? OUTPUT?) and where in the chain order it should go — iptables processes rules top to bottom and stops at the first match.==

```bash
sudo iptables -I <CHAIN> <position> -s <source-ip> -d <dest-ip> -p tcp --dport <port> -j DROP
```

<!-- SecGen: Hackerbot checks via SSH: (1) nc/nmap probe from webserver to server on the randomised port fails, (2) nc/nmap probe from workstation to server still succeeds. -->

### Challenge 6: Enforce segmentation policy {#challenge-6}

==action: Add iptables rules to the **gateway** to enforce a proper segmentation policy:==

* The **webserver** must NOT be able to initiate **any** new TCP connections to the **server**
* The **workstation** must still be able to reach both the server and webserver on any port
* The **server** must still be able to send response traffic to the webserver for connections that the server initiated (i.e. established/related traffic should still flow)

Hackerbot will verify all three conditions.

==hint: You will need to use stateful matching to distinguish between new connections and responses to existing ones:==

```bash
# Allow established/related traffic (responses)
sudo iptables -I FORWARD -s <server-ip> -d <webserver-ip> -m state --state ESTABLISHED,RELATED -j ACCEPT

# Block new connections from webserver to server
sudo iptables -A FORWARD -s <webserver-ip> -d <server-ip> -p tcp --syn -j DROP
```

Think carefully about the order of these rules.

<!-- SecGen: Hackerbot checks via SSH:
  (1) New TCP connection from webserver to server is blocked
  (2) Workstation can connect to both server and webserver
  (3) Server can respond to connections (test with an established connection probe)
-->

## Conclusion {#conclusion}

At this point you have:

* Learned how to use network reconnaissance tools to discover hosts and services
* Examined and interpreted iptables firewall rules
* Understood how network segmentation restricts traffic flow between zones
* Investigated how NAT and port forwarding work in practice
* Learned the traffic flow principles that govern DMZ architecture
* Identified and fixed firewall misconfigurations

Congratulations! Next week we will build on these concepts with a deeper look at **perimeter defence**, including more advanced firewall configurations and VPN tunnels.