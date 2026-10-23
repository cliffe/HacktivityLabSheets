---
title: "The Mole: VM Technical Steps"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Technical companion to The Mole walkthrough, for the lab network: step-by-step hints for the repository server, the mole's credentials, the login to svc-planning, and the escalation to root, plus command-line practice."
tags: ["gitlist", "cve-2018-1000533", "argument-injection", "git-history", "ssh", "sudo", "privilege-escalation", "break-escape"]
categories: ["safetynet"]
redirect_from:
  - /labs/introducing_attacks/m08-the-mole-vm-technical-steps/
type: ["game-based-learning", "lab-sheet"]
difficulty: "intermediate"
source: "https://github.com/cliffe/BreakEscape/blob/main/scenarios/m08_the_mole/"
cybok:
  - ka: "NS"
    topic: "Networking Applications"
    keywords: ["Secure shell (SSH)", "Port scanning"]
  - ka: "WAM"
    topic: "Server-Side Vulnerabilities and Mitigations"
    keywords: ["Injection vulnerabilities", "Server-side misconfiguration and vulnerable components"]
  - ka: "SS"
    topic: "Categories of Vulnerabilities"
    keywords: ["CVEs and CWEs", "Hard-coded password"]
  - ka: "SOIM"
    topic: "Fundamental Concepts"
    keywords: ["Penetration testing software tools", "Vulnerability analysis"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["Privilege escalation"]
  - ka: "AAA"
    topic: "Authentication"
    keywords: ["User authentication"]
---

> Note: This is the technical companion to the [The Mole walkthrough](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/m08-the-mole/). Play the game there first, and come here for the repository server hints.

## The Training Network {#network}

The Server Room has a **GitList Repository Server** terminal. It opens a Kali attack box on the lab network. From that box you reach SAFETYNET's internal repository server, the other host on the network. The repository server holds four flags, and you submit each one at the **Evidence Relay Terminal** in the same room. The main walkthrough covers the game around this work. This sheet covers the work on the repository server.

The four flags all come off one host, and they all belong to one account. The exposed repository names the account, the mole left its password on the box, that account owns the home directory you log in to, and the same account's name is in the root-only access logs. The account is **svc-planning**. Keeping that in mind stops the four stages feeling like four separate puzzles: they are one person's trail.

1. **Exposure flag.** Get at SAFETYNET's own repository browser, with no login, and read what it exposes.
2. **Credentials flag.** Recover the mole's password, left on the box.
3. **Account flag.** Log in as **svc-planning** with that password, and read its home directory.
4. **Root flag.** Escalate to root through a sudo rule, then read the logs the server keeps for its users.

The flag values are generated for each game, so this sheet never gives one. It says where each flag sits and how to reach it.

## Concepts {#concepts}

You do not need to read all of this before you start. Come back to it when a stage leaves you unsure what a tool or a result is telling you.

### Secure Shell and the Linux Shell {#ssh}

**SSH** (Secure Shell) gives you a command line on another machine over an encrypted connection. You give it an account name, a host and a password, or a key. The server checks the credentials against the account. If they match, you get a shell that runs as that account, and everything you type can read and write only what that account may.

A Linux shell works on a set of directories and files. Each file has an owner and permissions. Your **home directory** is the part of the disk the account owns. Files outside it, such as another account's home or the system logs, usually belong to someone else, and the permissions decide whether you may read them.

Worked example, on a practice machine of your own:

```
$ ssh alice@192.0.2.10
alice@host:~$ ls
notes.txt
alice@host:~$ cat /var/log/auth.log
cat: /var/log/auth.log: Permission denied
```

### Exposed Repositories and Where Secrets Hide {#repos}

A source-code server such as GitList lets you browse a project's files and its commit history in a web page. If it is open with no login, anyone who can reach it reads the code, the configuration and every commit message. A commit message such as "temp creds for the planning sync job, will rotate" tells you a credential exists, which account it belongs to, and that nobody rotated it.

The history names the account. The password is a separate problem. A developer who was careless once is often careless twice: the secret the commit message hints at can be sitting in a file on the server's disk, outside the web root and outside any repository, where only someone who can run code on the box will find it. So you read the repository for the lead, then you read the filesystem for the secret.

Worked example, reading a repository's log on a box you have a shell on:

```
$ git log --oneline
4f2a9c1 Tidy the config
b71e02d Add planning sync job settings
$ git show b71e02d
```

The second commit's message says what the change was for. Read it for the account name, then go looking for where the password itself ended up.

### Argument Injection {#argument-injection}

A web application often passes what a visitor types into a command that runs on the server. If that input is joined into the command without checks, the visitor can add options or extra commands. This is **argument injection**, a form of injection flaw. It can give you the ability to run commands on the server with no login at all.

Software versions that contain a flaw like this often have a published **CVE** (Common Vulnerabilities and Exposures) entry. The entry names the affected versions and describes the input that is not checked. You compare the version the service reports against that entry before you try anything.

### Sudo and Privilege Escalation {#sudo}

**Privilege escalation** means moving from a low-rights account to a higher one, usually root. **sudo** lets an account run a command as another user, if the sudo rules allow it. Only root may edit those rules. Running `sudo -l` lists what your account may run.

A rule that lets an account run a tool which can start a shell, or run other programs, is a misconfiguration. The tool may have been meant for something harmless, such as keeping packages up to date, and the rule still hands out a root shell.

Worked example, with made-up output:

```
$ sudo -l
User svc-planning may run the following commands:
    (root) /usr/bin/apt-get
```

## Stuck? Hints, Stage by Stage {#hints}

Find the stage you are on. Read the hint, then go back and try. If you are still stuck, open **Nudge**. Open **Recipe** last. The Recipe names the tools and the steps, never a flag value.

> Tip: Before you open any hint, ask three things. What version is this? What does the service say when you connect? What can this account do?

### Getting Onto the Attack Box {#hints-vm-attack-box}

**Where:** the GitList Repository Server terminal, in the Server Room. **Goal:** a working terminal on the attack box, and the address of the repository server.

> Hint: The terminal opens the attack box, not the repository server. Before you aim anything, find your own address and the lab's subnet.

<details markdown="1">
<summary>Nudge</summary>

The attack box and the repository server share a subnet. The attack box's own address tells you where to look for the other host. The number after the slash in the address says how many addresses the subnet holds.

**Learn it:** ==action: Work out the subnet by hand== from an address and a prefix length. A `/24` keeps the first three numbers fixed and lets the last number vary, so it covers 256 addresses.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Run `ip -4 addr` in the attack box's terminal==.
2. \==action: Note your address and the prefix length on the interface that holds the lab address==.
3. \==action: Find the other live host with `nmap -sn <subnet>`==, using the subnet from step 2. The host that is not your own box is the repository server.

</details>

### Stage 1: The Exposure Flag {#hints-vm-exposure}

**Where:** the attack box's terminal and browser, against the repository server. **Goal:** reach SAFETYNET's own repository browser with no login, read what it exposes, and submit the flag that comes with it.

> Hint: The web service names a piece of software and a version. One flaw in that version lets you run commands with no login, and the repository it serves is open to read anyway. Both routes reach the same exposed configuration.

<details markdown="1">
<summary>Nudge</summary>

Fingerprint the web service and note the software name and version. Look up that name and version in the CVE database, and read the affected versions and the input the description names. The repository browser is open: you can read the committed files and commit messages straight from the web page. The exposed configuration names the service account, **svc-planning**, and carries the flag. It also carries a commit message about "temp creds for the planning sync job" that were never rotated. Hold on to both: the account name is for Stage 3, and the "never rotated" note points at Stage 2.

**Learn it:** ==action: Write down the version and the CVE number before you run anything==, then check any proof of concept against the CVE description.

**To learn more in game:** ask the phone for the Scanning and Exploitation field guide.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Fetch the front page and read the headers and the page source: `curl -i http://<repository server>/`==, and open the GitList browser in the attack box's browser.
2. \==action: Search the CVE database for the software name and version, and read the entry's affected versions and its description==.
3. \==action: Browse the exposed repository, or run a proof of concept for the CVE from the attack box, and read the exposed configuration==. Note the account name **svc-planning** and the commit message about credentials that were never rotated.
4. \==action: Copy the flag from what you read and submit it at the Evidence Relay Terminal==.

</details>

> Warning: A proof of concept written for another version may fail, or do something you did not expect. Check its version notes against the version you found in step 1.

### Stage 2: The Credentials Flag {#hints-vm-credentials}

**Where:** the repository server, through the foothold you got in Stage 1. **Goal:** recover the mole's password, and submit the flag that comes with it.

> Hint: The commit message promised the credentials would be rotated, and named the account. The password itself is not printed in the repository. It was left in a file on the box, outside the web root, where only someone who can run code on the server will reach it.

<details markdown="1">
<summary>Nudge</summary>

Stage 1 gave you the ability to run commands on the server as the web account. Use it to read the filesystem, not just the web pages. The git service account's home directory holds more than repositories: the mole left a file there with the login details, the word **Password** beside the value and the flag. List that home directory, then read the file that is not part of a repository.

The in-game **Secrets in Git History** field guide explains why a careless developer's secrets end up where they do, and it is worth reading. On this box the password was not scrubbed out of a commit, so the history gives you the account and the "never rotated" lead, and the password sits in a file you read with your foothold.

**Learn it:** ==action: List a directory with `ls -la` before you open anything in it==, so you see every file, including the ones a plain `ls` hides, and can tell a repository folder from a loose file.

**To learn more in game:** ask the phone for the Secrets in Git History field guide.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: From your Stage 1 foothold, get a shell or run commands on the server as the web account==.
2. \==action: List the git service account's home directory: `ls -la /home/git`==.
3. \==action: Read the loose file there (the one that is not a `.git` repository) with `cat`==, and find the word `Password`, the value beside it, and the flag.
4. \==action: Copy the flag and submit it at the Evidence Relay Terminal==.

</details>

> Warning: The login account **svc-planning** cannot read this file: it belongs to the web account and its permissions keep others out. If `cat` says "Permission denied", you are reading it as the wrong account. Read it from the foothold you got in Stage 1, before you log in.

> Tip: A natural stopping point for a 60-minute class is after this stage. The next two stages use the account and password you now have.

### Stage 3: The Account Flag {#hints-vm-login}

**Where:** the attack box's terminal, logging in to the repository server. **Goal:** log in as **svc-planning** with the recovered password, read its home directory, and submit the flag.

> Hint: A password only works on the account it was made for. You have the account name from Stage 1 and the password from Stage 2. Log in, then look at what is in the home directory.

<details markdown="1">
<summary>Nudge</summary>

SSH takes the account name before the host. Once you are in, the home directory belongs to svc-planning. List everything in it, including hidden files, before you open any file. One file holds the mole's correspondence with ENTROPY, sent under the alias **deep_state_drop** to an address at `entropy.onion`, and the flag sits with it. That mail is the same account you will see named in the root logs in Stage 4, which is the point of logging in properly.

**Learn it:** ==action: List the home directory with `ls -la` before you open any file in it==. Names that start with a dot are hidden from a plain `ls`.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Log in with `ssh svc-planning@<repository server>`, and enter the password from Stage 2==.
2. \==action: List the home directory: `ls -la`==.
3. \==action: Open the files one at a time with `cat`==, and read the ENTROPY correspondence. The flag is with it.
4. \==action: Submit the flag at the Evidence Relay Terminal==.

</details>

> Warning: If the password is rejected, check the account name first. A correct password on the wrong account fails in the same way as a wrong password. Copy the password rather than retyping it.

### Stage 4: The Root Flag {#hints-vm-root}

**Where:** the attack box's terminal, from the svc-planning shell you got in Stage 3. **Goal:** find out what svc-planning may run as root, use it to get a root shell, read the logs and the cached files that only root can open, and submit the flag.

> Hint: Ask what the account may do with sudo before you look for anything else. A rule that lets an account run a tool as root is a rule the account can abuse, if the tool can run other programs.

<details markdown="1">
<summary>Nudge</summary>

Run `sudo -l` as svc-planning. It lists one tool the account may run as root: a package manager. A package manager can run other programs, so it can be turned into a root shell. The Privilege Escalation field guide has a section on escaping an allowed command to a shell. Once you have root, the access logs and The Architect's cached authorisation sit where only root can read them. The log puts svc-planning at a Cryptography Lab terminal opening the Portland planning file, `pnw_contingency.enc`, and the flag is in the same place.

**Learn it:** ==action: Before you run a command as root, write down what it will do and what it could change==.

**To learn more in game:** ask the phone for the Privilege Escalation field guide.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Run `sudo -l` as svc-planning==. Note the tool you may run as root (a package manager such as `apt-get`), and whether it asks for a password.
2. \==action: Open the Privilege Escalation guide at the section "Method 4: Escaping an Allowed Command to a Shell (GTFOBins)", and find the entry for that tool==.
3. \==action: Follow that entry to a root shell, then confirm with `id`==.
4. \==action: Read the root-only access logs and The Architect's cached authorisation. Find the flag, and submit it at the Evidence Relay Terminal==.

</details>

> Warning: You are root on a shared server. Read the logs, but do not change, delete or move them.

### Submitting the Four Flags {#hints-vm-submit}

> Tip: Submit each flag as soon as you find it. The Evidence Relay Terminal takes flags from the repository server.

Copy each flag exactly as it appears in the output.

## Try It on the Command Line (Optional) {#command-line}

These exercises use a repository and an account of your own. Do not run them on the lab server.

### A secret you commit and then remove {#cli-git-history}

Make a practice repository, commit a made-up secret, delete it, then search the history for it. This is the careless-developer habit the mission plays on, even though this particular box left its password in a loose file rather than a commit.

```
$ mkdir practice-repo && cd practice-repo && git init
$ echo "api_token=example-not-real" > config.txt
$ git add config.txt && git commit -m "Add config"
$ rm config.txt && git add -A && git commit -m "Remove config"
$ git log -p | grep -i token
```

> Note: The token is made up. The exercise is to see that the removal did not remove the value from the history.

\==action: Run the search, and note which commit the match came from==. Then \==action: run `git show` on that commit== and find the line you removed.

### Reading your own sudo rules {#cli-sudo}

On your own Kali box, run `sudo -l` and read the output line by line.

\==action: For each command the output lists, write one sentence saying what that command can do when it runs as root==. Ask whether the command can run another program or start a shell. This exercise is reading only. Do not try to escape a command on the lab server.

## What the Tools and Locks Are Telling You {#symptoms}

| What you see | What it usually means |
|---|---|
| The GitList page loads with no login prompt | The repository browser is open to anyone. Read the files and commit messages straight from it. |
| `git log` shows the account but no password | The password was never committed here. It is a loose file on the box; read the filesystem with your foothold. |
| `cat /home/git/<file>` says "Permission denied" | You are reading as the wrong account. The file belongs to the web account, not svc-planning. Read it from the Stage 1 foothold. |
| SSH as svc-planning is rejected | Wrong account name or a mistyped password. Copy the password from Stage 2 rather than retyping it. |
| `sudo -l` prints nothing you can run | You are not the account the sudo rule names. Check `id`; you want to be svc-planning. |

## After the Game: Questions and Exercises {#questions}

### Attacking the Server {#questions-server}

> Question: The exposure needed no login. Which single change would have stopped it, and what would still be exposed after that change?

> Question: The commit message named the account and admitted the credentials were never rotated, but the password was in a separate file. Why does that split not help the defender here, and what should have happened to the credential the moment it was committed?

> Question: Four flags, one account. Which of the four would a server administrator be least likely to notice from the logs, and why?

> Action: Write a short checklist for the administrator of the repository server. Give one line for each of the four stages, naming the control that would have stopped that stage. Hand in the checklist.

## Further Reading {#further-reading}

- [CVE-2018-1000533 in the NVD](https://nvd.nist.gov/vuln/detail/CVE-2018-1000533)
- [Git Tools: Searching](https://git-scm.com/book/en/v2/Git-Tools-Searching)
- [The sudoers manual](https://www.sudo.ws/docs/man/sudoers.man/)
- [GTFOBins](https://gtfobins.github.io/)
