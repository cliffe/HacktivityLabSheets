---
title: "Open Day Hacktivity"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
overview: |
  A short taster exercise for open day visitors. You will get a feel for the kind of activities you will get up to on the course, see our lab platform Hacktivity in action, and hack into a server by following some of the typical steps in an attack. Similar techniques are used by malicious attackers and security professionals alike.

  You will work through the three stages of a typical attack: information gathering (scanning the network to find a victim and its services), exploitation (attacking a vulnerable service to gain access), and post-exploitation (using that access to read files and uncover credentials that lead on to another system). Along the way you will use popular tools including the Metasploit Framework, the Armitage GUI, the Nmap scanner, and various Linux commands.
description: |
  A beginner-friendly open day taster in which you scan a network, exploit a vulnerable IRC server with Armitage and Metasploit, and use post-exploitation to steal credentials and pivot to a third machine. No prior experience needed.
tags: ["open-day", "taster", "armitage", "metasploit", "nmap", "exploitation", "post-exploitation", "penetration-testing"]
categories: ["introducing_attacks"]
type: ["ctf-lab", "lab-sheet"]
---

## Introduction {#introduction}

In this short exercise you will:

1. Get a taster of the kind of activities you will get up to on the course.
2. See our lab platform, Hacktivity, in action.
3. Hack into a server! You will follow some of the typical steps in an attack. Similar techniques are used by malicious attackers and security professionals alike.

This may be your first step on your path to a life of hacking and cyber security.

## Preparation {#preparation}

\==action: Make sure you are logged into Hacktivity== (https://hacktivity.leedsbeckett.ac.uk/).

You can stay logged in to the machine in the open day lab room, or open a private browser tab and register yourself an account (which takes a while longer).

> Tip: If you need instructions for registering, [click here for a guide to using Hacktivity](https://docs.google.com/document/d/17d5nUx2OtnvkgBcCQcNZhZ8TJBO94GMKF4CHBy1VPjg/edit?usp=sharing).

\==action: On Hacktivity, click Experience; Open Day Workshop; Open Day Proxmox.==

![Experience menu][experience_menu]

![Open Day Proxmox][open_day_proxmox]

\==action: Click "Assign VMs" or (if using the shared open day lab machine) click "Give me another set of VMs".==

![Assign VMs][assign_vms] ![Give me another set of VMs][give_another_set]

\==action: Click "Activate and start challenge". Click the startup icon== ![Startup servers icon][startup_servers_icon] ==action: to start up the servers.==

\==VM: Interact with the Kali VM.== (Click the launch icon ![Interact icon][interact_icon] after the VMs have started.)

## Hacking scenario {#hacking-scenario}

In this hacktivity you will go through the most common steps that hackers do every day ;-) using popular hacking tools (the Metasploit Framework, the Nmap scanner, the Armitage GUI) and various Linux commands: `ls`, `cd`, `cat`, `ssh`, and so on.

**First**, you will scan the network and search for potential victims. As part of this you will check the services running on those PCs and search for vulnerabilities known in those services.

At the **second** step you will exploit a vulnerability in one of the services of a web server and get access to the operating system. You will be able to reach the file system and read files. As often happens, you will uncover some useful secret information, for example credentials to access another PC.

Finally, at the **third** step you will use the found credentials to get access to the Desktop system and steal personal information, for example credit card details.

The whole scenario looks like this:

![Attack scenario diagram][scenario_diagram]

## Getting started: login and start tools {#getting-started}

\==action: Login with username "kali", password "kali".==

> Note: *You don't need to login to the other victim target VMs* (you don't need to know their login passwords), just make sure the VMs are running.

\==action: Open the command prompt by clicking the terminal icon:== ![Terminal icon][terminal_icon]

![Terminal window][terminal_window]

\==action: Run this command:==

```bash
sudo msfdb reinit
```

\==action: Type in the password for Kali (`kali`) and press enter.==

![msfdb reinit][msfdb_reinit]

This will start the database.

\==action: Now run the command:==

```bash
armitage
```

This will launch a 'connect' pop up.

\==action: Click "Connect" and "Yes":==

![Armitage connect][armitage_connect] ![Armitage progress][armitage_progress]

\==action: When prompted for your IP address, open a new terminal and get the IP by running this command:==

```bash
hostname -I
```

![hostname -I output][hostname_i]

\==edit: Enter **your** IP address, not the one in these images.==

## Hacking Step 1: Information Gathering {#step-1-information-gathering}

Most attacks start at the information gathering stage. The aim is to gather as much information as possible about the target. The more information the attacker has, the more likely they will be successful.

Scanning is an active phase of an attack or security test, involving identifying IP addresses, ports, and services. Scanning is a critical stage for an attacker, since it can give them all the information they need in order to launch an attack.

*In this example, you will be guided through the process.*

\==action: Start an Nmap scan (Nmap is one of the most popular tools for scanning) by clicking "Hosts", "Intense Scan".==

![Hosts, Intense Scan][intense_scan]

\==action: Enter an IP address range: enter your IP address (identified earlier) and== ==edit: replace the last octet (number) with "0/24".==

This will take a little time to run. You will get the "Scan Complete!" message once it is finished.

![IP range entry][ip_range] ![Scan Complete][scan_complete]

> Note: *"Nmap uses raw IP packets in novel ways to determine what hosts are available on the network, what services (application name and version) those hosts are offering, what operating systems (and OS versions) they are running, what type of packet filters/firewalls are in use, and dozens of other characteristics." (Nmap manual)*

Once that's finished some hosts will show up, one of which is your own attacking system.

\==action: Right click and browse the results of each scan by clicking "Services".==

\==hint: Look for the server with an IRC server (on port 6667).==

![Services, port 6667 IRC][services_irc]

## Hacking Step 2: Exploitation {#step-2-exploitation}

After gathering enough information about a target using fingerprinting and scanning, an attacker may now know enough to launch an attack. Once you know the operating system and software running on a system, you can refer to your own knowledge of known vulnerabilities, or an online database, to do a more extensive search.

*In this example, you will be guided through the process.*

In this case there is a vulnerable IRC server present. Armitage is a frontend user interface to the powerful Metasploit Framework, and also has a feature to search for attacks.

\==action: Click the "Armitage" menu, "Set Exploit Rank", "Poor".==

![Set Exploit Rank, Poor][set_exploit_rank]

\==action: Click the "Attacks" menu, "Find Attacks".==

![Find Attacks][find_attacks]

\==action: After that is complete, right click the vulnerable server== (==hint: the one with the irc service running==), and browse the suggested attacks.

\==action: Click "Attack", "irc", "unreal_ircd_3281_backdoor".==

![Attack, irc, unreal_ircd_3281_backdoor][attack_irc]

\==action: Click "Use a reverse connection".==

![Use a reverse connection][reverse_connection]

\==action: Click "Launch" to launch the exploit against the vulnerable server.==

Once your attack succeeds, red colouring and lightning bolts indicate you have successfully hacked and compromised the server (==hint: this can take a few moments==).

![Compromised host][compromised_bolts]

> Note: If after a couple of minutes the target has not been compromised, you might need to try another payload.

\==action: First, show the list of available payloads by executing:==

```bash
show payloads
```

![show payloads command][show_payloads_cmd] ![Payloads list][payloads_list]

\==action: In the list of compatible payloads, select #1 (payload/cmd/unix/bind_perl) by executing:==

```bash
set PAYLOAD 1
```

\==action: Then try to exploit the vulnerability again:==

```bash
exploit
```

![set PAYLOAD and exploit][set_payload_exploit]

Wait until the target is compromised:

![Compromised shell][compromised_shell]

## Hacking Step 3: Post-exploitation {#step-3-post-exploitation}

Once an attacker has a foothold in a system, they can misuse the privileges they have "appropriated" to take actions on the system, or go on to try to gain even more access on this or other connected systems.

The initial level of access an attacker gains depends on the security context of the software they have attacked: for example, did they attack a part of the operating system, a service, or a program that a user is running? What access control restrictions are in place? These factors determine what the attacker can do on a compromised system.

*In this example, you will be guided through the process.*

\==action: Right click the compromised server, and select "Shell 1", "Interact".==

![Shell 1, Interact][shell_interact]

\==action: Then run these commands:==

```bash
ls /home
cd /home/irc
ls
cat *
```

This will list the files in the `/home` directory ("folder"), change to the irc user's directory, and then list and print the contents.

\==hint: In this scenario you have uncovered some additional credentials, which you can use to login to the 3rd system in the scenario, either at the desktop, or remotely using ssh.==

![cat credentials][cat_credentials]

After you provide the login credentials, you will now be able to **interact** with the third system:

![Interact with the third system][interact_third]

\==action: Check what information is available in the current location, once you have access to the third server.== Use `ls` to list files and sub-folders, `cd` to change directory and go to a new location, and `cat` to display file contents.

> Flag: Explore the third system and find the personal information (for example credit card details) hidden there.

## Conclusion {#conclusion}

This is the end of this short exercise, in which you have:

- Learned about the steps of an attack, starting with gathering information, carrying out an attack (exploiting a security vulnerability), and then taking actions after the attack.
- Used Armitage as an interface for the Metasploit Framework, to automatically search for and launch exploits.
- Hacked into a server, gaining shell access.

Congratulations!

[experience_menu]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/experience_menu.png
[open_day_proxmox]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/open_day_proxmox.png
[assign_vms]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/assign_vms.png
[give_another_set]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/give_another_set.png
[startup_servers_icon]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/startup_servers_icon.png
[interact_icon]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/interact_icon.png
[scenario_diagram]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/scenario_diagram.png
[terminal_icon]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/terminal_icon.png
[terminal_window]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/terminal_window.png
[msfdb_reinit]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/msfdb_reinit.png
[armitage_connect]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/armitage_connect.png
[armitage_progress]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/armitage_progress.png
[hostname_i]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/hostname_i.png
[intense_scan]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/intense_scan.png
[ip_range]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/ip_range.png
[scan_complete]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/scan_complete.png
[services_irc]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/services_irc.png
[set_exploit_rank]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/set_exploit_rank.png
[find_attacks]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/find_attacks.png
[attack_irc]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/attack_irc.png
[reverse_connection]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/reverse_connection.png
[compromised_bolts]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/compromised_bolts.png
[show_payloads_cmd]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/show_payloads_cmd.png
[payloads_list]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/payloads_list.png
[set_payload_exploit]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/set_payload_exploit.png
[compromised_shell]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/compromised_shell.png
[shell_interact]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/shell_interact.png
[cat_credentials]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/cat_credentials.png
[interact_third]: {{ site.baseurl }}/assets/images/introducing_attacks/open_day/interact_third.png
