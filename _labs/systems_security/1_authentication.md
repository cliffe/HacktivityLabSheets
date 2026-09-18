---
title: "Authentication: Users, Password Hashing, and Cracking with John the Ripper"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Explore Unix/Linux user accounts and identity, password hashing and salting, and crack weak passwords with John the Ripper, while completing Hackerbot's live challenges."
overview: |
  Authentication is the process of verifying a user's identity, ensuring that individuals are who they claim to be before granting them access to systems and resources. This lab will provide you with hands-on experience, enabling you to explore the intricacies of user accounts and identity on Unix/Linux systems, gain insights into password storage and hashing, and even attempt to crack passwords using dictionary attacks. By the end of this lab, you will have a deeper understanding of how authentication works, the role of password security, and the importance of safeguarding user identities.

  Throughout this lab, you will learn about user accounts, their attributes, and their association with user and group IDs. You'll also explore the concept of salts in password hashing, understand the strengths and weaknesses of different passwords, and attempt to crack passwords using tools like John the Ripper. Practical tasks include examining the system's /etc/passwd and /etc/group files, changing user identities, and analysing the /etc/shadow file to understand password storage. By actively engaging in these activities, you will gain a comprehensive understanding of authentication processes and the key factors that contribute to securing user identities in Unix/Linux systems.

  The Hackerbot tasks in this lab involve configuring new users and group membership. Then you will attempt to crack the passwords of users on the desktop VM whose user IDs (UIDs) are higher than 1001. After successfully cracking passwords, you will use these credentials to SSH into the separate server VM, where you will discover flags. This task showcases the practical implications of password security and cracking.

  This is a Hackerbot lab. Work through the lab sheet, then when prompted interact with Hackerbot.
tags: ["authentication", "users", "groups", "passwords", "hashing", "salt", "password-cracking", "john-the-ripper", "ssh", "hackerbot"]
categories: ["systems_security"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AAA"
    topic: "Authentication"
    keywords: ["identity management", "user authentication", "facets of authentication", "Cryptography and authentication (hashes and attacks against authentication schemes / passwords)"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["authentication and identification", "Linux authentication", "Types of user accounts"]
---

## Getting started {#getting-started}

### VMs in this lab {#vms-in-this-lab}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop (you can sudo to get superuser access)
- server (you can SSH to this machine, but you don't have superuser access)
- kali_cracker (user: `kali`, password: `kali`; you will use this to crack the hashes you find)

### Your login details for the "desktop" and "server" VMs {#your-login-details}

\==VM: On the desktop and server VMs==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the hackerbot_server, but it needs to be running to complete the lab.

### Note the IP addresses of your VMs {#note-the-ip-addresses-of-your-vms}

Throughout this lab you will need the IP addresses of the desktop and server VMs.

\==VM: On the desktop VM==, ==action: open a terminal and run:==

```bash
ip -4 -o a s
```

> Note: The `ip a s` command lists all local IP addresses, `-4` filters to only show IPv4, and `-o` sets one-line output mode. Note the IP address — this is your **desktop IP address**.

\==VM: On the server VM==, ==action: run the same command== and note the IP address — this is your **server IP address**.

> Tip: Wherever this lab sheet says "the desktop IP address" or "the server IP address", ==edit: substitute the address you noted down==.

{% include hackerbot-intro.md role="task you to configure new users, then crack and use passwords to find flags on the server" pidgin="full" %}

## Introduction to authentication {#introduction-to-authentication}

Authentication plays the important role of verifying an identity. For example, when someone gets into an airplane, sits down at a computer, picks up a mobile device, or uses a website, authentication is what is used to confirm that the person is who they claim to be. Authentication is an important first step *before* deciding how the system should act and what to allow.

## Identity: users and groups {#identity-users-and-groups}

Most computer systems have the concept of a user account. Although some devices such as mobile phones typically only have one user account, most modern computers can support having multiple users, each with their own identity. For example, a computer can have a separate account for each person that uses it, and if configured to do so may enable each user to have their own account preferences, and access to different resources.

On Unix/Linux systems every user account is identified by a user ID number (UID), which is a 32-bit integer (whole number), and can have one or more user names, which are human readable strings of text.

\==VM: On the desktop VM==, ==action: open a terminal console.==

Assuming you have already logged in, you have already authenticated yourself on this system.

> Question: When and how did you authenticate yourself?

==action: Use these commands to find out about your current identity== (or more accurately the identity of the software you are interacting with):

```bash
whoami

groups

id
```

==edit: Make a note of your UID and username.==

Note that your account is also a member of one or more groups. A primary group, and a list of other groups. Some Linux systems, such as Debian, create a new separate primary group for each user, others such as openSUSE have a shared group (named "users") that all normal users are a member of. Similar to the relationship between user names and UIDs, each group has a group name, and a group ID (GID).

Information about user accounts is stored in the /etc/passwd file, which typically all users can read.

==action: View the /etc/passwd file:==

```bash
less /etc/passwd
```

==action: Find the line that describes your user account.==

This line defines the username, password (well, it used to be stored here... we will come back to this), UID, primary group GID, full name, home directory, and shell for your account.

Confirm this matches the information you recorded earlier.

==action: Find the line that describes the root user account.==

> Question: Where is the root user's home directory?

> Tip: Press 'q' to quit less.

==action: View the /etc/group file:==

```bash
less /etc/group
```

Groups are defined in this file, along with which users are members.

> Question: Which users are members of the audio group?

Remember, primary groups do not appear in this file; for example, on openSUSE the "users" group, which all normal users are a member of, may not appear in the /etc/group file.

The "sudo" program can be used to run a program as another user, effectively enabling users to switch between user accounts at the command prompt.

==action: Change your identity to root.== Run:

```bash
sudo -i
```

Enter your password.

==action: Use these commands to find out about your new identity:==

```bash
whoami

groups

id
```

> Question: What is the UID of root? What does this mean about this user?

> Question: What gives this user special privileges: the name of the account, or the UID?

==action: Use the useradd command to create a new user account 'fred'.==

> Hint: Refer to the man page for useradd, by running `man useradd`.

==action: Set a password for the user fred.==

> Hint: `sudo passwd fred`

==action: Change identity to fred.==

> Hint: `su - fred` or `sudo -i -u fred`

==action: Run (after su):==

```bash
id
```

> Question: Compare the result to the previous output.

> Question: How does this compare to your other normal user account? What is different, and what about it is the same?

==action: Run the single command "id" as root:==

```bash
sudo id
```

==action: Open a fresh terminal window== (so you are running as your normal user again).

> Question: What is the difference between sudo and su? Which is most likely to protect against accidental damage and also log the commands used? Do they authenticate users (that is, use passwords) differently?

## Users and SSH {#users-and-ssh}

==action: Log in to the server via ssh:==

```bash
ssh $USER@<server IP address>
```

==action: Display details of all users logged on to the system:==

```bash
who
```

==action: List all the processes run by all users:==

```bash
ps -eo user,comm
```

==action: List all the processes running as root:==

```bash
ps -o user,comm -u root
```

==action: Run a command to list all the processes running as *your* normal user.==

> Question: How is this server authenticating users? What user accounts exist?

## Passwords, hashes and salt {#passwords-hashes-and-salt}

Given that important security decisions are made based on the user accounts, it is important to authenticate users, to ensure that the subjects are associated with the correct identity.

> Question: What are the kinds of factors that can be used to verify a user's identity? Hint: for example, "something they have".

> Question: Which category of authentication factors is a password considered to be?

Originally passwords were stored "in the clear" (not enciphered). For example, Multics stored passwords in a file, and once at MIT a software bug caused the password file to be copied to the motd file (message of the day), which was printed every time anyone logged into the system. A solution is not to store the password in the clear. Instead a hash can be computed, using a one way hash function, and stored. When the user enters a password, a new hash is computed and compared to the original.

On Linux, the command "shasum" can be used to check the integrity of files (hash functions have many uses), and works on the same principle. We can use it to generate a hash for any given string, for example a password:

```bash
shasum
```

> Tip: Type "hello" without the quotes. Press Ctrl-D (which indicates "EOF"; that is, end of input).

==action: Repeat the above, with the same password ("hello"), and with a slight difference ("hello.").==

> Question: Are the outputs the same? Are the different hashes similar? Is this good? Why?

> Question: Which one-way hash function does the shasum program use? Would this be a good option for hashing passwords?

For password authentication, the hash still needs to be stored. On Unix, password hashes were once stored in the world-readable file /etc/passwd, now they are typically stored in /etc/shadow, which only root (the superuser) can access.

==action: View the shadow file:==

```bash
sudo less /etc/shadow
```

The format of the shadow file is:

> Note: username:**password**:last-changed(since 1-1-1970):days-until-may-change:days-until-must-change:days-warning-notice:days-since-expired-account-disabled:date-disable:reserved-field

==action: Find the hash of your user account's password.==

> Tip: Exit less ("q").

==action: Use the passwd command to change your password:==

```bash
passwd
```

> Note: When prompted, enter a new password of your choosing.

==edit: Make a note of your new password! You will need this!==

==action: View the shadow file, and confirm that the stored password has changed.==

With reference to the shadow file, and the man page for crypt (Hint: `man crypt`, or search online if not installed), consider these questions:

- On Linux, the password hash stored in /etc/shadow has a prefix that specifies the hash function used.
  > Question: What hash function is used for your password?

- > Question: When was the root password last changed?

- > Question: Do any accounts have a setting that will force a password change at a specific date?

A salt is a random string, used as further input into a one-way hash function (concatenated to the password). The salt is typically stored along with the hash. As a result the same password will have different hashes, so long as the salt is different.

> Question: Why is that a good thing? What kind of attack does a salt defend against? What is the current salt for your account? Hint: it is stored after the second "$".

## Password weaknesses {#password-weaknesses}

The strength of a password depends on its entropy: its degree of randomness. If a user chooses a word from a dictionary, it would not take long to attempt every dictionary word until finding one that results in the same hash.

Try your hand at cracking passwords using the Kali virtual machine.

\==VM: On your desktop VM==, ==action: add some new users with these passwords:==

```
hello
hellothere
password1
```

\==VM: On your Kali VM==, ==action: use John the Ripper (or Johnny, a GUI for John the Ripper) to crack the passwords.==

> Hint: `man john`, on the Kali Linux system.

> Hint: You will need to combine the passwd and shadow files (manually or with the Kali `unshadow` command).

> Tip: You can make a copy of the passwd and shadow files on the desktop (to your home directory), then from the Kali VM scp them over:

```bash
scp $USER@<desktop IP address>:FILENAME .
```

> Tip: Then run unshadow, then start cracking them with your software of choice.

> Hint: Some users like to use a word followed by some numbers as their password.

> Question: Which passwords are cracked the fastest? How long did they take?

## Conclusion {#conclusion}

At this point you have:

- Applied authentication concepts to Unix/Linux
- Experimented with user accounts and identity
- Experimented with one-way hash functions, salts, and password storage
- Cracked passwords with low entropy using dictionary attacks

Well done!

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Create a new user account on the desktop VM, using the username Hackerbot gives you in the chat.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Add the new user you just created to the 'users' group.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #3 {#hackerbot-attack-3}

You can skip the bot to here, by saying **goto 3**.

> Hackerbot: Crack the passwords of the desktop VM's user accounts with a UID higher than 1001, then SSH into the server VM (using the server IP address) with each cracked username and password to find the flags. This is the final challenge.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

## Resources {#resources}

[Chapter 11 "Authentication": Bishop, M. (2004), Introduction to Computer Security, Addison-Wesley. (ISBN-10: 0321247442)](https://my.leedsbeckett.ac.uk/bbcswebdav/pid-2221598-dt-content-rid-4451698_1/institution/Online%20Learning/AET/CT/MSc%20Computer%20Security/Principles%20of%20Digital%20Security/Readings/Week%205/DCS-85139%20%281%29.pdf)
