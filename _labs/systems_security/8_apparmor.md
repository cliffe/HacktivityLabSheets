---
title: "Mandatory Access Controls: AppArmor"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Use Linux capabilities and AppArmor to build mandatory access controls, then defend a confined program against Hackerbot's live attacks."
overview: |
  Mandatory Access Controls (MAC) encompass mechanisms such as Capabilities and AppArmor, which provide system-wide access controls to manage and enforce permissions for processes and applications, mitigating security risks and enhancing overall system security. In this lab, you will explore two aspects of system-wide access controls in Linux security: Capabilities and AppArmor.

  First, you will look at Capabilities, a coarse-grained approach to controlling privileges in Linux, learning how they can grant specific permissions to programs without running them as the all-powerful root user. You will also explore AppArmor, a rule-based, fine-grained access control system for Linux, examining how AppArmor profiles specify the resources and permissions a program can access, effectively creating a whitelist of allowed actions. You will create rules and use AppArmor's learning mode, which helps construct rules based on actual program behaviour, and consider the trade-offs between a blacklist (deny) and a whitelist (ignore) approach to writing rules. By the end of this lab, you will understand how capabilities and AppArmor can improve the security of a Linux system by controlling what programs can do and which resources they can access.

  This is a Hackerbot lab. Work through the lab sheet, then when prompted interact with Hackerbot. Hackerbot will challenge you to use AppArmor to confine a program that provides a shell to attackers, with only limited access to specific resources.
tags: ["apparmor", "mac", "mandatory-access-control", "capabilities", "sandboxing", "hackerbot"]
categories: ["systems_security"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AAA"
    topic: "Authorisation"
    keywords: ["ACCESS CONTROL - MAC (MANDATORY ACCESS CONTROL)", "ACCESS CONTROL - NDAC (NON-DISCRETIONARY ACCESS CONTROL)", "Application-based access controls: user-based access controls insufficiently limit privileges", "Rule-based sandboxes"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["Rule-based controls: Fine grained: AppArmor", "Vulnerabilities and attacks on sandboxing misconfigurations"]
  - ka: "SS"
    topic: "Mitigating Exploitation"
    keywords: ["limiting privileges"]
---

## Getting started {#getting-started}

### VMs in this lab {#vms-in-this-lab}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop (you can sudo to get superuser access)

### Your login details for the "desktop" VM {#your-login-details}

\==VM: On the desktop VM==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the hackerbot_server, but it needs to be running to complete the lab.

{% include hackerbot-intro.md %}

## Mandatory Access Controls: Capabilities and AppArmor {#mac-capabilities-and-apparmor}

Rule-based system-wide access controls can control what each application is authorised to do. The security system enforces exactly which files or resources are accessible to each process. They don't typically require applications to be launched into a sandbox — rules are applied to any applications that have policies.

### Capabilities: coarse-grained rights {#capabilities-coarse-grained-rights}

Some rule-based controls are quite coarsely grained. For example, Android grants permissions such as "Network", "SD Card", "Camera", and "GPS" access.

Another coarsely grained system is *Linux capabilities*, which break up root's special permissions so that some programs can be granted specific "capabilities" rather than run as root. Normally on Unix, there are two types of users: privileged (uid=0) and unprivileged (uid != 0). The root user (0) is allowed to do practically anything and bypasses all kernel permission checks. Capabilities divide these privileges, making it possible to, for example, allow a program raw network access or to call chroot (`CAP_CHROOT`), without granting it all of root's other privileges, such as the ability to access every file on the system.

> Note: See `man capabilities` for the full list of available capabilities.

One of the limitations of the traditional Unix approach to privilege is that programs that require special permissions, such as ping, need to run as root — in this case so that ping can do raw network operations, something normal users can't do. However, when ping runs as root (via setuid), a programming mistake (vulnerability) in ping could possibly give normal users root access.

Capabilities help to solve the problem. Instead of running the program setuid root, we can give it the capability to do what it needs, without access to everything else that root is allowed to do.

\==action: Ping your own system== (Ctrl-C to stop):

```bash
ping localhost
```

Now \==action: make a copy of ping== (using sudo so that the copy is also owned by root):

```bash
sudo cp /bin/ping /tmp/ping
```

As your normal user (not root), try pinging again:

```bash
/tmp/ping localhost
```

It won't work since it doesn't have the required permissions:

```
ping: socket: Operation not permitted
```

One way to enable ping to work is to let it run as root, using setuid (this is how most Linux distros have worked with ping in the past).

\==action: Add setuid permissions== to the copy:

```bash
sudo chmod u+s /tmp/ping
```

\==action: Try pinging again== (it should work):

```bash
/tmp/ping localhost
```

A better solution is to use capabilities rather than setuid root.

\==action: Remove setuid:==

```bash
sudo chmod u-s /tmp/ping
```

\==action: Check the man page== of setcap:

```bash
man setcap
```

Now \==action: set ping to use the capability==, by attaching the capability to the file:

```bash
sudo setcap cap_net_raw=ep /tmp/ping
```

Check that the program now has the capability. \==action: Run:==

```bash
/sbin/getcap /tmp/ping
```

You should now be able to \==action: use the /tmp/ping program== as any user, and it will be able to ping as before:

```bash
/tmp/ping localhost
```

The advantage is that now the program cannot do all the other things root can do, so a vulnerability in ping wouldn't expose your entire system.

> Question: What approach does your desktop VM use to run ping?

> Question: Consider where capabilities can be used to remove the need for setuid.

### AppArmor: rule-based fine-grained controls {#apparmor-rule-based-fine-grained-controls}

Another approach taken by some schemes is to simply specify a list of all the resources each application is authorised to access. This is the approach taken by AppArmor and TOMOYO, which are Linux kernel security features.

First, \==action: check that AppArmor is installed and enabled== on your Linux system:

```bash
systemctl status apparmor

sudo aa-enabled
```

AppArmor takes a rule-based approach to specify which files (and other permissions) a *program* gets access to. View the profiles that have been loaded. \==action: Run:==

```bash
sudo aa-status
```

The profiles are stored in `/etc/apparmor.d/`.

\==action: View an example profile:==

```bash
less /etc/apparmor.d/bin.ping
```

Note that the profile has rules to enable networking (by allowing the program to use any matching capabilities it has been assigned, and permitting it to use networking):

```
capability net_raw,

capability setuid,

network inet raw,

network inet6 raw,
```

Some rules grant access to files. This permits the `/etc/modules.conf` file to be read:

```
/etc/modules.conf r,
```

And this permits the program to read "r", memory map "m", and execute the ping program itself:

```
/{,usr/}bin/ping mixr,
```

> Note: When a process (running program) starts a new process (program on disk), there are a few options about how the new process can be confined. The option used here is Inherit, "ix", which means the new process is confined by this same profile. This is generally the safest and easiest to understand. Other options include using its own separate profile or a child sub-profile.

There are also some time-saving *abstractions* included, which are collections of rules:

```
#include <abstractions/base>
```

\==action: Have a look at a more complicated profile:==

```bash
less /etc/apparmor.d/usr.sbin.smbd
```

### Creating your own AppArmor profile {#creating-your-own-apparmor-profile}

You will start by using AppArmor to confine a harmless text viewer to enable it to read `~/hello`, but not allow it to read `~/mysecret`.

\==action: Make a copy of less:==

```bash
sudo cp /bin/less /tmp/less
```

\==action: Check you can use this `/tmp/less` to access the "mysecret" and "hello" files in your home directory.==

\==action: Create a barebones profile== for less by running:

```bash
sudo aa-autodep /tmp/less
```

\==action: Check that your profile is now in complain mode:==

```bash
sudo aa-status
```

\==action: Set the new profile to enforcing:==

```bash
sudo aa-enforce /tmp/less
```

\==action: Test that you can no longer open either of your files.==

```bash
/tmp/less hello

/tmp/less mysecret
```

\==action: Even with root:==

```bash
sudo /tmp/less hello
```

\==action: View your new profile:==

```bash
sudo less /etc/apparmor.d/tmp.less
```

\==action: View the audit log==, which includes the AppArmor denials that have taken place:

```bash
sudo less /var/log/audit/audit.log
```

\==action: Confirm your profile is now in enforcing mode:==

```bash
sudo aa-status
```

\==action: Change your profile into complain mode== so that the denials are logged but not enforced:

```bash
sudo aa-complain /tmp/less
```

AppArmor has a learning mode to make rule construction easier. During learning mode, AppArmor logs all the denials (either in enforcing or complaining mode), then when you are ready it steps you through each of the things the program did, with the option to add to the profile rules.

\==action: Run:==

```bash
sudo aa-genprof /tmp/less
```

\==action: Leave that running and, in a separate console, run less to view some files.==

When you are finished, go back to your running `aa-genprof` and \==action: press "S"== to scan the audit log for rules.

The `aa-genprof` will ask you whether to add various rules to your profile. You should choose to accept all the access attempts that you deem appropriate (most of them, hopefully!). If you opened your mysecret file, you should not add that to the rules.

> Note: You can "deny" access to a file, but you can also choose to "ignore" those files, because anything not explicitly granted by the AppArmor profile will be denied. There is also an option to have rules only grant permission when the user is the owner of the file, which is not always what you want.

\==action: Change your profile into enforce mode so that the denials are enforced:==

```bash
sudo aa-enforce /tmp/less
```

\==action: Update and test== to create a profile that enables `/tmp/less` to access `hello`, and any files in your Documents folder, while denying access to your `mysecret` file.

> Tip: If you edit profiles directly, you can reload profiles with:

```bash
sudo service apparmor reload
```

> Question: What are the advantages and disadvantages of using a blacklist (deny) vs whitelist (ignore) approach to writing AppArmor rules?

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Write an AppArmor profile that confines a specific program so it can read one of your files but is blocked from reading the other.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

Don't forget to \==action: save and submit any flags!==

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Confine a listening shell with AppArmor, so that anyone who connects to it can read one of your files through it but not the other.

When you are ready for the bot to run the attack, \==action: say 'ready'== to Hackerbot.

Don't forget to \==action: save and submit any flags!==
