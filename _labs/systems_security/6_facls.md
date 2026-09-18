---
title: "Access Controls: Access Control Lists (ACLs)"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Learn POSIX Access Control Lists on Linux — setting, masking, and default ACLs — then use them, and find a permissions weakness, to satisfy Hackerbot's challenges."
overview: |
  Access Control Lists (ACLs) are sets of rules attached to resources, specifying which subjects (users or entities) are authorised to access the resource and the type of permissions granted to each subject. ACLs allow for a granular and flexible approach to managing who can access a file, what kind of access they have, and how these permissions are inherited and checked.

  You will learn about the fundamental concepts of full ACLs, their syntax and usage on Linux systems, and how they differ from traditional Unix file permissions. Through hands-on tasks, you will set ACLs on files, manipulate permissions for specific users, explore the mask entry's role in determining maximum permissions, and understand the behaviour of access checks in ACLs. Additionally, you will discover the concept of default ACLs and their impact on newly created files within a directory. By comparing Linux ACLs to Windows ACLs, you'll gain insights into the unique features and nuances of each system, such as inheritance logic and the use of global security identifiers. This lab will equip you with practical skills and knowledge to manage access control effectively across a diverse range of computing environments.

  This is a Hackerbot lab. Work through the lab sheet below, then when prompted interact with Hackerbot. The Hackerbot tasks involve creating and managing files and directories using Linux ACLs to control access, allowing specific users to read and write while denying access to others. There is also a file permissions challenge on a server, where you take what you've learned over the last few topics to find and exploit a permissions weakness.
tags: ["acl", "facl", "access-control-lists", "posix-acl", "linux-permissions", "setfacl", "getfacl", "hackerbot"]
categories: ["systems_security"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AAA"
    topic: "Authorisation"
    keywords: ["access control", "ACCESS CONTROL LIST (ACL)", "Vulnerabilities and attacks on access control misconfigurations"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["Access controls and operating systems", "Linux security model", "Linux Extended Access Control Lists (facl)"]
---

## Getting started {#getting-started}

### VMs in this lab {#vms-in-this-lab}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop (you can sudo to get superuser access)
- server (you can ssh to this machine, but you don't have superuser access)

### Your login details for the "desktop" and "server" VMs {#your-login-details}

\==VM: On the desktop and server VMs==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the hackerbot_server, but it needs to be running to complete the lab.

### Note the other usernames on your VMs {#note-the-other-usernames}

Several tasks in this lab involve other user accounts on the desktop VM.

\==VM: On the desktop VM==, ==action: open a terminal and run:==

```bash
ls /home
```

> Note: This lists the other usernames present on the desktop. The same usernames (with the same passwords as each other, but not the same as yours) also exist on the server VM. Wherever this lab sheet says "the second username" or "the third username", ==edit: substitute one of the other usernames you noted down== (any two of them will do, so long as you use the same one consistently within a task).

### Note the server VM's IP address {#note-the-server-ip-address}

You will need this later, to ssh from the desktop VM to the server VM.

\==VM: On the server VM==, ==action: open a terminal and run:==

```bash
ip -4 -o a s
```

> Tip: Wherever this lab sheet says "the server IP address", ==edit: substitute the address you noted down==.

{% include hackerbot-intro.md role="set you ACL challenges to complete on the desktop VM, and a file permissions challenge to find on the server VM" %}

## Introducing full Access Control List (ACL) file permissions {#introducing-full-acl-file-permissions}

An *access control list (ACL)* is attached to an object (resource) and lists all the subjects (users / active entities) that are allowed access, along with the kind of access that is authorised.

We have explored standard Unix file permissions, which is an abbreviated (simplified) form of ACL. With standard Unix file permissions all authorisation is defined in terms of the owning user (u), groups (g), and others (o), and the type of access that can be granted is read (r), write (w), and execute (x) — along with some special permission flags, SUID, SGID, and stickybit, which change the meaning of these.

The Unix file permissions (0664) `-rw-rw-r-- 1 <user> group1 5 Feb 5 test` can be thought of as a simplified ACL with:

Subject | Permission
--- | ---
the owning user | read, write
members of group1 | read, write
everyone else | read

While this is an effective way of representing permissions, and is often adequate, using these traditional Unix file permissions there is no way of representing more complicated rules, such as also granting specific users access to write the file without making them members of group1.

Modern systems (Windows, Linux, and some other Unix-based systems) now have more complete (and complicated) ACL support, enabling more fine-grained control over authorisation.

A more expressive ACL for a file can represent a state such as:

Subject | Permission
--- | ---
the owning user | read, write
a named user | read, write
members of group1 | read, write
members of group2 | read
everyone else | nothing

## Linux Extended ACLs {#linux-extended-acls}

Linux now has support for full ACLs (known as Linux ACLs or POSIX ACLs). Linux ACLs can include entries for named users and named groups.

ACLs require compatible filesystems so that they can be stored. Linux ACLs are saved as extended attributes (EA), which are used to associate metadata with files.

Linux ACLs that are equivalent with Unix file permissions are known as **minimal ACLs**. Linux ACLs with more than these three entries (owner user, owner group, and others) are known as **extended ACLs**. Below is a table showing the types of subjects present in Linux ACLs.

Subject type | Text representation
--- | ---
Owner | user::rwx
Named user | user:name:rwx
Owning group | group::rwx
Named group | group:name:rwx
Mask | mask::rwx
Other | other::rwx

The Owner (user::xxx) and Other (other::xxx) permissions are automatically synced to the matching Unix file permission bits.

\==action: Set a file ACL on your `mysecret` file==, using the setfacl command:

```bash
setfacl -m u:==edit: second username==:r ~/mysecret
```

> Note: The `-m` flag specifies that the ACL is to be modified. `u:` or `user:` specifies a rule for a named user; `g:` or `group:` could be used for a named group. This is followed by the name of the user or group. Finally read (r), write (w), and/or execute (x) can be specified using letters (rwx) or a number (7, which is the octet representing rwx).

This grants the second user read access to the file (without requiring access granted to any other groups or users).

\==action: Confirm you can access the file as the second user:==

```bash
sudo -u ==edit: second username== cat /home/==edit: your username==/mysecret
```

> Tip: You'll need to ensure that the second user has permission to enter the directory.

Note that the `stat` program is not usually ACL aware, so won't report anything out of the usual. ==action: Run:==

```bash
stat ~/mysecret
```

The `ls` program can be used to detect file ACLs. ==action: Run:==

```bash
ls -la ~/mysecret
```

`-rw-r-----+ 1 <you> <you> 22 Feb 28 11:47 mysecret`

Note that the output includes a `+`. This indicates an ACL is in place.

\==action: Use getfacl to display the permissions:==

```bash
getfacl ~/mysecret
```

## Mask {#mask}

Extended ACLs contain a mask entry that defines the upper bound (maximum permissions) that can be assigned by the ACL rules that apply to any named users or groups. This mask (mask::xxx) is typically automatically updated to the union (maximum) of all permissions granted, and automatically synced with the value of the group Unix file permission bits.

\==action: Grant full rwx permission to the second user:==

```bash
setfacl -m u:==edit: second username==:rwx ~/mysecret
```

\==action: View the updated permissions visible via `ls`:==

```bash
ls -la ~/mysecret
```

> Note: The group file permission has changed (in addition to the `+`); this helps to show the level of permission that can result from the new ACL rule.

Again, ==action: use getfacl to display the ACL rules:==

```bash
getfacl ~/mysecret
```

Note that the mask has changed.

\==action: Change the mask value to "r"==

> Hint: See the table above that describes the text representation.

\==action: Confirm the second user can no longer access the file due to the mask, even though they have rwx permission.==

## Understanding the access check behaviour {#access-check-behaviour}

The decision making logic has been described as follows:

>If
>>the user ID of the process is the owner, the owner entry determines access

>else if
>>the user ID of the process matches the qualifier in one of the named user entries, this entry determines access

>else if
>>one of the group IDs of the process matches the owning group and the owning group entry contains the requested permissions, this entry determines access

>else if
>>one of the group IDs of the process matches the qualifier of one of the named group entries and this entry contains the requested permissions, this entry determines access

>else if
>>one of the group IDs of the process matches the owning group or any of the named group entries, but neither the owning group entry nor any of the matching named group entries contains the requested permissions, this determines that access is denied

>else
>>the other entry determines access.

>If
>>the matching entry resulting from this selection is the owner or other entry and it contains the requested permissions, access is granted

>else if
>>the matching entry is a named user, owning group, or named group entry and this entry contains the requested permissions and the mask entry also contains the requested permissions (or there is no mask entry), access is granted

>else
>>access is denied.

Quoted from (Grünbacher, 2003) [^1]

## Default ACLs {#default-acls}

Directories can have two kinds of ACLs: **access ACLs** (which define the actual rules applied — this is what we have been using so far), and **default ACLs**.

Default ACLs set the ACL rules that are applied to any new files created in the directory. Directories created inherit the default ACL, as the new access ACL and default ACL.

When a default ACL is specified on the parent directory, `umask` has no effect on the permissions of new files.

\==action: Create a directory to share with the second user:==

```bash
mkdir shared
setfacl -m u:==edit: second username==:rw -d -m u:==edit: second username==:rw shared
```

\==action: Create a new file in the shared directory.==

\==action: View the ACL created on the new file.==

## Comparison with Windows ACLs {#comparison-with-windows-acls}

Windows file permissions are similar to Linux ACLs, although they are slightly more complicated.

On Windows, permissions are dynamically inherited and checked at access time. Changing permissions on a directory can change the permissions applied to the files within (or even changing the permissions of a directory's parent directory!). Linux ACLs only inherit permissions from default ACLs when they are created, and there is no complicated checking of all the parent directories to calculate access permissions.

Windows has lots more kinds of access that can be assigned (including append and delete permissions, and ACLs can contain rules about inheritance logic, and deny permissions), compared to Linux ACLs, which define rules in terms of read, write, and execute (rwx).

Linux ACLs use local UIDs and GIDs to assign identity to all subjects (even when authenticating against remote servers, local UIDs are generated). Windows uses global security identifiers (SIDs) that can be local or for domain users (authenticated against a domain controller, the global SID is used on ACLs).

> Question: How can the results differ between how Linux ACLs and Windows ACLs grant permissions? Consider how permissions work for files inside nested directories that have inherited ACLs, and whether Linux ACLs include deny rules.

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Create a file on the desktop, owned by you, containing a string it gives you. Use Linux ACLs (without groups) so the second user can read the file but not write to it, and make sure the third user has no access to it at all.

\==action: Do any necessary preparation, then when you are ready for the bot to complete the attack, say 'ready'.==

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Create a directory on the desktop, owned by you. Use Linux ACLs (without groups) so the second and third users can also create shared files inside it (read and write for all three of you), while it stays inaccessible to everyone else.

\==action: Do any necessary preparation, then when you are ready for the bot to complete the attack, say 'ready'.==

Don't forget to ==action: save and submit any flags!==

## A file permissions weakness on the server {#file-permissions-weakness-on-the-server}

\==VM: On the desktop VM==, ==action: ssh to the server== using your own username and password:

```bash
ssh ==edit: your username==@==edit: server IP address==
```

> Hint: There is a file permissions problem on the server that could let a normal user read files they shouldn't be able to. There is a flag to be found in a home directory that isn't your own.

#### Hackerbot Attack #3 {#hackerbot-attack-3}

You can skip the bot to here, by saying **goto 3**.

> Hackerbot: There is a file permissions weakness on the server that could let a normal user read any file. Find the flag hidden in a home directory. This is the end.

\==action: Do any necessary preparation, then when you are ready for the bot to complete the attack, say 'ready'.==

Don't forget to ==action: save and submit any flags!==

## Resources {#resources}

This excellent paper describes Linux ACLs in detail:

[Grunbacher, Andreas. "POSIX Access Control Lists on Linux." *USENIX Annual Technical Conference*, FREENIX Track. 2003.](https://www.usenix.org/legacy/events/usenix03/tech/freenix03/full_papers/gruenbacher/gruenbacher.pdf)

[^1]: Grünbacher, Andreas. "POSIX Access Control Lists on Linux." *USENIX Annual Technical Conference*, FREENIX Track. 2003.
