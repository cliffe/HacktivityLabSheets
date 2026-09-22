---
title: "Integrity Management: Detecting Change"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Learn to detect unauthorised changes to files and systems using backups, cryptographic hashing, file integrity checkers, and package verification, while responding to Hackerbot's live attacks."
overview: |
  Integrity management is a crucial aspect of information security, focusing on preventing and detecting unauthorised changes to resources, such as files and configurations, within a computer system. Maintaining the integrity of these resources is vital in ensuring the trustworthiness of a system, as any unauthorised changes can lead to security breaches and data corruption. This lab sheet explores the various techniques for detecting changes to system integrity, including the use of backups, file hashing, and package verification. It emphasises the importance of these methods in safeguarding the integrity of a system and provides hands-on exercises to demonstrate their practical application.

  In this lab, you will learn about different strategies for detecting unauthorised changes. You will create and compare backups of critical system files, generate and compare file hashes using tools like md5sum and sha1deep, and explore the concept of package verification to check the integrity of installed software packages. You will face challenges from Hackerbot, where you'll apply the learned techniques to detect and respond to various security threats, such as detecting new users, changes to config files, and replaced binary files with malware. This hands-on experience will equip you with the skills and knowledge needed to protect and maintain the integrity of a computer system, a fundamental component of effective information security.

  This is a Hackerbot lab. Hackerbot will attack your system live, and you must apply what you've learned to detect each attack and answer its questions before you can move on.
tags: ["integrity", "file-integrity-monitoring", "hashing", "md5sum", "sha1deep", "hashdeep", "debsums", "backups", "incident-response", "hackerbot"]
categories: ["response_and_investigation"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "F"
    topic: "Artifact Analysis"
    keywords: ["cryptographic hashing"]
  - ka: "SOIM"
    topic: "Monitor: Data Sources"
    keywords: ["MONITORING - FILE INTEGRITY CHECKERS"]
  - ka: "OSV"
    topic: "OS Hardening"
    keywords: ["code and data integrity checks"]
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

> Note: In bash you can type `~` as shorthand for your home directory. Commands below also use `~` in this way; substitute your own username where a full path is shown.

{% include hackerbot-intro.md role="attack your system" chat="full" %}

## Integrity {#integrity}

Security is often described in terms of confidentiality, integrity, and availability. Protecting the integrity of information involves preventing and detecting unauthorised changes. In many commercial organisations integrity of information is the highest priority security goal. Managing who is authorised to make changes to databases or files, and monitoring the integrity of resources for unauthorised changes is an important task in managing information security.

## Protecting integrity {#protecting-integrity}

Protecting the integrity of resources, such as the files on a system, involves successfully managing a variety of security mechanisms, such as authentication, access controls and file permissions, firewalls, and so on.

> Note: On Linux systems this can include managing passwords, packet filtering IPTables rules, standard Unix file permissions (rwx), Linux extended attributes (including ACLs for detailed authentication, labels for mandatory access control (MAC), and Linux Capabilities). Linux (like other Unix-like and Unix-based systems) has a long history of adding new security features as and when they are required.
>
> Note that many security controls such as those listed above are very important for protecting the integrity of files, but are beyond the scope of this lab. Here the focus is on techniques that are focussed on integrity rather than confidentiality or availability.

There are precautions that can be taken to reduce the chances of unauthorised changes.

## Detecting changes to resources {#detecting-changes-to-resources}

Although we can aim to protect integrity, eventually even the strongest defences can fail, and when they do we want to know about it! In order to respond to a security incident we need to detect that one has occurred. One way we do so is to detect changes to files on our system.

### Detecting changes to resources using backups {#detecting-changes-to-resources-using-backups}

One technique is to compare files to a backup known to represent the system or resources in a clean state. One advantage of this approach is that we detect that files have changed, and also see *exactly* how they differ.

Make a directory to store your backups. ==action: Run:==

```bash
mkdir ~/backups/
```

\==action: Make a backup copy of your /etc/passwd file:==

```bash
cp /etc/passwd ~/backups/
```

This file (/etc/passwd) is an important file on Unix systems, which lists the user accounts on the system. Although historically the hashes of passwords were once stored here, they are now typically stored in /etc/shadow. Changes to the /etc/passwd file are usually infrequent (such as when new user accounts are created) and changes should only be made for authorised purposes.

\==action: Add a new user== to your computer...

```bash
sudo useradd new-username
```

> Note: Where ==edit: new-username== is some new name.

To make things even more interesting, ==action: edit the /etc/passwd file== and move the new user account line somewhere other than right at the bottom, so that it is less obvious:

```bash
sudo vi /etc/passwd
```

> Warning: **Be careful, making the wrong changes to this file will stop your system from working!**

> Note: Move the cursor onto the line representing your new account (probably at the bottom).
>
> In vi type:
> `:m -`==edit: number==
>
> Where ==edit: number== is the number of lines to move up, for example: `:m -20` will move the currently selected line up 20 lines, 'hiding' the new user account amongst the others.
>
> Save your changes and exit vi by typing:
>
> `:wq`

Look at the changes in your accounts made on your computer, and try to spot the new user account:

```bash
less /etc/passwd
```

> Tip: Press q to exit.

It's not as easy as it sounds, especially if your system has lots of user accounts.

Since you have a backup of your passwd file, you can compare the backup with the current passwd file to determine it has been modified. One such tool for determining changes is diff. Diff is a standard Unix command.

\==action: Run:==

```bash
diff -q ~/backups/passwd /etc/passwd
```

Diff should report that the two files differ. Diff can also produce an easy to read description of exactly how the file has changed. This is a popular format used by programmers for sharing changes to source code:

```bash
diff -u ~/backups/passwd /etc/passwd
```

The diff program can compare entire mirrored directory structures to each other. For example, if you wanted to know exactly what changes have happened since a backup.

Make a backup of your personal_secrets. ==action: Run:==

```bash
cp -r ~/personal_secrets/ ~/backups/personal
```

> Note: The -r tells cp to copy directories and their contents recursively (including sub-directories)

\==action: Make a change to a file== in `~/personal_secrets/`

Then ==action: compare using diff:==

```bash
diff -r -u ~/personal_secrets/ ~/backups/personal/
```

> Note: -r instructs diff to do a recursive comparison (searching through sub-directories). You can add `--suppress-common-lines` to reduce the amount of output.

There are many advantages to the comparison of backups approach to detecting changes, but it also has its limitations. To apply this approach to an entire system, you will need a large amount of either local or network shared storage, and writes need to be controlled to protect the backups, yet written to whenever authorised changes are made to keep the backup up-to-date. Also, when the comparisons are made **substantial disk/network access is involved**, since both sources need to be read at the same time in order to do the comparison.

In the example above, the backup was stored on the same computer. Did you think as an attacker of editing the backup passwd file? This is related to a major issue when checking for changes to the system: if your system has been compromised, then you can't necessarily trust any of the local software or files, since they may have been replaced or modified by an attacker. For that reason, it can be safer to run software (such as diff) from a separate read-only storage. Yet that still may not be enough, the entire operating system could be infected by a rootkit.

> Note: Filesystems, such as btrfs, that support history and snapshots can also be helpful for investigating breaches in integrity.

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: An attempt to add a new user is coming, let it happen. But first create a backup of /etc/passwd to `~/backups/passwd`.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Once Hackerbot has run the attack, it will ask you a question. Work out the answer using a backup comparison, then ==action: say "answer YOURANSWER"==, replacing *YOURANSWER* with the username that was created.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: An attempt to edit a config file is coming, let it happen. But first make sure you have a backup of the /etc/ directory at `~/backups/etc/`.

Before saying ready, ==action: back up the whole /etc/ directory:==

```bash
cp -r /etc/ ~/backups/etc/
```

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will insert a flag into a random file somewhere in /etc/. Find the flag by comparing against your backup, then ==action: say "answer YOURANSWER"==, replacing *YOURANSWER* with the file the flag was found in.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #3 {#hackerbot-attack-3}

You can skip the bot to here, by saying **goto 3**.

> Hackerbot: An attempt to edit a config file is coming, let it happen. But first make sure you have a backup of the /etc/ directory at `~/backups/etc/`.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Warning: This time Hackerbot will insert a flag into a random file **inside your own backups**. Did you really think that was a safe place to store them? Find the flag, then ==action: say "answer YOURANSWER"==, replacing *YOURANSWER* with the file the flag was found in.

Don't forget to ==action: save and submit any flags!==

## Detecting changes to resources using hashes and file integrity checkers {#detecting-changes-to-resources-using-hashes-and-file-integrity-checkers}

Another technique for detecting modifications to files is to use hashes of files in their known good state. Rather than storing and comparing complete copies, a one way hash function can be used to produce a fixed length hash (or 'digest'), which can be used for later comparisons.

Hashes have security properties that enable this use:

- Each hash is unique to the input
- It is extremely difficult (practically impossible) to find another input that produces the same hash output
- Any change to the input (no matter how minor) changes the output hash dramatically

We can store a hash and later recompute the hash, to determine whether the file has changed (if the hash is different), or it is exactly the same (if the hash is the same). If you have studied digital forensics, many of these concepts will be familiar to you, since hashes are also commonly used for verifying the integrity of digital evidence.

\==action: Generate an MD5 hash== of your backup password file, which you copied previously:

```bash
md5sum ~/backups/passwd
```

Now ==action: calculate a hash== of your current passwd file:

```bash
md5sum /etc/passwd
```

If the generated hashes are different, you know the files do not have **exactly the same content**.

Note that using hashes, there is no need to have the backup on-hand in order to check the integrity of files, you can just compare a newly generated hash to a previous one.

\==action: Repeat the above two commands using shasum== rather than md5sum.

SHA1, SHA2, and SHA3 are considered to be more secure than the 'cryptographically broken' MD5 algorithm. Although MD5 is still in use today, it is safer to use a stronger hash algorithm, since MD5 is not collision-resistant, meaning it is possible to find multiple files that result in the same hash. SHA1 is considered partially broken, so a new algorithm such as SHA2, or the newest SHA3 are currently good options. There are a number of related commands for generating hashes, named md5sum, shasum, sha224sum, sha256sum, and so on. These commands (as well as those in the next section) are readily available on most Unix systems, and are also available for Windows.

### File integrity checkers {#file-integrity-checkers}

A file integrity checker is a program that compares files to previously generated hashes. A number of these kinds of tools exist, and these can be considered a form of host-based intrusion detection system (HIDS), particularly if the checking happens automatically. One of the most well known integrity checkers is Tripwire, which was previously released open source; although, new versions are closed source and maintained by Tripwire, Inc, with a more holistic enterprise ICT change management focus. There are other tools similar to Tripwire, such as AIDE (Advanced Intrusion Detection Environment), and OSSEC (Open Source Host-based Intrusion Detection System).

The above md5sum, shasum (and so on) programs can also be used to check a list of file hashes.

You have some pre-seeded files under `~/trade_secrets/`, `~/personal_secrets/`, and `~/logs/`. ==action: List them:==

```bash
find ~/trade_secrets ~/personal_secrets ~/logs -type f
```

\==action: Pick one of these files== to use for the exercise below, and substitute its path wherever you see ==edit: your chosen file==.

\==action: Run the following== to generate a file containing hashes of files we can later check against:

```bash
mkdir ~/hashes/

shasum ==edit: your chosen file== >> ~/hashes/hash.sha
shasum /etc/passwd >> ~/hashes/hash.sha
sudo shasum /etc/shadow >> ~/hashes/hash.sha
shasum /bin/bash >> ~/hashes/hash.sha
shasum /bin/ls >> ~/hashes/hash.sha
```

\==action: Look at the contents== of our new hashes file:

```bash
less ~/hashes/hash.sha
```

> Tip: Press q to quit when done.

Now use your new hash list to ==action: check that nothing has changed== since we generated the hashes:

```bash
shasum -c ~/hashes/hash.sha
```

> Question: Log Book question: Why does shasum fail to check the integrity of the shadow file?

\==action: Make a change== to the end of your chosen file:

```bash
echo "hello" >> ==edit: your chosen file==
```

Check whether anything has changed since we generated hashes:

```bash
shasum -c ~/hashes/hash.sha
```

You should see a nice explanation of the files that have changed since generating the hashes.

### Scripted integrity checking {#scripted-integrity-checking}

The above can also be accomplished via a simple script (in this case a Ruby script):

```ruby
#!/usr/bin/ruby
# Copyleft Z. Cliffe Schreuders
# Licenced under the terms of the GPLv3

require 'digest'

hashes = {
  "/bin/ls" => "075e188324c2f4e54359128371a01e4d5e3b7be08382e4433bd53523f8bf6217",
  "/etc/passwd" => "8a9d9fa67078d83274fae27e4ffd3d100db51501dfdef42dde7b190c91a899ef",
  "/bin/bash" => "059fce560704769f9ee72e095e85c77cbcd528dc21cc51d9255cfe46856b5f02"
}

hashes.each { |filepath,hash|
  calculated_hash = Digest::SHA256.hexdigest File.read filepath
  puts "#{filepath}: #{calculated_hash}"
  if calculated_hash == hash
    puts "OK: file unmodified"
  else
    puts "FILE CHANGED: expected #{hash}"
  end
}
```

This script iterates over a list of file paths with SHA256 hashes (stored in an associative array), and calculates the hash for each one to check whether the files are still the same.

\==action: Save the script as checker.rb==

> Tip: you may wish to use the default KDE GUI text editor Kate. You should be able to copy the script and paste it into Kate to save it as checker.rb.
>
> Alternatively you can type `cat > checker.rb`, paste with Ctrl-Shift-V, then Ctrl-D to end the input.

Then ==action: run the script== with:

```bash
ruby checker.rb
```

> Question: Log Book question: Are the files reported as unmodified, or have they changed? Why might they be different to when I wrote the script?

#### Hackerbot Attack #4 {#hackerbot-attack-4}

You can skip the bot to here, by saying **goto 4**.

> Hackerbot: Creating a new file in your home directory... Let it happen.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will ask you for the SHA1 hash of the file it creates. Work it out, then ==action: say "answer YOURANSWER"==, replacing *YOURANSWER* with the hash.

Don't forget to ==action: save and submit any flags!==

### Recursive file integrity checkers {#recursive-file-integrity-checkers}

The md5deep program (also known as sha1deep, sha256deep, and so on for different hash algorithms) can recursively walk through directories (and into all contained subdirectories) to generate and check lists of hashes.

\==action: Run:==

```bash
sudo sha1deep -r /etc/
```

> Tip: You can stop the program early by pressing Ctrl-C.

The output of the above command will include hashes of every file in /etc/, which is where system-wide configuration files are stored on Unix.

Read the sha1deep manual to understand the above command:

```bash
man sha1deep
```

\==action: Figure out what the -r flag does.==

> Tip: Press q to quit.

We can save (redirect) this output to a file so that we have a record of the current state of our system's configuration:

```bash
sudo sha1deep -r /etc > ~/hashes/etc_hashes
```

This may take a minute or so, while the program calculates all the hashes and sends them to standard out (known as stdout), which is then redirected to the etc_hashes file.

Next, let's compare the size of our list of hashes, with the actual content that we have hashed...

See how big our list of hashes is:

```bash
ls -hs ~/hashes/etc_hashes
```

> Note: -h = human readable, -s = size.

This is likely to be in the Kilobytes.

And for the size of all of the files in /etc/:

```bash
sudo du -hs /etc/
```

> Note: -h = human readable, -s summarise.

This is likely in the Megabytes (or maybe even Gigabytes).

Clearly, **the list of hashes is much smaller**.

Create a new file somewhere in /etc/, containing your name. Name the file whatever you like (for example /etc/test).

> Hint: `sudo vi /etc/test`, `i` to enter insert mode, and after typing your name, `Esc`, `:wq`.

Also, ==action: change an existing file in /etc/==, but do be careful to only make a minor change that will **not cause damage to your system**. For example, you could use vi to edit /etc/wgetrc (`sudo vi /etc/wgetrc`), and add a comment to the file such as `#find this comment!`

Let's try to identify what has changed on our system...

Now that we have a list of hashes of our files, ==action: use shasum to check if anything has changed using our newly generated list of hashes== (`~/hashes/etc_hashes`).

> Hint: look at the previous command using shasum to check hashes.

Does this detect the changed file AND the new file? Why not?

Md5deep/sha1deep takes a different approach to checking integrity, by checking all of the files it is told to check (possibly recursing over all files in a directory) against a list of hashes, and reporting whether any files it checked did not (or did, depending on the flags used) have its hash somewhere in the hash list.

Run sha1deep to check whether any files in /etc/ do not match a hash previously generated:

```bash
sudo sha1deep -X ~/hashes/etc_hashes -r /etc
```

This should detect both modified files, both new and modified.

But would sha1deep detect a copy of an existing file, to a new location?

Try it:

```bash
sudo cp /etc/passwd /etc/passwd.backup
```

Now rerun the previous sha1deep command. Was the copy detected? Why not?

What about copying one file over another? Which out of shasum or sha1deep would detect that?

Another tool, hashdeep, which is included with md5deep, provides more coverage when it comes to detecting files that have moved, changed, or created.

Generate a hash list for /etc using hashdeep:

```bash
sudo hashdeep -r /etc/ > ~/hashes/etc_hashdeep_hashes
```

Hashdeep stores hashes in a different format than the previous tools. Have a look:

```bash
less ~/hashes/etc_hashdeep_hashes
```

> Tip: Press q to quit. Note that the output includes some more information, such as the file size for each file.

Delete the new file that you created earlier:

```bash
sudo rm /etc/==edit: whatever-the-filename-was==
```

Conduct a hashdeep audit to detect any changes:

```bash
sudo hashdeep -r -a -k ~/hashes/etc_hashdeep_hashes /etc
```

> Note: This can take a while, so feel free to start working through the next section in another terminal, if you like.

After, run it again, this time asking for more details, since the default message does not provide any information as to why an audit has failed:

```bash
sudo hashdeep -ravv /etc/ -k ~/hashes/etc_hashdeep_hashes
```

Consult the man page for information about what each of the above flags do.

#### Hackerbot Attack #5 {#hackerbot-attack-5}

You can skip the bot to here, by saying **goto 5**.

> Hackerbot: Going to edit one of your files in /etc/. First, create hashes of /etc/. You will use hash comparisons to detect which file changes.

Before saying ready, ==action: generate a hash list of /etc/== using sha1deep or hashdeep, as covered above.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will ask which file changed. Work it out using hash comparisons, then ==action: say "answer YOURANSWER"==, replacing *YOURANSWER* with the full path of the changed file.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #6 {#hackerbot-attack-6}

You can skip the bot to here, by saying **goto 6**.

> Hackerbot: Going to create a new file in /etc/, use hash comparisons to detect which new file changes.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will ask which file was created. Work it out using hash comparisons, then ==action: say "answer YOURANSWER"==, replacing *YOURANSWER* with the full path of the new file.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #7 {#hackerbot-attack-7}

You can skip the bot to here, by saying **goto 7**.

> Hackerbot: Going to copy a new random binary in /bin/ or /usr/bin/, use hash comparisons to find the filename of the copied file.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will ask for the filename of the copy. Work it out using hash comparisons, then ==action: say "answer YOURANSWER"==, replacing *YOURANSWER* with the full path.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #8 {#hackerbot-attack-8}

You can skip the bot to here, by saying **goto 8**.

> Hackerbot: Going to move random binaries in /bin/ or /usr/bin/, use hash comparisons to find the filenames.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will ask for the two files involved. Work them out using hash comparisons, then ==action: say "answer YOURANSWER"==, replacing *YOURANSWER* with the two full paths separated by a space.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #9 {#hackerbot-attack-9}

You can skip the bot to here, by saying **goto 9**.

> Hackerbot: Going to copy a new random file in /etc/, use hash comparisons to find the filename.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will ask for the filename of the copy. Work it out using hash comparisons, then ==action: say "answer YOURANSWER"==, replacing *YOURANSWER* with the full path.

Don't forget to ==action: save and submit any flags!==

### Detecting changes to resources using package management {#detecting-changes-to-resources-using-package-management}

On Linux systems, package management systems are used to organise, install, and update software. The package management system has a database that keeps track of all the files for each program or software package. Depending on the package management system used, the database may maintain hashes in order to detect changes to files since install. DEB-based systems (such as Debian, and Ubuntu) and RPM-based systems (such as Red Hat, Fedora, and OpenSUSE), typically store hashes of each file that is included in software packages. There are commands that can be used to detect changes to files that have occurred since being installed by the package management software.

Note that there are times where it is perfectly normal for a number of files to not match the 'fresh' versions that were installed: for example, configuring a system for use will involve editing configuration files that were distributed with software packages.

\==action: View the files containing MD5 hashes== stored for the packages on the system:

```bash
ls /var/lib/dpkg/info/*.md5sums
```

\==action: View the contents== of one of the files.

debsums is a program that can use those MD5 hashes to verify that files on a DEB-based system match the corresponding packages that are installed. By default it doesn't check configuration files (such as in /etc/).

\==action: Verify all files installed by all packages:==

```bash
sudo debsums -ac
```

> Tip: Ctrl-C to end the program early. Options for debsums include: `-a` also check config files, `-e` *only* check config files, `-c` only report *changed* files.

Verify the files installed by a specific package:

```bash
sudo debsums firefox-esr
```

Choose any system file on the computer, such as /etc/securetty. To determine which package the file belongs to:

```bash
dpkg-query -S ==edit: any-file-you-chose==
```

> Note: Where ==edit: any-file-you-chose== is any file such as /etc/securetty.

The output of that command contains the package-name, and is required in the next step.

Check the integrity of the file:

```bash
sudo debsums -a ==edit: package-name==
```

> Note: Where ==edit: package-name== is the output from the previous command.

Try to understand the cause of any files failing the integrity checks.

> Question: Log Book question: What are the limitations of this approach? What files will (and won't) this approach to integrity management cover? Are the hashes protected against tampering?

#### Hackerbot Attack #10 {#hackerbot-attack-10}

You can skip the bot to here, by saying **goto 10**.

> Hackerbot: Going to replace a binary file in /bin/ or /usr/bin/ with malware. Use PACKAGE VERIFICATION to detect which file has changed.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will ask which file was replaced. Work it out using package verification (debsums), then ==action: say "answer YOURANSWER"==, replacing *YOURANSWER* with the full path.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #11 {#hackerbot-attack-11}

You can skip the bot to here, by saying **goto 11**.

> Hackerbot: Going to replace a binary file in /bin/ or /usr/bin/ with malware. Use your method of choice to detect which file has changed.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Hackerbot will ask which file was replaced. Use any technique from this lab sheet to work it out, then ==action: say "answer YOURANSWER"==, replacing *YOURANSWER* with the full path.

Don't forget to ==action: save and submit any flags!==

## Limitations of integrity checking {#limitations-of-integrity-checking}

Perhaps the greatest limitation to all of these approaches, is that if a system is compromised, you may not be able to trust any of the tools on the system, or even the operating system itself to behave as expected. In the case of a security compromise, your configuration files may have been altered, including any hashes you have stored locally, and tools may have been replaced by Trojan horses. For this reason it is safer to run tools over the network or from a removable drive, with read-only access to protect your backups and hashes. Even then, the OS/kernel/shell may not be telling you the truth about what is happening, since a rootkit could be concealing the truth from other programs.

## Resources {#resources}

An excellent resource on the subject of integrity management is Chapter 20 of the excellent book *Practical Unix & Internet Security, 3rd Ed*, by Garfinkel et al (2003).

Bind mounting: [http://lwn.net/Articles/281157/](http://lwn.net/Articles/281157/)

