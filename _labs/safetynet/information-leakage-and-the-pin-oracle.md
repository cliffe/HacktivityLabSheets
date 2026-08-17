---
title: "SAFETYNET Field Note: Information Leakage & the PIN Oracle"
layout: lab
description: Optional in-game field note on partial-feedback oracles — how a device that leaks "how close you got" turns a blind four-digit lock into a handful of deductions
game_fragment: true
permalink: /labs/safetynet/information-leakage-and-the-pin-oracle/
redirect_from:
  - /labs/m02_ransomed_trust/safetynet-field-note-information-leakage-and-the-pin-oracle/
---

# Handler Note — Agent HaX

The thing you just pulled out of that case is one of theirs, and it is worth understanding rather than just using.

It does not brute-force the safe. A blind four-digit keypad has ten thousand combinations, and if all you get back is a red light, you have to try them until one works. This device does something cleverer and much nastier: after every wrong guess it tells you *how close you were*. That single scrap of feedback is the whole attack. It is the board game Mastermind, built in silicon and pointed at a lock.

Learn the principle, because you will meet it again everywhere. Any system that answers a wrong attempt with more than "wrong" is leaking, and attackers live in that leak.

— HaX

---

# SAFETYNET Field Note: Information Leakage & the PIN Oracle

## Objective
Use this note the moment you have the ENTROPY keypad oracle on a lock. Your aim is to read its feedback correctly and deduce the code in a handful of attempts, and to recognise the same partial-feedback weakness when it shows up in software you are assessing.

## Quick Reference
- **Green light** = right digit, **right position**.
- **Amber light** = right digit, **wrong position**.
- **No light for a slot** = that digit is **not in the code** (once greens and ambers are accounted for).
- The count of lights matters more than which slot they appear next to — treat each guess as a question and each light as part of the answer.
- Every guess should be *designed to eliminate possibilities*, not to get lucky.

## The Core Idea — a Partial-Feedback Oracle

An **oracle** is any component that answers a question you are not supposed to be able to ask. A **partial-feedback oracle** answers *incompletely* — it will not hand you the secret, but it grades your guess. That grade leaks information.

A secure lock is all-or-nothing: a wrong code and a nearly-right code get the exact same response. This device breaks that. It converts each failed attempt into a measurement, and measurements accumulate. The search space does not shrink one code at a time — it collapses.

Ten thousand combinations sounds like a lot. It is not, once every wrong answer tells you which digits belong and roughly where.

## Core Workflow — Reading the Lights

### Step 1 — Open with a probe
Enter any code and read the response. Your first guess is not meant to succeed; it is meant to tell you which digits are in play.

### Step 2 — Separate presence from position
- **Greens** are locked-in facts: that digit belongs in that slot. Keep it.
- **Ambers** tell you a digit belongs to the code but you have it in the wrong slot. Move it.
- **Dark slots** tell you that digit is absent. Stop trying it anywhere.

### Step 3 — Change one thing at a time
When you can, alter a single digit or swap two positions between guesses. If the light count changes, you know exactly which change caused it. Changing everything at once wastes the feedback.

### Step 4 — Converge
Fix greens in place, shuffle ambers into untried slots, and fill the remaining gaps only with digits you have not yet ruled out. Four or five well-chosen rows will corner the code.

### Worked Example (hidden code: `6 3 5 1`)

Note the device reports *counts* — how many greens, how many ambers — not which slot each light belongs to. Working out the positions from those counts is the whole game.

```text
Guess    Feedback          What it tells you
1 2 3 4  2 amber           1 and 3 belong to the code but are misplaced;
                           2 and 4 are not in it at all.
5 6 1 3  4 amber           5 and 6 belong too — that is the whole digit
                           set, {1,3,5,6}. No greens, so none of them sit
                           where this guess put them.
6 5 3 1  2 green, 2 amber  Two digits are now home. Cross-referencing the
                           earlier "misplaced" facts, the greens can only
                           be 6 (slot 1) and 1 (slot 4); the 5 and 3 are
                           right digits in the wrong slots, so they swap.
6 3 5 1  4 green           all four fixed — open.
```

Two probes handed you the complete ingredient list. Two more, reasoning from the green count against what you already knew, fixed the order. Four rows against a lock that was supposed to withstand ten thousand.

You never "tried ten thousand combinations." Each guess was a question, each light was part of the answer, and the leak collapsed the search for you.

## The Wider Lesson — Where This Bites in the Real World

The PIN oracle is a toy version of a whole family of real attacks. All of them exploit a system saying *more than it should* about a wrong attempt:

- **Username enumeration** — a login that says "no such user" for a bad name but "wrong password" for a real one has just told an attacker which accounts exist. The fix: one identical message for every failed login.
- **Padding oracle attacks** — a server that reveals whether decrypted ciphertext had valid padding (a different error, or a different response time) leaks enough, byte by byte, to recover plaintext without the key. Same shape as the keypad: partial feedback, accumulated.
- **Timing side channels** — a password check that returns *faster* when the first character is wrong leaks the secret one character at a time. Compare secrets in constant time.
- **Verbose errors** — stack traces, "close but no match", or field-specific validation messages all hand the attacker a grading function.

The defensive principle is one line: **a wrong answer should reveal nothing but that it was wrong.** No partial credit, no distinguishable errors, no measurable difference in time or response. Design the failure case to be uniform and boring.

## Common Failure Modes
- **Reading lights as positions.** Amber does *not* mean "right idea, nearly there" for that specific slot — it means the digit belongs somewhere else. Track presence and position separately.
- **Changing every digit between guesses.** You lose the ability to attribute a change in feedback to a specific move. Vary deliberately.
- **Ignoring dark slots.** A digit that produced no light is the most valuable result you get — it permanently removes options. Use it.
- **Assuming the mechanic is the point.** In an assessment, the finding is not "I opened the lock" — it is "this interface leaks how close a guess is." Report the leak, not the trophy.

## Mission Application
You are holding this device because someone on ENTROPY's payroll was sent to this exact safe to reach the offline keys before you — and left their kit behind. Turn it on their target. Read the lights, deduce the code, take the keys.

Then remember what it demonstrates. ENTROPY built an attack out of a lock that was too talkative. The hospital's own systems — its logins, its terminals, its error messages — are worth the same suspicion. The moment a system tells you *how wrong* you are, it has already started telling you how to be right.
