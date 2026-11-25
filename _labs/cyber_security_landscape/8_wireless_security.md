---
title: "Wireless Security: Evil Twins and Man-in-the-Middle Attacks"
author: ["Tom Shaw"]
license: "CC BY-SA 4.0"
description: "Use a Wi-Fi Pineapple to run an evil twin of a café's open Wi-Fi network, then see what an attacker in the middle can learn and do: the sites a victim visits over HTTPS, passwords sent over plain HTTP, and a victim's browser sent to a fake site, where HTTPS and HSTS stop the attack on one site but not the other."
overview: |
  A phone or laptop that has joined a network once will usually rejoin anything that broadcasts the same name, and on an open network nothing proves that the access point is the real one. In this in-person lab you work in a team with a Wi-Fi Pineapple and a lab PC playing a customer in the "CSL Café". You will survey the wireless network, set up an evil twin of the café's Wi-Fi, knock your victim off the real network so that they reconnect to yours, and then find out what being in the middle actually gives you. You will see which websites the victim visits even though the traffic is encrypted, read a password sent over plain HTTP, and use your control of the victim's DNS to send their browser to a fake shop and a fake bank, where you will see why the attack works against one and HTTPS and HSTS stop it against the other.

  The worksheet's background reading covers how Wi-Fi attacks have changed: why the classic "Karma" attack rarely works against modern devices, why Protected Management Frames stop deauthentication but not evil twins, and which defences actually prevent an attacker from impersonating a network. Your team submits one worksheet (downloaded from MyBeckett) answering the Submission Questions, with evidence from the practical tasks.
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

Most people use public Wi-Fi: in cafés and hotels, on trains, and on our university campus. Very few check which access point they have actually connected to, because their devices make that decision for them. This lab looks at Wi-Fi from an attacker's perspective. You will use a Wi-Fi Pineapple (a small device made by Hak5 for wireless auditing) to impersonate a network and place yourself between a victim and the services they use. This position is known as a **man-in-the-middle** (MITM).

You will carry out the attack, and you will also work out what it does and does not give an attacker today. Many of the attacks that made Wi-Fi notorious ten years ago have been weakened by changes to devices and protocols, whilst others work as well as they ever did. By the end of the lab you should be able to explain which is which, what the countermeasures address, and why some issues remain.

The lab is set in a fictional café, the **CSL Café**, which offers free open Wi-Fi to its customers. Your team works on two lab PCs:

* **Attackers**, who operate the Wi-Fi Pineapple from one lab PC.
* **Victim**, a customer using a laptop in the café, played by a second lab PC with a USB Wi-Fi dongle.

> Warning: ⚠️ Intercepting other people's wireless traffic, impersonating a network that you do not own, or disrupting a wireless network without permission is a criminal offence in the UK (under the Computer Misuse Act 1990 and the Wireless Telegraphy Act 2006, amongst others). Everything in this lab is done against the lab's own access point and your own team's victim PC, with your tutor's permission. Only ever target your own victim, keep the Pineapple's filters set as described below, never give your evil twin the name of a real network, and never use these techniques outside the lab.

> Warning: ⚠️ Never type a real username or password into anything on the victim PC. Make up credentials for each task: they will be read on the attacker PC.

### How to work through this lab {#how-to-work-through-this-lab}

Each team has one Wi-Fi Pineapple and one Wi-Fi dongle, and works on two neighbouring lab PCs. The session lasts two hours, so the practical work is kept to five short parts. ==action: Use a third PC, not the attacker or victim PC, to read this sheet and download the worksheet from MyBeckett==.

Everyone in the team should follow every step from both perspectives: what the attacker does on one PC, and what the victim sees on the other.

The numbered **Submission Questions** in this sheet are repeated in the worksheet, which also holds Question 1 and its background reading. Other questions in this sheet are for discussion and are not submitted. Your team submits **one** completed worksheet via MyBeckett. [Submission and marking](#submission) explains what to hand in. If something doesn't work, check the [FAQ](#faq) at the end of the sheet.

### Sharing the airwaves {#sharing-the-airwaves}

Every Pineapple in the room shares the same channels, so one team's careless settings can stop everybody else's attack from working. Throughout the lab:

* **Do** set your Pineapple's filters to "Allow" with only your own victim's MAC/hardware address and only `CSL-Cafe` before you broadcast anything (Part 1 shows how).
* **Don't** use "Deauthenticate All". The only device you may deauthenticate is your own victim, from the Recon page, as described in Part 2.
* **Don't** add any network other than `CSL-Cafe` to the Impersonation pool, and leave "Capture SSIDs to Pool" (or "Auto-collect") turned off.
* **Don't** move your Pineapple away from your victim, swap Pineapples with another team, or change the café router's settings.
* **Don't** leave anything running when you finish: follow [Clean up](#clean-up) so the next class starts with a clean Pineapple.

### The lab network {#the-lab-network}

The CSL Café network has been set up for you as follows:

| Item | Details |
|---|---|
| Café Wi-Fi network (SSID) | `CSL-Cafe`, open (no password), 2.4 GHz only |
| Websites on the café network | `intranet.csl.internal`, `shop.csl.internal`, `bank.csl.internal`, `health.csl.internal`, `jobs.csl.internal` |
| Café router | `192.168.75.1` or `192.168.75.254`, depending on the room (it is on the router's sticker); hands out addresses in `192.168.75.0/24` |
| Café web server and DNS server | `192.168.75.10` |
| "Attacker" web server (Part 5) | `192.168.75.11` |

The websites are fictional and only exist on this network; they are there to give your victim something realistic to browse. There is no internet access through the café network, and none is needed.


## Getting started {#getting-started}

==action: Read this sheet and download the worksheet from MyBeckett on a third PC, not the attacker or victim PC==. The attacker and victim PCs keep their network cables unplugged for the whole lab, and the next class uses them as you leave them, so don't log in to MyBeckett or your email on them.

> Note: **Copy your screenshots onto a USB stick.** Take each screenshot on the attacker or victim PC when the sheet asks for it, save it, and copy it onto one of the USB sticks provided. Use the USB stick to move the screenshots to the third PC and add them to your worksheet. Before you leave, delete them from the attacker and victim PCs (see [Clean up](#clean-up)).

==action: Open your Hak5 kit and take out the Wi-Fi Pineapple, its three antennae and the USB-C to USB-C cable. Screw the antennae onto the Pineapple. Don't plug the Pineapple into your PC yet.==

Place the Pineapple on the victim's desk, as close as possible to the Wi-Fi dongle; this is your strongest defence against accidentally attracting another team's victim, and theirs against attracting yours.

### Victim PC {#victim-pc}

==VM: On the victim PC==

> Warning: ⚠️ **Unplug the victim PC's network cable before you start.** Windows prefers a wired connection over Wi-Fi, so whilst the cable is plugged in your traffic does not travel over the air and the attacker PC sees nothing. The café sites may still seem to work at first, but they stop loading once your victim joins the evil twin in Part 2.

==action: Unplug the PC's network cable==, then ==action: plug in the USB Wi-Fi dongle==, and ==action: click the network icon in the taskbar and connect to `CSL-Cafe`, ticking "Connect automatically"==. Windows may show the network as `CSL-Cafe 2` in some places; that is fine. Windows adds " 2" when it has already saved another network with the same name.

==action: Open a Command Prompt and run:==

```bash
ipconfig
netsh wlan show interfaces
```

> Note: `ipconfig` should show an address in `192.168.75.0/24` for the Wi-Fi adapter, with the café router (`192.168.75.1` or `192.168.75.254`) as its default gateway. In the output of `netsh wlan show interfaces`, note the **BSSID** of the access point you are connected to and the **Physical address**: the MAC address your dongle is using on this network. You need the physical address on the attacker PC in Part 1. Windows may use a different random address for each network (the "Random hardware addresses" setting), so use the one shown heref, not one printed on the dongle.

![ipconfig and netsh wlan show interfaces on the victim PC, connected to the café router: gateway 192.168.75.254, BSSID starting 28:87:ba]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/ipconfig.PNG)

==action: Open your browser (Chrome or Edge) and visit each site in the CSL Cafe folder on the bookmarks/favourites bar==: Intranet, Shop, Bank, Health and Jobs, to check that the café network is working.

> Note: If the sites do not load, check that you are connected to `CSL-Cafe`. If a site starts to load but then times out or if the browser tries to use the university proxy, the network cable is probably still plugged in. If your browser has no CSL Cafe folder, use Chrome.

### Attacker PC {#attacker-pc}

==VM: On the attacker PC==

==action: Unplug the attacker PC's network cable==, then ==action: connect the Wi-Fi Pineapple to the PC with its USB-C cable== and wait about a minute for it to boot (the LED settles).

==action: Open a browser and go to the Pineapple's web interface== at `http://PINEAPPLE-IP:1471`, replacing `PINEAPPLE-IP` with the address on the label on your Pineapple (for example `http://172.22.252.102:1471`). Without `:1471` the page will not load. ==action: Log in== with username `root` and password `hak5pineapple`.

The first time the interface opens, a window may ask you to set up an internet connection for the Pineapple. ==action: Close that window==: the Pineapple doesn't need the internet in this lab.

> Note: If the page doesn't load, see [The Pineapple's web interface won't load](#faq-web-interface) in the FAQ.

==action: Check that you can also log in to the Pineapple over SSH from a Command Prompt:==

```bash
ssh root@PINEAPPLE-IP
```

As above, replace `PINEAPPLE-IP` with the IP address on your Pineapple's label. The first time, answer `yes` when asked whether to continue connecting; the password is the same as for the web interface. Type `exit` to leave the SSH session.

## Part 1: Surveying the network {#reconnaissance}

The first stage of any wireless assessment is reconnaissance: finding out which networks and devices are present, without sending anything that would affect them.

==VM: On the attacker PC==

==action: Open the Recon page and start a 2-minute scan== (or a continuous one, which you stop once `CSL-Cafe` appears; you may need to increase the items displayed per page to 100 to see it). The Pineapple scans one channel at a time and the room is full of networks, so a short scan can miss `CSL-Cafe`; if it is not listed, scan again before asking for help. Your Pineapple's radios only support 2.4 GHz, so it can only see 2.4 GHz networks and clients.

==action: Find `CSL-Cafe` in the results==. Note its BSSID, channel, encryption and whether it uses management frame protection (the **MFP** column; MFP is also called PMF). ==action: Expand the network to find its clients== and identify your victim by the physical address you noted on the victim PC.

![The Recon page: the café router's CSL-Cafe (BSSID 28:87:BA:..., channel 6, Open, MFP No), and access points with BSSIDs starting 00:13:37, which belong to a Pineapple]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/RECON.PNG)

> Warning: ⚠️ **Do not attack, deauthenticate or connect to any network except CSL-Cafe.** The university's Wi-Fi and every other network you see are real, in use, and not part of this lab. Interfering with them is against university rules and may be illegal. Leave them alone.

> Note: Expect to see a large number of other networks, including the university's own Wi-Fi. If you cannot see your victim, check that the victim PC is connected to `CSL-Cafe` and that the Pineapple is close to it; a scan takes time to visit every channel.

Now limit what the Pineapple will interact with. Professional testers are always bound by a **scope** agreed with the client, and the Pineapple's filters are how you enforce yours.

==action: Open PineAP, then its Filtering page==.

==action: Set the Client Filter to "Allow" mode== (an allow list: only the devices listed may connect), then ==action: add your victim's physical address== exactly as `netsh wlan show interfaces` showed it on the victim PC, six pairs of hexadecimal digits such as `a1:b2:c3:d4:e5:f6`. Add nothing else.

==action: Set the SSID Filter to "Allow" mode, remove any existing entries using the red button at the bottom, and add `CSL-Cafe`== as the only entry.

![The Client Filter and SSID Filter, both on Allow List, with only the victim's address and only CSL-Cafe]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/Filters.PNG)

With these filters, your Pineapple will refuse connections from any other device, including other teams' victims and the phones of anybody passing by.

> Warning: ⚠️ A filter left in "Deny" mode, or an allow list with the wrong address, means your Pineapple will accept other people's devices (or refuse your own victim). Check both filters with a teammate before you start Part 2.

> Question: Submission Question 2. Include a screenshot of `CSL-Cafe` and your victim in Recon (blur or crop other networks). List what you were able to learn about the network and the victim without connecting to anything or transmitting a single frame. Why does reconnaissance like this raise few, if any, alarms?

## Part 2: The evil twin {#evil-twin}

You will now make the Pineapple impersonate `CSL-Cafe`. For the attack to go unnoticed, your victim must still be able to use the café's websites once they are connected to you, so the Pineapple has to pass their traffic on to the real network.

### Connecting the Pineapple to the real network {#pineapple-upstream}

The Pineapple has three radios: one hosts its management network and the open AP that victims join, one is used by PineAP and Recon, and one (`wlan2`) can join another Wi-Fi network as an ordinary client. Before you impersonate the café, join `wlan2` to the café router, so that the Pineapple can pass your victim's traffic on.

1. ==action: Open Settings, then Networking. In Wireless Client Mode, select `wlan2` and click Scan==.

   <Insert screenshot 1 showing wlan2 and scan button>

2. ==action: Choose `CSL-Cafe` from the drop-down list and connect to it==. Pick the café router: BSSID starting `28:87:ba`, normally on channel 6. Other teams may already be impersonating the café, so you may see more than one `CSL-Cafe`; any with a BSSID starting `00:13:37` is a Pineapple, not the router. The café network is open, so you should not be asked for a password. If you are, you have picked the wrong `CSL-Cafe`: go back and choose the router.

   <Insert screenshot 2 showing the cafe router>

3. ==action: Check that `wlan2` now shows an IP address in `192.168.75.0/24`==.

![Settings, Networking: Wireless Client Mode connected to CSL-Cafe on wlan2, with an IP address of 192.168.75.102]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/Wireless%20IP%20Addr.png)

> Note: If `wlan2` already shows `CSL-Cafe` with an address in `192.168.75.0/24`, check that it is the router's BSSID and carry on. If it doesn't get an address, see [The Pineapple isn't connected to CSL-Cafe](#faq-pineapple-client).

Your Pineapple blocks DNS answers that point to private addresses such as `192.168.75.10`. This is **DNS rebind protection**: it stops a website on the internet from using DNS to trick your browser into attacking devices on your own network. Here it would stop the café sites working through your Pineapple, so you need to allow the café's domain.

> Note: Do this before your victim joins the Pineapple. The command restarts the Pineapple's DNS and DHCP server, which disconnects any connected clients.

==action: Click the Terminal icon (`>_`) at the top right of the Pineapple's page==; a Web Shell opens at the bottom of the page. ==action: Paste this single line into the Terminal and press Enter:==

```bash
uci -q del_list dhcp.@dnsmasq[0].rebind_domain='csl.internal'; uci add_list dhcp.@dnsmasq[0].rebind_domain='csl.internal'; uci commit dhcp; /etc/init.d/dnsmasq restart; sleep 2; nslookup intranet.csl.internal 127.0.0.1
```

You should see `Address 1: 192.168.75.10` in the last lines. An extra "No answer" line for IPv6, and lines starting `udhcpc`, are normal.

![The Pineapple's Web Shell after the DNS fix: nslookup returns Address 1: 192.168.75.10 for intranet.csl.internal]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/dns_config.png)

> Note: If the pasted line arrives with extra characters such as `^[[200~` at the start and fails, press Enter a couple of times and paste it again.

### Impersonating the café {#impersonating-the-cafe}

1. ==action: Add `CSL-Cafe` to the Impersonation pool==: on the Recon page, select the café router's `CSL-Cafe` and add it to the PineAP pool, or type it in on PineAP's Impersonation tab. Add nothing else.
2. ==action: Set PineAP to Advanced mode and turn on "Impersonate All Networks" and "Advertise AP Impersonation Pool"==.
3. ==action: On PineAP's Evil WPA tab, check that Evil WPA is turned off==. If it is on, it broadcasts a second, password-protected `CSL-Cafe` (BSSID `00:13:37:be:ef:00`), which Windows treats as a different network.
4. ==action: Check that "Capture SSIDs to Pool" is off and that the intervals are set to "Normal", not "Aggressive"==.
5. ==action: Save the settings==.

Your Pineapple is now broadcasting `CSL-Cafe` and will accept connections to it, but only from your victim, because of the filters you set earlier.

> Note: Menu names vary a little between Pineapple firmware versions. If you cannot find a setting, ask your tutor.

### Moving your victim onto the evil twin {#deauthentication}

Your victim is still connected to the café router, and Windows has no reason to leave a network that is working. In order to kick a client off you can send a forged **deauthentication** frame that appears to come from the router, telling the Victim PC that it has been disconnected. When the PC reconnects, if all goes well it will automatically reconnect to your Pineapple rather than the router.

> Warning: ⚠️ Only ever deauthenticate your own victim, and never use "Deauthenticate All". Deauthenticating anybody else's device disrupts a network connection you have no permission to touch.

==VM: On the attacker PC==

==action: On the Recon page, find your victim under the café router's `CSL-Cafe` (BSSID starting `28:87:ba`), select it and click Deauth==.

This works because `CSL-Cafe` is an open network, so it has no management frame protection (look back at the MFP column you noted in Part 1). On a network with MFP, the victim's PC would ignore the forged frame.

==VM: On the victim PC==

==action: Run `ipconfig` and `netsh wlan show interfaces` again== and compare them with your output from Getting started. Your victim is on the Pineapple if:

* the address and default gateway are no longer in `192.168.75.0/24` (the gateway is now your Pineapple), and
* the BSSID now starts `00:13:37`, the prefix Hak5 uses for its Pineapples.

If they still show the café router, see the note at the end of this section.

==action: Browse to two or three of the café's sites==, for example [Intranet](http://intranet.csl.internal), [Shop](http://shop.csl.internal) and [Bank](https://bank.csl.internal) (also in the CSL Cafe bookmarks).

==VM: On the attacker PC==

==action: Open the Clients page==. Your victim should appear as connected to your Pineapple, and the Pineapple also shows a notification when it connects.

![The Pineapple's notification that the victim's address has connected]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/client%20connected.png)

> Note: If the victim reconnected to the café router instead, check the PineAP settings and filters, move the Pineapple right next to the dongle, and deauthenticate your victim again. It may take a few attempts. If you cannot get this working after five minutes, tell your tutor.

> Note: Discussion: would a typical customer notice being moved to another network?

> Question: Submission Question 3. Include a screenshot of the Pineapple's Clients page (or its notification) showing your victim connected. Explain, in your own words, why your victim's PC joined your evil twin without asking.

## Part 3: What can the network see? {#metadata}

You are now in the middle: every packet your victim sends passes through your Pineapple. You will capture that traffic once and look at it in two ways: in this part, what you can still learn from traffic encrypted with HTTPS, and in Part 4, what you can read from traffic that is not encrypted at all.

==VM: On the attacker PC==

==action: Open a Command Prompt (not PowerShell, which corrupts binary data passed through a pipe) and run the following command to capture traffic on the Pineapple and show it live in Wireshark:==

```bash
ssh root@PINEAPPLE-IP "tcpdump -i any -U -w - not port 22 and not port 1471" | "C:\Program Files\Wireshark\Wireshark.exe" -k -i -
```

Replace `PINEAPPLE-IP` with the address on your Pineapple's label, and enter the Pineapple's password promptly when asked. Wireshark should open and start showing packets.

> Note: Wireshark may say that Npcap is not installed or that no local interfaces are available. Ignore it: the packets come from the Pineapple over SSH, not from this PC's own network adapters.

==VM: On the victim PC==

==action: Browse the [Health](https://health.csl.internal), [Jobs](https://jobs.csl.internal) and [Bank](https://bank.csl.internal) sites from the CSL Cafe bookmarks==, clicking a few pages on each.

==VM: On the attacker PC==

==action: In Wireshark, apply the display filter `dns`==. Each DNS query is a device asking "what is the address of this name?", and these are sent unencrypted.

![Wireshark filtered to dns, showing queries and responses for bank.csl.internal and shop.csl.internal]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/dns_filter.PNG)

==action: Then apply the filter `tls.handshake.extensions_server_name`==. When a browser opens an HTTPS connection, it tells the server which site it wants in the **Server Name Indication** (SNI) field of the TLS handshake, and this is sent before encryption starts.

![A Client Hello with the server_name extension expanded, showing jobs.csl.internal in the SNI field]({{ site.baseurl }}/assets/images/cyber_security_landscape/8_wireless_security/SNI.PNG)

> Note: Newer technologies can hide both of these. DNS over HTTPS (DoH) encrypts DNS lookups, and Encrypted Client Hello (ECH) encrypts the SNI. Neither is in use on the café network.

==action: Try to read the content of one of the HTTPS pages==: right-click a Client Hello for one of the HTTPS sites (for example `bank.csl.internal`) and choose Follow, then TLS Stream. The window is empty: Wireshark can't decrypt the connection, because only the victim's browser and the café's server have the keys.

==action: Close it, right-click the same packet and choose Follow, then TCP Stream==, then ==action: set "Show data as" to ASCII==. Near the start you can read the site's name (the SNI). Everything after the handshake is scrambled: that is the encrypted page.

So the network can see **which** HTTPS site the victim visited, but not **what** was on it. In Part 4 you will compare this with a page sent without encryption.

==action: Close the Follow window and clear the display filter== (the ✕ at the right of the filter bar). Follow replaces your filter with one for that single connection, such as `tcp.stream eq 7`, so clearing it shows all the traffic again.

> Note: You will also see traffic that the victim did not knowingly create: Windows checking for updates, telemetry, time synchronisation and connectivity checks. A real device is far noisier than its user realises, and all of this is visible too.

> Note: Discussion: why might a list of the sites someone visited be sensitive on its own, even without seeing what was on them?

> Question: Submission Question 4. Include a screenshot of a Client Hello with the `server_name` extension expanded, and of the Follow TCP Stream window for one HTTPS connection (for example to the bank). What could you learn about your victim's HTTPS browsing, and what stayed hidden? Would someone passively sniffing the open café network, without an evil twin, have seen the same?

## Part 4: Reading unencrypted traffic {#plain-http}

Not everything uses HTTPS. Older internal systems, embedded devices, IoT devices and some apps still send data in plain text. The café's staff intranet is one of these: it still uses plain HTTP.

==VM: On the victim PC==

==action: Open the [Intranet](http://intranet.csl.internal) site from the bookmarks folder and log in with a made-up username and password==. Make a note of what you typed, and look at what the browser shows at the left of the address bar.

==VM: On the attacker PC==

==action: In Wireshark, apply this display filter:==

```bash
http.request.method == "POST"
```

==action: Right-click the request and choose Follow, then HTTP Stream==. The username and password the victim typed are in the request, in plain text.

> Question: Submission Question 5. Include a screenshot of the Follow HTTP Stream window showing the username and password your victim typed. Explain why you could read this login, but not the content of the bank's pages in Part 3.

## Part 5: Sending the victim to the wrong site {#wrong-site}

On an open network, anyone nearby could read the traffic you captured in Parts 3 and 4. Encrypting the Wi-Fi itself makes passive eavesdropping much harder, but it doesn't help once the victim has joined the attacker's access point. As the victim's access point you can also do more: your Pineapple answers the victim's DNS lookups, so you decide where their browser goes.

==VM: On the attacker PC==

==action: In the Pineapple's Terminal (or over SSH), point the shop and the bank at the attacker's server:==

```bash
echo '192.168.75.11 shop.csl.internal bank.csl.internal' > /tmp/hosts/csl-spoof; killall -HUP dnsmasq; sleep 1; nslookup shop.csl.internal 127.0.0.1
```

You should see `192.168.75.11`. (This only lasts until the Pineapple restarts.) Ignore the "No answer" line, as before.

==VM: On the victim PC==

The browser remembers addresses it looked up earlier, and may keep its connections to the real servers open. ==action: Close your browser completely (every window)==.

> Warning: ⚠️ Don't use an Incognito or InPrivate window for this part. A private window starts without the browser's memory of the sites you visited earlier in the lab, and this part depends on that memory.

> Warning: ⚠️ Use **made-up details only** from here on. Anything typed into the fake sites is saved in a file that anyone on the café network can open.

==action: Open your browser (Chrome or Edge) and click the Shop bookmark==. If the address bar shows `https://` and a padlock, you have reached the real shop: follow [I still reach the real shop after the DNS change](#faq-real-shop) in the FAQ.

==action: Log in with made-up details==. Look at the address bar: what does it say, and is there a padlock?

==action: Now try typing `shop.csl.internal` into the address bar instead==. You get "This site can't provide a secure connection". Typed addresses go to `https://` (the browser remembers the real shop's HTTPS address from earlier), and the attacker's server can't prove it is the shop, so the browser stops. Modern browsers going to HTTPS by default is one of the main defences against this attack.

==action: Now click the Bank bookmark==. You should see a full-page warning: "Your connection is not private" (Edge: "Your connection isn't private"), saying that attackers might be trying to steal your information from `bank.csl.internal`. ==action: Click Advanced and read what it says==. Is there a link to continue to the site anyway? ==action: Take a screenshot of the warning, with Advanced open==.

> Hint: Compare how the two bookmarks start (`http://` or `https://`), and read what the Advanced section says. Then look up **HTTP Strict Transport Security** (HSTS), and remember that your victim visited the real bank at the start of the lab.

==VM: On the attacker PC==

==action: Find the Shop login in Wireshark, as in Part 4==.

==action: Then see what the attacker's server has been quietly collecting. In the Pineapple's Terminal, run:==

```bash
wget -q -O - http://192.168.75.11/inputs.txt
```

(Or, on the victim PC, open `http://192.168.75.11/inputs.txt` in the browser.) Find your victim's login: the "from" column is your Pineapple's address on the café network. ==action: Take a screenshot showing your victim's line==. Wireshark only shows what passed through your Pineapple whilst it was capturing, whereas the attacker's server keeps every login sent to it.

> Question: Submission Question 6. Include screenshots of the fake Shop page on the victim PC (with the address bar visible), the Bank's warning with Advanced open, and your victim's line in inputs.txt. Why did the attack work against the Shop but fail against the Bank? Explain the part HSTS played.

==action: Undo the change== (you should see `192.168.75.10` again):

```bash
rm -f /tmp/hosts/csl-spoof; killall -HUP dnsmasq; sleep 1; nslookup shop.csl.internal 127.0.0.1
```

==VM: On the victim PC==

==action: Close the browser and run `ipconfig /flushdns` in a Command Prompt==, so that it goes back to the real shop.


## Ethics and scope {#ethics-and-scope}

The techniques in this lab are used in authorised wireless penetration tests and red team engagements, where the tester has written permission from the organisation and a defined scope. Even then, other people share the same airspace: customers, employees and neighbouring organisations.

> Question: Submission Question 7 (complete as a team after the session). Imagine you have been hired to assess the guest Wi-Fi of a real café chain or a university. Drawing on this lab, describe (a) the legal and ethical requirements you would need in place before starting, and (b) the steps you would take to avoid affecting, or collecting data from, people who are not in scope. Refer to the measures you used in this lab (filters, the choice of network name, deauthenticating only your own victim) and to the National Cyber Security Centre's guidance on penetration testing. Maximum 300 words.

## Clean up {#clean-up}

==VM: On the attacker PC==

==action: In the Pineapple's Terminal, make sure the Part 5 DNS change has been removed:==

```bash
rm -f /tmp/hosts/csl-spoof; killall -HUP dnsmasq
```

==action: In PineAP, turn off "Impersonate All Networks" and "Advertise AP Impersonation Pool", clear the Impersonation pool, and clear your filters== so that the next team starts from a clean Pineapple. ==action: Leave the Pineapple's wireless client connected to `CSL-Cafe`== unless your tutor says otherwise.

==VM: On the victim PC==

==action: Forget the `CSL-Cafe` network== (Settings, Network and Internet, Wi-Fi, Manage known networks), ==action: unplug the dongle==.

==VM: On both PCs==

==action: Check that all your screenshots are on the USB stick, then delete them from the PC and empty the Recycle Bin==. Leave the network cables unplugged: the next class uses these PCs as they are.

## Conclusion {#conclusion}

At this point you have:

* Surveyed a wireless network passively and limited your attack to an agreed scope with the Pineapple's filters
* Run an evil twin of an open network and moved your own victim onto it with a deauthentication attack
* Used DNS and SNI to see which HTTPS sites a victim visited
* Captured credentials sent over plain HTTP
* Used the Pineapple's DNS to send a victim to a fake shop, and seen HTTPS and HSTS stop the same attack against the bank
* Considered the legal and ethical limits of wireless testing

The worksheet's background reading and Question 1 put these attacks in context: how Wi-Fi attacks and defences have changed, and why PMF stops deauthentication but not an evil twin.

> Tip: Well done! You have carried out the core of a real wireless assessment.


## Submission and marking {#submission}

Download the worksheet from MyBeckett, and submit one completed worksheet per team containing your answers to Submission Questions 1 to 7, with the screenshots requested, and the names of everyone in your team. Questions 1 and 7 are completed as a team after the session. If you are unable to work in a team, you may complete the worksheet individually. Submit through MyBeckett by the deadline shown there.

| Section | Weighting |
|---|---|
| Submission Question 1: how wireless attacks and defences have changed, with references | 25% |
| Submission Questions 2 to 6: evidence from the practical tasks and accuracy of explanations | 40% |
| Submission Question 7: legal and ethical considerations | 25% |
| Clarity of communication and use of appropriate references throughout | 10% |

## FAQ and troubleshooting {#faq}

### The Pineapple's web interface won't load {#faq-web-interface}

* Check the address: it must be the one on your Pineapple's label, with `:1471` on the end.
* Give the Pineapple two or three minutes to boot after plugging it in.
* Run `ipconfig` on the attacker PC. Plugging in the Pineapple should add a new network adapter with an address starting `172.`. If no new adapter appears, try a different USB cable: some cables only charge and carry no data.
* If the browser shows an "Access denied" page from the university proxy, ask your tutor.

### The Pineapple isn't connected to CSL-Cafe {#faq-pineapple-client}

The Pineapple's wireless client (`wlan2`) can drop off the café network, for example if the café router is restarted, and it doesn't always rejoin by itself. While it is disconnected, the café sites won't load on a victim connected to the Pineapple, and the Pineapple's DNS lookups for the café sites fail.

To check, run these in the Pineapple's Terminal:

```bash
iw dev wlan2 link
ip -4 addr show wlan2
```

The first should say `Connected to 28:87:ba:...`, and the second should show an address in `192.168.75.0/24`. If either doesn't, join the café router again by repeating the steps in [Connecting the Pineapple to the real network](#pineapple-upstream), then check again with the two commands above.

If this does not work, it may be due to the router's signal. Talk to your tutor.

### The café sites don't load on the victim PC {#faq-sites-dont-load}

* If names resolve but every page times out, the victim PC's network cable is probably still plugged in. Unplug it.
* If the victim is on the Pineapple, check the Pineapple can reach the café server. In the Pineapple's Terminal, run `nslookup intranet.csl.internal 127.0.0.1`. You should see `192.168.75.10`.
* If that lookup fails, check the Pineapple's wireless client ([previous question](#faq-pineapple-client)), then run the DNS fix from [Part 2](#pineapple-upstream) again. It disconnects the victim, so deauthenticate them again afterwards.

### Wireshark opens and closes again, or shows no packets {#faq-wireshark}

* Run the capture command from a Command Prompt, not PowerShell.
* Log in once with `ssh root@PINEAPPLE-IP` first, so that the "continue connecting" question has already been answered, and type the password promptly when the capture command asks for it.
* Check that `PINEAPPLE-IP` has been replaced with your Pineapple's address.

### I still reach the real shop after the DNS change {#faq-real-shop}

Windows also remembers addresses it looked up earlier, separately from the browser.

==VM: On the victim PC==

==action: Close your browser completely (every window), then run these in a Command Prompt:==

```bash
ipconfig /flushdns
nslookup shop.csl.internal
```

`nslookup` asks the DNS server directly, so it should now show `192.168.75.11`. If it still shows `192.168.75.10`, the DNS change on the Pineapple hasn't worked: run the Part 5 command in the Pineapple's Terminal again and check that its `nslookup` shows `192.168.75.11`. Then open the browser and click the Shop bookmark again.

### Typing the shop's address gives "This site can't provide a secure connection" {#faq-typed-address}

That is expected: typed addresses go to `https://`. Use the Shop bookmark, which starts with `http://`. If the bookmark gives the same error, ask your tutor.
