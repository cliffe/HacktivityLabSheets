---
title: "Wireless Security: Evil Twins and Man-in-the-Middle Attacks"
author: ["Tom Shaw"]
license: "CC BY-SA 4.0"
description: "Use a Wi-Fi Pineapple to run an evil twin of a café's open Wi-Fi network, then see what an attacker in the middle can learn: the sites a victim visits over HTTPS, passwords sent over plain HTTP, credentials typed into a fake captive portal, and why HSTS stops a downgrade attack."
overview: |
  A phone or laptop that has joined a network once will usually rejoin anything that broadcasts the same name, and on an open network nothing proves that the access point is the real one. In this in-person lab you work in a team with a Wi-Fi Pineapple and a lab PC playing a customer in the "CSL Café". You will survey the wireless network, set up an evil twin of the café's Wi-Fi, wait for your victim to arrive and connect, and then find out what being in the middle actually gives you. You will see which websites the victim visits even though the traffic is encrypted, read a password sent over plain HTTP, harvest credentials with a fake captive portal, and (as a stretch task) attempt an HTTPS downgrade and watch HSTS stop it.

  Along the way you will look at how Wi-Fi attacks have changed: why the classic "Karma" attack rarely works against modern devices, why Protected Management Frames stop deauthentication but not evil twins, and which defences actually prevent an attacker from impersonating a network. Your team submits one short worksheet answering the Submission Questions in this sheet, with evidence from the practical tasks.
tags: ["wireless", "wifi", "wifi-pineapple", "evil-twin", "mitm", "captive-portal", "hsts", "wireshark", "pmf", "wpa3"]
categories: ["cyber_security_landscape"]
type: ["lab-sheet"]
difficulty: "easy"
cybok:
  - ka: "NS"
    topic: "Network Protocols and Vulnerability"
    keywords: ["MAN-IN-THE-MIDDLE ATTACK (MITM)", "MITM (MAN-IN-THE-MIDDLE ATTACK)"]
---

# Wireless Security: Evil Twins and Man-in-the-Middle Attacks

## Introduction {#introduction}

Most people use public Wi-Fi in cafés, hotels, trains and on campus. Very few people check which access point they have actually connected to, and their devices are designed to make the decision for them. This lab looks at Wi-Fi from the attacker's side, using a Wi-Fi Pineapple (a small device made by Hak5 for wireless auditing) to impersonate a network and place yourself between a victim and the services they use. This position is known as a **man-in-the-middle** (MITM).

You will carry out the attack, and you will also work out what it does and does not give an attacker today. Many of the attacks that made Wi-Fi notorious ten years ago have been weakened by changes to devices and protocols; others work as well as they ever did. By the end of the lab you should be able to explain which is which, and why.

The lab is set in a fictional café, the **CSL Café**, which offers free open Wi-Fi to its customers. Your team takes two roles, and you will swap them part way through:

* **Attackers**, who operate the Wi-Fi Pineapple from one lab PC.
* **Victim**, a customer using a laptop in the café, played by a second lab PC with a USB Wi-Fi dongle.

> Warning: Intercepting other people's wireless traffic, impersonating a network that you do not own, or disrupting a wireless network without permission is a criminal offence in the UK (under the Computer Misuse Act 1990 and the Wireless Telegraphy Act 2006, amongst others). Everything in this lab is done against the lab's own access point and your own team's victim PC, with your tutor's permission. Only ever target your own victim, keep the Pineapple's filters set as described below, never give your evil twin the name of a real network, and never use these techniques outside the lab.

> Warning: When you play the victim, never type a real username or password into anything in this lab. Make up credentials for each task; your attackers are going to read them.

### How to work through this lab {#how-to-work-through-this-lab}

Each team has one Wi-Fi Pineapple and one Wi-Fi dongle, and works on two neighbouring lab PCs. Your tutor will tell you whether all teams run the practical tasks at the same time or take turns with the hardware. If you are waiting for your turn, work on the background reading and Submission Question 1, which need no hardware.

Your team submits **one** document containing your answers to the numbered **Submission Questions** in this sheet, with screenshots as evidence where asked. Other questions in this sheet are for discussion and your own understanding, and are not submitted. The marking scheme is at the end of the sheet.

### The lab network {#the-lab-network}

The CSL Café network has been set up for you as follows:

| Item | Details |
|---|---|
| Café Wi-Fi network (SSID) | `CSL-Cafe`, open (no password), 2.4 GHz only |
| Café router | `192.168.75.1`, hands out addresses in `192.168.75.0/24` |
| Café web server and DNS server | `192.168.75.10` (your tutor's PC) |
| Websites on the café network | `intranet.csl.internal`, `shop.csl.internal`, `bank.csl.internal`, `health.csl.internal`, `jobs.csl.internal` |
| "Attacker" web server (stretch task only) | `192.168.75.11` (also your tutor's PC) |

The websites are fictional and only exist on this network; they are there to give your victim something realistic to browse. There is no internet access through the café network, and none is needed.

## Background: how Wi-Fi devices choose a network {#background}

Before attacking the network, it is worth understanding how a device decides which access point to join, since every attack in this lab depends on it.

An access point (AP) announces a network by sending **beacon** frames several times a second, each containing the network's name (its **SSID**), the AP's hardware address (its **BSSID**), the channel and the security settings it supports. Devices listen for beacons to build the list of networks you see when you click the Wi-Fi icon. A device can also send **probe requests** asking whether a network is nearby.

Every device keeps a list of networks it has joined before, often called its **preferred network list** (PNL). When a device sees a beacon for a network in that list, it will usually reconnect automatically, without asking the user. A device identifies a remembered network by its **name and security type**, not by which physical AP it belongs to; a café chain with fifty branches relies on this so that its customers reconnect in every shop. If two APs broadcast the same name, the device normally chooses whichever has the stronger signal.

An **evil twin** is an attacker's AP that copies a legitimate network's name and settings, so that devices connect to it instead. On an open network this needs nothing more than the name. On a network protected with a pre-shared key (WPA2-Personal or WPA3-Personal), the evil twin also needs the password, which stops an outsider but not anyone who knows it; a password printed on the wall of a café is known to everyone in the room. The only common setting in which the AP has to prove its own identity is **WPA2/WPA3-Enterprise (802.1X)**, where the client checks a certificate presented by the network's authentication server, provided the client has been configured to check it.

### What has changed since the early 2010s {#what-has-changed}

The Wi-Fi Pineapple became well known for the **Karma** attack: answering "yes, that's me" to a device's probe requests for any network it asked about, so that a device would connect to the Pineapple while believing it was at home or at work. Karma relied on devices broadcasting the names of networks in their PNL. Modern versions of Windows, macOS, iOS and Android no longer do this for normal (non-hidden) networks, so Karma rarely works against current devices. Attackers adapted by broadcasting beacons for network names that many people are likely to have saved (common café, hotel and transport Wi-Fi names); the Pineapple's **SSID pool** does exactly this.

The second classic technique is **deauthentication**. Management frames, which control joining and leaving a network, were originally sent without any protection, so an attacker could forge a "deauthenticate" frame from the AP and knock a device off the network, ready for it to reconnect to an evil twin (or to capture the WPA2 handshake as it reconnects, which can then be cracked offline if the password is weak). **Protected Management Frames** (PMF, defined in IEEE 802.11w) add cryptographic protection to these frames using keys from the existing connection, so forged deauthentication frames are ignored. PMF is mandatory in WPA3 and optional in WPA2, and many WPA2 networks still run without it, so deauthentication remains effective against a large number of real networks.

PMF protects a connection that already exists. It does nothing to prove to a device that is *about to* join a network that the AP is genuine, so it does not prevent an evil twin. A customer walking into a café, or an employee arriving at the office, will join whichever matching AP is strongest. Deauthentication is also noisy and easy to detect, so real attackers often just wait for new devices to arrive, and you will do the same in this lab.

What an attacker gains from being in the middle has changed too. Almost all web traffic is now encrypted with HTTPS, so passwords for mainstream websites can't simply be read off the wire, though you will find there is still plenty to see.

> Question: Submission Question 1 (complete as a team; this can be done whilst waiting for the hardware). Complete a table with one row for each of the following: Karma, deauthentication, evil twin of an open network, evil twin of a network with a shared password, evil twin of a WPA2/WPA3-Enterprise network, and capturing and cracking a WPA2-Personal handshake. For each, give (a) how the attack works, in one or two sentences; (b) whether it is still effective against a typical modern network and device, and in what circumstances; and (c) the defence or defences that prevent it (for example PMF, WPA3-SAE, 802.1X with server certificate validation, strong passphrases, wireless intrusion detection). Reference your sources.

## Getting started {#getting-started}

Decide who in your team will start as the attackers and who will start as the victim, and sit at two neighbouring PCs. Keep the Pineapple on the desk next to the victim PC, as close as possible to the victim's Wi-Fi dongle; this is your strongest defence against accidentally attracting another team's victim, and theirs against attracting yours.

### Victim PC {#victim-pc}

==VM: On the victim PC==

==action: Unplug the PC's network cable==. This matters: Windows prefers a wired connection over Wi-Fi, so whilst the cable is plugged in your traffic would never travel over the air and your attackers would see nothing.

==action: Plug in the USB Wi-Fi dongle==, then ==action: click the network icon in the taskbar and connect to `CSL-Cafe`, ticking "Connect automatically"==.

==action: Open a Command Prompt and run:==

```bash
ipconfig
netsh wlan show interfaces
```

> Note: `ipconfig` should show an address in `192.168.75.0/24` for the Wi-Fi adapter. In the output of `netsh wlan show interfaces`, note the **Physical address** (the MAC address your dongle is using on this network; Windows may randomise it per network) and the **BSSID** of the AP you are connected to. Give the physical address to your attackers.

==action: Open Microsoft Edge and visit each site in the favourites bar== (Intranet, Shop, Bank, Health and Jobs) to check that the café network is working. Visiting the Bank site now matters for the stretch task later.

> Note: If the sites do not load, check that the cable is unplugged and that you are connected to `CSL-Cafe`. If Edge tries to use the university proxy, ask your tutor.

### Attacker PC {#attacker-pc}

==VM: On the attacker PC==

==action: Connect the Wi-Fi Pineapple to the PC with its USB-C cable== and wait about a minute for it to boot (the LED settles).

==action: Open a browser and go to the Pineapple's web interface== at `http://==edit: your Pineapple's IP address==:1471`. The address is on the label on the back of your Pineapple. ==action: Log in== with the details your tutor gives you.

> Note: If the page does not load, disable the browser's proxy (or check that the Pineapple's address is in the proxy exceptions), and check that a new USB network adapter has appeared in `ipconfig`.

==action: Spend a few minutes looking around the interface==: Dashboard, Campaigns, PineAP, Recon, Clients, Logging, Modules and Settings. You don't need to document every page; you will use the important ones below.

==action: Check that you can also log in to the Pineapple over SSH from a Command Prompt:==

```bash
ssh root@==edit: your Pineapple's IP address==
```

Type `exit` to leave the SSH session.

## Part 1: Surveying the network {#reconnaissance}

The first stage of any wireless assessment is reconnaissance: finding out which networks and devices are present, without sending anything that would affect them.

==VM: On the attacker PC==

==action: Open the Recon page and start a scan==. Your Pineapple's radios only support 2.4 GHz, so it can only see 2.4 GHz networks and clients.

==action: Find `CSL-Cafe` in the results==. Note its BSSID, channel, encryption and whether it uses PMF ("MFP" or "PMF" in the security details). ==action: Expand the network to find its clients== and identify your victim by the physical address they gave you.

> Note: Expect to see a large number of other networks, including the university's own Wi-Fi. Leave them alone. If you cannot see your victim, check that the victim PC is connected to `CSL-Cafe` and that the Pineapple is close to it; a scan takes time to visit every channel.

Now limit what the Pineapple will interact with. Professional testers are always bound by a **scope** agreed with the client, and the Pineapple's filters are how you enforce yours.

==action: Open PineAP's filtering settings and set the client filter to "Allow" mode, containing only your victim's physical address==. ==action: Set the SSID filter to "Allow" mode, containing only `CSL-Cafe`==. With these filters, your Pineapple will refuse connections from any other device, including other teams' victims and the phones of anybody passing by.

> Question: Submission Question 2. Include a screenshot of `CSL-Cafe` and your victim in Recon (blur or crop other networks). List what you were able to learn about the network and the victim without connecting to anything or transmitting a single frame. Why does reconnaissance like this raise few, if any, alarms?

## Part 2: The evil twin {#evil-twin}

You will now make the Pineapple impersonate `CSL-Cafe`. For the attack to go unnoticed, your victim must still be able to use the café's websites once they are connected to you, so the Pineapple has to pass their traffic on to the real network.

### Connecting the Pineapple to the real network {#pineapple-upstream}

The Pineapple has three radios: one hosts its management network and the open AP that victims join, one is used by PineAP and Recon, and one can connect to another Wi-Fi network as an ordinary client. Your tutor will normally have connected this client radio to `CSL-Cafe` already.

==action: Open Settings, then Networking, and check that the wireless client is connected to `CSL-Cafe` with an address in `192.168.75.0/24`==. If it is not, connect it to `CSL-Cafe` now.

### Impersonating the café {#impersonating-the-cafe}

==action: In PineAP, add `CSL-Cafe` to the SSID pool==.

==action: Set PineAP to Advanced mode and enable "Beacon Response", "Broadcast SSID Pool" and "Allow Associations"==, then ==action: save the settings==. Your Pineapple is now broadcasting `CSL-Cafe` and will accept connections to it, but only from your victim, because of the filters you set earlier.

> Note: Menu names vary a little between Pineapple firmware versions. If you cannot find a setting, look at your tutor's Pineapple or ask.

### The victim arrives {#the-victim-arrives}

Rather than knocking your victim off the network, you will simulate them walking into the café.

==VM: On the victim PC==

==action: Turn Wi-Fi off from the taskbar, wait about 20 seconds, then turn it back on==. Do not choose a network; let Windows reconnect by itself.

==action: Run `ipconfig` again==, and ==action: browse to two or three of the café's sites==.

==VM: On the attacker PC==

==action: Open the Clients page==. Your victim should appear as connected to your Pineapple.

> Note: If the victim reconnected to the real router instead, check the PineAP settings and filters, move the Pineapple closer to the dongle, and turn the victim's Wi-Fi off and on again.

> Question: Discussion: from the victim's side, what changed when they connected to your evil twin? Compare the IP address and the gateway shown by `ipconfig` with those from earlier, and the BSSID shown by `netsh wlan show interfaces`. Would a typical customer notice either?

### Deauthentication {#deauthentication}

Your tutor will demonstrate a deauthentication attack against one victim, or tell you whether you may try it yourselves against your own victim (only ever use "Deauthenticate Client" on your own victim; never "Deauthenticate All"). Note how the attack depends on the AP not using PMF.

> Question: Submission Question 3. Explain, in your own words, why your victim's PC joined your evil twin without asking. Then explain what would have prevented the attack if the café had used (a) WPA2-Personal with the password printed on the menu, (b) WPA3-Personal with the same printed password, (c) WPA2-Personal with PMF enabled, and (d) WPA2-Enterprise with 802.1X, with clients configured to check the server certificate. Be precise: which of these stop an evil twin, which only stop deauthentication, and which stop neither?

## Part 3: What can the network see? {#metadata}

You are now in the middle: every packet your victim sends passes through your Pineapple. In this part you will capture that traffic and look at it in Wireshark. Your victim will browse the Health, Jobs and Bank sites, all of which use HTTPS.

==VM: On the attacker PC==

==action: Open a Command Prompt (not PowerShell, which corrupts binary data passed through a pipe) and run the following command to capture traffic on the Pineapple and show it live in Wireshark:==

```bash
ssh root@==edit: your Pineapple's IP address== "tcpdump -i any -U -w - not port 22 and not port 1471" \| "C:\Program Files\Wireshark\Wireshark.exe" -k -i -
```

Enter the Pineapple's password when prompted. Wireshark should open and start showing packets.

> Note: If the live capture does not work, capture to a file instead: run `ssh root@==edit: your Pineapple's IP address== "tcpdump -i any -w /tmp/capture.pcap not port 22"`, let the victim browse, press Ctrl+C, then copy the file with `scp root@==edit: your Pineapple's IP address==:/tmp/capture.pcap .` and open `capture.pcap` in Wireshark.

==VM: On the victim PC==

==action: Browse the Health, Jobs and Bank sites from the favourites bar==. Click around a few pages on each.

==VM: On the attacker PC==

==action: In Wireshark, apply the display filter `dns`==. Each DNS query is a device asking "what is the address of this name?", and these are sent unencrypted.

==action: Then apply the filter `tls.handshake.extensions_server_name`==. When a browser opens an HTTPS connection, it tells the server which site it wants in the **Server Name Indication** (SNI) field of the TLS handshake, and this is sent before encryption starts.

==action: Try to read the content of one of the HTTPS pages== (right-click a packet, Follow, TLS Stream).

> Note: You will also see traffic that the victim did not knowingly create: Windows checking for updates, telemetry, time synchronisation and connectivity checks. A real device is far noisier than its user realises, and all of this is visible too.

> Question: Submission Question 4. Include a screenshot showing the sites your victim visited, as revealed by DNS and SNI. Which parts of the victim's browsing could you see, and which could you not? Explain why HTTPS hides some of it but not the rest. Name and briefly explain technologies that would hide what you could see (consider DNS over HTTPS, Encrypted Client Hello and VPNs). Why might a list of sites visited be sensitive on its own, even without the content?

## Part 4: Reading unencrypted traffic {#plain-http}

Not everything uses HTTPS. Older internal systems, embedded devices, IoT devices and some apps still send data in plain text. The café's staff intranet is one of these.

==VM: On the victim PC==

==action: Open the Intranet site from the favourites bar and log in with a made-up username and password==. Make a note of what you typed.

==VM: On the attacker PC==

==action: In Wireshark, apply the filter `http.request.method == "POST"`==, ==action: right-click the request and choose Follow, then HTTP Stream==.

> Question: Submission Question 5. Include a screenshot of the captured login (it will show your victim's made-up credentials). Look at the address bar on the victim PC: what did the browser display to warn the user, and is it likely that a typical user would notice it? Apart from websites, give two examples of systems that might still send credentials or sensitive data unencrypted on a real network.

## Part 5: Captive portal phishing {#captive-portal}

When you join public Wi-Fi in a hotel or café, you are often shown a sign-in page, known as a **captive portal**, before you can use the internet. Users are used to typing details into these pages, and there is no reliable way for them to tell a genuine portal from a fake one. Because the attacker controls the network, they control the portal. HTTPS does not help, because the user is typing their details into the attacker's own page.

Your Pineapple has the **Evil Portal** module installed, with a CSL Café portal prepared for you.

==VM: On the attacker PC==

==action: Open Modules, then Evil Portal==. ==action: Select the CSL Café portal and look at its files==; you may edit the wording to make it more convincing (but never to imitate a real organisation). ==action: Activate the portal and start Evil Portal==.

==VM: On the victim PC==

==action: Turn Wi-Fi off and on again==, then ==action: try to visit a café website==. Windows should show a sign-in notification, or your browser should show the portal. ==action: Sign in with a made-up email address and password==.

==VM: On the attacker PC==

==action: Find the captured credentials in Evil Portal's log==, then ==action: stop Evil Portal==.

> Question: Submission Question 6. Include a screenshot of your portal and of the captured credentials. Why does captive portal phishing still work when almost all websites use HTTPS? Would WPA3 or PMF on the café's own network have prevented it? What advice would you give a member of the public about captive portals?

## Stretch task: HTTPS downgrade and HSTS {#hsts}

This task is optional. Attempt it if you have time with the hardware.

Many websites still accept a first connection over plain HTTP and then redirect the browser to HTTPS. An attacker in the middle can intercept that first HTTP request and keep the victim on HTTP, serving their own copy of the site. This is known as an **HTTPS downgrade** or **SSL stripping** attack. Websites defend against it with **HTTP Strict Transport Security** (HSTS): a response header telling the browser "only ever contact me over HTTPS", which the browser remembers. Once a browser has seen it, the browser refuses to use HTTP for that site and refuses to let the user click past a certificate error.

The café's Shop site redirects to HTTPS but does not use HSTS. The Bank site uses HSTS, and your victim visited it at the start of the lab, so their browser has already remembered it. Your tutor's PC plays the part of the attacker's server at `192.168.75.11`, hosting a fake copy of the Shop over HTTP and a Bank site with a certificate that the victim's PC does not trust.

You will use the Pineapple's DNS server to send your victim to the fake server. ==VM: On the attacker PC==, ==action: SSH to the Pineapple and run:==

```bash
uci add_list dhcp.@dnsmasq[0].address='/shop.csl.internal/192.168.75.11'
uci add_list dhcp.@dnsmasq[0].address='/bank.csl.internal/192.168.75.11'
uci commit dhcp
/etc/init.d/dnsmasq restart
```

==VM: On the victim PC==

==action: Close Edge, then run `ipconfig /flushdns` in a Command Prompt==, so that the PC forgets the addresses it looked up earlier. ==action: Open Edge and click the Shop favourite==, then ==action: log in with made-up credentials==. ==action: Next, click the Bank favourite==.

==VM: On the attacker PC==

==action: Find the Shop login in Wireshark, as in Part 4==.

==action: Remove the spoofed DNS entries:==

```bash
uci del_list dhcp.@dnsmasq[0].address='/shop.csl.internal/192.168.75.11'
uci del_list dhcp.@dnsmasq[0].address='/bank.csl.internal/192.168.75.11'
uci commit dhcp
/etc/init.d/dnsmasq restart
```

> Question: Submission Question 7 (stretch, optional). What did the victim see when visiting the Shop, and when visiting the Bank? Explain why the attack worked against one site and not the other. What would the Bank's protection not have covered if the victim had never visited it before, and how does the HSTS preload list address this?

## Swap roles {#swap-roles}

Swap attacker and victim roles, and repeat Parts 2 to 5 so that everyone in the team has operated the Pineapple. Use different made-up credentials each time.

## Ethics and scope {#ethics-and-scope}

The techniques in this lab are used in authorised wireless penetration tests and red team engagements, where the tester has written permission from the organisation and a defined scope. Even then, other people use the same airspace: customers, employees and neighbouring organisations.

> Question: Submission Question 8. Imagine you have been hired to assess the guest Wi-Fi of a real café chain or a university. Drawing on this lab, describe (a) the legal and ethical requirements you would need in place before starting, and (b) the steps you would take to avoid affecting, or collecting data from, people who are not in scope. Refer to the measures you used in this lab (filters, the choice of network name, avoiding deauthentication) and to the National Cyber Security Centre's guidance on penetration testing. Maximum 300 words.

## Clean up {#clean-up}

==VM: On the attacker PC==

==action: Make sure Evil Portal is stopped and any spoofed DNS entries have been removed==. ==action: In PineAP, turn off "Broadcast SSID Pool" and "Allow Associations", clear the SSID pool, and clear your filters== so that the next team starts from a clean Pineapple. ==action: Leave the Pineapple's wireless client connected to `CSL-Cafe`== unless your tutor says otherwise.

==VM: On the victim PC==

==action: Forget the `CSL-Cafe` network== (Settings, Network and Internet, Wi-Fi, Manage known networks), ==action: unplug the dongle and plug the network cable back in==.

## Conclusion {#conclusion}

At this point you have:

* Surveyed a wireless network passively and limited your attack to an agreed scope with the Pineapple's filters
* Run an evil twin of an open network and caught a victim as they arrived, without deauthenticating anyone
* Seen how a device chooses a network, and why PMF stops deauthentication but not an evil twin
* Used DNS and SNI to see which HTTPS sites a victim visited
* Captured credentials sent over plain HTTP
* Harvested credentials with a fake captive portal
* (Stretch) Attempted an HTTPS downgrade and seen HSTS block it
* Considered the legal and ethical limits of wireless testing

> Tip: Well done! You have carried out the core of a real wireless assessment.

"Use HTTPS" and "turn on WPA3" each solve part of the problem. Encryption protects the content of a connection, PMF protects a connection that already exists, and only authentication of the network itself (a passphrase the attacker does not know, or 802.1X with certificate checking) stops someone pretending to be it. Everything else, including what a captive portal asks you to type, depends on the user.

## Submission and marking {#submission}

Submit one document per team containing your answers to Submission Questions 1 to 8 (Question 7 is optional), with the screenshots requested, and the names of everyone in your team. If you are unable to work in a team, you may complete the worksheet individually. Submit through MyBeckett by the deadline shown there.

| Section | Weighting |
|---|---|
| Submission Question 1: how wireless attacks and defences have changed, with references | 25% |
| Submission Questions 2 to 6: evidence from the practical tasks and accuracy of explanations | 50% |
| Submission Question 8: legal and ethical considerations | 15% |
| Clarity of communication and use of appropriate references throughout | 10% |

Submission Question 7 is not marked separately, but a good answer can make up for marks lost elsewhere in Questions 2 to 6.
