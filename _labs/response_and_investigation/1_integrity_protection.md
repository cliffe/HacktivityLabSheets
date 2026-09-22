---
title: "Integrity Management: Protecting Against Change"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Learn to protect the integrity of files and systems against unauthorised change, using Unix file permissions, file attributes, and read-only bind mounts, while fending off Hackerbot's live attacks."
overview: |
  This lab addresses preserving the integrity of your digital assets. In today's data-driven world, ensuring the accuracy and reliability of information is of utmost importance. Unauthorised changes, whether intentional or accidental, can lead to significant data breaches and compromise the trustworthiness of your system. This lab is designed to provide you with essential knowledge and practical skills to fortify the security of your data by exploring key theoretical concepts like file permissions, file attributes, and read-only filesystems.

  Throughout this lab, you will engage in practical exercises to grasp fundamental principles of data integrity protection. You'll explore the use of file attributes to restrict access and protect sensitive information. You'll also discover the utility of read-only filesystems by mounting directories in read-only mode, ensuring that changes cannot be made to critical system files. By completing these exercises and challenges, you will acquire the skills to protect your system's integrity.

  This is a Hackerbot lab. Hackerbot will attack your system live, and you must apply what you've learned to stop each attack before it succeeds.
tags: ["integrity", "file-permissions", "file-attributes", "chattr", "read-only", "bind-mount", "hackerbot"]
categories: ["response_and_investigation"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AAA"
    topic: "Authorisation"
    keywords: ["access control", "Protecting integrity"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["Linux read only protections: ro mounts, file attributes"]
---

## Getting started {#getting-started}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop

### Your login details for the "desktop" VM {#your-login-details-for-the-desktop-vm}

\==VM: On the desktop VM==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the hackerbot_server, but the VM needs to be running to complete the lab.

{% include hackerbot-intro.md role="attack your system" chat="full" %}

## Integrity {#integrity}

Security is often described in terms of confidentiality, integrity, and availability. Protecting the integrity of information involves preventing and detecting unauthorised changes. In many commercial organisations integrity of information is the highest priority security goal. Managing who is authorised to make changes to databases or files, and monitoring the integrity of resources for unauthorised changes is an important task in managing information security.

## Protecting integrity {#protecting-integrity}

Protecting the integrity of resources, such as the files on a system, involves successfully managing a variety of security mechanisms, such as authentication, access controls and file permissions, firewalls, and so on.

> Note: On Linux systems this can include managing passwords, packet filtering IPTables rules, standard Unix file permissions (rwx), Linux extended attributes (including ACLs for detailed authentication, labels for mandatory access control (MAC), and Linux Capabilities). Linux (like other Unix-like and Unix-based systems) has a long history of adding new security features as and when they are required.
>
> Note that many security controls such as those listed above are very important for protecting the integrity of files, but are beyond the scope of this lab. Here the focus is on techniques that are focussed on integrity rather than confidentiality or availability.

There are precautions that can be taken to reduce the chances of unauthorised changes.

## Protecting integrity with file permissions {#protecting-integrity-with-file-permissions}

### Getting to know file permissions {#getting-to-know-file-permissions}

File permissions enable users to control the access that other users have to their files.

We will cover the topic in depth elsewhere. This just provides an introduction to Unix file permissions.

\==VM: On the desktop VM==, ==action: open a terminal console== (such as "Konsole" from KDE Menu / Applications / System / Konsole).

Start by creating a file with some content.

\==action: Run:==

```bash
cat > ~/example
```

> Note: Type some content, then press Ctrl-D to finish and return to the prompt. The output is sent to the file `~/example` in your home directory. In bash you can type `~` as shorthand for your home directory.

You can read the content:

```bash
cat ~/example
```

Or replace the content:

```bash
cat > ~/example
```

> Note: Type some content, then press Ctrl-D to finish and return to the prompt.

You can view the file permissions with:

```bash
ls -la ~/example
```

```
-rw-r--r-- 1 user user 20 Feb 7 17:38 /home/user/example
```

This shows that the file is owned by *user*, and that the user has read-write access ("rw-"), others on the system have read access ("r--").

By default new files can only be edited by the owner of the file (more on file permissions and umask another time). However, by default other users of the system can likely *read* your files.

You can remove the ability of *anyone* changing the content. ==action: Run:==

```bash
chmod -w ~/example
```

> Note: `-w` means "remove write access (for everyone)".

Try changing the content. ==action: Run:==

```bash
cat > ~/example
```

You can't.

You can remove the ability of **everyone else** changing the content. ==action: Run:==

```bash
chmod u+w,go-rw ~/example
```

> Note: `u+w`: user who owns the file, add write access. `go-rw`: group and others, remove read and write access.

You can view the file permissions with:

```bash
ls -la ~/example
```

```
-rw-------- 1 user user 20 Feb 7 17:38 /home/user/example
```

> Note: The root user can access any files, regardless of file permissions.

```bash
chmod -w ~/example
sudo cat ~/example
```

> Note: Enter your password, and note that as root you can access the file regardless of permissions.

`sudo` runs a command as another user (typically root). On Unix the root user (or any user with a UID of 0) is a superuser (i.e. administrator) with extra privileges.

Exploring Unix file permissions further is outside the scope of this lab, but will be covered elsewhere.

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: An attempt to write a file in /tmp is coming from another user on the system. Stop the attack by creating the file without permission for other users to write to the file.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will tell you the filename to create in /tmp when it runs this attack. Create that file and lock down its permissions so that only you can write to it, before Hackerbot's attack runs.

Don't forget to ==action: save and submit any flags!==

## Protecting integrity with file attributes {#protecting-integrity-with-file-attributes}

### Getting to know file attributes {#getting-to-know-file-attributes}

Unix systems (such as Linux or FreeBSD) include file attributes that, amongst other features, can make files immutable or append only. Setting these file attributes can provide an effective layer of security, and yet could be considered one of the more obscure Unix security features.[1](#user-content-fn-1) Note that this feature is dependent on the use of a compatible filesystem (most Unix filesystems, such as ext, are compatible with file attributes). Once configured, file attributes can even prevent root (the all-powerful Unix superuser) from making changes to certain files.

\==action: Create a file to experiment on, then run:==

```bash
touch ~/example2
lsattr ~/example2
```

```
-------------e- /home/user/example2
```

> Note: The 'e' flag is common on ext filesystems, may or may not be present when you run the above, and does not really concern us. From a security perspective the 'a' and 'i' flags are the most interesting.

Read the man page for chattr to find out more about these flags and what they do:

```bash
man chattr
```

> Note: Press q to leave the manual page.

\==action: Set the 'i' flag== using the chattr command:

```bash
sudo chattr +i ~/example2
```

Now ==action: try to delete the file== and see what happens:

```bash
rm ~/example2
```

Denied!

\==action: Use root permissions== to try to delete the file:

```bash
sudo rm ~/example2
```

It still didn't work! That's right, *even root can't delete the file*, without changing the file's attributes back first.

\==action: Use some commands to remove the 'i' flag.== ==hint: '-i', instead of '+i'.==

Now run a command to ==action: set the 'a' flag on your file.==

If you have done so correctly, attempting to overwrite the file with a test message should fail. ==action: Run:==

```bash
sudo bash -c "echo 'test message' > $HOME/example2"
```

> Note: This should produce an error, since `>` causes the output of the program to be written to the specified file, which is not allowed due to the chattr command you have run.

> Warning: Note the `$HOME` rather than `~` here. Inside `sudo bash -c '...'` a `~` would be expanded by root's shell, so it would mean `/root`, not your home directory. `$HOME` in double quotes is expanded by your own shell before `sudo` runs.

Yet you should be able to append messages to the end of the file:

```bash
sudo bash -c "echo '==edit: YOURNAME==: test message' >> $HOME/example2"
```

> Note: This should succeed, since `>>` causes the output of the program to be appended (added to the end of) to the specified file, which is allowed.

\==action: View your changes== at the end of the file:

```bash
tail ~/example2
```

This has obvious security benefits: this feature can be used to allow files to be written to without altering existing content. For example, for ensuring that log files can be written to, but avoiding giving everyone who can write to the file the ability to alter its contents.

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: An attempt to delete a log file in your home directory is coming. Stop the attack using file attributes.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will tell you which file in your home directory it is going to try to delete. Set the appropriate file attribute on that file before running the attack.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #3 {#hackerbot-attack-3}

You can skip the bot to here, by saying **goto 3**.

> Hackerbot: An attempt to overwrite a log file in your home directory is coming. Stop the attack by making the file append only.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will overwrite the file, then also append to it, and check that only the append succeeded. Make sure the file is append-only (rather than immutable) before running the attack.

Don't forget to ==action: save and submit any flags!==

## Protecting integrity with read-only filesystems {#protecting-integrity-with-read-only-filesystems}

### Getting to know read-only mounting {#getting-to-know-read-only-mounting}

On Unix, a filesystem is mounted to a particular point in the directory structure; for example, a USB thumb drive may be mounted to /media/myUSB/. Some filesystems will automatically mount read-only; for example, if you insert a CD-ROM, since those disks are physically read-only. It is possible to optionally mount almost any filesystem, such as a USB or even a directory, in read-only mode, which will make it practically impossible to write changes to it (without remounting or accessing the drive/directory in other ways, which normally only root can do).

In modern Linux, it is possible to have a directory (one part of what is on a disk) present in the directory structure twice with different mount options (for example, `/home/user` and `/home/user-read-only`). This can be achieved by bind mounting, and then remounting to set the bind mount to read only.

\==action: In a terminal, run:==

```bash
mount
```

> Note: Many of the devices and directories have been mounted for read and write access (**rw**). For security reasons, it can be safer to mount things as read-only, when we don't need to be able to make changes to the contents.

Ordinary users can only read the /etc/ directory but the superuser root who owns the /etc/ directory can read and write to it. In the following example, you are going to mount the /etc/ directory to a mount point (another directory within the filesystem) and the contents of the /etc/ directory will be accessible via the mount point.

List the contents of the /etc/ directory so you are familiar with its contents:

```bash
ls /etc/
```

Create a new directory to be the mount point. ==action: Run:==

```bash
mkdir ~/etc
```

\==action: Mount the /etc/ directory to the new mount point:==

```bash
sudo mount -o bind /etc/ ~/etc/
```

Make sure the /etc/ directory is accessible via the mount point:

```bash
ls ~/etc/
```

Ordinary users can only read but the superuser root can still write to the directory. Test this by creating a new file as the superuser root in the `~/etc/` directory:

```bash
sudo touch ~/etc/newfile1
```

Check that a new file has been created using the following commands:

```bash
ls -l ~/etc/newfile1
ls -l /etc/newfile1
```

We can use read-only mounting to make filesystems and directories available read-only. Next you will ==action: remount /etc/ in read-only mode== so that even the superuser root who owns the /etc/ directory cannot make changes to its contents via the mount point.

```bash
sudo mount -o remount,ro,bind /etc/ ~/etc/
```

\==action: Test this== by trying to create a new file as the superuser root in the `~/etc/` directory:

```bash
sudo touch ~/etc/newfile2
```

This should prevent changes being accidentally made to important configuration files in the /etc/ directory.

We can ==action: remount a directory as read-only to itself:==

```bash
mkdir -p ~/personal_secrets/
sudo mount -o bind ~/personal_secrets/ ~/personal_secrets/
sudo mount -o remount,ro,bind ~/personal_secrets/ ~/personal_secrets/
```

Now even the owner of the directory (you), can't make changes. ==action: Try:==

```bash
cat > ~/personal_secrets/new_file
```

Mounting read-only can be an effective way of protecting resources that you don't need to make any changes to. Read-only mounting is particularly effective when an actual disk resides externally, and *can be enforced remotely*. For example, when sharing files over the network.

> Note: Mounting read-only may be circumvented by root (or a user with enough privilege) via direct access to the device files, or by re-mounting as read-write (when the mount being read-only is not enforced via a remote network share).

#### Hackerbot Attack #4 {#hackerbot-attack-4}

You can skip the bot to here, by saying **goto 4**.

> Hackerbot: An attempt to edit a file in /etc/ is coming. Stop the attack by bind mounting /etc/ as read-only.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #5 {#hackerbot-attack-5}

You can skip the bot to here, by saying **goto 5**.

> Hackerbot: Finally, try to prevent Hackerbot from obtaining shell access to your system.

> Hint: Think about everything you've done so far, and consider what else might grant an attacker access to your account or system, such as SSH keys, passwords, or sudo access.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

## Limitations of integrity checking {#limitations-of-integrity-checking}

Perhaps the greatest limitation to all of these approaches, is that if a system is compromised, you may not be able to trust any of the tools on the system, or even the operating system itself to behave as expected. In the case of a security compromise, your configuration files may have been altered, including any hashes you have stored locally, and tools may have been replaced by Trojan horses. For this reason it is safer to run tools over the network or from a removable drive, with read-only access to protect your backups and hashes. Even then, the OS/kernel/shell may not be telling you the truth about what is happening, since a rootkit could be concealing the truth from other programs.

## Resources {#resources}

An excellent resource on the subject of integrity management is Chapter 20 of the excellent book *Practical Unix & Internet Security, 3rd Ed*, by Garfinkel et al (2003).

Bind mounting: [http://lwn.net/Articles/281157/](http://lwn.net/Articles/281157/)

## Footnotes {#footnotes}

1. Setting a file to immutable (and therefore impossible to simply delete) can be an effective prank against the uninitiated in Unix ways. [↩](#user-content-fnref-1)

