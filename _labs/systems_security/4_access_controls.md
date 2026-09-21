---
title: "Access Controls and Linux File Permissions"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Learn access control concepts and Unix file permissions, then apply them against Hackerbot's live challenges."
overview: |
  Access control involves authorising and mediating access to resources, determining what actions are permitted, and enforcing security policies. In this lab, you will explore access control and Unix file permissions, gaining a practical understanding of how they work and their significance in maintaining system security. The lab introduces subjects and objects in the context of access control, different access control models, and Unix file permissions.

  Throughout this lab, you will learn how to view and manipulate file permissions in a Unix-like operating system. You will explore the concept of inodes, examine file permissions using the `ls` command, create and manage hard and symbolic links to files, and understand how directory-level permissions affect file access. You will also work with `chmod` to change file permissions, and discover the significance of `umask` in setting default permissions for new files.

  This is a Hackerbot lab. Work through the lab sheet, then when prompted interact with Hackerbot. The Hackerbot tasks give you hands-on experience managing user access, group permissions, and file ownership, creating files with specific permissions, ownership, and group assignments, while making sure other users are appropriately restricted from accessing them.
tags: ["access-control", "file-permissions", "unix", "chmod", "umask", "inodes", "acls", "hackerbot"]
categories: ["systems_security"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AAA"
    topic: "Authorisation"
    keywords: ["access control", "enforcing access control", "ACCESS CONTROL - DAC (DISCRETIONARY ACCESS CONTROL)", "Vulnerabilities and attacks on access control misconfigurations"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["Access controls and operating systems", "Linux security model", "Unix File Permissions", "Filesystems, inodes, and commands", "umask"]
  - ka: "OSV"
    topic: "Role of Operating Systems"
    keywords: ["mediation"]
---

## Getting started {#getting-started}

### VMs in this lab {#vms-in-this-lab}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop (you can `sudo` to get superuser access)
- server (you can `ssh` to this machine, but you don't have superuser access)

All of these VMs need to be running to complete the lab.

### Your login details for the "desktop" and "server" VMs {#your-login-details}

\==VM: On the desktop and server VMs==, log in using:

- User 1: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

Your desktop VM also has a second user account, with a password you don't know. ==action: List the other usernames on the desktop VM:==

```bash
ls /home
```

> Note: This lists the other usernames present on the desktop. Wherever this lab sheet says "your second user", ==edit: substitute the second username you found here==. Since you don't know this account's password, you'll access it using `sudo` (as your own sudoer account) rather than logging in directly with `su`.

You won't log in to the hackerbot_server, but the VM needs to be running to complete the lab.

{% include hackerbot-intro.md role="ask you to configure the security of your desktop, and will reward you with flags" %}

## Introduction to access control {#introduction-to-access-control}

*Access control* enforces *authorisation* by determining and enforcing which actions are allowed. Some terminology: a *subject* is an active entity taking actions, such as a user or program, and an *object* is the (often passive) resource that can be accessed, such as a file or network resource. Access control mediates all subjects' access to objects by enforcing a security policy, limiting which actions are and are not allowed. The *policy* expresses what is allowed, either formally or informally as a set of rules.

An access control *mechanism* is the code or thing that enforces a policy. An access control *model* is a way of representing and reasoning about a policy or types of policy.

## Unix file permissions and inodes {#unix-file-permissions-and-inodes}

The traditional Unix security model is based on the *discretionary access control (DAC)* model, which enables users to configure who can access the resources that they "own". Each user can control which other users can access the files that they create. This enables users to grant permissions, without involving a system admin. This is the type of security that has traditionally been built into most consumer OSs such as Windows and Unix.

Unix file permissions use an abbreviated (simplified) form of access control list (ACL). A (full) ACL involves attaching a list of every subject and what they can do to each file (this is how Windows manages file access). For example, a file may have this ACL: "Joe can read, Frank can write, Alice can read, and Eve can read".

Unix simplifies permissions by only defining rules for these three kinds of subjects:

- **u**: The **u**ser that owns the file
- **g**: The file's **g**roup
- **o**: All **o**ther users

\==action: Open a terminal console.==

Use the `ls`[1](#user-content-fn-1) command to ==action: display the permissions for a file== (the details of the `ls` executable program itself):

```bash
ls -l /bin/ls
```

```
-rwxr-xr-x 1 root root 130736 Feb 22  2017 /bin/ls
```

The `-l` flag instructs `ls` to provide this detailed output.

The first part of the output contains the Unix file permissions for the file: what access the user (`rwx`), group (`r-x`), and other (`r-x`) are authorised.

The meaning of these letters is fairly self evident, but does change meaning slightly depending on whether it refers to a normal file or a directory (which is really just a special kind of file).

The meaning for a regular file (as is the case for `/bin/ls`):

- **r**: Read the contents of the file
- **w**: Change the contents of the file
- **x**: Execute the file as a process (the first few bytes describe what type of executable it is, a program or a script)

For a directory:

- **r**: See what files are in the directory
- **w**: Add, rename, or delete names from the directory
- **x**: 'stat' the file (view the file owners and sizes, `cd` into the directory, and access files within)
- **t** (in place of `x`), AKA the "sticky bit": write is not enough to delete a file from the directory, in this case you also need to own the file

The rest of the output from `ls` describes how many names/hard links the file has (1), who owns the file: the user (`root`) and group (`root`) associated with the file, the file size in bytes (130736 bytes in the example above), the last access date, and finally the path and name of the file.

The permissions for each file are stored in the file's inode. An inode is a data structure in Unix filesystems that defines a file. An inode includes an inode number, and defines the location of the file on disk, along with attributes including the Unix file permissions, and access times for the file.

\==action: View the inode number for this file:==

```bash
ls -i /bin/ls
```

Note that the inode does **not** contain the file's name, rather a directory can contain names that point to inodes. It is therefore possible to create two names (AKA hard links) that point to the same file.

\==action: Create a hard link to the `ls` program:==

```bash
sudo ln /bin/ls /tmp/ls
```

Now ==action: view the details for your new filename==, `/tmp/ls`:

```bash
ls -l /tmp/ls
```

> Question: How many hard links does this report? What are the file ownership and permissions associated with the new name?

\==action: View the inode number for this file:==

```bash
ls -i /tmp/ls
```

The inode matches. There is *only one file*, but that data can now be accessed using two different names, `/tmp/ls` and `/bin/ls`. If the `/tmp/ls` file was edited, the `/bin/ls` command would also change.

Deleting one of the names simply decrements the link counter. Only when that reaches 0 is the inode actually removed. ==action: Run:==

```bash
sudo rm /tmp/ls
```

In addition to hard links, there are also symbolic or soft links. ==action: Let's create a symlink now:==

```bash
ln -s /bin/ls /tmp/ls
```

Unlike hard links, symbolic links do not contain the information of the file they are linked to; a symbolic link is similar to a Windows shortcut, it simply points to another file on the system — this allows them to link to directories and remote files, in a way that hard links cannot. If the original file is deleted, the symlink becomes unusable, whereas the data of the target file is preserved in the case of a hard link.

\==action: View the details for this file:==

```bash
ls -l /tmp/ls
```

The first letter is an `l` where it had been an `-` before, representing the fact that this file is a symbolic link file. The very last part indicates what this file is linked to (in this case, `/bin/ls`).

Now, ==action: try to remove this symlink as your second user:==

```bash
sudo -u <second user> rm /tmp/ls
```

> Note: Substitute your second username for `<second user>`.

Permission denied! Interestingly, in this case as a normal user we can create the symlink to `/bin/ls` in the shared directory, but the other user cannot then delete that link since the sticky bit is set for the `/tmp/` directory. ==action: Run:==

```bash
ls -ld /tmp/
```

Note the `t` in the permissions, and refer to the meaning described above.

> Question: What is this directory used for? Why do you think the `/tmp/` directory has the sticky bit set — what does this stop users from doing to each other? How is this related to security?

You can ==action: delete the link as root:==

```bash
sudo rm /tmp/ls
```

The `stat` command can be used to display further information from the inode. ==action: Run:==

```bash
stat /bin/ls
```

Look through this information. Note that the output includes the access rights, along with the last time the file was accessed, modified, and when the inode was last changed.

The output from `stat` includes the format that the information is stored as, along with a more "human readable" output. As we know, user accounts are referred to by UIDs by the system, in this case the UID is 0, as the file is owned by the root user. Similarly, groups are identified by GID, in this case also 0. The actual permissions are stored as four octets (digits 0-7), in this case `0755`. This translates to the (now familiar) human-friendly output, `-rwxr-xr-x`. For now we will ignore the first octet, this is normally 0, we will come back to the special meaning of this later.

Each of the other three octets simply represents the binary for `rwx`, each represented as a 0 or a 1. The first of the three represents the **u**ser, then the **g**roup, then the **o**ther permission.

An easy and quick way to do the conversion is to simply remember:

- r = 4
- w = 2
- x = 1

And add them together to produce each of the three octets.

So for example, `rwx` = binary 111 = (4 + 2 + 1) = 7.

Likewise, `r-x` = binary 101 = (4 + 1) = 5.

Therefore, `-rwxr-xr-x` = 755.

## Changing file permissions on a Linux system {#changing-file-permissions-on-a-linux-system}

\==action: Open a second console/tab.==

> Tip: In Konsole, press Ctrl+Shift+T to open another tab.

\==action: Switch to your second user account:==

```bash
sudo -u <second user> -i
```

> Note: Do not log in as root, instead use `sudo` as required. Since you don't know your second user's password, `sudo -u <second user> -i` gets you an interactive shell as that user using your own sudo privileges, without needing their password.

Create a file named "mysecrets" in your second user's home directory[2](#user-content-fn-2):

```bash
cat > ~/mysecrets
```

Enter a number of lines of content. Press Ctrl-D when finished entering a "secret".

Your first aim is to ensure your "mysecrets" file is not visible to other users on the same system.

First ==action: view the permissions of your newly created file:==

```bash
ls -l ~/mysecrets
```

Oh no! It's not so secret!

> Question: What kind of access do other users on the system have to this file?

The `chmod` command can be used to set permissions on a file. `chmod` can set permissions based on absolute octal values, or relative changes.

So for example, you could use `chmod` to set permissions on a file based on octet:

> Note: `770` would give the owner and group `rwx`, and others no permissions. Example: `chmod 770 /home/tmp/somefile`

Or you can make relative changes:

> Note: `u+x` would add the owner (user) the ability to execute the file. Example: `chmod u+x /home/tmp/somefile`. Likewise, `o-w` removes *other*'s ability to write to the file. Example: `chmod o-w /home/tmp/somefile`

\==action: Use `chmod` to grant yourself read-write permission to your mysecrets file, and everyone else no permissions to the file:==

```bash
chmod ==edit:XXX== ~/mysecrets
```

> Note: Where `XXX` is three octets that grants the appropriate access.

\==action: Test whether you have correctly set permissions. Switch back to your first user's console and test that they cannot access the file:==

```bash
less /home/<second user>/mysecrets
```

Permission denied.

\==action: Create a file that should be readable by all users on the system:==

```bash
echo "Readable!" > ~/readable
chmod 0644 ~/readable
```

```bash
less /home/<second user>/readable
```

Permission denied.

> Question: Why is the readable file, which has read permissions for all users, inaccessible by your first user? Investigate the directory-level permissions.

```bash
ls -la /home/ | grep <second user>
```

Other users do not have permission to interact with files within the directory at the directory level. The permissions of a directory determine what a subject can do with the files within the directory.

\==action: Grant permissions on your second user's home directory to other users:==

> Note: Switch back to your second user's console and modify their home directory permissions to grant all other users read and execute access.

```bash
chmod ==edit:XXX== ~
```

> Note: Where `XXX` is three octets that grants the appropriate access. Alternatively use the relative change syntax described above.

```bash
cat /home/<second user>/readable
```

You should see the string "Readable!"

```bash
cat /home/<second user>/mysecrets
```

Permission denied, as expected.

## `umask` {#umask}

Remember that our newly created file started with permissions that meant everyone could read the file. This can be avoided by setting the **u**ser file-creation mode **mask** (`umask`). Every process has a umask: an octal that determines the permissions of newly created files. It works by removing permissions from the default `666` for files and `777` for new executables (based on a logical NOT). That is, a umask of `000` would result in new files with permissions `666`. A umask of `022` (which is the default value) gives `644`, that is `rw- r-- r--`.

The umask Bash built-in (or system call) can be used to set the umask for the current process.

\==action: Check the current umask value:==

```bash
umask
```

\==action: Using the umask built-in, set your umask so that new files are only rw accessible by you (but not to your group or others):==

```bash
umask ==edit:XXX==
```

> Note: Where `XXX` is the new umask to use.

\==action: Test your new umask value by creating a new file and checking its permissions:==

```bash
touch ==edit:newfilename==
ls -l ==edit:newfilename==
```

> Question: Do the permissions read `rw-------`? If not, change the umask and try again.

\==action: Figure out how to (and do) make that setting apply every time you log in.==

> Tip: Try searching online for "bash login" or "startup config".

> Question: What would be a safe umask for a shared Linux system? Justify your decision.

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Create a new group on your desktop.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Add yourself to the group Hackerbot just created on your desktop.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #3 {#hackerbot-attack-3}

You can skip the bot to here, by saying **goto 3**.

> Hackerbot: Create a file with a specific string as its contents, owned by you, with a particular set of permissions Hackerbot specifies.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #4 {#hackerbot-attack-4}

You can skip the bot to here, by saying **goto 4**.

> Hackerbot: Create a file with a specific string as its contents, owned by your second user, with a particular set of permissions and group ownership Hackerbot specifies.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #5 {#hackerbot-attack-5}

You can skip the bot to here, by saying **goto 5**.

> Hackerbot: Create a file owned by you, containing a specific string, and use group permissions so that your second user can read it (but not write to it), while a third user has no access at all.

> Hint: You'll need to use groups and standard permissions to achieve this; using an ACL for this task is not allowed.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #6 {#hackerbot-attack-6}

You can skip the bot to here, by saying **goto 6**.

> Hackerbot: There is a serious access control misconfiguration on your server. Investigate to find a way to escalate to root access.

> Flag: There are flags to be found once you've escalated your privileges on the server — look in a home directory.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

## Resources {#resources}

[Chapter 1 "Foundations of Security and Access Control in Computing": Benantar, M. (2006), Access Control Systems: Security, Identity Management and Trust Models, Springer. (ISBN-10: 0387004459)](https://www-dawsonera-com.ezproxy.leedsbeckett.ac.uk/readonline/9780387277165)

## Footnotes

1. The name `ls` is from the old Multics command which was named after "list segments", although it can be thought of as "list" (since the term "segment" is no longer meaningful for Unix), it is similar in use to the `dir` command on Windows. [↩](#user-content-fnref-1)
2. The `~` character is interpreted by Bash as the location of your own home directory, such as `/home/<second user>/`. [↩](#user-content-fnref-2)
