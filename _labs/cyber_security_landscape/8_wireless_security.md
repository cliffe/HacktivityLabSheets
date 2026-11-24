---
title: "Wireless Security: Evil Twins and Man-in-the-Middle Attacks"
author: ["Tom Shaw"]
license: "CC BY-SA 4.0"
description: "Use a Wi-Fi Pineapple to run an evil twin of a café's open Wi-Fi network, then see what an attacker in the middle can learn and do: the sites a victim visits over HTTPS, passwords sent over plain HTTP, and a victim's browser sent to a fake site, where HTTPS and HSTS stop the attack on one site but not the other."
overview: |
  A phone or laptop that has joined a network once will usually rejoin anything that broadcasts the same name, and on an open network nothing proves that the access point is the real one. In this in-person lab you work in a team with a Wi-Fi Pineapple and a lab PC playing a customer in the "CSL Café". You will survey the wireless network, set up an evil twin of the café's Wi-Fi, knock your victim off the real network so that they reconnect to yours, and then find out what being in the middle actually gives you. You will see which websites the victim visits even though the traffic is encrypted, read a password sent over plain HTTP, and use your control of the victim's DNS to send their browser to a fake shop and a fake bank, where you will see why the attack works against one and HTTPS and HSTS stop it against the other.

  Along the way you will look at how Wi-Fi attacks have changed: why the classic "Karma" attack rarely works against modern devices, why Protected Management Frames stop deauthentication but not evil twins, and which defences actually prevent an attacker from impersonating a network. Your team submits one short worksheet answering the Submission Questions in this sheet, with evidence from the practical tasks.
tags: ["wireless", "wifi", "wifi-pineapple", "evil-twin", "mitm", "dns-spoofing", "hsts", "wireshark", "pmf", "wpa3"]
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

Most people use public Wi-Fi in their homes, at work, in cafés and hotels, on trains, and on our univeristy campus. Very few people check which access point they have actually connected to, and their devices are designed to automatically make the decision for them. This lab looks at Wi-Fi from an attacker's perspective, where you will use a Wi-Fi Pineapple (a small device made by Hak5 for wireless auditing) to impersonate a network and place yourself between a victim and the services they use. This position is known as a **man-in-the-middle** (MITM).

You will carry out the attack, and you will also work out what it does and does not give an attacker today. Many of the attacks that made Wi-Fi notorious ten years ago have been weakened by changes to devices and protocols, whilst others work as well as they ever did. By the end of the lab you should be able to explain which is which, what the countermeasures address, and why some issues remain.

The lab is set in a fictional café, the **CSL Café**, which offers free open Wi-Fi to its customers. Your team takes two roles, and you will swap them part way through:

* **Attackers**, who operate the Wi-Fi Pineapple from one lab PC.
* **Victim**, a customer using a laptop in the café, played by a second lab PC with a USB Wi-Fi dongle.

> Warning: Intercepting other people's wireless traffic, impersonating a network that you do not own, or disrupting a wireless network without permission is a criminal offence in the UK (under the Computer Misuse Act 1990 and the Wireless Telegraphy Act 2006, amongst others). Everything in this lab is done against the lab's own access point and your own team's victim PC, with your tutor's permission. Only ever target your own victim, keep the Pineapple's filters set as described below, never give your evil twin the name of a real network, and never use these techniques outside the lab.

> Warning: When you play the victim, never type a real username or password into anything in this lab. Make up credentials for each task; your attackers are going to read them.

### How to work through this lab {#how-to-work-through-this-lab}

Each team has one Wi-Fi Pineapple and one Wi-Fi dongle, and works on two neighbouring lab PCs. The session lasts two hours, so the practical work is kept to five short parts, and the two written questions that need no hardware (Submission Questions 1 and 6) are completed after the session.

Split your team into two pairs. The first pair operate the Pineapple for Parts 1 to 4 whilst the second pair play the victim; at the start of Part 5 you swap seats, so that everyone gets to run part of the attack. The victim stays connected when you swap, so there is nothing to set up again.

| Time | Task |
|---|---|
| 0:00 | Introduction |
| 0:10 | Getting started and Part 1: surveying the network |
| 0:25 | Part 2: the evil twin |
| 0:45 | Part 3: what the network can see |
| 1:05 | Part 4: reading unencrypted traffic |
| 1:15 | Swap seats, then Part 5: sending the victim to the wrong site |
| 1:45 | Clean up |
| 1:50 | Debrief |

> Note: Read the background section before the session if you can, since there is little time to read it during the practical work.

Your team submits **one** document containing your answers to the numbered **Submission Questions** in this sheet, with screenshots as evidence where asked. Other questions in this sheet are for discussion and your own understanding, and are not submitted. The marking scheme is at the end of the sheet.

### Where to sit {#where-to-sit}

All four teams attack at the same time, in one room, on one shared radio band. A Windows PC joins whichever copy of a network it hears loudest, so your victim must hear your Pineapple far more loudly than the café's router or any other team's Pineapple. Distance is what makes that happen. The café router sits in the middle of the room and each team takes a corner:

```text
 [staff]                          [staff]       front
 A victim    .       .     B victim     row 1   (Pineapple on each victim's desk)
 A attacker  .       .     B attacker   row 2
   .         .       .        .
   .      [ café router ]     .         middle
   .         .       .        .
 C attacker  .       .     D attacker   row 7
 C victim    .       .     D victim     row 8   back
```

* The victim PC takes the corner seat, and the Pineapple sits on the victim's desk, next to the Wi-Fi dongle.
* The attacker PC is the one next to it, towards the middle of the room. The rest of the team sit at the PCs beside them.
* Your tutor will tell you which corner is yours, and may give you a channel for your Pineapple's Open AP so that the teams furthest apart share one.

If your victim sits near the router, or near another team, the attack can fail even when every setting is right, so stay in your corner.

### Sharing the airwaves {#sharing-the-airwaves}

Every Pineapple in the room shares the same channels, so one team's careless settings can stop everybody else's attack from working. Throughout the lab:

* **Do** set your Pineapple's filters to "Allow" with only your own victim's address and only `CSL-Cafe` before you broadcast anything (Part 1 shows how).
* **Don't** use "Deauthenticate All". The only device you may deauthenticate is your own victim, from the Recon page, as described in Part 2.
* **Don't** add any network other than `CSL-Cafe` to the Impersonation pool, and leave "Capture SSIDs to Pool" (or "Auto-collect") turned off. Collecting and broadcasting the names that nearby phones ask for is the old Karma-style approach, and here it would advertise real networks to people outside the lab.
* **Don't** set the beacon or response intervals to "Aggressive". Leave them at "Normal": aggressive beaconing fills the channel and slows down every team, including yours.
* **Don't** move your Pineapple away from your victim, swap Pineapples with another team, or change the café router's settings.
* **Don't** leave anything running when you finish: follow [Clean up](#clean-up) so the next class starts with a clean Pineapple.

### The lab network {#the-lab-network}

The CSL Café network has been set up for you as follows:

| Item | Details |
|---|---|
| Café Wi-Fi network (SSID) | `CSL-Cafe`, open (no password), 2.4 GHz only |
| Café router | `192.168.75.1` or `192.168.75.254`, depending on the room (it is on the router's sticker); hands out addresses in `192.168.75.0/24` |
| Café web server and DNS server | `192.168.75.10` (your tutor's PC) |
| Websites on the café network | `intranet.csl.internal`, `shop.csl.internal`, `bank.csl.internal`, `health.csl.internal`, `jobs.csl.internal` |
| "Attacker" web server (Part 5) | `192.168.75.11` (also your tutor's PC) |

The websites are fictional and only exist on this network; they are there to give your victim something realistic to browse. There is no internet access through the café network, and none is needed.

## Background: how Wi-Fi devices choose a network {#background}

Before attacking the network, it is worth understanding how a device decides which access point to join, since every attack in this lab depends on it.

An access point (AP) announces a network by sending **beacon** frames several times a second, each containing the network's name (its **SSID**), the AP's hardware address (its **BSSID**), the channel and the security settings it supports. Devices listen for beacons to build the list of networks you see when you click the Wi-Fi icon. A device can also send **probe requests** asking whether a network is nearby.

Every device keeps a list of networks it has joined before, often called its **preferred network list** (PNL). When a device sees a beacon for a network in that list, it will usually reconnect automatically, without asking the user. A device identifies a remembered network by its **name and security type**, not by which physical AP it belongs to; a café chain with fifty branches relies on this so that its customers reconnect in every shop. If two APs broadcast the same name, the device normally chooses whichever has the stronger signal.

An **evil twin** is an attacker's AP that copies a legitimate network's name and settings, so that devices connect to it instead. On an open network this needs nothing more than the name. On a network protected with a pre-shared key (WPA2-Personal or WPA3-Personal), the evil twin also needs the password, which stops an outsider but not anyone who knows it; a password printed on the wall of a café is known to everyone in the room. The only common setting in which the AP has to prove its own identity is **WPA2/WPA3-Enterprise (802.1X)**, where the client checks a certificate presented by the network's authentication server, provided the client has been configured to check it.

### What has changed since the early 2010s {#what-has-changed}

The Wi-Fi Pineapple became well known for the **Karma** attack: answering "yes, that's me" to a device's probe requests for any network it asked about, so that a device would connect to the Pineapple while believing it was at home or at work. Karma relied on devices broadcasting the names of networks in their PNL. Modern versions of Windows, macOS, iOS and Android no longer do this for normal (non-hidden) networks, so Karma rarely works against current devices. Attackers adapted by broadcasting beacons for network names that many people are likely to have saved (common café, hotel and transport Wi-Fi names); the Pineapple's **Impersonation pool** (the "SSID pool" on older firmware) does exactly this.

The second classic technique is **deauthentication**. Management frames, which control joining and leaving a network, were originally sent without any protection, so an attacker could forge a "deauthenticate" frame from the AP and knock a device off the network, ready for it to reconnect to an evil twin (or to capture the WPA2 handshake as it reconnects, which can then be cracked offline if the password is weak). **Protected Management Frames** (PMF, defined in IEEE 802.11w, and labelled **MFP**, Management Frame Protection, in many tools including the Pineapple) add cryptographic protection to these frames using keys from the existing connection, so forged deauthentication frames are ignored. PMF is mandatory in WPA3 and optional in WPA2, and many WPA2 networks still run without it, so deauthentication remains effective against a large number of real networks.

PMF protects a connection that already exists. It does nothing to prove to a device that is *about to* join a network that the AP is genuine, so it does not prevent an evil twin. A customer walking into a café, or an employee arriving at the office, will join whichever matching AP is strongest. Deauthentication is also noisy and easy to detect, so real attackers often just wait for new devices to arrive. A two-hour lab leaves no time to wait, so you will deauthenticate your own victim instead.

What an attacker gains from being in the middle has changed too. Almost all web traffic is now encrypted with HTTPS, so passwords for mainstream websites can't simply be read off the wire, though you will find there is still plenty to see.

> Question: Submission Question 1 (complete as a team after the session). Complete a table with one row for each of the following: Karma, deauthentication, evil twin of an open network, evil twin of a network with a shared password, evil twin of a WPA2/WPA3-Enterprise network, and capturing and cracking a WPA2-Personal handshake. For each, give (a) how the attack works, in one or two sentences; (b) whether it is still effective against a typical modern network and device, and in what circumstances; and (c) the defence or defences that prevent it (for example PMF, WPA3-SAE, 802.1X with server certificate validation, strong passphrases, wireless intrusion detection). Reference your sources.

## Getting started {#getting-started}

Decide which pair will start as the attackers and which as the victim, and sit in your team's corner as shown in [Where to sit](#where-to-sit): the victim on the corner seat, the attacker next to them. Put the Pineapple on the victim's desk, as close as possible to the Wi-Fi dongle; this is your strongest defence against accidentally attracting another team's victim, and theirs against attracting yours.

### Victim PC {#victim-pc}

==VM: On the victim PC==

> Warning: ⚠️ **Unplug the victim PC's network cable before you start.** Windows prefers a wired connection over Wi-Fi, so whilst the cable is plugged in your traffic does not travel over the air and your attackers see nothing. The café sites may still seem to work at first, but they stop loading once your victim joins the evil twin in Part 2.

==action: Unplug the PC's network cable==, then ==action: plug in the USB Wi-Fi dongle==, and ==action: click the network icon in the taskbar and connect to `CSL-Cafe`, ticking "Connect automatically"==.

==action: Open a Command Prompt and run:==

```bash
ipconfig
netsh wlan show interfaces
```

> Note: `ipconfig` should show an address in `192.168.75.0/24` for the Wi-Fi adapter. In the output of `netsh wlan show interfaces`, note the **Physical address** (the MAC address your dongle is using on this network; Windows may randomise it per network) and the **BSSID** of the AP you are connected to. Give the physical address to your attackers.

![ipconfig and netsh wlan show interfaces on the victim PC, connected to the café router: gateway 192.168.75.254, BSSID starting 28:87:ba]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/ipconfig.PNG)

==action: Check which network the PC is on==: open Control Panel, then Network and Internet, then Network and Sharing Center. Under "View your active networks", the active network should be the Wi-Fi connection to `CSL-Cafe`. The name on the left may read `CSL-Cafe` or `CSL-Cafe 2`; both are fine. Windows adds " 2" when it has already saved another network with the same name.

![Network and Sharing Center, with CSL-Cafe 2 as the active network and Wi-Fi (CSL-Cafe) as its connection]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/network%20settings.PNG)

==action: Click the Wi-Fi (CSL-Cafe) link next to "Connections" to open Wi-Fi Status, then click Details...==. The Network Connection Details window shows the PC's IPv4 address, default gateway and DNS server. On the café router, the address is in `192.168.75.0/24` and the gateway is the router (`192.168.75.1` or `192.168.75.254`). You will look at this window again in Part 2 to see whether your victim has moved to the Pineapple.

![Wi-Fi Status and Network Connection Details for CSL-Cafe, showing the IPv4 address, default gateway and DNS servers]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/network_connection_details.PNG)

==action: Open your browser (Chrome or Edge) and visit each site in the CSL Cafe folder on the bookmarks bar== (Edge calls it the favourites bar): Intranet, Shop, Bank, Health and Jobs, to check that the café network is working. Visiting the Bank site now matters for Part 5.

> Note: If the sites do not load, check that you are connected to `CSL-Cafe`. If a site starts to load but then times out, the network cable is probably still plugged in. If your browser has no CSL Cafe folder, use Chrome. If the browser tries to use the university proxy, ask your tutor.

### Attacker PC {#attacker-pc}

==VM: On the attacker PC==

==action: Connect the Wi-Fi Pineapple to the PC with its USB-C cable== and wait about a minute for it to boot (the LED settles).

==action: Open a browser and go to the Pineapple's web interface== at `http://PINEAPPLE-IP:1471`, replacing `PINEAPPLE-IP` with the address on the label on your Pineapple (for example `http://172.22.252.102:1471`). Without `:1471` the page will not load. ==action: Log in== with username `root` and password `hak5pineapple`.

> Note: If nothing loads after two or three minutes and no new USB network adapter appears in `ipconfig`, try a different USB cable. Some cables only charge and carry no data.

==action: Check that you can also log in to the Pineapple over SSH from a Command Prompt:==

```bash
ssh root@PINEAPPLE-IP
```

Replace `PINEAPPLE-IP` with the address on your Pineapple's label. The first time, answer `yes` when asked whether to continue connecting; the password is the same as for the web interface. Type `exit` to leave the SSH session.

## Part 1: Surveying the network {#reconnaissance}

The first stage of any wireless assessment is reconnaissance: finding out which networks and devices are present, without sending anything that would affect them.

==VM: On the attacker PC==

==action: Open the Recon page and start a 2-minute scan== (or a continuous one, which you stop once `CSL-Cafe` appears). The Pineapple scans one channel at a time and the room is full of networks, so a short scan can miss `CSL-Cafe`; if it is not listed, scan again before asking for help. Your Pineapple's radios only support 2.4 GHz, so it can only see 2.4 GHz networks and clients.

==action: Find `CSL-Cafe` in the results==. Note its BSSID, channel, encryption and whether it uses management frame protection (the **MFP** column; MFP is also called PMF). ==action: Expand the network to find its clients== and identify your victim by the physical address they gave you.

![The Recon page: the café router's CSL-Cafe (BSSID 28:87:BA:..., channel 6, Open, MFP No), and access points with BSSIDs starting 00:13:37, which belong to a Pineapple]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/RECON.PNG)

> Warning: ⚠️ **Do not attack, deauthenticate or connect to any network except `CSL-Cafe`.** The university's Wi-Fi and every other network you see are real, in use, and not part of this lab. Interfering with them is against university rules and may be illegal. Leave them alone.

> Note: Expect to see a large number of other networks, including the university's own Wi-Fi. If you cannot see your victim, check that the victim PC is connected to `CSL-Cafe` and that the Pineapple is close to it; a scan takes time to visit every channel.

Now limit what the Pineapple will interact with. Professional testers are always bound by a **scope** agreed with the client, and the Pineapple's filters are how you enforce yours.

==action: Open PineAP, then its Filtering page==.

==action: Set the Client Filter to "Allow" mode== (an allow list: only the devices listed may connect), then ==action: add your victim's physical address== exactly as `netsh wlan show interfaces` showed it on the victim PC, six pairs of hexadecimal digits such as `a1:b2:c3:d4:e5:f6`. Add nothing else.

==action: Set the SSID Filter to "Allow" mode and add `CSL-Cafe`== as the only entry.

![The Client Filter and SSID Filter, both on Allow List, with only the victim's address and only CSL-Cafe]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/Filters.PNG)

With these filters, your Pineapple will refuse connections from any other device, including other teams' victims and the phones of anybody passing by.

> Warning: A filter left in "Deny" mode, or an allow list with the wrong address, means your Pineapple will accept other people's devices (or refuse your own victim). Check both filters with a teammate before you start Part 2.

> Note: Use the address `netsh` reported whilst the victim was connected to `CSL-Cafe`, not one printed on the dongle. If Windows' "Random hardware addresses" setting is on, the PC uses a different address for each network.

> Question: Submission Question 2. Include a screenshot of `CSL-Cafe` and your victim in Recon (blur or crop other networks). List what you were able to learn about the network and the victim without connecting to anything or transmitting a single frame. Why does reconnaissance like this raise few, if any, alarms?

## Part 2: The evil twin {#evil-twin}

You will now make the Pineapple impersonate `CSL-Cafe`. For the attack to go unnoticed, your victim must still be able to use the café's websites once they are connected to you, so the Pineapple has to pass their traffic on to the real network.

### Connecting the Pineapple to the real network {#pineapple-upstream}

The Pineapple has three radios: one hosts its management network and the open AP that victims join, one is used by PineAP and Recon, and one can connect to another Wi-Fi network as an ordinary client. Your tutor will normally have connected this client radio to `CSL-Cafe` already.

==action: Open Settings, then Networking, and check that the wireless client is connected to `CSL-Cafe` with an address in `192.168.75.0/24`==. It must be connected to the café router's access point (BSSID starting `28:87:ba`, normally on channel 6), not to a Pineapple's own open AP, which can also be called `CSL-Cafe` and has a BSSID starting `00:13:37`. If it is not connected, scan and join the router's `CSL-Cafe` now.

Your Pineapple blocks DNS answers that point to private addresses such as `192.168.75.10`. This is **DNS rebind protection**: it stops a website on the internet from using DNS to trick your browser into attacking devices on your own network. Here it would stop the café sites working through your Pineapple, so you need to allow the café's domain.

==action: Click the Terminal icon (`>_`) at the top right of the Pineapple's page==; a Web Shell opens at the bottom of the page. ==action: Paste this single line into the Terminal and press Enter:==

```bash
uci -q del_list dhcp.@dnsmasq[0].rebind_domain='csl.internal'; uci add_list dhcp.@dnsmasq[0].rebind_domain='csl.internal'; uci commit dhcp; /etc/init.d/dnsmasq restart; sleep 2; nslookup intranet.csl.internal 127.0.0.1
```

You should see `Address 1: 192.168.75.10` in the last lines. An extra "No answer" line for IPv6, and lines starting `udhcpc`, are normal.

![The Pineapple's Web Shell, opened from the Terminal icon at the top right of the page]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/web_shell.png)

> Note: Run this before your victim joins the Pineapple: it restarts the Pineapple's DNS and DHCP server, which disconnects any connected clients. If the pasted line arrives with extra characters such as `^[[200~` at the start and fails, paste it again or run it over SSH instead.

### Impersonating the café {#impersonating-the-cafe}

==action: Add `CSL-Cafe` to the Impersonation pool==: on the Recon page, select the café router's `CSL-Cafe` and add it to the PineAP pool, or type it in on PineAP's Impersonation tab. Add nothing else.

==action: Set PineAP to Advanced mode and turn on "Impersonate All Networks" and "Advertise AP Impersonation Pool"==. ==action: On PineAP's Evil WPA tab, check that Evil WPA is turned off==: it would broadcast a second, password-protected `CSL-Cafe` (BSSID `00:13:37:be:ef:00`), which Windows treats as a different network. ==action: Check that "Capture SSIDs to Pool" is off and that the intervals are set to "Normal", not "Aggressive"== (see [Sharing the airwaves](#sharing-the-airwaves)), then ==action: save the settings==. Your Pineapple is now broadcasting `CSL-Cafe` and will accept connections to it, but only from your victim, because of the filters you set earlier.

> Note: Menu names vary a little between Pineapple firmware versions. If you cannot find a setting, look at your tutor's Pineapple or ask.

### Moving your victim onto the evil twin {#deauthentication}

Your victim is still connected to the café router, and Windows has no reason to leave a network that is working: in testing, a stronger signal from the Pineapple was not enough on its own. So you will push it. You send a forged **deauthentication** frame that appears to come from the router, telling your victim's PC that it has been disconnected. When the PC reconnects, it joins your Pineapple.

> Warning: Only ever deauthenticate your own victim, and never use "Deauthenticate All". Deauthenticating anybody else's device disrupts a network connection you have no permission to touch.

==VM: On the attacker PC==

==action: On the Recon page, find your victim under the café router's `CSL-Cafe` (BSSID starting `28:87:ba`), select it and click Deauth==.

This works because `CSL-Cafe` is an open network, so it has no management frame protection (look back at the MFP column you noted in Part 1). On a network with MFP, the victim's PC would ignore the forged frame.

==VM: On the victim PC==

==action: Open the Network Connection Details window again== (Network and Sharing Center, Wi-Fi (CSL-Cafe), Details...) and ==action: check the default gateway==. If the address and gateway are no longer in `192.168.75.0/24`, your victim is on the Pineapple. ==action: Run `ipconfig` and `netsh wlan show interfaces` again== and compare them with the output from Getting started: the BSSID now starts `00:13:37`, the prefix Hak5 uses for its Pineapples.

==action: Browse to two or three of the café's sites==, for example [Intranet](http://intranet.csl.internal), [Shop](http://shop.csl.internal) and [Bank](https://bank.csl.internal) (also in the CSL Cafe bookmarks).

==VM: On the attacker PC==

==action: Open the Clients page==. Your victim should appear as connected to your Pineapple, and the Pineapple also shows a notification when it connects.

![The Pineapple's notification that the victim's address has connected]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/client%20connected.png)

> Note: If the victim reconnected to the café router instead, check the PineAP settings and filters, move the Pineapple right next to the dongle, and deauthenticate your victim again. Give it two or three tries before asking your tutor about the backup network below.

> Note: Discussion: from the victim's side, what changed when they were moved to your evil twin? Compare the IP address, gateway and BSSID with those from earlier. Would a typical customer notice being moved to another network?

### If your victim will not join the evil twin {#backup-network}

With four Pineapples and the university's own Wi-Fi in one room, the 2.4 GHz band gets crowded, and your victim may keep choosing the real access point. That is a realistic outcome (attackers in busy places have the same problem), and your tutor will tell you if your team should switch to the **backup network** so that you can still complete Parts 3 to 5.

==VM: On the attacker PC==

==action: Open Settings, then Networking, and change the Pineapple's Open AP name to `CSL-Cafe-Team==edit: your team number==`==, then ==action: save==. Leave PineAP running.

==VM: On the victim PC==

==action: Connect to `CSL-Cafe-Team==edit: your team number==` by choosing it from the network list==, then ==action: run `ipconfig`== to check that you have a Pineapple address rather than a `192.168.75.x` one.

The attack from here on is the same, because your victim's traffic now passes through the Pineapple. The only difference is that your victim chose the network instead of joining it automatically; answer Submission Question 3 about what would have happened with less interference.

> Question: Submission Question 3. Explain, in your own words, why your victim's PC joined your evil twin without asking. Then explain what would have prevented the attack if the café had used (a) WPA2-Personal with the password printed on the menu, (b) WPA3-Personal with the same printed password, (c) WPA2-Personal with PMF enabled, and (d) WPA2-Enterprise with 802.1X, with clients configured to check the server certificate. Be precise: which of these stop an evil twin, which only stop deauthentication, and which stop neither?

## Part 3: What can the network see? {#metadata}

You are now in the middle: every packet your victim sends passes through your Pineapple. You will capture that traffic once and look at it in two ways: in this part, what you can still learn from traffic encrypted with HTTPS, and in Part 4, what you can read from traffic that is not encrypted at all.

==VM: On the attacker PC==

==action: Open a Command Prompt (not PowerShell, which corrupts binary data passed through a pipe) and run the following command to capture traffic on the Pineapple and show it live in Wireshark:==

```bash
ssh root@PINEAPPLE-IP "tcpdump -i any -U -w - not port 22 and not port 1471" | "C:\Program Files\Wireshark\Wireshark.exe" -k -i -
```

Replace `PINEAPPLE-IP` with the address on your Pineapple's label, and enter the Pineapple's password promptly when asked. Wireshark should open and start showing packets.

> Note: Wireshark may say that Npcap is not installed or that no local interfaces are available. Ignore it: the packets come from the Pineapple over SSH, not from this PC's own network adapters.

> Note: If the live capture does not work, capture to a file instead: run `ssh root@PINEAPPLE-IP "tcpdump -i any -w /tmp/capture.pcap not port 22"`, let the victim browse, press Ctrl+C, then copy the file with `scp root@PINEAPPLE-IP:/tmp/capture.pcap .` and open `capture.pcap` in Wireshark.

> Note: If your team could not get a victim connected at all, your tutor will tell you to use the **recorded capture** instead: ==action: open `C:\csl-lab\csl-cafe-capture.pcapng` in Wireshark== and work through the rest of this part and Part 4 on that file. It was recorded on this network by a victim doing exactly what is described below, so every filter in Parts 3 and 4 will work on it.

==VM: On the victim PC==

==action: Browse the [Health](https://health.csl.internal), [Jobs](https://jobs.csl.internal) and [Bank](https://bank.csl.internal) sites from the CSL Cafe bookmarks==, clicking a few pages on each.

==VM: On the attacker PC==

==action: In Wireshark, apply the display filter `dns`==. Each DNS query is a device asking "what is the address of this name?", and these are sent unencrypted.

![Wireshark filtered to dns, showing queries and responses for bank.csl.internal and shop.csl.internal]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/dns_filter.PNG)

==action: Then apply the filter `tls.handshake.extensions_server_name`==. When a browser opens an HTTPS connection, it tells the server which site it wants in the **Server Name Indication** (SNI) field of the TLS handshake, and this is sent before encryption starts.

![A Client Hello with the server_name extension expanded, showing jobs.csl.internal in the SNI field]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/SNI.PNG)

==action: Try to read the content of one of the HTTPS pages==: right-click a Client Hello for one of the HTTPS sites (for example `bank.csl.internal`) and choose Follow, then TLS Stream. The window is empty: Wireshark can't decrypt the connection, because only the victim's browser and the café's server have the keys.

==action: Close it, right-click the same packet and choose Follow, then TCP Stream==, then ==action: set "Show data as" to ASCII==. Near the start you can read the site's name (the SNI). Everything after the handshake is scrambled: that is the encrypted page.

So the network can see **which** HTTPS site the victim visited, but not **what** was on it. In Part 4 you will compare this with a page sent without encryption.

==action: Close the Follow window and clear the display filter== (the ✕ at the right of the filter bar). Follow replaces your filter with one for that single connection, such as `tcp.stream eq 7`, so clearing it shows all the traffic again.

> Note: You will also see traffic that the victim did not knowingly create: Windows checking for updates, telemetry, time synchronisation and connectivity checks. A real device is far noisier than its user realises, and all of this is visible too.

> Note: Consider why a list of the sites someone visited might be sensitive on its own, even without seeing what was on them.

## Part 4: Reading unencrypted traffic {#plain-http}

Not everything uses HTTPS. Older internal systems, embedded devices, IoT devices and some apps still send data in plain text. The café's staff intranet is one of these: it still uses plain HTTP.

==VM: On the victim PC==

==action: Open the [Intranet](http://intranet.csl.internal) site from the CSL Cafe bookmarks and log in with a made-up username and password==. Make a note of what you typed.

==VM: On the attacker PC==

==action: In Wireshark, apply this display filter:==

```bash
http.request.method == "POST"
```

==action: Right-click the request and choose Follow, then HTTP Stream==.

> Question: Submission Question 4. Include a screenshot of the captured intranet login (it will show your victim's made-up credentials). What did the victim's browser display to warn them about the intranet login, and would a typical user notice it?

## Part 5: Sending the victim to the wrong site {#wrong-site}

> Action: Swap seats now. The second pair take over the attacker PC, and the first pair become the victim. Leave the victim connected to the Pineapple and the capture running.

> Note: If your team is using the recorded capture because no victim could connect, your tutor will run this part on the projector. Take your screenshots for Submission Question 5 from the demonstration and answer the question as normal.

On an open network, anyone nearby could read the traffic you captured in Parts 3 and 4. As the victim's access point, you can do more: your Pineapple answers the victim's DNS lookups, so you decide where their browser goes.

==VM: On the attacker PC==

==action: In the Pineapple's Terminal (or over SSH), point the shop and the bank at the attacker's server:==

```bash
echo '192.168.75.11 shop.csl.internal bank.csl.internal' > /tmp/hosts/csl-spoof; killall -HUP dnsmasq; sleep 1; nslookup shop.csl.internal 127.0.0.1
```

You should see `192.168.75.11`. (This only lasts until the Pineapple restarts.)

==VM: On the victim PC==

==action: Close your browser completely (every window), then run `ipconfig /flushdns` in a Command Prompt==. The browser and Windows both remember addresses they looked up earlier, and the browser may also keep its connections to the real servers open. Don't use an Incognito or InPrivate window.

> Warning: Use **made-up details only** from here on. Anything typed into the fake sites is saved in a file that anyone on the café network can open.

==action: Open your browser (Chrome or Edge) and click the Shop bookmark==. Don't type the address: the bookmark starts with `http://`, like an old bookmark or a link in an email. ==action: Log in with made-up details==. Look at the address bar: what does it say, and is there a padlock?

<!-- TODO screenshot (to come from Tom): the fake shop on the victim PC, with "Not secure" in the address bar. -->

==action: Now try typing `shop.csl.internal` into the address bar instead==. You get "This site can't provide a secure connection". Typed addresses go to `https://` (the browser remembers the real shop's HTTPS address from earlier), and the attacker's server can't prove it is the shop, so the browser stops. Modern browsers going to HTTPS by default is one of the main defences against this attack.

==action: Now click the Bank bookmark==. You should see a full-page warning: "Your connection is not private" (Edge: "Your connection isn't private"), saying that attackers might be trying to steal your information from `bank.csl.internal`. ==action: Click Advanced and read what it says==. Is there a link to continue to the site anyway? ==action: Take a screenshot of the warning== to compare with the Shop page.

<!-- TODO screenshot (to come from Tom): the Bank warning on the victim PC, with Advanced open (shows the HSTS line and no "Continue" link). -->

==VM: On the attacker PC==

==action: Find the Shop login in Wireshark, as in Part 4==.

==action: Then see what the attacker's server has been quietly collecting. In the Pineapple's Terminal, run:==

```bash
wget -q -O - http://192.168.75.11/inputs.txt
```

Find your victim's login: the "from" column is your Pineapple's address on the café network. (On the victim PC you can also open `http://192.168.75.11/inputs.txt` in the browser.) Wireshark only shows what passed through your Pineapple whilst it was capturing, whereas the attacker's server keeps every login sent to it.

==action: Undo the change== (you should see `192.168.75.10` again):

```bash
rm -f /tmp/hosts/csl-spoof; killall -HUP dnsmasq; sleep 1; nslookup shop.csl.internal 127.0.0.1
```

==VM: On the victim PC==

==action: Close the browser and run `ipconfig /flushdns` again==, so that it goes back to the real shop.

### Why the bank warned you but the shop didn't {#why-the-bank-warned-you}

Both bookmarks led to the same place: the attacker's server, because your Pineapple gave the victim its address for both names. The difference is what the browser expected to find there.

**The shop** bookmark starts with `http://`. Plain HTTP has no way to check who is answering: any server can reply, and the browser simply shows what it gets. The real shop would have answered by redirecting the browser to `https://`, but the attacker's server never does, so the victim stayed on plain HTTP on a page the attacker controls. The only clue was the small "Not secure" label in the address bar. This is the idea behind **SSL stripping**: keep the victim on HTTP, and HTTPS never gets the chance to protect them.

**The bank** is different in two ways:

1. **HTTPS checks who is answering.** To set up an HTTPS connection, the server must show a certificate for `bank.csl.internal`, signed by an authority the browser trusts. The real bank's certificate is signed by the lab's authority, which the lab PCs trust. The attacker could make a certificate with the right name, but only signed by their own authority, which the PCs don't trust. So the browser can tell this isn't the real bank, and stops before sending anything: no page, no password. That is what the warning means.
2. **HSTS removes the "continue anyway" option.** When the victim visited the real bank earlier, its reply included a header (`Strict-Transport-Security`) telling the browser: "for the next year, only ever use HTTPS for this site". The browser remembered. So even a link starting `http://` is turned into `https://` before anything is sent, and when the certificate is wrong the browser won't let the user click past it. **Advanced** says so: the site uses HSTS, so you can't visit it right now. Without HSTS, many users would click "Continue" and the attack would still work.

| | Shop | Bank |
|---|---|---|
| Bookmark | `http://` | `https://` (and HSTS remembered) |
| What the browser checked | Nothing: plain HTTP | The server's certificate |
| What the victim saw | The fake shop; a small "Not secure" label | A full-page warning, no way past it |
| Did the attacker get the password? | Yes | No |
| What would have protected it | HTTPS for every page, a redirect *and* HSTS, browsers going to HTTPS by default | Already protected |

> Note: HSTS only works once the browser has seen the site over HTTPS at least once. That's why you visited the bank at the start of the lab. Big sites close this gap by being on the **HSTS preload list** built into every browser, so even the very first visit uses HTTPS.

> Question: Submission Question 5. Include a screenshot of the fake Shop page and of the Bank's warning on the victim PC. Why did the attack work against the Shop but fail against the Bank? What would have protected the Shop?

## Ethics and scope {#ethics-and-scope}

The techniques in this lab are used in authorised wireless penetration tests and red team engagements, where the tester has written permission from the organisation and a defined scope. Even then, other people use the same airspace: customers, employees and neighbouring organisations.

> Question: Submission Question 6 (complete as a team after the session). Imagine you have been hired to assess the guest Wi-Fi of a real café chain or a university. Drawing on this lab, describe (a) the legal and ethical requirements you would need in place before starting, and (b) the steps you would take to avoid affecting, or collecting data from, people who are not in scope. Refer to the measures you used in this lab (filters, the choice of network name, deauthenticating only your own victim) and to the National Cyber Security Centre's guidance on penetration testing. Maximum 300 words.

## Clean up {#clean-up}

==VM: On the attacker PC==

==action: In the Pineapple's Terminal, make sure the Part 5 DNS change has been removed:==

```bash
rm -f /tmp/hosts/csl-spoof; killall -HUP dnsmasq
```

==action: In PineAP, turn off "Impersonate All Networks" and "Advertise AP Impersonation Pool", clear the Impersonation pool, and clear your filters== so that the next team starts from a clean Pineapple. ==action: Leave the Pineapple's wireless client connected to `CSL-Cafe`== unless your tutor says otherwise.

==VM: On the victim PC==

==action: Forget the `CSL-Cafe` network== (Settings, Network and Internet, Wi-Fi, Manage known networks), ==action: unplug the dongle and plug the network cable back in==.

## Conclusion {#conclusion}

At this point you have:

* Surveyed a wireless network passively and limited your attack to an agreed scope with the Pineapple's filters
* Run an evil twin of an open network and moved your own victim onto it with a deauthentication attack
* Seen how a device chooses a network, and why PMF stops deauthentication but not an evil twin
* Used DNS and SNI to see which HTTPS sites a victim visited
* Captured credentials sent over plain HTTP
* Used the Pineapple's DNS to send a victim to a fake shop, and seen HTTPS and HSTS stop the same attack against the bank
* Considered the legal and ethical limits of wireless testing

> Tip: Well done! You have carried out the core of a real wireless assessment.

"Use HTTPS" and "turn on WPA3" each solve part of the problem. Encryption protects the content of a connection, PMF protects a connection that already exists, and only authentication of the network itself (a passphrase the attacker does not know, or 802.1X with certificate checking) stops someone pretending to be it. Everything else, including whether anyone notices a small "Not secure" label, depends on the user.

## Submission and marking {#submission}

Submit one document per team containing your answers to Submission Questions 1 to 6, with the screenshots requested, and the names of everyone in your team. If you are unable to work in a team, you may complete the worksheet individually. Submit through MyBeckett by the deadline shown there.

| Section | Weighting |
|---|---|
| Submission Question 1: how wireless attacks and defences have changed, with references | 25% |
| Submission Questions 2 to 5: evidence from the practical tasks and accuracy of explanations | 50% |
| Submission Question 6: legal and ethical considerations | 15% |
| Clarity of communication and use of appropriate references throughout | 10% |
