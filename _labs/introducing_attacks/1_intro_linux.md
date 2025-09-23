---
title: "Introduction to Linux and Security"
author: "Z. Cliffe Schreuders"
license: "CC BY-SA 4.0"
description: "Learn Linux fundamentals and security tools, including command-line operations, file system navigation, SSH, and basic penetration testing with Kali Linux."
overview: |
  In this lab, you will delve into Linux and security tools, gaining practical knowledge and skills that are highly relevant in the field of cyber security. Linux is a powerful and versatile operating system widely used in the IT industry. Understanding Linux and its command-line interface is crucial for anyone interested in security testing and ethical hacking. You'll begin by familiarizing yourself with Linux basics, from fundamental command-line operations to concepts like piping between programs and file redirection. This lab will also introduce you to the Kali Linux distribution, a platform designed for penetration testing and ethical hacking.

  Throughout this lab, you will learn how to perform various tasks, such as creating and manipulating files, exploring the Linux file system, and conducting network-related activities. You will gain hands-on experience with SSH, a secure remote shell protocol used for administration, and even attempt online brute force attacks to understand the importance of security in the digital realm. By the end of this lab, you will have honed your Linux command-line skills, developed a basic understanding of networking, and practiced using essential security tools, preparing you for more advanced challenges in the field of cyber security.
tags: ["linux", "command-line", "ssh", "kali", "networking", "security"]
category: "introducing_attacks"
lab_sheet_url: "https://docs.google.com/document/d/1vA_Ev_GPqPg3cGZblgVclWmTU-sUEEBqwYpFH09mQjg/edit?usp=sharing"
type: ["ctf-lab", "lab-sheet"]
lecture_url: "http://z.cliffe.schreuders.org/presentations/slides/DSL_DS_OSPT_Lectures_1_Intro_to_Unix_FOSS_and_Linux.html"
reading: "Chapters 1-2: Practical Unix and Internet Security by Garfinkel, Spafford, and Schwartz"
cybok:
  - ka: "NS"
    topic: "Network Protocols and Vulnerability"
    keywords: ["common network attacks"]
  - ka: "SOIM"
    topic: "PENETRATION TESTING"
    keywords: ["PENETRATION TESTING - SOFTWARE TOOLS"]
---

## General notes about the labs

Many of the tasks you complete within our labs could be considered illegal if targeted at a computer that you do not have explicit permission to interact with, do security tests on, and attack. In short, keep all activity contained to our labs and to computers you have legal permission to attack[^1]. Use common sense, and act within the law, ethically, and according to your own morals. With power comes responsibility, use it wisely.

One of the interesting and inevitable things about working with security attacks, is that because we are often intentionally “breaking” things and making them misbehave for our own intentions, sometimes things do not go exactly according to plan, software may crash or behave erratically. This adds to the challenge, and may require some troubleshooting.

The labs are written to be informative and, in order to aid clarity, instructions that you should actually execute are generally written in this colour. Note that all lab content is assessable for the module, but the ==action: colour coding may help you skip to the “next thing to *do*”==, but make sure you dedicate time to read and understand everything. Coloured instructions in ==action: *italics*== indicates you need to change the instructions based on your environment: for example, using your own IP address.

Often the lab instructions are intentionally open ended, and you will have to figure some things out for yourselves. This module is designed to be challenging, as well as fun\!

However, we aim to provide a well planned and fluent experience. If you notice any mistakes in the lab instructions or you feel some important information is missing, please let us know and we will try to address any issues. 

## Preparation and logging in {#preparation-and-logging-in}

[**Click here to read through a guide to using Hacktivity.**](https://docs.google.com/document/d/17d5nUx2OtnvkgBcCQcNZhZ8TJBO94GMKF4CHBy1VPjg/edit?usp=sharing) 

This includes some important information about how to use the lab environment and how to troubleshoot during lab exercises. Read through this now before continuing.

> Action: For all of the labs in this module, start by logging into Hacktivity.
> Sign up for the module, claim a set of VMs for lab 1, and start your VMs.

==VM: Interact with the Desktop VM==. (Click ![][image2] after the VMs have started).

> Note: Note that a command shell will open automatically, and a username has been randomly generated for you. 

> Tip: To adjust the size of the terminal text, you can press "Ctrl", "Shift" and "+" to increase it, or "Ctrl" and "-" to decrease it.

==action: From the command line run:==

```bash
whoami
```

Your password is "tiaspbiqe2r" (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember). 

> Note: You don't (yet 😉) have root (superuser / admin) access to this desktop VM.

In any case, never log in to the desktop environment using the root account \-- that is bad practice, and should always be avoided[^2].

> Tip: Don't waste time typing out the full commands and directory / file names - pressing the "Tab" key will autocomplete words, as long as nothing else starts with those letters (if it does, try typing a few more before pressing "Tab"). ==action: Try it now - type "whoa" then press "Tab"==. You should see the previous command complete itself.

## Familiarisation with the environment {#familiarisation-with-the-environment}

The desktop VM is a Linux system, which is based on Debian (a distribution of GNU/Linux[^3]), and is configured with the KDE desktop environment[^4]. Note that many of the VMs you will use are based on different Linux distros, with various desktop environments. Although different distributions may appear to be visually very different, the commands used for each are typically almost identical. By the end of your studies you will be familiar with many flavors of Linux. We will also be using other operating systems (OSs), such as Windows.

Side note: Linux distros have various levels of support for different desktop environments (such as KDE and Gnome), which can often be chosen upon install, and these change the user interface quite dramatically. Note that servers are often headless; that is, they have no graphical interface, and are typically configured via the command line. 

A major difference between various distros is the way that software is organised and installed, and what is installed by default. Some distros are more suited to specific use cases, since they are designed to do certain things well. Beyond these differences, there are many great distributions, and comparisons often come down to a matter of preference. 

Why study Linux in this module? Familiarity with Linux and Unix tools are valuable skills. Often Linux is the right tool for the job. Linux servers are common in large organisations, or any serious ICT setup. For example, Google and Facebook run most of their servers on Linux, and even Apple and Microsoft have been known to use Linux servers (as much as Microsoft may rather you not know that). Many security testing tools are only available on Linux, and there are many Linux distros that specialise in security testing, and are industry-standard.

Here is a brief summary of some of the most popular desktop flavours of Linux:

* Ubuntu:  
  * One of the most popular and user-friendly Linux distributions. It's widely used for desktop and server applications. Canonical, the company behind Ubuntu, releases a new version every six months.  
* Debian:  
  * Known for its stability and adherence to free software principles. Debian is the foundation for many other Linux distributions, including Ubuntu. It has a large community and a reputation for being a reliable choice for servers.  
* Fedora:  
  * Sponsored by Red Hat, Fedora is known for its cutting-edge features and being a testing ground for technologies that may later be incorporated into Red Hat Enterprise Linux (RHEL). It's popular among developers and enthusiasts.  
* Arch:  
  * Known for its simplicity and flexibility. Arch is a rolling release system, providing the latest software updates continuously. It has a steep learning curve but is favored by users who want to customize their system extensively.  
* Raspberry Pi OS:  
  * Specifically designed for the Raspberry Pi single-board computers. It's the default operating system for Raspberry Pi devices and is optimized for low-resource usage, making it suitable for various projects and educational purposes.  
* Steam OS:  
  * Developed by Valve Corporation, Steam OS is designed for gaming and intended for use with the Steam gaming platform. While it hasn't gained widespread adoption as a general-purpose operating system, it remains relevant in the gaming community and is used in the Steam Deck console.

Each of these Linux distributions has its strengths and caters to different user preferences and needs, whether it's ease of use, stability, bleeding-edge software, or specialized applications. The popularity of each distribution can vary depending on the target audience and use case.

## Basic Linux command skills {#basic-linux-command-skills}

We will start with a crash course in building your way to Linux command-line wizardry (you have to start somewhere), then quickly jump into network sniffing, password grabbing, remote administration of machines via ssh (secure shell), and other exciting things.

Here’s a brief cheat sheet of some common Linux/Unix commands:

| Command | Simplified description | Example usage |
| :---- | :---- | :---- |
| pwd | Check your current location in the file system | pwd |
| ls | Lists all the files in your current working directory, similar to “dir” on windows (-la shows details) | ls \-la |
| cp | Copies files (-r to recursively copy directory contents) | cp file1 copy\_of\_file1 |
| mv | Moves (or renames) a file or directory | mv file1 file2 |
| cat | Prints the contents of a file to the console | cat file1 |
| echo | Prints a message to the screen | echo “hello, world\!” |
| mkdir | Makes a directory | mkdir newdirectory |
| cd | Change working directory, to “move us into a different directory” | cd newdirectory |

> Tip: If you ever get lost within the file structure, you can type "cd" on its own (no directory name afterwards) and you'll return to your home folder. To go up just one level within the file system, type "cd .." ("cd", followed by a space then two full-stops.)

If you haven't already, ==action: open a terminal console==.

> Note: One way to do this is to start Konsole from KDEMenu → Applications → System → Terminal → Konsole.

Start by ==action: checking your current location in the file system==:

```bash
pwd
```

Continue by ==action: making a new directory, moving into it, and creating another directory there== (check you location using pwd if needed):

```bash
mkdir mydir
```

```bash
cd mydir
```

```bash
mkdir mydir2
```

==action: Display the contents of your working directory==:

```bash
ls
```

> Note: Note that this is lowercase “LS”.

Ok, that lists the directory name, but doesn’t tell you much else...

### Getting unstuck {#getting-unstuck}

If you don't know what a command does, or what flags (command arguments) to use, then look it up in the manual, using the **man** command.

==action: Try it now==:

```bash
man ls
```

(and press enter when prompted which ls you are interested in learning about)

The cheat sheet above mentions how how to use **ls** to display more details. Scroll through the manual page you have just opened, and read about what “-a” does, and what “-l” does. You may wish to read about some of the other options and/or take some notes.

When you are done reading, press “q” to quit.

Now ==action: try it==. Run:

```bash
ls -la
```

> Note: This is lowercase “LS \-LA”.

This gives a much more satisfying output. The output includes permissions, the user who owns the file, filesize (in bytes), last time each file/directory was modified, and more. We will come back to the meaning of all this information in more detail another time.

You can also read the info page, which like the man page, also provides a summary of usage:

```bash
info ls
```

(press "q" to quit)

### VI {#vi}

Next, lets ==action: edit a file, using vi==, the "paragon of editing perfection"[^5], and most importantly the editor available on nearly every Unix and Linux system. Run:

```bash
vi mynewfile
```

Vi is 'modal': it has an insert mode, where you can type text into the file, and normal mode, where what you type is interpreted as commands. ==action: Press the "i" key to enter "insert mode"==. ==action: Type a message (such as "hello there")==, then ==action: exit back to "normal mode" by pressing the Esc key==. Now to ==action: exit and save the file press the ":" key, followed by "wq" (write quit), and press Enter==. 

Now you know everything you need to edit files using vi\!

> Tip: Side note: if you want to become a serious guru, take 10-20 mins to run through an online tutorial on vi. You will soon be impressing people with your wizard-like editing skills. What’s that you say? Want to delete 30 lines? In normal mode, just type “30dd”. 

==action: Open the file using vi again, and add another line of text to the file. Save and quit==.

Next, ==action: list the files in your working directory again==. Then, ==action: refer to the cheat sheet to copy your new file to a file named "mynewfile2"==.

==action: Print the contents of the file to the console==.

> Tip: If your terminal is getting a little crowded with text, press "Ctrl" and "l" (lower-case L) together to clear it.

### Piping between programs {#piping-between-programs}

Another important command line skill is piping between programs. You can send the output (known as stdout) of one program to the input (known as stdin) of another. For example, imagine you had a large text file, and wanted to find all the lines that matched a certain pattern, and then sort those alphabetically. Doing this manually could take an impossibly long time, depending on the size of the file. Using some simple Unix commands we can do this easily.

Let's start by ==action: printing the contents of a file on our system==. Run:

```bash
cat /etc/passwd
```

> Note: The passwd file contains information about each of the user accounts on the local system.

Now if we wanted to see only the lines that contained the text "/home/", we can use the grep command, to filter the output to only those lines. Run:

```bash
cat /etc/passwd | grep /home/
```

> Note: There are user accounts that are not for normal users (with home directories), so this command will filter those out. *Also, depending on your computer's keyboard layout or language settings, you may find that the "\|" and "\~" keys are reversed, so try the other if you get an unexpected output.*

And to put these in *reverse* alphabetical order, run:

```bash
cat /etc/passwd | grep /home/ | sort -r
```

> Tip: Pressing the **↑** key (up arrow) or ↓ key (down arrow) allows you to cycle through previous commands. For example, after typing each command above, press **↑** to bring it back, then you can just add the new parts.

### Redirecting to/from files {#redirecting-to-from-files}

The final command line skill we will cover in this quick crash course is redirection to and from files. You can send the output (known as stdout) of a program to a file, or send the contents of a file to the input (known as stdin) of a program. 

So for example, it is easy to ==action: save the output from a command to a file==. Run:

```bash
ps aux > processes
```

> Note: The **ps** command lists the processes (running programs) on the system, and the “aux” flags tell it to show all of the processes in some detail. The command above writes a list of all the processes on the machine to a file named 'processes'.

To ==action: display that file we can send the contents of the file to the **cat** program==:

```bash
cat < processes
```

Alternatively you can ==action: tell cat to read the file itself==:

```bash
cat processes
```

> The difference is that the first version sends the contents of the file to the cat process, which just receives the lines of text and displays them, whereas the second command tells cat that you want it to open the file and read out its contents.

Another handy program is **less**, which gives you the ability to scroll through the file (as well as lots of other handy features). Run:

```bash
less processes
```

==action: Scroll through, and press "q" to quit when you are ready==.

==action: Write a one line command that only prints the processes that contain the text 'bash' to a file named 'bashes'==.

> Hint: Pipe the output from ps to grep, then redirect the output to a file.

## Basic Linux networking {#basic-linux-networking}

==action: Find your system's IP address(es)==. Run:

```bash
/sbin/ifconfig
```

> Note: This is similar in purpose to the *ipconfig* command on Windows.

Also ==action: try the newer command==:

```bash
ip a s
```

(Short for "ip address show", which also works in full)

Finally, you can ==action: use the "hostname" command with the flag "-I" to display just your IP address(es)==:

```bash
hostname -I
```

> Hint: In the Hacktivity environment, your IPv4 address will typically start either with “172.22” (where you are on a shared network with other students) or “10” (where you are on a more isolated network).

On many Linux systems you can leave off the /sbin/ part, depending on the $PATH environment variable, which lists where to look for programs to run. To ==action: see what your $PATH is currently set to==, run:

```bash
echo $PATH
```

> Note: The **echo** command simply outputs something to the screen (so for example, “echo hello, world\!” would print “hello, world\!” to the console), and variables start with “$” in Bash, the Linux shell[^6].

You will see a list of folders, separated by the “:” symbol. Any executables contained within these folders will be accessible from any directory, without typing the path first.

Note that the commands to list IP addresses will display each of the network interfaces, including physical interfaces, and virtual ones. Ethernet ports will be represented as “eth0”, “eth1”, “ens3” and so on. 

If you ever find that your ethernet port has not been allocated an appropriate IP address (for example, there was a problem with the DHCP server), you can usually ==action: remedy the problem (and get allocated an IP address) by running==:

```bash
dhclient eth0
```

or (depending on distro)

```bash
dhcpcd eth0
```

> Note: You can also try restarting the entire network service, or bring up/down interfaces (ask Google or your tutor).

## Virtualisation and our use of virtual machines (VMs) {#virtualisation-and-our-use-of-virtual-machines-vms}

Virtualisation is a very powerful tool, which can provide important security features, such as isolation, and is an important component of many modern cloud infrastructures. Virtualisation can create virtual environments, and can even run entire operating systems as though they were on separate hardware. This type of virtualisation is known as platform virtualisation, or hardware virtualisation. As illustrated in the figure below, virtualisation allows one set of hardware (a computer), to host a number of guest virtual machines (VMs), each with their own operating systems, applications, and virtual hardware.

![][image3]

Hardware Virtualization ([Image](http://commons.wikimedia.org/wiki/File:Hardware_Virtualization_\(copy\).svg): public domain by [John Aplessed](http://commons.wikimedia.org/wiki/User:John_Aplessed))

During the module we will make use of various VMs to recreate realistic security scenarios, typically generated by our software and running on our oVirt and Proxmox cloud infrastructure.

## A note about working from home {#a-note-about-working-from-home}

You can access Hacktivity remotely to work on labs from home, and you might also be interested in setting up your own home lab environment with VMs installed locally. However, choosing to do work outside of our lab environment is at your own risk and responsibility.

> Warning: The most important thing to consider is to **ensure you are not acting illegally**. As mentioned, many of the tasks we do in our isolated labs could be considered illegal if targeted at someone else's servers. Any tasks done in your own environment should be contained to your own personal computer(s), and to be sure you should disconnect your personal lab from all external network connections. If in any doubt, only complete the exercises within our secure labs. 

Ideally you would have a PC with VMware Player and Virtualbox installed. Keep in mind that your mileage will vary, and we cannot provide support for your own home setups. Getting some practice with Linux outside of the labs (either installed on your computer or through a VM) will also help with upcoming lessons.

## Introduction to Kali Linux {#introduction-to-kali-linux}

In 2013, Offensive Security released Kali Linux, the successor to the very popular BackTrack Linux distribution.

Kali Linux is a Linux distribution especially designed for penetration testing, and forensics. These distros have become the industry standard for ethical hacking. 

If you have not already done so (it should already be running), start and interact with the Kali VM. The username is "kali", with password "kali".

==action: Start by browsing through the tools that are available==. 

==action: Click the "Applications" menu → hover over any of the numbered subdirectories==

There are an amazing amount of security/hacking tools included with Kali. ==action: Take a few minutes to familiarise yourself with the layout of this menu==.

Most of these programs are command line tools. ==action: Open a terminal, by clicking the console icon== (![][image4]).

This is where the magic happens\!

To further emphasise the sheer amount of ~~awesomeness~~ tools, run:

```bash
ls /usr/bin
```

Have a quick scroll through the vast “arsenal” of tools. Do you already recognise any of these programs?

## Remote shell access and SSH {#remote-shell-access-and-ssh}

Secure shell (SSH) is a network protocol that enables secure communication between two computers on an insecure network. The primarily purpose of SSH is to provide an encrypted remote shell (command line) session, for executing commands on a remote server. This is safer than the old insecure method of remote logins using Telnet or rlogin, which have no encryption and can be easily attacked (by simply listening to network traffic, which includes user logins with passwords).

In addition to remote shell access, SSH can also be used for encryption of other kinds of connections, and can be used for SSH tunneling, SCP file transfers, VPNs, and so on. In short, it is very useful.

SSH involves a server listening to a port (typically on TCP port 22, it can be a good idea to change this), and a client connects and sends commands. The protocol uses a form of public-key cryptography for authentication and encryption[^7].

Now lets see ssh in action. 

**On your Desktop system**

==action: Confirm that a local SSH server (sshd) is running on your system==:

```bash
/usr/sbin/service sshd status
```

> Note: On Kali “/usr/sbin/” is not necessary, since you are logged in as root (again, running everything as root is normally a bad idea, but for security *testing* purposes is ok).

When the sshd service is running, other users can SSH into your machine (if they have valid credentials), and issue commands. 

**On your Kali system**

To illustrate this, ==action: ssh into your Desktop VM==. Run this command to ssh into the server:

```bash
ssh *username*@*IP-OF-DESKTOP*
```

Where *username* is the desktop user's username, as shown previously by the whoami command, and the IP address is the address of the Desktop.

If you leave out the username (and @ symbol),the username you are logged in as is used to connect to the remote system (which won’t work here, as we are running as root on Kali). *This is also an instance where keyboard layout and language can cause the incorrect symbol to be typed \- you may find that the “@” symbol and “ symbol (quote mark) are reversed.*

==action: Enter the password given to you at the start of the lab, "tiaspbiqe2r"==.

You should ==action: check the fingerprint displayed, to confirm you are connecting to the machine you think you are connecting to==. This protects against man-in-the-middle attacks, where you think you are connecting to a trusted server, but are actually being fooled into talking to a malicious host, who may be intercepting or modifying the communications.

To ==action: check the fingerprint, on the desktop run==:

```bash
ssh-keygen -lf /etc/ssh/ssh_host_rsa_key.pub
```

> hint: Hint: you may also need to check other .pub files in that directory

If the fingerprint presented to you while connecting matches, type “yes”, and from then on if you connect to the same machine you won't be prompted.

> Tip: If you wish to copy / paste commands within the terminal, press the "Shift" key along with the usual shortcut \- "Shift", "Ctrl" and "c" will copy, "Shift", "Ctrl" and "v" will paste.

If all has gone well you are now sharing the computer. ==action: Use these commands and interpret the output==:

```bash
hostname
```

```bash
/sbin/ifconfig
```

```bash
whoami
```

```bash
top
```

```bash
who
```

```bash
write *username*
```

```bash
ps aux
```

> Hint: remember, if you are not sure what a command does, check its man page, using “man *command*”.

==action: Try running "kate" on the remote system, why doesn't that work?==

==action: Log out of the ssh session (run "exit" or press Ctrl-D)==
> Warning: Be careful, if you exit one too many times your current terminal console will close (the username within the terminal should indicate which account you are currently using). 

Now ==action: try adding the command line argument "-X" which forwards X11 traffic, so that graphical programs have their interfaces forwarded to your local X server==:

```bash
ssh *username*@*desktop-ip* -X
```

==action: Retry running "kate"==.

Now the program is running on the remote server, but displayed locally\! You should be able to graphically edit files on the remote system. ==action: Try adding some text and saving it==. You should then be able to view the new document back on the Desktop machine.

When you are finished, simply ==action: run "exit" or press Ctrl+D to exit back to your own local terminal==.

## Hacking SSH via online bruteforce attacks {#hacking-ssh-via-online-bruteforce-attacks}

Now, for those of you hanging out to hack something\!

One approach to attacking SSH servers is to attempt remote logins. 

Hydra is an online login tool, which can test login credentials (and bruteforce them) against a long list of different protocols/services, including SSH.

Services Hydra can check credentials include: Asterisk, AFP, Cisco AAA, Cisco auth, Cisco enable, CVS, Firebird, FTP, HTTP-FORM-GET, HTTP-FORM-POST, HTTP-GET, HTTP-HEAD, HTTP-POST, HTTP-PROXY, HTTPS-FORM-GET, HTTPS-FORM-POST, HTTPS-GET, HTTPS-HEAD, HTTPS-POST, HTTP-Proxy, ICQ, IMAP, IRC, LDAP, MEMCACHED, MONGODB, MS-SQL, MYSQL, NCP, NNTP, Oracle Listener, Oracle SID, Oracle, PC-Anywhere, PCNFS, POP3, POSTGRES, Radmin, RDP, Rexec, Rlogin, Rsh, RTSP, SAP/R3, SIP, SMB, SMTP, SMTP Enum, SNMP v1+v2+v3, SOCKS5, SSH (v1 and v2), SSHKEY, Subversion, Teamspeak (TS2), Telnet, VMware-Auth, VNC and XMPP.

==action: Use Hydra to test a known username and password combination==:

```bash
hydra -l *username* -p tiaspbiqe2r *IPADDRESS* -t 4 ssh
```

**On your Desktop system**

==action: Confirm the user home directories present==:

```bash
ls /home/
```

There is a victim account… ==action: Can you read the victim's files in other users' home folders?==

```bash
ls /home/victim
```

No. *(Not yet\!)* 

**On your Kali system**

Hydra can receive a list of passwords to attempt. But which passwords should you try? ==action: List some of the wordlists available on Kali==:

```bash
ls /usr/share/wordlists/seclists/Passwords/Common-Credentials
```

==action: Which of these are most likely to work against SSH credentials?==

==action: Use some password lists to use Hydra to crack the victim account on Desktop==:

```bash
hydra -l victim -P /usr/share/wordlists/seclists/Passwords/Common-Credentials/*File_name* *DESKTOP-IP-ADDRESS* -t 4 ssh
```

*Where filename is a password list.*

> Warning: Using the wrong list will take a REALLY long time to try to crack credentials using online methods (and can quickly result in your IP address being blocked from some online services). To stop the scan press Ctrl-C, and try a different password list file.

Once you have identified login credentials for the victim account, ==action: SSH to the desktop using the victim credentials==.

Once you have access to the victim user, ==action: look in the victim user's home directory for a flag==. ==action: Read the flag file in the victim's home directory with the command==:

```bash
cat /home/victim/flag
```

There is another account to be hacked, the "bystander" user. There is a flag. ==action: Try to access it using==:

```bash
cat /home/bystander/flag
```

The victim can't access it directly (neither can your user).

Note that the victim user has the extra ability to act as a superuser (root). As the victim, ==action: use the "sudo" command to act as root and access the "bystander" user's files==.

```bash
sudo cat /home/bystander/flag
```

==action: **Submit all flags to Hacktivity to show you have completed these tasks.**==

## Conclusion {#conclusion}

At this point you have:

* learned about our lab environment for the module, including some of the virtual machines we will be using;

* developed some very important Unix/Linux command line skills, including common commands and piping between processes;

* learned some basic Linux networking commands and skills;

* learned about remote administration using SSH;

* conducted bruteforce online attacks using Hydra.

Well done\! Not bad for the first week\!

## Footnotes

[^1]:  See the section about working from home for some more details about setting up your own isolated lab

[^2]:  For more information, see: [http://en.opensuse.org/SDB:Login\_as\_root](http://en.opensuse.org/SDB:Login_as_root)

[^3]:  Overview of what a Linux distribution is: [http://en.wikipedia.org/wiki/Linux\_distribution](http://en.wikipedia.org/wiki/Linux_distribution)

[^4]:  KDE happens to be my (Cliffe’s) favourite desktop environment for everyday use, but you should play around with others and make up your own mind. Note that Kali Linux is not really designed for everyday desktop use.

[^5]:  Vi vs Emacs: [http://en.wikipedia.org/wiki/Editor\_war](http://en.wikipedia.org/wiki/Editor_war)

[^6]:  A shell is the processor that interprets commands, and on Linux that is commonly Bash: [https://en.wikipedia.org/wiki/Bash\_%28Unix\_shell%29](https://en.wikipedia.org/wiki/Bash_%28Unix_shell%29)

[^7]:  Public-key crypto will be covered at a later stage in your studies, but if you are curious now here is an overview: [http://en.wikipedia.org/wiki/Public\_key](http://en.wikipedia.org/wiki/Public_key)

[image1]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAADkAAAAUCAYAAAA3KpVtAAAD1UlEQVR4Xt1XS0tbQRTOumBw76KBLkwKgrvSjQr2B6Q/wOJPEFoKgqVWYkEoSLBYu6gpdFcfMQ+TmMTcaGIT8zAPa7cRXNid+AtO73eSuU4muTERocEDh7lz5nyT+eacOTOxEJHVYrHQQ1VdLBAKx0MU1fYomdYolTmk42KWTipFKp+WqHpWpdM/VW4rvytsz5fy9Ct3xL77h3HG70aD5AvvkHd3m7YCm7Tp36AN38//rg2yFiaIxaazKcrkM0zEteiiyReTTbsyYB0g10eXTrasE81RtpChg6Mk40HUH/HRTshL24EtJqr+4OzcLDkcDmM+fKs+nVTGQjGf6qOqQRIRBMFCucAExCSDg4M0Pz9PmqZxOz09bYw5XzopnUlx1JNHGsUPYhSK7VIg4udogqiIpufHOlmtVnI6nVSr1ZBCLPjGXBhTFycrxuEnYyGYD/aVtZUWTAtJpB0iCIJYPGwgdXV11TQpxOPxMHn42B123hjgtVSCIvthTluOZvCGJPzgL0T+xnzoq4tTF4oNhlxcXFA2k+FW4DG/imkhmS3Uz2DD0JacKqOjo+zr/uzmaCITYsloPW3DPo4mSELhp0ZBFoyZpS7sAvvksY3Gnz2nt6/f8Ld7eZntmN8Mb5AsNs4gvhHBbkVEARuE85k43OfziZT1hXaMAjQzM9OEE5up2tQFikVCrq+vmZjdbuc+Ion+38tLnr8TnkmW9CqKIoM0FFFEvk9MTBikcS6FbbmxgxDgUYVzxWPS0gmOZnAvwJX2PklCRkZGeB0QQfK8dt4dyepZhTti8UhFm83GaYJWRAx2r9fLNiF1fJUK+rWCSosChHOJlBUk4SOnq0qwl3SFuj4s0NPhYVpb/cJ2zGeGN0jiHkQrdgnfatq2swk78ChAnUgiC2SMLBgzuw5gF1iQE0ShSGEI5jPDGyTNIonURQtyGIe9VCr1HMm+uEJwdeCiF2UaKdkYZJXvR6FCBD5/kuP7MpaMUTDafCbxYyAqzyeqM8p/p0UKrLiGgMMZlPGqf1uSqK7uFTcb5KJym7SrrnuJenXFXdkPzzuDJJ5o4qWDCtuNIJXhOzQ0ZLxl4wdxnWTEeN71Fcm593OcblOvpoyU6CTiLEFxfSwsLhj9PtWbDipkuYe3K6K/+nVVndBUhag21c9MZXwvOIvceadHFFVy/fs31alJkaKIYKGcbxnrVntcZJP/HYi2GMjr93IxwksI10v9/2SFIyf+T46Nj7XgetUeFtmEuReS0KVPSxRPxjmyiBhanFvY70pQXqDoqz5mKmPV9lbV/R61GB+QYh/+AcxGR7g4odpQAAAAAElFTkSuQmCC>

[image2]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACQAAAAjCAIAAABzZz93AAADfElEQVR4Xr2Ve0/TUBiH+yU3NjBuA4fcpuOixACJGHE6VGAYiSAmXmJCZIgMuYQoExGH8w5TQVi79bqWXbryAWx7BjvnrBYGypvnn57ze9+np21SIpdVdHZPACKb3T0xiGxm9+iIdHdnV0dHpwmjkxFKKuSPJ5NYl91iXjZ32+TSJsgTmfTusaA3Z4av4ga4qurvhKIg/FeZyEuzwbHALX9Pz/VSbgyNr5ESSO4wpLvSijv2C5aldxSYteWFoZ4LeANaNuc5MoV0xT+E8NB+VdUPhqIghsheP7iCR0vq/tw3VkRMAhWprMBjxYJlO5ICkFIZ9ymTJq1sjsYkX8gDeCrS11iJ5+Cqqg9MRUG4IBM5YW70oGPZ638xiGn7e9jsTKBgmSQqKhtzA2ewjLuV4WSwa0BK5sgI2vGX0mWgqyCb9p+FA3and2R+HRdAbH0LD7QjLVhVVOx9n4gspd6m0mVDor5xEawbwsVNvwiL1dnSKySTC496tStV9iIKGgkxpah40PjNF9qiIWw8ctv0i3B6uqdXKC2cpKrVm9JloJcQBUUFeyI3J7XFUshY1PRMFu1McAu11VR3fvjlV3BJpAQlZSQD6xjRVyNoEC6reia+pAWmPBmzuemwGx9NNY2/2S5tgSFSvKKCy55ri4awZCIUaEPjFldbn4DG6E8z3e0dWC8h8LLA53HZRF7gzHjaf9lZeHvW6mYfB+8y0lp4SttxebEuXcbJ5cqon7Gx/i41WX2hf341CW+th6euNtcay3hO5ktkvRN5njsK25Hp4hSXF9sleDbHsyWyYJ5nyyUXW521wf81VYZm1JP9K1l6ZW4QmWIo4xhZf8bFUmUcUy7pd7MBZIrLi2X+o8xa04JlCIaVGUZuhFMWiz+YZ+lySS+jsqq6S1hGl9FyH2pr6JmK4bMOgCGl0J1L0AxrbesAlinIgtfcUM5id3hGZzZKJ5pArk5cdMA/Kluz7xmWIdhknknmt9bf+5pOQVGtauo8Ho/3MDTU1mC9dlfn5Mcsow/fh2ASMq1CybG3i1jDcWphO0cn8hh7Mu1CrEOew9HLfvo85ADzNfZlOr+p5mqzv/Bh6u7Yxx8bGdjB7EHQVC6pIQO+Li36LzbgAw5d7va78Xhxmk6O3gOXARLxTOzz9yejjwcH7gUOwYOHwcgXgUSHGMsSpIr83yjK/gBwmQ+jyG79IQAAAABJRU5ErkJggg==>

[image3]: <data:image/png;base64,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>

[image4]: <data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABkAAAAUCAIAAAD3FQHqAAACA0lEQVR4XpXTzW7aQBAH8H2oBIjtNQaavEkPVZ+mqvo6PbRST1VOJaThw97Fn4GmUnPgSP4zYy9WwKVFfyHB4h+zszvqz/Nztf1dbp8om6eC8itHHpFthlSUtNqk5WZd59EWksrklCSvvn2/VbWyrRWCjpXqb0qSl0lWxllJFhR/9CYYXwd45+CjH01cPGQ4drkKR4foCAEUp4WSWvBAOLlB9OSmryM9vpa0/4DS+gN/OPYbepUWiJLWiEVQMNzv97vdDo91KgwdytQRoOU6V4DQGuwCVWBhz6+3797j14ctnyqHEo483iYgsqTHWIDlNxbKrq0uxUHhaMDWwuYq5ZMSS9ZqTkddm3KK9H4QDBc2m9tMyXnjW1SBX3z4+Emsnh+eVSRoMaC5yZTcGmdJ7y89DeXyKrho0vfDkxA2iKW5SR9MqtZ898hqtkMQt8ZBFwMfDxwr2B2CJUAPSaoAmaIatLtzblOkNBCCbvxM1oiSUaitc0q7HFdUz9OA7mO2MFD49pVyDB0rElj3sUUUxhLpO+tflBaE4IhmsZ2trKKxFKtL6SiH4mkURdbK3q2Minks5chPQF0Kb00CC9Dd0igZ8Z4c+X8qFL4x06WZLhMlYykDJaPAl5juntwaOW8cE8dKa2YohGsRBfmxSNTnL18XBGU1ZLJXSgM5hVoDhaFa4cQvLUq/lX5VefEAAAAASUVORK5CYII=>
