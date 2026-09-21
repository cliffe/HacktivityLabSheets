---
title: "Secure Communications: VPNs, SSL/TLS and DNS Security"
author: ["Tom Shaw"]
license: "CC BY-SA 4.0"
description: "Configure DNS resolution and fix a zone transfer misconfiguration, inspect TLS certificates, and establish an OpenVPN tunnel into an internal network, to satisfy Hackerbot's challenges."
overview: |
  Secure communications lab covering DNS security, SSL/TLS, and VPNs. You will configure DNS resolution and discover a zone transfer misconfiguration, inspect TLS certificates, and establish an OpenVPN tunnel from an external client into the internal network.

  This lab builds on the network topology from the Network Security Fundamentals lab. This is a Hackerbot lab: work through the lab sheet below, then when prompted interact with Hackerbot, who will verify your DNS fix and your VPN tunnel, and reveal flags as you go.
tags: ["dns", "dns-security", "zone-transfer", "axfr", "tls", "ssl", "https", "certificates", "vpn", "openvpn", "hackerbot"]
categories: ["network_security"]
lab_sheet_url: "https://cliffe.github.io/HacktivityLabSheets/labs/network_security/2-dns_tls_vpns/"
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "NS"
    topic: "Secure Communications"
    keywords: ["DNS SECURITY", "ZONE TRANSFER", "DNS OVER TLS", "TLS CERTIFICATES", "HTTPS", "HSTS", "VPN", "OPENVPN", "CERTIFICATE AUTHORITY"]
  - ka: "NS"
    topic: "Network Defence"
    keywords: ["ENCRYPTED TUNNELS", "CERTIFICATE-BASED AUTHENTICATION", "FIREWALL CONFIGURATION"]
---

## Getting started {#getting-started}

### VMs in this lab {#vms-in-this-lab}

This lab builds upon the network topology from the Network Security Fundamentals lab. Your environment has been pre-configured to match the end state of that lab. The routing, IP forwarding, and firewall rules are all in place. Your task is to layer additional security mechanisms on top of that foundation.

| VM | Hostname | Network segment | Role |
|---|---|---|---|
| desktop | desktop.hacktivity-netsec.co.uk | Internal LAN (10.0.1.0/24) | Debian desktop - work from here unless told otherwise |
| web_server | web.hacktivity-netsec.co.uk | DMZ (10.0.2.0/24) | A public-facing web server running HTTPS |
| server | server.hacktivity-netsec.co.uk | Server zone (10.0.3.0/24) | An internal server running DNS and other services |
| gateway | gateway.hacktivity-netsec.co.uk | All segments + external | A Linux router/firewall |
| remote | n/a | External (10.0.4.0/24) | A remote client outside the organisation (10.0.4.10) |

The **remote** VM represents a machine outside the organisation - a remote worker's laptop. It can reach the gateway's external interface (10.0.4.1) but has no access to any internal systems at the start of this lab.

\==action: Start all VMs== if you have not already done so. You do not need to log into the hackerbot_server directly.

### Your login details {#your-login-details}

\==VM: On the desktop and remote VMs==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You can use these credentials on the **desktop** and **remote** VMs via their consoles, and to SSH between systems throughout the lab. If you are not sure of your username, ==action: open a terminal and run:==

```bash
whoami
```

> Note: Wherever this lab sheet says "your username", ==edit: substitute the username you noted down==.

> Tip: Commands throughout this lab are prefixed with the VM you should run them on, for example `# On: desktop`. Unless told otherwise, you should be working on the desktop VM.

{% include hackerbot-intro.md role="set you challenges on DNS security, TLS certificates, and VPNs, and verify your work" %}

## DNS Security {#dns-security}

### What is DNS? {#what-is-dns}

When you type a hostname into a browser or terminal, such as `web.hacktivity-netsec.co.uk` or `google.com`, your system needs to translate that name into an IP address so that it can connect to another system. This translation is performed by the Domain Name System (DNS).

DNS works as a hierarchy of servers. When your computer needs to resolve a hostname, it sends a query to a configured DNS resolver. The resolver either has the answer cached, or it works through the DNS hierarchy by querying authoritative name servers until it finds the answer and returns it to your machine.

In this lab, the server VM (10.0.3.10) runs an authoritative DNS server for the `hacktivity-netsec.co.uk` domain. It holds records for all the internal hostnames in your environment.

#### DNS record types {#dns-record-types}

DNS zones contain multiple record types, each serving a different purpose:

| Record type | Purpose | Example |
|---|---|---|
| A | Maps a hostname to an IPv4 address | `web.hacktivity-netsec.co.uk -> 10.0.2.10` |
| PTR | Reverse lookup (maps an IP to a hostname) | `10.0.2.10 -> web.hacktivity-netsec.co.uk` |
| MX | Mail server | `hacktivity-netsec.co.uk -> mail.hacktivity-netsec.co.uk` |
| TXT | Arbitrary text data (used for verification, SPF, etc.) | `"v=spf1 mx -all"` |
| NS | Authoritative name servers for a zone | `hacktivity-netsec.co.uk -> server.hacktivity-netsec.co.uk` |
| SOA | Start of Authority (metadata about the zone) | serial number, refresh interval, etc. |
| CNAME | Canonical name (an alias for another hostname) | `www.hacktivity-netsec.co.uk -> web.hacktivity-netsec.co.uk` |

### Configuring DNS resolution on the desktop {#configuring-dns-resolution}

Your desktop currently has no DNS resolver configured and therefore can only communicate with other hosts using their IP addresses.

DNS resolver configuration on Linux is stored in `/etc/resolv.conf`. This file tells the system which DNS server to query. However, on Debian-based systems this file can be overwritten when interfaces are restarted. A more robust approach is to configure the DNS server in `/etc/network/interfaces` alongside the interface's IP settings, so it is always restored correctly.

\==action: Check your current DNS configuration:==

```bash
# On: desktop
cat /etc/resolv.conf
```

You may see a placeholder or an empty file. \==action: Try to resolve a hostname to confirm it is not working:==

```bash
# On: desktop
ping web.hacktivity-netsec.co.uk
```

This will fail as your desktop does not know which DNS server to ask.

\==action: Edit `/etc/network/interfaces` to add the DNS server:==

```bash
# On: desktop
sudo vi /etc/network/interfaces
```

Find the block for your network interface and add a `dns-nameservers` line pointing at the internal DNS server:

```
auto ens19
iface ens19 inet static
    address 10.0.1.10/24
    gateway 10.0.1.1
    dns-nameservers 10.0.3.10
```

==action: Press "i" to enter insert mode to update the file as above, then Esc, `:wq` to write changes and quit==

\==action: Restart networking to apply the change:==

```bash
# On: desktop
sudo service networking restart
```

\==action: Verify that `/etc/resolv.conf` has been updated:==

```bash
# On: desktop
cat /etc/resolv.conf
```

You should now see `nameserver 10.0.3.10` in the file.

\==action: Test that hostname resolution is working:==

```bash
# On: desktop
ping web.hacktivity-netsec.co.uk
ping server.hacktivity-netsec.co.uk
```

Both should resolve and respond. From here on, you can use hostnames instead of IP addresses throughout the lab.

### Querying DNS records with dig {#querying-dns-records-with-dig}

`dig` (Domain Information Groper) is a command-line tool for querying DNS servers. It gives you precise control over what you query and shows the full response.

\==action: Query an A record:==

```bash
# On: desktop
dig web.hacktivity-netsec.co.uk
```

The response includes an answer section showing the IP address, along with metadata such as the query type, TTL (time to live, in seconds), and which server answered the request.

\==action: You can query specific record types by passing the type after the hostname:==

```bash
# On: desktop
dig MX hacktivity-netsec.co.uk
dig NS hacktivity-netsec.co.uk
dig TXT hacktivity-netsec.co.uk
```

\==action: You can also direct a query at a specific DNS server rather than using your configured resolver, using the `@` syntax:==

```bash
# On: desktop
dig @10.0.3.10 web.hacktivity-netsec.co.uk
```

### Observing plaintext DNS {#observing-plaintext-dns}

One important property of standard DNS is that queries and responses are sent in plaintext over UDP port 53. This means anyone on the network path between your machine and the DNS server can read every query you make - and see every hostname you are looking up, even before any actual connection is made.

To demonstrate this, ==action: open Wireshark on the desktop:==

```bash
# On: desktop
sudo wireshark
```

Select the `ens19` interface and start a capture. In the display filter bar at the top, type `dns` and press Enter to show only DNS traffic.

\==action: Back in your terminal, make a few DNS queries:==

```bash
# On: desktop
dig web.hacktivity-netsec.co.uk
dig server.hacktivity-netsec.co.uk
dig TXT hacktivity-netsec.co.uk
```

Look at the Wireshark output. You can see each query and response in plaintext. The hostname being looked up, the query type, and the answer are all clearly visible in separate columns. Anyone in a position to intercept traffic on this network can see exactly which services you are communicating with before any data is exchanged.

This is the problem that **DNS over TLS (DoT)** and **DNS over HTTPS (DoH)** address, by encrypting DNS queries so they cannot be read in transit. **DNSSEC** is another security mechanism which addresses a related but different problem by providing cryptographic verification that DNS responses have not been tampered with in transit, but DNSSEC does not encrypt the queries themselves.

\==action: Stop the Wireshark capture when you are done observing.==

### DNS zone transfers {#dns-zone-transfers}

A DNS zone transfer is a mechanism that allows one DNS server to replicate an entire zone's records to another server. This is used in organisations with multiple DNS servers to keep them synchronised, where a primary server holds the authoritative records, and secondary servers periodically request a full copy via zone transfers. The protocol used for this is called AXFR.

The security problem arises when a DNS server is misconfigured to allow zone transfers from any host, rather than only from authorised secondary servers. An attacker who performs a zone transfer receives every record in the zone in a single response, i.e. all A records, MX records, TXT records, CNAME records, etc. This provides a complete map of the organisation's internal infrastructure: every hostname, IP address, and service that has a DNS entry.

This type of information disclosure significantly assists reconnaissance. An attacker who knows the names of all internal servers has a much clearer picture of what to target than one who has only a list of IP addresses, or who has to probe the network blind.

The internal DNS server holds a TXT record at a special hostname in the hacktivity-netsec.co.uk domain. \==action: Try requesting a zone transfer from the internal DNS server:==

```bash
# On: desktop
dig axfr hacktivity-netsec.co.uk @10.0.3.10
```

If the server is misconfigured, you will receive the entire contents of the `hacktivity-netsec.co.uk` zone. ==hint: Look carefully at the response, as it may include hosts that have never been mentioned anywhere in this lab sheet.==

\==action: To fix the issue, SSH into the server and edit the BIND zone configuration:==

```bash
# On: desktop
ssh server.hacktivity-netsec.co.uk
```

```bash
# On: server
sudo vi /etc/bind/named.conf.local
```

Find the zone block for `hacktivity-netsec.co.uk` and add an `allow-transfer` directive:

```
zone "hacktivity-netsec.co.uk" {
    type master;
    file "/etc/bind/db.hacktivity-netsec.co.uk";
    allow-transfer { none; };
};
```

\==action: Reload BIND to apply the change:==

```bash
# On: server
sudo rndc reload
```

\==action: Verify the fix from the desktop. The zone transfer should now be refused:==

```bash
# On: desktop
dig axfr hacktivity-netsec.co.uk @10.0.3.10
```

You should see a `Transfer failed` message. \==action: Confirm that normal DNS resolution still works:==

```bash
# On: desktop
dig web.hacktivity-netsec.co.uk
ping server.hacktivity-netsec.co.uk
```

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: The DNS server is misconfigured to allow zone transfers from any host. Restrict zone transfers on the server while making sure normal DNS resolution still works.

\==action: Do any necessary preparation, then when you are ready for the bot to complete the attack, say 'ready'.==

Don't forget to ==action: save and submit any flags!==

## TLS and HTTPS {#tls-and-https}

### What is TLS? {#what-is-tls}

Transport Layer Security (TLS) is the cryptographic protocol that underpins HTTPS. When you connect to a server over HTTPS, TLS provides three things:

- **Confidentiality** - the content of your communication is encrypted and cannot be read by anyone intercepting the traffic
- **Integrity** - any tampering with data in transit will be detected
- **Authentication** - you can verify that you are talking to the intended server, and not an impostor

TLS uses a combination of asymmetric and symmetric cryptography. During the TLS handshake, the client and server use asymmetric cryptography (public/private key pairs) to authenticate and negotiate a shared session key. All subsequent communication is encrypted with that session key using fast symmetric encryption.

#### The TLS handshake {#the-tls-handshake}

In simplified form, the TLS handshake works as follows:

1. The client sends a `ClientHello`, advertising the TLS versions and cipher suites it supports
2. The server responds with a `ServerHello`, selects a cipher suite, and presents its certificate
3. The client verifies the certificate against its trusted Certificate Authorities (CAs)
4. The client and server negotiate a shared session key
5. Both sides confirm the handshake is complete and switch to encrypted communication

#### Certificates {#certificates}

A TLS certificate binds a public key to an identity (a domain name). It is signed by a Certificate Authority (CA), whose signature allows clients to verify that the certificate is legitimate and belongs to the claimed identity.

Certificates contain several important fields:

- **Subject** - the identity the certificate is issued to (e.g. `CN=web.hacktivity-netsec.co.uk`)
- **Subject Alternative Name (SAN)** - additional hostnames, IPs, or URIs the certificate is valid for
- **Issuer** - the CA that signed the certificate
- **Validity period** - the Not Before and Not After dates
- **Public key** - the server's public key
- **Fingerprint** - a hash of the certificate, useful for verifying you are seeing the expected certificate

A **self-signed certificate** is one where the issuer and subject are the same, i.e. the certificate has been signed with its own private key rather than by a trusted CA. Browsers and other clients will warn about self-signed certificates because there is no trusted third party vouching for the server's identity.

### Observing HTTP vs HTTPS {#observing-http-vs-https}

First we should compare unencrypted HTTP and encrypted HTTPS traffic on the wire to see the difference.

\==action: Open Wireshark on the desktop.== Select the `ens19` interface and start a capture.

```bash
# On: desktop
sudo wireshark
```

\==action: In your terminal, make an HTTP request to the web server:==

```bash
# On: desktop
curl http://10.0.2.10
```

In the Wireshark display filter bar, type `http` and press Enter. You should be able to see the HTTP request and response in plaintext, where the request method, path, and response body are all clearly visible. Right-click a packet and select **Follow -> TCP Stream** to see the full conversation including headers and page content.

==action: Clear the display filter, then type `tls` and press Enter.==

\==action: Make an HTTPS request.== The `-k` flag tells curl to accept the self-signed certificate without rejecting it:

```bash
# On: desktop
curl -k https://10.0.2.10
```

Look at the Wireshark output now. You can see the TLS handshake packets and encrypted application data, but the content is unreadable. Unlike the HTTP capture, you cannot see the request path, headers, or response body - everything inside the TLS tunnel is opaque.

==action: Stop the wireshark capture when you are done.==

### Inspecting a TLS certificate {#inspecting-a-tls-certificate}

\==action: You can inspect the certificate that a server presents during the TLS handshake using `openssl s_client`:==

```bash
# On: desktop
openssl s_client -connect 10.0.2.10:443 -showcerts
```

This prints a lot of output. The most important parts are the certificate block between `-----BEGIN CERTIFICATE-----` and `-----END CERTIFICATE-----`, and the `Verify return code` line - for a self-signed certificate you will see an error here, which is expected.

\==action: To see a more readable summary of the certificate fields, pipe the output through `openssl x509`:==

```bash
# On: desktop
openssl s_client -connect 10.0.2.10:443 2>/dev/null \| openssl x509 -noout -text
```

Look through the output and identify:

- The **Subject** - what identity does this certificate claim?
- The **Subject Alternative Name** - what hostnames or URIs is it valid for?
- The **Issuer** - who signed this certificate?
- The **Validity** period - when does it expire?

\==action: To get just the SHA-256 fingerprint:==

```bash
# On: desktop
openssl s_client -connect 10.0.2.10:443 2>/dev/null \| openssl x509 -noout -fingerprint -sha256
```

==action: Inspect the TLS certificate presented by web.hacktivity-netsec.co.uk and find the flag hidden in one of its fields.==

==hint: Look carefully at the Subject Alternative Name extension - it can contain URIs as well as hostnames. If you find a URI, try fetching it.==

Don't forget to ==action: save and submit any flags you find!==

## VPNs {#vpns}

### What is a VPN? {#what-is-a-vpn}

A Virtual Private Network (VPN) creates an encrypted tunnel between two endpoints over an untrusted network. Traffic inside the tunnel is encrypted so that anyone intercepting it on the external network sees only encrypted VPN packets rather than the content, destinations, or metadata of the connections inside.

VPNs are used in two main configurations:

- **Remote access VPN** - a single client connects to a corporate gateway, gaining access to internal resources as if they were on the local network. This is the configuration you will set up in this lab.
- **Site-to-site VPN** - two gateways connect their respective networks together, allowing hosts on both sides to communicate as if they share the same network.

#### Why use a VPN if TLS already encrypts traffic? {#why-use-a-vpn}

TLS encrypts the *content* of individual connections, but the destination IP address is still visible to anyone monitoring the network. An attacker watching your traffic can see which servers you are connecting to, how often, and how much data is being transferred - even if they cannot read what is inside those connections.

A VPN wraps all traffic, including TLS-encrypted traffic, inside an additional encryption layer. From the perspective of anyone on the external network, all they see is encrypted VPN packets flowing between the client and the VPN gateway. The actual destinations, ports, and contents of connections inside the tunnel are hidden entirely.

#### OpenVPN {#openvpn}

OpenVPN is an open-source VPN implementation that uses TLS for its control channel and strong symmetric encryption for its data channel. It supports certificate-based authentication, where both the client and server present certificates signed by a shared Certificate Authority, ensuring that only authorised clients can connect.

In this lab, the gateway (10.0.4.1) is configured as an OpenVPN server using certificate-based authentication. A client certificate and key pair have already been generated and placed on the remote VM. The VPN tunnel subnet is `10.8.0.0/24`. When the tunnel is up, the remote client will be assigned an address in this range.

### Demonstrating the problem: remote access without a VPN {#demonstrating-the-problem}

\==action: Log in to the remote VM directly via the VM console.==

\==action: From the remote VM, try to reach internal services:==

```bash
# On: remote
ping 10.0.1.10
ping 10.0.2.10
curl http://10.0.2.10
```

All of these should fail. The remote VM is on the external segment (10.0.4.0/24) and has no route into the internal network. The gateway's firewall also blocks direct access from the external segment to internal systems.

\==action: Now, try to ping the gateway's external IP.==

```bash
# On: remote
ping 10.0.4.1
```

This should succeed. Remote workers can typically only access the gateway's external interface, and cannot access any internal resources without VPN access.

### Understanding the OpenVPN client configuration {#understanding-the-openvpn-client-configuration}

\==action: Examine the client configuration file that has been prepared:==

```bash
# On: remote
cat /etc/openvpn/client/client.ovpn
```

The key directives in this file are:

- `client` - this is a client configuration
- `remote 10.0.4.1` - the address of the OpenVPN server to connect to
- `ca`, `cert`, `key` - paths to the CA certificate, client certificate, and client private key
- `dev tun` - use a TUN (tunnel) device, which operates at the IP layer
- `proto udp` - use UDP as the transport protocol

The presence of a client certificate and key means the server will verify your identity during the handshake. Only clients with a certificate signed by the correct CA can establish a tunnel.

### Starting the OpenVPN server on the gateway {#starting-the-openvpn-server}

The OpenVPN server on the gateway is installed but not set to start automatically - you will start it manually as part of this exercise.

\==action: SSH into the gateway from the desktop:==

```bash
# On: desktop
ssh gateway.hacktivity-netsec.co.uk
```

\==action: Start the OpenVPN server:==

```bash
# On: gateway
sudo openvpn --config /etc/openvpn/server/server.conf --daemon
```

\==action: Verify the server is running and the tunnel interface has been created:==

```bash
# On: gateway
ip link show tun0
```

You should see a `tun0` interface. The server is now listening for client connections.

### Establishing the VPN tunnel from the remote VM {#establishing-the-vpn-tunnel}

\==action: Switch back to the remote VM and start the OpenVPN client:==

```bash
# On: remote
sudo openvpn --config /etc/openvpn/client/client.ovpn
```

You should see log output showing the TLS handshake and tunnel negotiation. Look for a line containing `Initialization Sequence Completed` - this indicates the tunnel is up.

\==action: Open a second terminal on the remote VM and verify the tunnel interface has appeared:==

```bash
# On: remote
ip addr show tun0
ip route
```

You should see a `tun0` interface with an IP address in the `10.8.0.0/24` range, and new routes in the routing table for traffic destined for the internal network.

\==action: Now try to reach internal hosts:==

```bash
# On: remote
ping 10.0.1.10
```

This will probably still fail. The tunnel is up, but recall from the previous lab that the gateway has a default FORWARD policy of DROP. There is no rule yet allowing traffic arriving from the VPN tunnel interface to be forwarded onward. This is the same problem you solved before, where a new network path requires a new firewall rule.

### Opening firewall rules for VPN traffic {#opening-firewall-rules-for-vpn-traffic}

\==action: SSH into the gateway from the desktop and add rules to permit forwarded traffic through the tunnel interface:==

```bash
# On: desktop
ssh 10.0.1.1
```

```bash
# On: gateway
sudo iptables -A FORWARD -i tun0 -j ACCEPT
sudo iptables -A FORWARD -o tun0 -j ACCEPT
sudo bash -c 'iptables-save > /etc/iptables/rules.v4'
```

The first rule allows traffic arriving on `tun0` to be forwarded to other interfaces. The second allows return traffic to be forwarded back through the tunnel. Together they permit bidirectional traffic flow through the VPN.

\==action: Now test connectivity from the remote VM again:==

```bash
# On: remote
ping 10.0.1.10
curl -k https://10.0.2.10
```

Both should now succeed. The remote VM has access to internal resources through the encrypted tunnel.

### Accessing internal resources through the VPN {#accessing-internal-resources-through-the-vpn}

With the tunnel established, the remote VM is effectively on the internal network. It can reach services that are only accessible from inside - including services that are explicitly blocked from the external segment.

You can also use hostnames from the remote VM if DNS is configured. \==action: Check whether it is already set up:==

```bash
# On: remote
cat /etc/resolv.conf
```

If `10.0.3.10` is not listed as a nameserver, add it the same way you did on the desktop (i.e. by editing `/etc/network/interfaces` and adding `dns-nameservers 10.0.3.10` to the interface block, then restarting the interface).

\==action: Once DNS is working, try:==

```bash
# On: remote
ssh server.hacktivity-netsec.co.uk
curl -k https://web.hacktivity-netsec.co.uk
```

Both should succeed through the tunnel.

\==action: Open Wireshark on the remote VM.== Select the `ens19` interface and start a capture.

```bash
# On: remote
sudo wireshark
```

\==action: With the VPN tunnel active, make an HTTPS request to the web server:==

```bash
# On: remote
curl -k https://10.0.2.10
```

Look at the Wireshark output. Filter by `udp` so that all you see is encrypted UDP packets flowing between the remote VM and the gateway at 10.0.4.1. The actual destination 10.0.2.10 is not visible anywhere.

\==action: Now stop the capture and try the same request without the VPN active== (kill the OpenVPN process first with `sudo killall openvpn`). If you restart the capture, you will see the TCP connection attempt going directly to 10.0.2.10 with the destination fully visible.

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Start the OpenVPN server on the gateway, then start the client on the remote VM. Add FORWARD rules on the gateway to allow tun0 traffic into the internal network, so the remote VM can reach the desktop.

\==action: Do any necessary preparation, then when you are ready for the bot to complete the attack, say 'ready'.==

Don't forget to ==action: save and submit any flags!==

## Conclusion {#conclusion}

In this lab you have configured and explored three complementary mechanisms for securing network communications.

In the **DNS section**, you configured hostname resolution using a local authoritative DNS server, observed that standard DNS traffic is plaintext and exposes every hostname you query to anyone on the network path, and discovered and remediated a zone transfer misconfiguration that would allow an attacker to enumerate the entire internal infrastructure in a single request.

In the **SSL/TLS section**, you were introduced to the concept of certificate authorities (CAs), compared unencrypted HTTP and encrypted HTTPS on the wire, and inspected a TLS certificate in detail to understand what information it contains, what trust it provides, and how certificate fields can carry information beyond what is immediately obvious.

In the **VPN section**, you demonstrated the limitations of remote access without a VPN, established an OpenVPN tunnel using certificate-based authentication, extended the gateway firewall policy from the previous lab to accommodate VPN traffic, and observed that a VPN conceals not just the content but also the destinations and metadata of connections.

These three mechanisms address different layers of the same underlying problem: how do you communicate securely over a network you do not fully trust?

## Resources {#resources}

- OpenVPN documentation: [https://openvpn.net/community-resources/](https://openvpn.net/community-resources/)
- BIND9 Administrator Reference Manual: [https://bind9.readthedocs.io/](https://bind9.readthedocs.io/)
- RFC 6797 - HTTP Strict Transport Security (HSTS): [https://www.rfc-editor.org/rfc/rfc6797](https://www.rfc-editor.org/rfc/rfc6797)
- RFC 8310 - DNS over TLS: [https://www.rfc-editor.org/rfc/rfc8310](https://www.rfc-editor.org/rfc/rfc8310)
- `man openssl`, `man dig`, `man tcpdump`, `man iptables`
