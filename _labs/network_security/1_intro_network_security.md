---
title: "Network Security Fundamentals: Network Design, Segmentation, NAT and DMZ"
author: ["Tom Shaw"]
license: "CC BY-SA 4.0"
description: "Connect a three-segment network, investigate firewall rules, discover a segmentation misconfiguration, and build iptables policies to enforce network segmentation, DMZ isolation, and NAT, while fending off Hackerbot's live challenges."
overview: |
  Network security fundamentals lab covering network design, segmentation, NAT, DMZ, and firewalls. Students connect a three-segment network, investigate firewall rules, discover misconfigurations, and build segmentation policies using iptables.

  This is a Hackerbot lab. Work through the lab sheet, then when prompted interact with Hackerbot.
tags: ["network-security", "segmentation", "dmz", "nat", "firewalls", "iptables", "routing", "hackerbot"]
categories: ["network_security"]
type: ["hackerbot-lab", "ctf-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "NS"
    topic: "Network Security Fundamentals"
    keywords: ["NETWORK SEGMENTATION", "DEMILITARISED ZONE (DMZ)", "NETWORK ADDRESS TRANSLATION (NAT)", "FIREWALLS", "IPTABLES", "DEFAULT DENY"]
  - ka: "NS"
    topic: "Network Defence"
    keywords: ["perimeter security", "firewall configuration", "stateful packet inspection"]
---

## Getting started {#getting-started}

\==action: Start all the VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop
- gateway_server
- web_server
- server

### Your login details for the "desktop" VM {#your-login-details-for-the-desktop-vm}

\==VM: On the desktop VM==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

### Lab environment {#lab-environment}

Your environment consists of the following VMs, spread across three separate network segments:

| VM             | Hostname     | Network segment | Role                               |
|----------------|--------------|---|------------------------------------|
| **desktop**    | `desktop`    | Internal LAN (10.0.1.0/24) | Your Linux desktop system          |
| **web_server** | `web_server` | DMZ (10.0.2.0/24) | A public-facing web server in the DMZ |
| **server**     | `server`     | Server zone (10.0.3.0/24) | An internal server running several services |
| **gateway**    | `gateway`    | All three segments | A Linux router/firewall system     |

The **gateway** has a network interface on each of the three segments and routes traffic between them.

> Note: Throughout this lab, commands are prefixed with the VM you should run them on. Unless told otherwise, you should be working on the **desktop**. When you need to run commands on another VM, you will SSH into it from the desktop.

{% include hackerbot-intro.md role="set you networking and security challenges and verify your work" chat="full" %}

## Network design principles {#network-design-principles}

The following quote from Bruce Schneier speaks to two core principles of secure network design:

"Defence in depth ensures that no single vulnerability can compromise security. Compartmentalisation ensures that a single vulnerability cannot compromise security entirely."

### Defence in depth {#defence-in-depth}

Defence in depth is the idea that one single security mechanism is not enough to protect a system, as it is a single point of failure, and that using a combination of multiple controls is a better approach towards mitigating the potential damage caused if a compromise were to occur. In this lab we will look at two such controls, where you will configure a segmented network with a firewall.

### Network segmentation {#network-segmentation}

Flat networks are those where all hosts are on the same subnet, which enables them to communicate with each other directly. Network segmentation involves creating separate-yet-interconnected zones which have different rules and permissions depending on their purpose. In these more complex network designs, routing systems and firewalls can be used to determine where traffic should be permitted or restricted to travel.

Common zones in a typical organisation include:

* **Internal LAN / Intranet**: workstations, printers, file servers. This is where most employees work day-to-day.
* **Server/data zone**: databases, application servers, domain controllers. These hold sensitive data and should only be accessible to authorised hosts.
* **Demilitarised Zone (DMZ)**: public-facing services such as web servers, mail servers, and external DNS. These are exposed to the internet and are therefore at higher risk of compromise.
* **Management network** - network infrastructure devices (switches, routers, firewalls). Access should be tightly restricted.
* **Guest network** - untrusted devices that need internet access but should not be able to reach internal systems, for example a university guest WiFi.

When designing a network, you are essentially making decisions about **trust**. Hosts in the same zone generally trust each other more than hosts in other zones. It is important to consider what an attacker could reach from a compromised system and to plan towards minimising their ability to directly attack other potentially more important or valuable target systems.

In this lab, your environment implements a three-zone design: an internal LAN (desktop), a server zone (server), and a DMZ (web_server), with a gateway controlling traffic between all three.

## Network reconnaissance {#network-reconnaissance}

### Identifying your own network configuration {#identifying-your-own-network-configuration}

On your **desktop**, \==action: open a terminal and run:==

```bash
# On: desktop
ip addr show
```

This shows your network interfaces and IP addresses. You should see that your desktop has an interface on the **Internal LAN** segment (10.0.1.0/24). Note your IP address and subnet mask.

\==action: Now check your routing table:==

```bash
# On: desktop
ip route
```

You will likely see something like this:

```
10.0.1.0/24 dev ens19 proto kernel scope link src 10.0.1.10
```

This tells you that your desktop knows how to reach hosts on the 10.0.1.0/24 subnet (the Internal LAN), but notice that there is **no default route** set. This means your desktop currently has no idea how to reach any other network segment, including the web server in the DMZ (10.0.2.0/24). Any traffic sent to a host outside your local subnet will currently fail.

\==action: Try to ping the web_server in the DMZ to confirm this:==

```bash
# On: desktop
ping 10.0.2.10
```

This should fail with "Network is unreachable" as your desktop has no route to 10.0.2.0/24.

### Discovering hosts on the network {#discovering-hosts-on-the-network}

\==action: Run a ping sweep of the Internal LAN to discover what hosts are on your segment:==

```bash
# On: desktop
nmap -sn 10.0.1.0/24
```

You should find the **gateway** on this segment (the desktop itself will also appear). Note the gateway's Internal LAN IP address for future use. The server and web_server are on separate segments and will not appear here until routes are added.

### Understanding routing and default gateways {#understanding-routing-and-default-gateways}

To reach other network segments, a host needs a **default gateway**, which is a router that it sends all non-local traffic to. The **gateway** VM will operate as the router between all three segments in this scenario. For cross-segment communication to work, every host that needs to communicate across segments must have a default route configured, pointing at the gateway's IP on its local segment.

To configure the default gateway so it persists after a reboot you need to edit the network config file. \==action: On the desktop, edit `/etc/network/interfaces`:==

```bash
# On: desktop
sudo vi /etc/network/interfaces
```

Find the block for your network interface (e.g. `ens19`) and add a `gateway` line pointing at the gateway's IP on your local segment. For the desktop, it should look like:

```
auto ens19
iface ens19 inet static
    address 10.0.1.10/24
    gateway 10.0.1.1
```

\==action: Press "i" to enter insert mode to update the file as above, then *Esc*, ":wq" to write changes and quit==

Restart the networking service to apply the changes:

```bash
# On: desktop
sudo service networking restart
```

Verify the route has been added:

```bash
# On: desktop
ip route
```

You should now see a `default via 10.0.1.1` line in the output.

When configuring the other VMs, use the gateway's IP on **their** local segment: for the web_server on the DMZ, this is the gateway's 10.0.2.x address. For the server on the Server zone, this is the gateway's 10.0.3.x address.

### Understanding IP forwarding {#understanding-ip-forwarding}

Even if every host has the correct routes set, the gateway itself needs to be configured to actually **forward** packets between its interfaces. By default, a Linux machine will not forward packets that arrive on one interface but that are for a host only accessible with another, it drops them instead.

IP forwarding is controlled by a kernel parameter. You can check whether it is enabled with:

```bash
cat /proc/sys/net/ipv4/ip_forward
```

A value of `0` means forwarding is disabled. A value of `1` means it is enabled. To enable it persistently, \==action: edit `/etc/sysctl.conf` on the gateway:==

```bash
# On: gateway
sudo vi /etc/sysctl.conf
```

Find the line `#net.ipv4.ip_forward=1` (it may be commented out with a `#`), uncomment it or add it if it's missing:

```
net.ipv4.ip_forward=1
```

Then apply the change:

```bash
# On: gateway
sudo sysctl -p
```

Verify it is enabled:

```bash
# On: gateway
cat /proc/sys/net/ipv4/ip_forward
```

This should now show `1`. Without IP forwarding enabled on the gateway, no traffic will pass between any of the three segments, even if all the routes are correctly configured.

### Reaching hosts on other segments via SSH {#reaching-hosts-on-other-segments-via-ssh}

Currently, your desktop can only reach hosts on the Internal LAN (10.0.1.0/24). The only other host on this segment is the **gateway**. The **server** (10.0.3.0/24) and **web_server** (10.0.2.0/24) are both on different subnets, so you cannot reach them directly.

However, the **gateway** has interfaces on all three segments. This means that once you SSH into the gateway, you can SSH from there to the server or the web_server even before IP forwarding or routes are configured.

This technique of hopping through segments by chaining SSH connections together is common in network administration and is similar conceptually to the pivoting techniques used in offensive security, where attackers use compromised hosts to enable them to access other areas of the network, e.g. compromising a web server in the DMZ and using it as a pivot point to attack internal systems.

```bash
# On: desktop - SSH to the gateway
ssh 10.0.1.1
```

Explore the network to find a flag in your user's home directory on both the server and web_server VMs.

```bash
# On: gateway - SSH to the web_server or server from here
ssh 10.0.2.10
ssh 10.0.3.10
```

> Warning: Once you complete the next Hackerbot challenge your desktop's IP address will change permanently. Make sure you use the new IP address for any SSH connections or network tests for the remainder of the lab.

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Connect the network — enable IP forwarding on the gateway, then set a default gateway on the desktop, web_server, and server, each pointing at the gateway's IP on their own segment. You may find some flags along the way.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

Don't forget to \==action: save and submit any flags!==

## IP and MAC address fundamentals {#ip-and-mac-address-fundamentals}

Every device on a network has at least two addresses that identify it: an **IP address** which is for Layer 3, aka the network layer, which is responsible for routing traffic between networks, and a **MAC address** for Layer 2, the data link layer, responsible for communication within a single network segment.

### IP addresses {#ip-addresses}

An IP address identifies a host on a network. IP addresses can be assigned statically (manually configured) or dynamically (via DHCP). IP addresses can be added to interfaces and changed and therefore a host is not permanently bound to a particular IP.

\==action: Let's demonstrate this. On your desktop, first note your current IP address and confirm you can ping the gateway:==

```bash
# On: desktop
ip addr show ens19
ping 10.0.1.1
```

\==action: Now temporarily add a second IP address to your interface:==

```bash
# On: desktop
sudo ip addr add 10.0.1.200/24 dev ens19
```

\==action: Verify the new address has been added:==

```bash
# On: desktop
ip addr show ens19
```

You should see both your original IP and the new 10.0.1.200 address listed on the same interface.

\==action: Remove the additional address to return to your original configuration:==

```bash
# On: desktop
sudo ip addr del 10.0.1.200/24 dev ens19
```

The above demonstrates adding and removing IPs temporarily using `ip addr`. However, changes made this way are lost on reboot. To permanently change your IP address, you should edit the network configuration file instead.

\==action: To change your IP persistently, edit `/etc/network/interfaces`:==

```bash
# On: desktop
sudo vi /etc/network/interfaces
```

Find the block for your interface and change the `address` line to the new IP. For example, to change from 10.0.1.10 to 10.0.1.50:

```
auto ens19
iface ens19 inet static
    address 10.0.1.50/24
    gateway 10.0.1.1
```

\==action: Then restart the networking service to apply the change:==

```bash
# On: desktop
sudo service networking restart
```

\==action: Verify your IP has changed:==

```bash
# On: desktop
ip addr show ens19
ping 10.0.1.1
```

This method is safer than using `ip addr` commands directly, because it preserves your default route and handles the network transition cleanly. You will use this approach in the Hackerbot challenge that follows.

> Note: If IP addresses can be easily changed, any security mechanism that relies solely on IP address for identification can potentially be bypassed by an attacker who changes their IP. Consider the implications of an attacker changing their IP to match a trusted host, how would the network tell the difference?

> Tip: If you accidentally misconfigure your network, try restarting the network service with `sudo service networking restart` and if that fails revert your VM to restore the original configuration.

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Change your desktop's IP address to the IP address Hackerbot gives you in the chat, by editing `/etc/network/interfaces` and restarting networking. Make sure you keep connectivity to the gateway.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

> Note: Once this attack succeeds, your desktop's IP address changes permanently. Use the new IP address for the rest of the lab.

Don't forget to \==action: save and submit any flags!==

### MAC addresses {#mac-addresses}

A Media Access Control (MAC) address is a hardware-level address assigned to each network interface. It is used for communication within a single network segment at Layer 2.

\==action: View and make note of your desktop's MAC address:==

```bash
# On: desktop
ip link show ens19
```

The MAC address is shown after `link/ether` and is in the format `xx:xx:xx:xx:xx:xx`. The first three octets typically identify the manufacturer (the OUI, or Organisationally Unique Identifier), and the last three are unique to the device.

\==action: To change your MAC address persistently, edit `/etc/network/interfaces`:==

```bash
# On: desktop
sudo nano /etc/network/interfaces
```

Add a `hwaddress` line to your interface block. For example, to change your MAC to `00:11:22:33:44:55`:

```
auto ens19
iface ens19 inet static
    address 10.0.1.10/24
    gateway 10.0.1.1
    hwaddress ether 00:11:22:33:44:55
```

\==action: Then restart the networking service to apply the change:==

```bash
# On: desktop
sudo service networking restart
```

\==action: Verify the MAC address has changed:==

```bash
# On: desktop
ip link show ens19
```

You should see `link/ether 00:11:22:33:44:55` in the output.

\==action: Restore your original MAC address by removing the `hwaddress` line from `/etc/network/interfaces` and restarting networking:==

```bash
# On: desktop
sudo nano /etc/network/interfaces
```

Remove the `hwaddress ether 00:11:22:33:44:55` line, save the file, then restart:

```bash
# On: desktop
sudo service networking restart
```

> Note: Although MAC addresses are often described as "hardware addresses" and are burned into the network interface by the manufacturer, as you have just demonstrated, they can be easily overridden at the software layer. Any security control that relies on MAC addresses for identification or access control (such as MAC filtering on a wireless network) can therefore be bypassed by an attacker who simply spoofs a known-good address. We will revisit this in later labs when we cover ARP spoofing attacks.

#### Hackerbot Attack #3 {#hackerbot-attack-3}

You can skip the bot to here, by saying **goto 3**.

> Hackerbot: Change your desktop's MAC address to the MAC address Hackerbot gives you in the chat. Make sure you maintain connectivity.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

Don't forget to \==action: save and submit any flags!==

## Firewall concepts {#firewall-concepts}

A firewall is a device or piece of software that monitors network traffic and enforces rules about what is allowed through. Firewalls are the primary mechanism for enforcing network segmentation.

### Types of firewall {#types-of-firewall}

* **Packet filtering** is the simplest type, which examines each packet individually based on header fields, such as the source/destination IP, port number, and/or protocol. It has no awareness of connection state and is fast, but limited.
* **Stateful packet inspection** tracks the state of network connections and can determine if a packet is part of an ongoing interaction or a new request. This is the type of firewalling you will work with in this lab using iptables.
* **Application layer (proxy) firewalls** operate at the application level and actively inspect the content of traffic. For example, a web application firewall (WAF) can inspect HTTP requests for SQL injection or XSS. This is the deepest level of inspection, but is the most resource-intensive.

### Host-based vs. network-based firewalls {#host-based-vs-network-based-firewalls}

Firewalls can be deployed in two ways:

* **Network-based firewalls** sit at a boundary between network segments. All traffic between zones passes through this firewall.
* **Host-based firewalls** run on individual hosts and control traffic to and from that specific machine. On Linux, `iptables` provides this.

In this lab, the **gateway** VM acts as a network-based firewall controlling traffic between zones.

### Key firewalling principles {#key-firewalling-principles}

There are three key principles to keep in mind when configuring firewalls. **Default deny** means blocking everything by default and only explicitly allowing traffic that is needed. The principle of **least privilege** means only allowing the minimum access required for a service to function. Finally, the **rule order matters** as iptables processes rules from top to bottom and stops at the first match, so a rule in the wrong place can inadvertently allow or block traffic.

## Understanding firewall rules and segmentation {#understanding-firewall-rules-and-segmentation}

In this scenario the **gateway** VM sits between the three network segments, routing traffic between them. You are going to configure `iptables` rules on the gateway to control which traffic is allowed to cross between zones.

### Setting up firewall rules on the gateway {#setting-up-firewall-rules-on-the-gateway}

\==action: SSH into the gateway and check the current FORWARD policy:==

```bash
# On: gateway
sudo iptables -L FORWARD -v -n
```

You should see that the FORWARD chain has a policy of ACCEPT, meaning all traffic between segments is allowed with no restrictions. As any host on any segment can reach any other host, which is insecure, we should change that.

\==action: First, set the default FORWARD policy to DROP:==

```bash
# On: gateway
sudo iptables -P FORWARD DROP
```

This is the principle of *default deny*, where all forwarded traffic is now blocked unless explicitly allowed by a rule. You can verify this by looking at the policy shown in parentheses at the top of the chain output:

> Note: iptables rules are not persistent by default and will be lost if the gateway reboots. To save your rules at any point, run `sudo iptables-save > /etc/iptables/rules.v4` on the gateway. It's worth doing this after each step as you go.

> Warning: Always save your rules after making changes you want to keep. If you need to start fresh, you can flush all rules with `sudo iptables -F` and `sudo iptables -t nat -F`, but be careful as this will remove all rules.

```bash
# On: gateway
sudo iptables -L FORWARD -v -n
```

You should see `Chain FORWARD (policy DROP)`.

\==action: Now try to ping the webserver from your desktop:==

```bash
# On: desktop
ping 10.0.2.10
```

This should now fail as the gateway is dropping all forwarded traffic.

\==action: Add a rule to allow traffic from the desktop's subnet to the webserver's subnet:==

```bash
# On: gateway
sudo iptables -A FORWARD -s 10.0.1.0/24 -d 10.0.2.0/24 -j ACCEPT
```

\==action: Try pinging the webserver again from the desktop - again, it should fail:==

```bash
# On: desktop
ping 10.0.2.10
```

The ping gets there, but you probably won't get a reply. Why? Because the reply from the webserver back to the desktop is also forwarded traffic, and there is no rule allowing it in the other direction.

\==action: Add a rule to allow established and related traffic back through:==

```bash
# On: gateway
sudo iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
```

This rule uses **stateful packet inspection** to allow packets through that are part of an existing connection (ESTABLISHED) or related to one (RELATED), without allowing new connections in that direction.

\==action: Now try pinging the webserver again:==

```bash
# On: desktop
ping 10.0.2.10
```

This should now work. The first rule allows new connections from the desktop to the DMZ, and the stateful rule allows the replies back through.

\==action: Now add a rule to allow the desktop to reach the server zone as well:==

```bash
# On: gateway
sudo iptables -A FORWARD -s 10.0.1.0/24 -d 10.0.3.0/24 -j ACCEPT
```

\==action: Verify the desktop can now reach both zones:==

```bash
# On: desktop
ping 10.0.3.10
```

> Tip: If connectivity is not behaving as you expect, check your ruleset with `sudo iptables -L FORWARD -v -n --line-numbers` on the gateway. Work through each rule top to bottom and check whether your traffic matches an ACCEPT rule or falls through to the DROP policy.

### Testing DMZ isolation {#testing-dmz-isolation}

Now let's verify that the DMZ is properly isolated from the other zones.

\==action: SSH into the webserver and try to reach the server:==

```bash
# On: webserver
ping 10.0.3.10
```

This should fail as there is no rule allowing the webserver to initiate connections to the server zone. DMZs are configured like this so that if the webserver is compromised, the attacker cannot pivot to internal systems.

\==action: Review your complete ruleset on the gateway:==

```bash
# On: gateway
sudo iptables -L FORWARD -v -n
```

Compare what you see against the traffic you just tested. You should be able to match each result (allowed or blocked) to a specific rule or the default DROP policy. This is how firewall rules enforce network segmentation in practice.

Because the web_server is on a different subnet, all traffic from your desktop to the web_server passes through the gateway's FORWARD chain. This means the gateway's forwarding rules directly determine what you can and cannot reach across zone boundaries.

## Network Address Translation (NAT) {#network-address-translation-nat}

NAT is one of the most widely deployed techniques in networking. Understanding it is essential for anyone working with firewalls, network design, or traffic analysis.

### Why NAT exists {#why-nat-exists}

IPv4 addresses are a finite resource. When the internet was designed, no one anticipated that billions of devices would eventually need unique addresses. NAT offered a solution by allowing many devices on a private network to share a single public-facing IP address.

Without NAT, every device that wanted to communicate with the outside world would need its own globally unique IP address. With NAT, the gateway translates it and rewrites the source IP address on outgoing packets (replacing the private internal IP with its own public-facing IP), and keeps track of those translations so it can rewrite the destination address on incoming reply packets and deliver them back to the correct internal host.

NAT also provides a degree of implicit security as hosts on the internal network are not directly reachable from the outside because they have no routable address. However, this should not be relied upon and is not as secure as deploying a proper firewall.

In this lab, NAT is used on the **gateway** to allow hosts on the internal LAN (10.0.1.0/24) to communicate across segments. You are going to configure it from scratch.

### Setting up outbound NAT (MASQUERADE) {#setting-up-outbound-nat-masquerade}

The most common form of NAT in small networks is **MASQUERADE**. Rather than specifying a fixed IP address to translate to, MASQUERADE automatically uses whatever IP address the outgoing interface has. This means that when a packet from an internal host leaves the gateway, the source IP is rewritten to the gateway's own address on that interface. As far as any host on the other side is concerned, the traffic appears to originate from the gateway itself, not from the internal host that sent it.

\==action: SSH into the gateway and add a MASQUERADE rule to the POSTROUTING chain of the NAT table:==

```bash
# On: desktop
ssh 10.0.1.1

# On: gateway
sudo iptables -t nat -A POSTROUTING -s 10.0.1.0/24 -o ens20 -j MASQUERADE
```

This rule says that for any packet originating from the 10.0.1.0/24 subnet leaving via `ens20`, rewrite the source IP to match the gateway's address on that interface.

\==action: Verify the rule has been added:==

```bash
# On: gateway
sudo iptables -t nat -L POSTROUTING -v -n
```

You should see your new MASQUERADE rule listed with the source network and output interface.

### Observing NAT in action {#observing-nat-in-action}

With the rule in place, let's verify it is working and observe what it actually does to traffic.

\==action: First, check the desktop can reach the webserver. Back on the desktop, unset any proxy environment variables that might interfere with `curl`, then make an HTTP request:==

```bash
# On: desktop
unset http_proxy HTTP_PROXY
curl http://10.0.2.10
```

If you get a response from the webserver, NAT is working — the gateway is translating your desktop's source IP as packets cross into the DMZ.

\==action: To see exactly what NAT is doing, SSH into the web_server and start a packet capture:==

```bash
# On: desktop (second terminal)
ssh 10.0.2.10

# On: web_server
sudo tcpdump -i any -n port 80
```

\==action: Then, back on the desktop, make another HTTP request:==

```bash
# On: desktop
curl http://10.0.2.10
```

Look at the source IP address in the tcpdump output on the web_server. You should see that the incoming packets appear to originate from the **gateway's DMZ-facing IP** (10.0.2.1), not from your desktop's real address on the 10.0.1.0/24 subnet. The gateway has rewritten the source before forwarding the packet into the DMZ.

> Question: Consider the implications of this for logging and attribution. If the web_server were compromised and an attacker examined its access logs, what would they and what would they *not* be able to learn about the internal network?

## DMZ concepts {#dmz-concepts}

A DMZ (Demilitarised Zone) is a network segment that sits between the internal network and the outside world. It hosts public-facing services such as web servers, mail servers, and public DNS, whilst keeping them isolated from the internal network. If a DMZ host is compromised, the attacker should not be able to pivot into the internal network.

### Key DMZ traffic flow principles {#key-dmz-traffic-flow-principles}

A properly configured DMZ enforces the following traffic policy:

| Direction            | Policy | Rationale                                     |
|----------------------|---|-----------------------------------------------|
| External to DMZ       | Allow specific services (e.g. HTTP/HTTPS) | Public needs to reach these services          |
| External to Internal | **Block** | Internal network must not be directly exposed |
| Internal to DMZ      | Allow | Staff need to manage DMZ services             |
| Internal to External | Allow (via NAT) | Users need internet access                    |
| DMZ to Internal      | **Block** | Critical to prevent pivoting after compromise |
| DMZ to External      | Limited | Only what the service requires                |

The most important rule here is that the **DMZ must not be able to initiate connections to the internal network**.

### Assessing the current configuration {#assessing-the-current-configuration}

Based on the iptables rules you created earlier, assess whether the gateway's configuration properly implements these DMZ principles:

> Question: Can the web_server (DMZ) initiate connections to the server (Server zone)?

> Question: Can the desktop (Internal LAN) reach the web_server and the server?

> Question: Are there any rules that violate the principles in the table above?

## Conclusion {#conclusion}

In this lab you have configured a multi-segment network from scratch, including setting up persistent routing and IP forwarding. You demonstrated that IP and MAC addresses can be changed, explored the security implications of that, and built iptables firewall rules to enforce network segmentation using default deny and stateful packet inspection. You also examined NAT and how traffic flows between network zones. These are the foundational skills for everything that follows in this module.

#### Hackerbot Attack #4 {#hackerbot-attack-4}

You can skip the bot to here, by saying **goto 4**.

> Hackerbot: Configure iptables on the gateway to enforce network segmentation: the desktop should be able to reach both the webserver and server, but the webserver must NOT be able to reach the server. Follow the instructions in the labsheet above to set up the rules.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

Don't forget to \==action: save and submit any flags!==

## Resources {#resources}

* [iptables manual](https://linux.die.net/man/8/iptables)
* [nmap reference guide](https://nmap.org/book/man.html)
* [Linux networking commands cheat sheet](https://access.redhat.com/sites/default/files/attachments/rh_ip_command_cheatsheet_1214_jcs_print.pdf)
