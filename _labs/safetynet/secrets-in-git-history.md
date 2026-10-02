---
title: SAFETYNET Field Guide - Secrets in Git History
layout: lab
description: Optional in-game guide for recovering credentials a developer committed, deleted or stashed — and why git never really forgets
game_fragment: true
permalink: /labs/safetynet/secrets-in-git-history/
---

# SAFETYNET Field Guide: Secrets in Git History

## Objective

Use this guide when you have access to a git repository — a browsable one on the web, or a `.git` directory on a box — and you suspect someone committed a secret they thought they had cleaned up. This is reading, not tooling. A password or key that was added in one commit and removed in the next is still sitting in the history, and `git stash` is a second hiding place people forget they ever used. Your job is to read the log, not run an exploit.

## Quick Reference

- A commit is permanent. Deleting a secret in a later commit **does not** remove it from history — the old commit still holds it.
- `git log` lists commits; `git log -p` shows the actual line-by-line changes in each one. That is where a removed secret still lives.
- `git stash` saves work-in-progress off to one side. Stashes are not shown by `git log` and are easy to leave behind.
- Search the whole history, not just the current files. The current checkout is the one place a careful developer *did* clean up.
- "We rotated it" only counts if they actually rotated it. A commit message promising a future fix is a gift.

```bash
# Every change ever made, with the diffs — read for added-then-removed secrets
git log -p

# Search all of history for a keyword across every commit
git log -p -S password
git grep -i password $(git rev-list --all)

# The second hiding place: stashes
git stash list            # anything parked here?
git stash show -p stash@{0}
```

## Core Workflow

1. Get the repository. On a web browser like GitList, read the commit history and file views directly; with a local clone, work from the shell.
2. Read the log with diffs (`git log -p`). Watch for a commit that *adds* a credential and a later one that *removes* it — the secret is in the add.
3. Pay attention to commit messages. "temp creds, will rotate" is a signpost to exactly what you want, and a hint it was never rotated.
4. Check the stash (`git stash list`, then `git stash show -p`). Work someone parked and forgot is not in the normal history and is often where the real secret hid.
5. Pull out the credential, confirm which account or service it belongs to, and use it.

## Common Failure Modes

- **You only looked at the current files.** The current checkout is the cleaned-up version. The secret is in an *earlier* commit — you have to read the history to see it.
- **`git log` looks empty of secrets.** Add `-p` to see diffs, and `-S <term>` to pickaxe for a string being added or removed. A plain log only shows messages.
- **You forgot the stash.** `git stash list` is a one-line check that people routinely skip. Run it every time.
- **The credential does not work where you expected.** Match it to the right account — a service password is not necessarily a login password. Check the surrounding commit for context.

## The Wider Lesson — Git Never Forgets

The mental model that burns people is treating a commit like an edit you can take back. It is not. Git is an append-only history: every version of every file is retained so the project can be rebuilt at any point in time. "Deleting" a secret just adds a new commit on top — the old one, secret intact, is still reachable. Public breaches routinely come from exactly this: an API key committed once, removed an hour later, and scraped from the history years on.

The defences are about never letting the secret in, and treating it as burned if it does:

- **Keep secrets out of the repo.** Use environment variables, a secrets manager, or an ignored config file — never a committed one.
- **Scan before you push.** Pre-commit hooks and secret scanners catch the credential before it becomes permanent.
- **If it was committed, rotate it.** Rewriting history is hard and never reaches every clone. The only reliable fix is to change the secret so the leaked one is worthless.
- **Do not trust the stash either.** It is still local history; a leaked clone carries it.

The defensive principle is one line: **a secret that ever touched a commit must be treated as public — the only cure is to change it.**

## Mission Application

SAFETYNET's own internal tooling repo is browsable with no authentication, and the mole was careless with it. The repository exposure alone names the ops service account. Then read the history properly: a password was committed and "scrubbed" in a later commit, and there is work parked in the stash that was never meant to be seen. Recover the mole's credential from the history and the stash, log in, and follow it to the ENTROPY correspondence in their home directory.
