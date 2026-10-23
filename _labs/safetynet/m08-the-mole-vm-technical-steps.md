---
title: "The Mole: VM Technical Steps"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Technical companion to The Mole walkthrough, for the lab network: step-by-step hints for the repository server, the credential buried in git history, the login to svc-planning, and the escalation to root, plus command-line practice."
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

Three of the four flags are one person's trail. The exposed repository names a service account, the credential buried in that repository's history is the account's password, the same account owns the home directory you log in to, and its name is in the root-only access logs. The account is **svc-planning**. The fourth flag, root, comes a different way. The web service runs as its own account, **www-data**, and that account, not svc-planning, holds the sudo rule to root. So you follow svc-planning's trail for the first three flags, and you go through the web account for the fourth.

1. **Exposure flag.** Reach SAFETYNET's own repository browser, with no login, and read what it exposes.
2. **Credentials flag.** Recover the mole's password from the repository's own history, after it was committed and then removed.
3. **Account flag.** Log in as **svc-planning** with that password, and read its home directory.
4. **Root flag.** Exploit the web service to a shell as its own account, escalate through that account's sudo rule, then read the logs the server keeps for its users.

The flag values are generated for each game, so this sheet never gives one. It says where each flag sits and how to reach it.

## Concepts {#concepts}

You do not need to read all of this before you start. Come back to it when a stage leaves you unsure what a tool or a result is telling you.

### Secure Shell and the Linux Shell {#ssh}

**SSH** (Secure Shell) gives you a command line on another machine over an encrypted connection. You give it an account name, a host and a password, or a key. The server checks the credentials against the account. If they match, you get a shell that runs as that account, and everything you type can read and write only what that account may.

A Linux shell works on a set of directories and files. Each file has an owner and permissions. Your **home directory** is the part of the disk the account owns. Files outside it, such as another account's home or the system logs, usually belong to someone else, and the permissions decide whether you may read them. A file set to `0600` can be read only by its owner, so an account that is not the owner is refused even if the file sits in a directory it can reach.

Worked example, on a practice machine of your own:

```
$ ssh alice@192.0.2.10
alice@host:~$ ls
notes.txt
alice@host:~$ cat /var/log/auth.log
cat: /var/log/auth.log: Permission denied
```

### Exposed Repositories and Secrets in Git History {#repos}

A source-code server such as GitList lets you browse a project's files and its commit history in a web page. If it is open with no login, anyone who can reach it reads the code, the configuration and every commit message. A commit message such as "temp creds for the planning sync job, will rotate" tells you a credential exists, which account it belongs to, and that nobody rotated it.

A secret that is removed from a project is not gone. Git keeps every version of every file in its history. Deleting a file from the working tree, and committing the deletion, takes it out of the current files, but the earlier commit that added it is still there. Anyone who reads the history can check out or print that old version. This is the lesson the mission makes real: the developer committed the credential, then committed its removal, and the working tree looks clean, but the password still sits in the commit that added it.

You find such a secret with `git log` and `git show`. `git log` lists the commits and their messages. `git show <commit>` prints what one commit changed, including the full content of a file it added. A history browser like GitList can show the same commits and diffs through the web page, so the secret is often reachable with no shell at all.

Worked example, in a repository where a credential was committed and later removed (output from a practice repo):

```
$ git log --oneline
311ff6a remove committed credentials from planning_sync.env
bb7f0ce add planning sync service credentials (temporary, rotate before go-live)
3cbddc1 initial import of mission-tooling
$ ls
README.md
$ git show bb7f0ce
...
diff --git a/planning_sync.env b/planning_sync.env
+SYNC_USER=svc-planning
+SYNC_PASSWORD=example-not-real
```

The working tree holds only `README.md`, yet `git show` on the commit that added the file prints the secret line in full. The removal commit's own message is the breadcrumb that tells you which commit to look at.

### Argument Injection {#argument-injection}

A web application often passes what a visitor types into a command that runs on the server. If that input is joined into the command without checks, the visitor can add options or extra commands. This is **argument injection**, a form of injection flaw. It can give you the ability to run commands on the server with no login at all, as whatever account the web service runs as.

Software versions that contain a flaw like this often have a published **CVE** (Common Vulnerabilities and Exposures) entry. The entry names the affected versions and describes the input that is not checked. You compare the version the service reports against that entry before you try anything.

### Sudo and Privilege Escalation {#sudo}

**Privilege escalation** means moving from a low-rights account to a higher one, usually root. **sudo** lets an account run a command as another user, if the sudo rules allow it. Only root may edit those rules. Running `sudo -l` lists what the current account may run.

A rule that lets an account run a tool which can start a shell, or run other programs, is a misconfiguration. The tool may have been meant for something harmless, such as keeping packages up to date, and the rule still hands out a root shell. A sudo rule belongs to a named account, so the rule you want may sit on the web service account rather than on the account you logged in with.

Worked example, with made-up output, as the web service account:

```
$ sudo -l
User www-data may run the following commands:
    (root) NOPASSWD: /usr/bin/apt-get
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

**Where:** the attack box's browser, against the repository server. **Goal:** reach SAFETYNET's own repository browser with no login, read what it exposes, and submit the flag that comes with it.

> Hint: The repository browser is open. No login, no exploit. Open it in the browser and read the project it serves, including the files and the commit messages.

<details markdown="1">
<summary>Nudge</summary>

Point the attack box's browser at the repository server and open the repository it serves. The committed files read as a real project: a readme, a small sync script, an example settings file. The readme carries the flag, names the service account **svc-planning**, and says a credential was committed to the settings file for testing and later removed, that the history was never cleared, and that the credential was never actually rotated. Hold on to all of it: the account name is for Stage 3, and "committed then removed, check the history" is the whole of Stage 2.

**Learn it:** ==action: Write down the software name and version the web service reports==. You do not need it here, but you will want it at Stage 4.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Open the repository browser in the attack box's browser, at `http://<repository server>/`==, and read the project it serves.
2. \==action: Read the readme and the other committed files, and the commit messages==. Note the account name **svc-planning** and the line that says a credential was committed then removed and never rotated.
3. \==action: Copy the flag from what you read and submit it at the Evidence Relay Terminal==.

</details>

> Warning: Do not reach for an exploit here. This flag is a plain read of an open web page. The version you noted matters at Stage 4, not now.

### Stage 2: The Credentials Flag {#hints-vm-credentials}

**Where:** the repository server's history, through the open browser or a shell. **Goal:** recover the mole's password from a commit that was later removed, and submit the flag that comes with it.

> Hint: Stage 1 told you a credential was committed and then removed. Removing a file from the current project does not remove it from the history. The commit that added it still holds it, with the password and the flag.

<details markdown="1">
<summary>Nudge</summary>

The settings file is gone from the current files, so browsing the project at its latest state shows nothing. Look at the commit history instead. One commit adds the service credentials, a later commit removes them. The adding commit still contains the file in full, with the line that starts `SYNC_PASSWORD=`, the password, and the flag. You can read the history two ways: through the repository browser's commits or diff view in the web page, or from a shell with `git log` and `git show` once you have one. Either reaches the same old commit.

The in-game **Secrets in Git History** field guide explains why a careless developer's secrets survive a "removal", and how to dig them back out. This box is exactly that lesson: the password was scrubbed from the working tree but not from the history.

**Learn it:** ==action: Run `git log --oneline` and read the messages top to bottom==, so you can tell the commit that added the file from the one that removed it, and pick the one to open.

**To learn more in game:** ask the phone for the Secrets in Git History field guide.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Open the repository's commit history==, in the browser's commits or diff view, or with `git log --oneline` from a shell on the box.
2. \==action: Find the commit that added the planning sync credentials== (its message is about adding the temporary credential), and the later one that removed it.
3. \==action: Show that adding commit==: open its diff in the browser, or run `git show <that commit>` from a shell. Read the file it added and find the line that starts `SYNC_PASSWORD=`, the password beside it, and the flag.
4. \==action: Copy the flag and submit it at the Evidence Relay Terminal==.

</details>

> Warning: Looking at the project's current files will not show the credential: the file was removed. You have to read the earlier commit in the history, not the latest state.

> Tip: A natural stopping point for a 60-minute class is after this stage. The next two stages use the account and password you now have.

### Stage 3: The Account Flag {#hints-vm-login}

**Where:** the attack box's terminal, logging in to the repository server. **Goal:** log in as **svc-planning** with the recovered password, read its home directory, and submit the flag.

> Hint: A password only works on the account it was made for. You have the account name from Stage 1 and the password from Stage 2. Log in over SSH, then look at what is in the home directory.

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

> Warning: The mail file is owned by svc-planning and set so only its owner can read it. The web service account cannot open it, so a foothold on the web service is not enough: this flag needs the svc-planning login. If the password is rejected, check the account name first; a correct password on the wrong account fails the same way as a wrong one. Copy the password rather than retyping it.

### Stage 4: The Root Flag {#hints-vm-root}

**Where:** the attack box, against the web service on the repository server. **Goal:** exploit the web service to a shell as its own account, escalate that account to root, read the logs and cached files only root can open, and submit the flag.

> Hint: The account you logged in as for Stage 3 has no sudo rights. Root is reached through the web service account instead. Get a shell as that account first, then ask what it may run as root.

<details markdown="1">
<summary>Nudge: getting a shell as the web account</summary>

The web service is a known version with an argument-injection flaw that needs no login, the same version you noted at Stage 1. Look the name and version up in the CVE database, read the affected versions and the input the entry names, then run a proof of concept from the attack box. It lands you a shell as the web service account, **www-data**, not as svc-planning. svc-planning cannot reach root; www-data is the account that can, and the only way onto it is this exploit.

**Learn it:** ==action: Write down the version and the CVE number before you run anything==, then check any proof of concept against the CVE description.

**To learn more in game:** ask the phone for the Scanning and Exploitation field guide.

</details>

<details markdown="1">
<summary>Nudge: escalating to root</summary>

From the www-data shell, run `sudo -l`. It lists one tool the account may run as root: a package manager. A package manager can run other programs, so it can be turned into a root shell. The Privilege Escalation field guide has a section on escaping an allowed command to a shell. Once you have root, the access logs and The Architect's cached authorisation sit where only root can read them. The log puts svc-planning at a Cryptography Lab terminal opening the Portland planning file, `pnw_contingency.enc`, and the flag is in the same place.

**Learn it:** ==action: Before you run a command as root, write down what it will do and what it could change==.

**To learn more in game:** ask the phone for the Privilege Escalation field guide.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Fingerprint the web service and confirm the software name and version== (`curl -i http://<repository server>/` and the page source).
2. \==action: Search the CVE database for that name and version, and read the entry's affected versions and description==.
3. \==action: Run a proof of concept for the CVE from the attack box to get command execution as the web account==, and open a shell as `www-data`.
4. \==action: Run `sudo -l` as www-data==. Note the tool you may run as root (a package manager such as `apt-get`), and whether it asks for a password.
5. \==action: Open the Privilege Escalation guide at the section "Method 4: Escaping an Allowed Command to a Shell (GTFOBins)", and find the entry for that tool==.
6. \==action: Follow that entry to a root shell, then confirm with `id`==.
7. \==action: Read the root-only access logs and The Architect's cached authorisation. Find the flag, and submit it at the Evidence Relay Terminal==.

</details>

> Warning: A proof of concept written for another version may fail, or do something you did not expect. Check its version notes against the version you found. And you are root on a shared server: read the logs, but do not change, delete or move them.

### Submitting the Four Flags {#hints-vm-submit}

> Tip: Submit each flag as soon as you find it. The Evidence Relay Terminal takes flags from the repository server.

Copy each flag exactly as it appears in the output.

## Try It on the Command Line (Optional) {#command-line}

These exercises use a repository and an account of your own. Do not run them on the lab server.

### A secret you commit and then remove {#cli-git-history}

This is the mission's Stage 2 in miniature. Make a practice repository, commit a made-up secret, delete it in a later commit, then recover it from the history.

```
$ mkdir practice-repo && cd practice-repo && git init
$ echo "mission tooling" > README.md
$ git add README.md && git commit -m "initial import"
$ printf 'SYNC_USER=svc-planning\nSYNC_PASSWORD=example-not-real\n' > planning_sync.env
$ git add planning_sync.env && git commit -m "add planning sync service credentials"
$ git rm planning_sync.env && git commit -m "remove committed credentials"
$ ls
$ git log --oneline
$ git show $(git log --oneline | grep "add planning sync" | awk '{print $1}')
```

> Note: The secret is made up. The exercise is to see that `ls` shows a clean working tree, yet `git show` on the adding commit still prints the `SYNC_PASSWORD=` line.

\==action: Run the `ls` and note the file is gone from the working tree==. Then \==action: run the `git show` on the adding commit== and find the line you removed, exactly as the mission's credential survives its "removal".

### Reading your own sudo rules {#cli-sudo}

On your own Kali box, run `sudo -l` and read the output line by line.

\==action: For each command the output lists, write one sentence saying what that command can do when it runs as root==. Ask whether the command can run another program or start a shell. This exercise is reading only. Do not try to escape a command on the lab server.

## What the Tools and Locks Are Telling You {#symptoms}

| What you see | What it usually means |
|---|---|
| The repository page loads with no login prompt | The repository browser is open to anyone. Read the files and commit messages straight from it. |
| The current files do not contain the credential | It was removed in a later commit. Read the history: find the adding commit and show it, in the web diff view or with `git show`. |
| `git log` shows an "add credentials" commit and a later "remove" commit | The password is in the adding commit. Open that commit, not the latest state of the file. |
| `ssh svc-planning` is rejected | Wrong account name or a mistyped password. Copy the password from Stage 2 rather than retyping it. |
| `cat ~/flag` (the mail) says "Permission denied" | You are the web account, not svc-planning. The file is owner-only. Log in as svc-planning over SSH to read it. |
| `sudo -l` as svc-planning prints nothing you can run | svc-planning has no sudo rule. The rule is on the web account; reach it through the web-service exploit, then run `sudo -l` as www-data. |

## After the Game: Questions and Exercises {#questions}

### Attacking the Server {#questions-server}

> Question: The exposure needed no login. Which single change would have stopped it, and what would still be exposed after that change?

> Question: The credential was committed and then removed, and the working tree looked clean. Why did the removal not protect it, and what should have happened the moment the credential was committed by mistake?

> Question: Root was reachable from the web service account but not from svc-planning. Why does scoping a sudo rule to a service account that has no interactive login not make it safe, once the web service itself can be exploited?

> Question: Four flags, one investigation. Which of the four would a server administrator be least likely to notice from the logs, and why?

> Action: Write a short checklist for the administrator of the repository server. Give one line for each of the four stages, naming the control that would have stopped that stage. Hand in the checklist.

## Further Reading {#further-reading}

- [CVE-2018-1000533 in the NVD](https://nvd.nist.gov/vuln/detail/CVE-2018-1000533)
- [Git Tools: Searching](https://git-scm.com/book/en/v2/Git-Tools-Searching)
- [The sudoers manual](https://www.sudo.ws/docs/man/sudoers.man/)
- [GTFOBins](https://gtfobins.github.io/)
