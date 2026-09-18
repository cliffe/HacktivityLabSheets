---
title: "Authentication: Pluggable Authentication Modules (PAM) and Secure Shell (SSH)"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Configure Pluggable Authentication Modules (PAM) password and lockout policies and SSH key-based authentication, then defend your configuration against Hackerbot's live attacks."
overview: |
  In this lab, you will explore Pluggable Authentication Modules (PAM) and Secure Shell (SSH) to enhance your understanding of authentication and security in Linux and Unix-like systems. PAM is a component that allows for the flexibility and extensibility of authentication methods, making it possible for various programs to leverage different authentication schemes, providing a standardized way to configure and manage authentication rules.

  Throughout the lab, you will gain hands-on experience with PAM by examining available PAM modules, understanding the structure of PAM configuration files, and making modifications to enforce policies including: password complexity requirements, time constraints, lockout policies after repeated login failures, creating home directories, enforcing session limits through cron jobs. You will also explore SSH password-less authentication, a powerful method of securely accessing remote systems without the need for traditional passwords. By generating SSH key pairs and configuring authorized keys, you will learn how to enhance the security and convenience of remote access.

  By the end of this lab, you will have a solid grasp of PAM's role in authentication, the benefits of SSH key-based authentication, and the practical skills to enhance the security and usability of authentication mechanisms in Linux systems.

  This is a Hackerbot lab. Work through the lab sheet, then when prompted interact with Hackerbot.
tags: ["pam", "authentication", "ssh", "password-policy", "faillock", "passwdqc", "libpam-abl", "hackerbot"]
categories: ["systems_security"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AAA"
    topic: "Authentication"
    keywords: ["identity management", "user authentication", "facets of authentication"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["authentication and identification", "Linux authentication", "Authentication frameworks (PAM)"]
---

## Getting started {#getting-started}

### VMs in this lab {#vms-in-this-lab}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop (you can `sudo` to get superuser access)
- server (you can `ssh` to this machine, but you don't have superuser access)

You won't log in to the hackerbot_server, but it needs to be running to complete the lab.

### Your login details for the "desktop" and "server" VMs {#your-login-details}

\==VM: On the desktop and server VMs==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

### Note the IP address of the server VM {#note-the-ip-address-of-the-server-vm}

Later in this lab you will `ssh` into the server VM, so you need its IP address.

\==VM: On the server VM==, ==action: open a terminal and run:==

```bash
ip -4 -o a s
```

> Note: The `ip a s` command lists all local IP addresses, `-4` filters to only show IPv4, and `-o` sets one-line output mode. Note the address on the network interface (typically something like `ens19`) — this is your **server IP address**.

> Tip: Wherever this lab sheet says "the server IP address", ==edit: substitute the address you noted down==.

{% include hackerbot-intro.md role="task you with configuring PAM authentication policies on your desktop, and will then attack it to test your work" pidgin="hello" %}

## Pluggable Authentication Modules (PAM) {#pluggable-authentication-modules-pam}

In the past all Linux/Unix programs that required the user to enter a password for authentication (such as `su`, `sudo`, and `login`) would access and interpret `/etc/passwd` using its own code. However, it was hard to maintain all this code, since any change in the way the passwords were stored (such as using a shadow file, or using new hash functions) would mean all the software that provides authentication needed to be changed. The solution to the problem was PAM.

*Pluggable Authentication Modules (PAM)* enables applications that make use of authentication to be independent of the specific authentication schemes in use. For example, a program such as a login screen that uses PAM can be configured to authenticate using a password, smartcard, and/or biometrics, simply by changing PAM configuration files.

PAM is supported in most distributions of Linux, Mac OS X, FreeBSD, and many other Unix-like systems.

\==VM: On the desktop VM==, ==action: view which PAM modules are available:==

The `.so` files are typically in `/lib/x86_64-linux-gnu/security/` (or similar). ==action: list them:==

```bash
ls /lib/*/security/
```

As you can see, there are lots of different features and authentication schemes, and these can be used with *any* PAM compatible program. This includes not only typical authentication schemes, such as `pam_unix.so`, which does the usual password comparison with `/etc/passwd` and `/etc/shadow`, but also can impose time limits (`pam_time.so`) or simply display messages to the user (`pam_motd.so`).

It is possible to determine whether a specific program is compiled to use PAM, by checking what dynamic libraries it uses. (On Linux `.so` shared objects are similar to DLL files on Windows, they contain library code that programs can reuse). ==action: check what shared objects the passwd program uses:==

```bash
ldd `which passwd`
```

> Note: `which` identifies the absolute path to a program. `which passwd` typically resolves to `/usr/bin/passwd`, and so is equivalent to running `ldd /usr/bin/passwd`.

Note that the output will include a line starting with `libpam.so`, such as:

```
libpam.so.0 => /lib/x86_64-linux-gnu/libpam.so.0 (0x00007fe211554000)
```

This would indicate that the program loads code from `/lib/x86_64-linux-gnu/libpam.so.0`, and does indeed make use of PAM.

PAM configuration is located in `/etc/pam.d`. ==action: take a look at which programs currently have PAM configuration files:==

```bash
ls /etc/pam.d
```

Depending on what is installed on the system, there will be a few configuration files. Each file contains a PAM configuration for the program it is named after. If a PAM-aware program does not have a configuration file the `other` file is used.

==action: view the "other" file:==

```bash
less /etc/pam.d/other
```

> Tip: Press the "q" key to exit `less`.

On Debian the default behaviour is to use the common authentication behaviour defined in `common-auth`, account access rules defined in `common-account`, password rules in `common-password`, and `common-session` rules for sessions.

```bash
less /etc/pam.d/common-auth
```

The syntax of the configuration file is that each line typically starts with:

> *type control module-path module-arguments*

The *type* is `auth`, `password`, `account` or `session`. The control (such as `required` or `optional`) defines whether the module needs to pass or not before moving on to the next module, then the module name is defined. It is not shown in this example, but the module-path can be followed with some settings for the module.

All the modules for a type (such as `auth`) are called a module stack. When the program requests PAM perform authentication each of the `auth` modules in the module stack are run in the order they appear. If a "required" module fails, the authentication process tries the next module to see if it passes, if no required modules pass, then the authentication fails.

Possible control values include:

> **required**
>
> failure of such a PAM will ultimately lead to the PAM-API returning failure but only after the remaining stacked modules (for this service and type) have been invoked.
>
> **requisite**
>
> like required, however, in the case that such a module returns a failure, control is directly returned to the application.
>
> **sufficient**
>
> success of such a module is enough to satisfy the authentication requirements of the stack of modules (if a prior required module has failed the success of this one is ignored). A failure of this module is not deemed as fatal to satisfying the application that this type has succeeded. If the module succeeds the PAM framework returns success to the application immediately without trying any other modules.
>
> **optional**
>
> the success or failure of this module is only important if it is the only module in the stack associated with this service+type.
>
> **include**
>
> include all lines of given type from the configuration file specified as an argument to this control.
>
> -- from the man page for pam.conf

There is also a more complex rule syntax available, described in the man page.

==action: look at which authentication methods are used by `passwd`:==

```bash
less /etc/pam.d/passwd
```

> Note: This indicates that PAM will apply the password rules in `common-password` for the `passwd` program.

==action: edit the rules in `common-password`:==

```bash
sudo vi /etc/pam.d/common-password
```

> Tip: Vi is 'modal': it has an insert mode, where you can type text into the file, and normal mode, where what you type is interpreted as commands. Press the "i" key to enter "insert mode". Type your changes to the file, then exit back to "normal mode" by pressing the Esc key. Now to exit and save the file press the ":" key, followed by "wq" (write quit), and press Enter.

==action: edit the `pam_pwquality` line, so it reads:==

```
password requisite pam_pwquality.so minlen=7 dictcheck=0
```

==action: comment out the `passwdqc` line== (add a `#` at the start of the line), so it reads:

```
#password requisite pam_passwdqc.so
```

==action: create a test user account:==

```bash
sudo useradd -m -s /bin/bash testuser
```

==action: set the initial password for the test user:== (enter a simple password like `password123` when prompted)

```bash
sudo passwd testuser
```

> Note: This runs as root, setting the password for the testuser.

==action: confirm that normal users can no longer use a password that is less than 7 characters long.== Run this command as the testuser, and try a password that is less than 7 characters long:

```bash
sudo -u testuser passwd
```

> Note: This will run *as the testuser*, rather than root setting the password for the user.

==action: view the man page for this PAM module:==

```bash
man pam_pwquality
```

> Tip: There is a man page for each available PAM module. Type `man pam_` and press the TAB key twice to see a list of man pages available for PAM modules.

Based on the options described in the man page, ==action: configure the `pam_pwquality` module to require at least one non-alphanumeric character.==

==action: confirm that normal users can no longer use passwords that contain only alphanumeric characters.==

## Troubleshooting PAM configurations {#troubleshooting-pam-configurations}

Before we continue configuring PAM modules, it's important to understand how to safely test changes and monitor results. Making changes to PAM can potentially lock you out of your system, so we'll use these tools throughout the lab to verify our configurations.

> Warning: A mistake in a PAM configuration file can lock every user, including root, out of a service. Consider keeping a root terminal open when making PAM changes (`sudo -i`), so you can revert changes easily.

### Testing PAM changes safely {#testing-pam-changes-safely}

The `pamtester` utility allows us to test PAM configurations without risking system lockout. It simulates authentication attempts without actually creating sessions or modifying the system.

Basic syntax for testing:

```bash
pamtester service username authenticate
```

For example, ==action: test SSH authentication:==

```bash
# Test with correct password
echo "password123" | sudo pamtester sshd testuser authenticate

# Test with wrong password
echo "wrongpass" | sudo pamtester sshd testuser authenticate
```

### Monitoring PAM activity {#monitoring-pam-activity}

When making PAM changes, it's helpful to monitor the authentication logs to understand what's happening and troubleshoot issues.

==action: monitor authentication attempts in real-time:==

```bash
sudo tail -f /var/log/auth.log
```

> Tip: Press Ctrl+C to stop monitoring.

You can also use `journalctl` to monitor system logs, which includes PAM messages:

```bash
sudo journalctl -f
```

When testing configurations, you'll see various PAM messages. Here are common ones and what they mean:

```
pam_unix(sshd:auth): authentication failure  # Basic password auth failed
pam_faillock(sshd:auth): User locked due to # Account locked after failures
pam_time(sshd:account): User not allowed at this time  # Time restriction
pam_pwquality(passwd:chauthtok): BAD PASSWORD # Password doesn't meet requirements
```

> Tip: Test changes with `pamtester` before applying them system-wide, rebooting the system, or logging out and back in. Make one change at a time and verify it works before proceeding.

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Enforce a minimum password length on the desktop.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

## Password quality enhancement {#password-quality-enhancement}

Password quality control is crucial for system security. While longer passwords generally provide better security, the relationship isn't linear — a short password with high complexity can be more secure than a long but simple one. The `pam_passwdqc` module implements advanced password quality controls using a multi-tiered approach. It recognises that very long passwords can be secure even with lower complexity (due to increased entropy), while shorter passwords need stricter requirements to maintain security. The module also checks against dictionary words and common patterns, addressing a common weakness where users choose memorable but easily guessable passwords.

==action: configure advanced password quality control using passwdqc:==

```bash
sudo vi /etc/pam.d/common-password
```

==action: add or modify (uncomment and edit) this line:==

```
password requisite pam_passwdqc.so min=disabled,24,12,8,7
```

==action: comment out the `pam_pwquality` line== (add a `#` at the start of the line), so it reads:

```
#password requisite pam_pwquality.so minlen=7 dictcheck=0
```

This enforces:

- 24+ chars: no restrictions
- 12+ chars: must contain 3 character classes
- 8+ chars: must contain 3 character classes and can't be a dictionary word
- 7+ chars: must contain all 4 character classes

Character classes are:

- Uppercase letters (A-Z)
- Lowercase letters (a-z)
- Digits (0-9)
- Special characters (!@#$%^&* etc.)

==action: test the passwdqc password rules.== Try changing your password with each of these scenarios:

```bash
sudo -u testuser passwd
```

==action: test the 7-character rule:==

Should fail — only 7 chars but missing character classes: `New0nn3`

Should succeed — 7 chars with all classes (upper, lower, digits, special): `NewP4$sw`

==action: test the 8-character rule:==

Should fail — dictionary word with numbers: `Password123`

Should succeed — 8 chars, 3 classes, non-dictionary: `Nw5$tr8p`

==action: test the 12-character rule:==

Should fail — only 2 character classes: `HELLOWORLD123`

Should succeed — 12 chars with 3 classes: `HelloWorld123`

==action: test the 24-character rule:==

Should succeed — no restrictions at this length: `this-is-a-very-long-password-123`

==action: monitor the authentication logs== to see detailed rejection reasons:

```bash
sudo tail -f /var/log/auth.log
```

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Configure `pam_passwdqc` so that passwords within a specific length range must use a minimum number of character classes.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

## Limiting failed login attempts {#limiting-failed-login-attempts}

Failed login attempt limiting is a critical security control that protects against password-guessing attacks. When attackers attempt to breach a system through brute force or dictionary attacks, they typically need multiple attempts to guess the correct credentials. By implementing account lockouts after a specified number of failed attempts, we create a time-based penalty that makes such attacks impractical. This defense is particularly effective against:

- Automated password guessing tools
- Dictionary-based attacks
- Credential stuffing attacks
- Manual brute force attempts

The lockout mechanism provides a balance between security and usability:

- Short lockout periods (minutes) protect against automated attacks while minimising user inconvenience
- Longer lockouts (hours) provide stronger protection but may impact legitimate users
- Some organisations implement progressive lockouts, where the duration increases with repeated failures

In Debian Bookworm, we use `pam_faillock.so` to manage failed login attempts. This module is included by default and replaces the older `pam_tally2.so` module.

==action: let's configure account lockouts.== First, ==action: check if `faillock.conf` exists:==

```bash
sudo ls /etc/security/faillock.conf
```

==action: edit or create the configuration:==

```bash
sudo vi /etc/security/faillock.conf
```

Add these settings:

```
deny = 5
unlock_time = 600
```

This will lock accounts for 10 minutes (600 seconds) after 5 failed attempts.

==action: edit the PAM configuration:==

```bash
sudo vi /etc/pam.d/common-auth
```

PAM's power comes from its ability to stack multiple authentication modules. This allows for sophisticated authentication policies that combine different security controls. Understanding module stacking is crucial for implementing defense in depth, creating flexible authentication policies, handling edge cases and fallback authentication, and managing emergency access procedures.

==action: add these three lines (around the existing line):==

```
auth    required pam_faillock.so preauth audit

# THIS LINE WILL ALREADY BE PRESENT
auth    [success=1 default=ignore]  pam_unix.so nullok try_first_pass

auth    [default=die] pam_faillock.so authfail audit
auth    sufficient pam_faillock.so authsucc audit
```

> Note: This configuration sets up a secure account lockout system using `pam_faillock`. The `preauth` line checks if the account is already locked before even attempting authentication, preventing unnecessary password attempts on locked accounts. The existing line is standard Unix password authentication (`pam_unix.so`); if it succeeds, it skips to the `authsucc` line due to `success=1`. The `authfail` line records failed login attempts in faillock's database, running only if the password authentication failed. The `authsucc` line records successful logins and resets the failure counter. Together these create a complete account lockout system, applying to all PAM-aware services that include `common-auth`.

==action: test the lockout configuration.== ==action: monitor the auth log in one terminal:==

```bash
sudo tail -f /var/log/auth.log
```

==action: in another terminal, attempt failed logins:==

```bash
# Try to login with incorrect password multiple times
su - testuser
# Enter incorrect password repeatedly
```

==action: check the faillock status.== You can monitor lockouts and manage them using these commands:

```bash
# View current lockouts
sudo faillock

# Check specific user's status
sudo faillock --user testuser

# Reset a user's lockout
sudo faillock --user testuser --reset
```

Expected test results:

- First 4 failures: Login prompt should reappear
- 5th failure: Account should become locked
- Further attempts: Should be rejected immediately
- After 10 minutes: Login should be possible again with correct password

==action: verify the lockout is working.== Try logging in with the correct password immediately after lockout (should be denied despite correct password). Wait 10 minutes. Try logging in with correct password (should succeed).

==action: test faillock with pamtester:==

```bash
# Attempt multiple failed logins
for i in {1..6}; do
    echo "wrongpass" | sudo pamtester login testuser authenticate
done

# Check faillock status
sudo faillock --user testuser

# Try a correct password (should still fail when locked)
echo "correctpass" | sudo pamtester login testuser authenticate
```

> Note: The current configuration may not apply to SSH logins, without further configuration.

## Automated blacklist (libpam-abl) {#automated-blacklist-libpam-abl}

Automated blacklisting is a crucial defense against brute-force attacks. Rather than just limiting authentication attempts, this approach actively blocks potential threats by temporarily banning IP addresses that show suspicious behavior. The `libpam-abl` module implements a dynamic blacklist system that tracks failed login attempts both per-IP and per-username, providing protection against distributed attacks and credential stuffing. The temporary nature of the bans helps prevent permanent denial of service while still effectively deterring automated attacks. This approach is particularly effective against automated scanning tools and botnets that attempt to breach systems through repeated login attempts.

This module automatically blacklists IP addresses after repeated failed login attempts.

==action: configure the blacklist settings:==

```bash
sudo vi /etc/security/pam_abl.conf
```

Update the rules to block for 1 hour after 2 failed attempts:

```
db_home=/var/lib/abl
host_db=/var/lib/abl/hosts.db
host_purge=1d
host_rule=*:2/1h
user_db=/var/lib/abl/users.db
user_purge=1d
user_rule=*/sshd:2/1h
host_clear_cmd=[logger] [clear] [host] [%h]
host_block_cmd=[logger] [block] [host] [%h]
user_clear_cmd=[logger] [clear] [user] [%u]
user_block_cmd=[logger] [block] [user] [%u]
limits=1000-1200
host_whitelist=localhost
user_whitelist=
```

==action: add the module to SSH authentication:==

```bash
sudo vi /etc/pam.d/sshd
```

Add this line at the top of the auth section:

```
auth required pam_abl.so config=/etc/security/pam_abl.conf
```

==action: test the blacklisting== by making repeated failed SSH login attempts.

```bash
ssh nonexistent_user@localhost
```

> Note: The error message to the user attempting a login may simply state permission denied, but the logs will show that pam-abl is "Blocking access".

If you don't already have the logs visible in a terminal tab/window:

```bash
sudo tail -f /var/log/auth.log
```

==action: once done, clear all blocks:==

```bash
sudo rm /var/lib/abl/hosts.db /var/lib/abl/users.db
```

> Warning: If you are testing this over SSH from your own host, be careful not to lock yourself out — clear the blocks (above) once you're done.

## Time-based access control {#time-based-access-control}

Time-based access control is a security approach that implements temporal least privilege — users only have access when they legitimately need it. This approach significantly reduces the attack surface by limiting the windows of opportunity for unauthorised access. For example, if a system is only accessed during business hours, any login attempts outside these hours are likely malicious. This control is particularly effective against automated attacks and helps detect compromised credentials, as legitimate users typically follow predictable access patterns.

Key security benefits include:

- Reduced exposure window for brute force attacks
- Detection of anomalous access patterns
- Enforcement of work-hour policies
- Automated access management for temporary workers
- Compliance with security frameworks requiring time-based controls
- Protection against credential abuse in different time zones

Let's configure PAM to only allow the user "testuser" to login between 9am and 5pm, and only on a Tuesday.

==action: first, edit the PAM configuration:==

```bash
sudo vi /etc/pam.d/common-account
```

Add this line at the start of the account section:

```
account required pam_time.so
```

==action: configure the time restrictions:==

```bash
sudo vi /etc/security/time.conf
```

Add this line:

```
*;*;testuser;Tu0900-1700
```

The format is:

```
services;ttys;users;times
```

> Tip: For testing purposes, you can add a 10-minute window from the current time. For example, if it's currently 14:30: `*;*;testuser;Al1430-1440`.

==action: test the time-based restrictions:==

```bash
# Check current time
date

# Try to login as testuser
su - testuser

# Monitor authentication attempts
sudo tail -f /var/log/auth.log
```

Expected results: if current time is Tuesday 9am-5pm, login should succeed; if outside allowed time, login should be denied with a time restriction message.

==action: to automatically disconnect the user, set up a cron job:==

```bash
sudo crontab -e
```

Add these lines:

```
# Send warning 10 minutes before
50 16 * * tue wall "WARNING: testuser will be disconnected in 10 minutes"

# Disconnect at 5pm
00 17 * * tue pkill -u testuser
```

==action: test the automatic disconnection== by logging in as testuser during allowed hours, waiting for the warning message (if near 16:50), and observing the automatic disconnection at 17:00.

==action: monitor access attempts:==

```bash
# Watch authentication logs in real-time
sudo tail -f /var/log/auth.log

# Check current session status
w
who
```

==action: verify time restrictions are working== by trying to log in before the end time, watching for the warning message, confirming the session is terminated at the end time, and attempting to log in again after the end time (should be denied).

#### Hackerbot Attack #3 {#hackerbot-attack-3}

You can skip the bot to here, by saying **goto 3**.

> Hackerbot: Set up time-based access control restricting a specific user to a specific login window, on specific days, as a single rule.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

## Multi-factor authentication (MFA) {#multi-factor-authentication-mfa}

Multi-factor authentication (MFA) adds additional security layers beyond just passwords. It requires users to verify their identity using two or more different factors:

- Something you know (password, PIN)
- Something you have (security token, smartphone)
- Something you are (fingerprint, facial recognition)

By combining multiple factors, MFA significantly improves security. Even if an attacker obtains a user's password, they still can't gain access without the second factor. This is especially important for protecting sensitive systems and data. Common MFA methods include SMS codes, authenticator apps generating time-based codes (TOTP), hardware security keys, and biometrics.

==action: generate MFA configuration:==

```bash
google-authenticator
```

==action: scan the QR code== with your authenticator app on your smartphone.

==action: get google-authenticator working for `su` logins== with your PAM configuration, requiring the user to enter a TOTP code, in addition to their password.

> Hint: you need to add a line to the sshd PAM configuration.

> Warning: Don't forget to remove the rule before taking on the Hackerbot tasks.

> Question: What are the trade-offs between security and usability in these configurations? Consider password complexity vs memorability, lockout duration vs legitimate user access, and time-based restrictions vs flexibility.

> Question: Briefly describe what each of the following PAM configurations do:
> ```
> session optional pam_mkhomedir.so skel=/etc/skel umask=077
>
> auth required pam_access.so, /etc/security/access.conf
> ```

## Secure Shell (SSH) password-less authentication {#secure-shell-ssh-password-less-authentication}

Public-key cryptography (AKA asymmetric) uses a pair of keys: a *public key* which can be shared freely, and *private keys* which are kept secret in order for the security to be effective.

SSH can be configured to enable access without a password, granting access to whoever holds the private key.

==action: run:==

```bash
ssh-keygen
```

The keypair will be created in `~/.ssh/`.

==action: copy the contents of the public key== (ends in `.pub`) to `.ssh/authorized_keys` on the server.

You can now ==action: ssh to the server== without providing your password.

```bash
ssh <server IP address>
```

> Question: What access does someone with the private key get? How does a passphrase help?

## Conclusion {#conclusion}

In this lab, you've explored the powerful and flexible PAM authentication framework, implementing several critical security controls:

Password Quality:

- Configured minimum length and complexity requirements
- Implemented dictionary word checks
- Set up multi-tiered password requirements based on length

Account Protection:

- Implemented account lockouts after failed attempts
- Set up automated IP blacklisting
- Configured time-based access restrictions

Advanced Authentication:

- Explored multi-factor authentication using TOTP
- Implemented SSH key-based authentication

Well done!

## Resources {#resources}

[Chapter 4 "Users, Passwords, and Authentication": Garfinkel, S. Spafford, G. and Schwartz, A. (2003), Practical Unix and Internet Security, O'Reilly. (ISBN-10: 0596003234)](https://www-dawsonera-com.ezproxy.leedsbeckett.ac.uk/abstract/9781449310325)
