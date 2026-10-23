---
title: "Full Disclosure (Break Escape Mission 10)"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Play the browser-based Season 1 finale: raid a Cold War bunker with a team, clone a card and pick a locker for a spare, dust a keypad to narrow a PIN and crack it, decode a Base64 margin note, read a door log against an alibi to find the sleeper on your own team, and decide at the Architect's console what happens to the database and to him."
overview: |
  Tomb Gamma, a converted Cold War bunker under the Montana hills. At six o'clock the man behind ENTROPY's plan releases every weakness SAFETYNET ever catalogued to every city at once, with two cells given a head start at four. You go in with Task Force Null, take his systems one host at a time, and reach his console before the clock does. One of the team beside you is a sleeper, placed years ago, and you have to find them without naming the wrong person.

  You play Agent 0x00. You breach the perimeter, work down through a security office and a workshop, cut the power to a sealed gallery, take three servers across the bunker, read a door log against an alibi to name the sleeper, and argue the case with the Architect across three exchanges. At his console you decide what happens to the database he built, and what happens to him. There are six endings, including a clearly signposted way to join ENTROPY that ends the mission as a failure.

  This sheet gets you started, explains the ideas behind each lock and each piece of evidence with small worked examples you can check by hand, and has a stage-by-stage set of hints for when you are stuck, from a gentle nudge up to the exact steps. The work on the three servers has its own companion sheet. The choices and the ending are yours; the hints help you understand what you hold, not which choice to make.
tags: ["vulnerability-disclosure", "responsible-disclosure", "insider-threat", "audit-trail", "door-log", "rfid", "cloning", "lockpicking", "pin-cracking", "smudge-attack", "base64", "cyberchef", "ethics", "break-escape"]
categories: ["safetynet"]
type: ["game-based-learning", "lab-sheet"]
difficulty: "advanced"
source: "https://github.com/cliffe/BreakEscape/blob/main/scenarios/m10_full_disclosure/labsheet.md"
cybok:
  - ka: "AB"
    topic: "Characterisation of Adversaries"
    keywords: ["The insider threat", "Social engineering", "Supply chain attack"]
  - ka: "F"
    topic: "Definitions and Conceptual Models"
    keywords: ["Audit trail", "Encoding"]
  - ka: "AAA"
    topic: "Authentication"
    keywords: ["User authentication", "Smart cards", "Personal identification number and memorable information"]
  - ka: "LR"
    topic: "Ethics"
    keywords: ["Vulnerability testing", "Vulnerability disclosure", "Responsible disclosure"]
  - ka: "SSL"
    topic: "Motivations for Secure Software Lifecycle"
    keywords: ["Customers don't apply patches", "Vulnerability response and disclosure"]
---

## Purpose {#purpose}

By the end of this lab you should be able to:

- explain what coordinated (responsible) disclosure is, what full disclosure is, and why the choice between them has a human cost either way
- read a door log against an alibi and say why a badge in a log names a card, not a person, and how a planted badge misleads an investigation
- describe how a card is cloned, how a picked locker gives up a spare, and how dusting a keypad narrows a PIN before a cracker finishes it
- recognise and decode a Base64 note, and say why an encoded note is not a protected one
- name a suspect carefully from evidence rather than instinct, and say what a wrong accusation costs an investigation
- weigh three outcomes for a database of weaknesses, and four outcomes for the man who built it, with each cost in view

The game teaches by doing. The questions are in this sheet, after the game.

## How to Use This Sheet {#how-to-use}

1. Read **Getting Started** and do the short CyberChef warm-up.
2. Play. Skim **Concepts** as you reach each new idea, or come back to it afterwards.
3. If you get stuck, go to **Stuck? Hints, Stage by Stage** and find the stage you are on. Each stage has a hint you can read straight away, then a stronger nudge and the exact steps hidden behind "Show" buttons. Open one at a time, and go back to the game after each.
4. After the game, work through **After the Game: Questions and Exercises**.

The work on the three servers is in the linked companion sheet, [VM Technical Steps](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/m10-full-disclosure-vm-technical-steps/), so you can play the rest of the mission without server spoilers.

> Note: The codes in the bunker are the same every game, but you still work them out from clues. This sheet says where each clue is and what shape the answer takes, never what it reads. The evidence you pull from the servers is generated for your game, and the companion sheet covers how to get it.

## Getting Started {#getting-started}

You are Agent 0x00, back with SAFETYNET for the last night of the season. Director Netherton runs the raid from a folding table at the gate with Task Force Null. Your handler, Agent HaX, is on the line to the end; the Architect trained her, and she has told you so. Mission 9 told you a sleeper is on tonight's team. Your job is to get a foothold on the bunker's systems, work down to the core, find the sleeper, and reach the Architect before his release goes out.

You do not need any prior knowledge before you start. The one new decode (Base64) is taught in the warm-up and covered in **Concepts**; everything else reinforces skills from earlier missions.

1. \==action: Start the Break Escape mission **Full Disclosure**==.
2. \==action: Watch the briefing at the forward post, then close it==. Take the aside that follows; it opens the search for the sleeper.
3. \==action: Talk to Director Netherton== about Nightshade in the van, and make the tether choice.
4. \==action: Open your phone whenever you are unsure==. Agent HaX reads your progress and answers from where you are.

The mission takes about 100 to 110 minutes. Your progress is kept between sessions.

> Note: Wall displays and your phone show a clock, counting the release at six o'clock UTC and the head start at four. It is story time that moves with your progress, not a real countdown you can run out of. "Nothing went at six" in the credits means you disarmed the release, not that you beat a timer.

> Tip: A natural stopping point for a 60-minute class is once you have cut the gallery's power and taken the release console and the hatch flags. The gallery, the core and the ending make a strong second session.

### How to Play {#how-to-play}

You move with the arrow keys or by clicking. Click objects, people and doors to interact. Items you take go to the inventory bar; documents open as readable pages you can reopen.

Your kit is the phone (Agent HaX), a **Lock Pick Kit**, an **RFID Cloner**, a **Fingerprint Kit**, a **PIN Cracker (Kowalczyk's)** and a **CyberChef Workstation**.

The raid moves room by room: the forward post at the gate, down the blast tunnel to the security office, the stair down to the workshop and the power room, the server hall, across the gallery and into the core. Task Force Null moves with you.

Agent HaX's phone reads your progress. Her hints change as the night moves, and she volunteers what the clues point at once you have them. She jams near the core, so gather what you can before you go in.

> Tip: Press **Q** to switch between your fists and your open hand. You need the open hand to use things. Striking a member of your own team has a cost that shows in the credits.

> Tip: The locks want exact values. A PIN is four digits. Copy decoded text with the mouse rather than retyping it.

> Warning: Most of the team can be knocked out, and several gates have a quiet route that needs nobody. You never have to hit a teammate to finish. The stages note where a fight is avoidable.

### Warm-up: Your First CyberChef Base64 Decode {#warm-up}

Do this once you are at the **CyberChef Workstation**. It uses made-up data, not anything from the game.

1. \==action: Open CyberChef and clear the recipe== if anything is in it.
2. \==action: Type `VHJ1ZSByYW5nZSBpcyBoaWdoZXIu` into **Input**==.
3. \==action: Search for `base64` and double-click **From Base64**==. The output reads `True range is higher.`
4. \==action: Clear the input and type a word of your own==, add **To Base64**, and watch it turn into a block of mixed-case letters, digits and maybe `=` signs.

That block is the shape you are looking for when a note is encoded. The next section explains why encoding is not protection.

## Concepts {#concepts}

You do not need to read all of this before you play. Use it when you reach each idea, and again when you answer the questions afterwards.

### The Sleeper and the Door Log {#door-log}

A sleeper is an insider placed years ago, who holds a legitimate badge and a legitimate seat on the team. Nothing about their access looks wrong, so you cannot find them by looking for a break-in. What is left is the record the bunker keeps without meaning to.

A **door log** (an audit trail) is the record a reader keeps: a door, a time, and the badge that opened it. It names a **card**, not a person. A card can be lent, stolen or planted, so a badge in a log is a lead, not a verdict. You test it against an **alibi**: if the person whose badge opened a door was demonstrably somewhere else at that minute, the badge was not in their hand.

Here is the shape of the reasoning, with made-up names:

```
Door log:   02:10  core service door  badge: MALHOTRA
Alibi:      Malhotra was on the line with the handler at 02:10.
```

Both cannot be true of the same person at once. Either the alibi is wrong, or the badge was not Malhotra's to use at 02:10. A planted badge is the classic way an insider throws the log at a colleague. The lesson is that a log narrows the field and names a card; a second source, an alibi or a bench log, is what turns a card into a person.

In the game three things point somewhere: the door log at the security office, the alibis you can check, and a bench log. Your handler tells you when you have all three and reminds you that the call is yours and that you do not have to make it.

| What you see in a log | What it probably means | What to try |
| --- | --- | --- |
| A badge at a door at a key minute | A card was used, not proof of who held it | Check whose badge it is against where that person was |
| A badge whose owner has a firm alibi | The badge was lent, stolen or planted | Treat the owner as pointed at, not guilty |
| A door opened with no badge in the log | A held-open door, a tailgate, or a reader off | Ask what else records that door |

> Question: The log names a badge at the core service door at a minute when that badge's owner was clearly elsewhere. Does that clear the owner, accuse them, or neither? Explain what you would check next.

### Naming a Suspect, and the Cost of a Wrong Name {#naming}

You can name the sleeper on the phone to the Director or face to face. A name you can support with the door log, an alibi and the bench log holds up. A name on instinct does not, and a wrong accusation has a cost: an officer is sent back, the real sleeper hears that you are looking, and the credits record it. This is the difference between an investigation and a hunch, and the game makes you feel it.

> Question: What is the smallest set of evidence you would want before you named a colleague as a traitor on an open line, and why is instinct the worst of the things you could use?

### Physical Bypasses: Cards, Lockers and Keypads {#bypasses}

The bunker reuses the physical attacks from earlier missions, so most of this is recognition.

- **A cloned card.** A contractor's card opens the power room. Clone it the usual way: read, crack if needed, save, then emulate at the reader. If the owner will not stand for it, the spare card is in a fitter's locker.
- **A picked locker.** The fitter's locker is a key lock. The Lock Pick Kit opens it one pin at a time under light tension, and the spare power-room card is inside.
- **A keypad and a smudge.** The gallery's outer lock is a four-digit PIN. Dust the keypad plate with the Fingerprint Kit first: the keys that are worn or marked are the ones in the PIN, which cuts the number of combinations the **PIN Cracker (Kowalczyk's)** has to try. The cracker then finishes it. There are other ways through the outer lock too (a teammate's card or code), but the dust-and-crack route needs nobody.

A dusted keypad is a real attack. A four-digit PIN has ten thousand combinations, but if the dust shows only four keys are ever pressed, the PIN uses those four digits, and the count drops sharply. If the dust shows four distinct keys, the PIN is some arrangement of those four: twenty-four orderings. The cracker walks that short list in seconds.

> Question: A keypad shows wear on exactly four keys, and you know the PIN is four digits. How many orderings are there, and how does that compare with the ten thousand a blind guess would face? What would a keypad have to do to stop this attack?

### Encoding Is Not Protection {#encoding}

A note in the workshop margin is written in **Base64**, the scheme Mission 2 taught. Base64 rewrites any data as printable text using `A`-`Z`, `a`-`z`, `0`-`9`, `+` and `/`, often ending in one or two `=` signs. It has no key, so it protects nothing; it only changes the alphabet the note is written in. One unbroken block of mixed-case letters and digits with no spaces is Base64, not English, and From Base64 reads it.

```
True range is higher.   ->   VHJ1ZSByYW5nZSBpcyBoaWdoZXIu
```

The margin note decodes to a sentence and a password for a bench terminal. Its content matters to the story: the Architect's own analyst corrected his casualty figure and he knew. The encoding did not hide it from anyone with a decoder.

> Question: The analyst wrote the correction in Base64 in a margin. Who was that meant to keep the note from, and who could still read it? What would she have needed to actually protect it?

### Vulnerability Disclosure: The Database Choice {#disclosure}

At the core you decide what happens to the database of weaknesses SAFETYNET catalogued. The three options map onto a real debate in Cyber Security about how a flaw should be made known:

- **Secure it.** Lock the catalogue back in the vault. Operations keep running, and the hospitals and utilities that run the flaws stay unpatched because nobody has told their vendors.
- **Coordinated (responsible) disclosure.** Give the vendors the flaws first, with workarounds, so a fix can be built before the details are public. Two operations go dark, and a fix takes time, but the defenders get a head start.
- **Wipe both copies.** Destroy the catalogue. Nobody can use it, attacker or defender, and the record of what was known is gone, which has its own cost.

There is a fourth idea in the background, the one the Architect champions: **full disclosure**, releasing everything to everyone at once. His case is that vendors ignore quiet reports and only a public release forces a fix. The cost is that every attacker gets the flaws at the same moment as every defender. The mission is named for this argument, and the whole night is a working-through of it.

> Question: Coordinated disclosure gives vendors a head start; full disclosure gives everyone the flaw at once. Write the strongest one-sentence case for each, then say which you would choose for a flaw in a hospital system and why.

### The Endings and Their Cost {#endings}

The night ends with three decisions: what happens at his console, what happens to the database, and what happens to him. There are six endings. One, joining ENTROPY, is reached by three deliberate picks, each with a warning and a way back, and it ends the mission as a failure by design. The others (arrest, talking him into surrender, lethal force as he reaches for the key, and shooting him where he sits) are not scored right or wrong. The game states the cost of each before you commit. The hints help you understand what each holds; they do not pick for you.

## Stuck? Hints, Stage by Stage {#hints}

Find the stage you are on. The stages are in play order. Read the hint, then go back and try. If you are still stuck, open **Nudge**. Open **Steps** or **Recipe** last.

> Tip: Before you open any hint, ask yourself three questions. What is this clue made of, and what does its own description say? What shape does the lock or the character want? And have I checked what my phone says now, since HaX reads your progress and her answer changes through the night?

### Breach the Perimeter {#hints-breach}

**Where:** the forward post at the gate. **Goal:** take the briefing, make the tether choice, submit the first flag, and get through the blast door.

> Hint: Everything starts at Netherton's table. Take the briefing and the aside, answer his question about Nightshade, then start the gate console.

<details markdown="1">
<summary>Nudge</summary>

Close the briefing and take the aside that follows; it opens the search for the sleeper. Talk to Director Netherton about Nightshade in the van and make the tether choice. Then click the gate console; that is what starts the breach, Arakawa's call and the split. Submit the first flag at the gate terminal, and HaX opens the blast door.

**Learn it:** ==action: Click the gate console before you submit the flag==. The first objective only moves once you touch the console.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Close the briefing and take the aside==.
2. \==action: Talk to Netherton== and make the tether choice.
3. \==action: Click the gate console==, then submit the first flag at the gate terminal.
4. \==action: Go through the blast door== when HaX opens it.

</details>

> Note: How to get the gate flag off the monitoring host is in the companion, [VM Technical Steps](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/m10-full-disclosure-vm-technical-steps/).

> Warning: If you have the server console already open and submit the gate flag without clicking the gate console, the breach stalls and the blast door stays shut. Go back and click the console to recover it.

### Get Below Ground {#hints-below}

**Where:** the blast tunnel and the security office. **Goal:** reach the security office and answer the duty handset.

> Hint: The inner door opens as you reach it. The duty handset rings; answer it.

<details markdown="1">
<summary>Steps</summary>

1. \==action: Go down the blast tunnel==; the inner door opens on a clean approach.
2. \==action: Answer the duty handset in the security office==; HaX opens the stair down afterward.

</details>

> Note: This is also where the sleeper hunt starts. Read the door log at the monitoring desk; the hints for that are under **Finding the Sleeper** below.

### Cut the Gallery's Power {#hints-cut}

**Where:** the workshop and the power room. **Lock:** the power room takes a contractor's card. **Goal:** cut the power to the gallery.

> Hint: The power room wants a contractor's card. Clone the contractor's, talk him into it, or pick the fitter's locker for the spare.

<details markdown="1">
<summary>Nudge</summary>

Clone Imran's card the usual way (read, crack if needed, save, emulate at the reader), or talk him into opening it. If neither works for you, pick the fitter's locker in the workshop; the spare power-room card is inside. In the power room, the fitter Wendell cuts the power if you tell him to; if he will not, cut it by hand. Either way, HaX confirms the gallery shutter is down.

The workshop also holds a casualty sheet with a Base64 note in the margin (see **The Margin Note** below). It is optional.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Clone Imran's card, or pick the fitter's locker for the spare==.
2. \==action: Open the power room and tell Wendell to cut the power==, or cut it by hand.

</details>

> Warning: Knocking out either fighter in the power room still cuts the power by hand, but it has a cost in the credits. The locker route needs nobody.

### Find the Release {#hints-release}

**Where:** the server hall. **Goal:** submit the release console flag and the hatch flag.

> Hint: Two flags here: the release console and the sealed hatch. The gallery stair opens once both are in and the power is cut.

<details markdown="1">
<summary>Steps</summary>

1. \==action: Submit the flag at the release console==.
2. \==action: Submit the flag at the sealed hatch==.
3. \==action: Optionally use the release console controls== to close the backdoor.

</details>

> Note: How to take the server hall's two flags is in the companion. The staging schedule you read here names the cities and the head-start buyers.

### Finding the Sleeper {#hints-sleeper}

**Where:** the security office, the workshop bench, and the team. **Goal:** gather the door log, the alibis and the bench log, and decide whether to name the sleeper.

> Hint: Three things point somewhere: the door log at the monitoring desk, the alibis you can check with the team, and the bench log. A badge in a log names a card, not a person.

<details markdown="1">
<summary>Nudge</summary>

Read the door log at the security office monitoring desk. It names a badge at the core's service door at a key minute. Check that badge's owner against where they were: your handler can confirm an alibi. The bench log is a third source. When you have all three, HaX tells you they point somewhere and reminds you the call is yours.

You can name the sleeper on the phone to the Director or face to face. Name them from the evidence, not from a face. A wrong name sends an officer back and warns the real sleeper.

**Learn it:** ==action: Write down the badge the door log names, and the alibi that contradicts it==, before you decide. The gap between the two is the whole clue.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Read the door log at the security office monitoring desk==.
2. \==action: Check the named badge's owner against their alibi== with the team or your handler.
3. \==action: Read the bench log==.
4. \==action: Name the sleeper on the phone or face to face== when the evidence supports it, or leave it.

</details>

> Warning: Naming the wrong person has a cost and cannot be taken back cleanly. If the evidence does not point one way yet, you are allowed to leave it; the sleeper can also be dealt with at the core.

### Across the Gallery to the Core {#hints-gallery}

**Where:** the gallery. **Lock:** a four-digit outer lock. **Goal:** open the outer lock and reach the core.

> Hint: The outer lock is four digits, and your handler's hints go quiet near the core. Dust the keypad to see which keys are used, then let the cracker finish.

<details markdown="1">
<summary>Nudge</summary>

Dust the outer lock's keypad plate with the Fingerprint Kit. The worn keys are the digits in the PIN, which cuts the cracker's work to a short list of orderings. Run the **PIN Cracker (Kowalczyk's)** on it. A teammate's card or code also opens it, and so does Victoria if she is helping you, but the dust-and-crack route needs nobody. Decide what to do about the head-start share at the lock before you go through.

**Learn it:** ==action: Count the worn keys on the plate== before you run the cracker. Four worn keys means the PIN is an ordering of those four.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Dust the outer lock's keypad plate== and note which keys are worn.
2. \==action: Run the PIN Cracker on the outer lock==; it tries the orderings of the worn digits.
3. \==action: Go through to the core== once it opens.

</details>

> Warning: HaX jams near the core, so her hints stop. Gather the sleeper evidence and anything else you want before you cross.

### The Core: The Case and the Three Exchanges {#hints-core}

**Where:** the core. **Goal:** submit the last flag, hear the Architect out, and land points in the three exchanges.

> Hint: The Architect is waiting. Submit the core flag, then hear him out. The three exchanges are where you land the points that shape how the end can go.

<details markdown="1">
<summary>Nudge</summary>

When you reach the core the Architect arrives. Submit the core flag at the core terminal (the server work is in the companion). His conversation reopens: the case, then three exchanges. Points you land in the exchanges open more of the ending, so make your best argument. If you named or are holding the sleeper, that beat plays here too.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Submit the core flag at the core terminal==.
2. \==action: Hear the Architect's case==, then work through the three exchanges.

</details>

> Note: How to take the core host is in the companion, [VM Technical Steps](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/m10-full-disclosure-vm-technical-steps/).

### The Console, the Database and His End {#hints-end}

**Where:** the Architect's console. **Goal:** decide what happens at the console, to the database, and to him. What you choose is your decision; no ending but Join is a failure.

> Hint: Three decisions in a row: the console, the database, and his end. **Concepts** lays out what each option costs. The game states the cost before you commit.

<details markdown="1">
<summary>Nudge</summary>

At the console you stop the release or take the key. The database choice is secure it, coordinated disclosure, or wipe both copies, each with the cost named in **Concepts**. His end is arrest, surrender, lethal force as he reaches for the key, or shooting him where he sits. The closing scene follows: six o'clock, or a hearing, or the Citadel.

</details>

<details markdown="1">
<summary>Spoiler: the way to join, and the failure ending</summary>

Joining ENTROPY is a real, signposted ending. It takes three deliberate picks at the console, each with a warning and a way back, and nothing else leads to it. The credits mark it MISSION FAILED. You will not reach it by accident; every step asks you to confirm.

</details>

> Warning: The console decisions play through once started. Finish anything you want to read or submit before you commit.

### The Closing Scene {#hints-closing}

**Where:** the closing scene after your decisions. **Goal:** see the night out.

> Hint: The ending you chose sets the closing scene. Let it play; the credits follow and list what you did.

<details markdown="1">
<summary>Steps</summary>

1. \==action: Finish anything you still want to do==.
2. \==action: Let the closing scene play==, then close it.
3. \==action: Watch the credits==, which list your choices across the season.

</details>

## What the Tools and Locks Are Telling You {#error-messages}

| You see | It usually means |
| --- | --- |
| The blast door stays shut after the gate flag | You submitted the flag without clicking the gate console; go back and click it |
| The power room reader refuses the card | Emulate the saved contractor card, or use the spare from the fitter's locker |
| The fitter's locker will not pick | Keep light tension and work one pin at a time, as in earlier missions |
| The outer lock cracker runs long | Dust the plate first so the cracker only tries the worn digits |
| The gallery stair stays shut | The two server-hall flags are not both in yet, or the power is not cut |
| A Base64 note reads as nonsense after decoding | Check you copied the whole block, with no stray spaces or line breaks |
| HaX stops answering near the core | She jams there by design; gather what you need before you cross |
| The sleeper beat says you named the wrong person | The door log names a card, not a person; check the badge against an alibi |

## Optional Side Content {#optional}

None of these is needed to finish. Each adds evidence or context.

<details markdown="1">
<summary>The margin note and the bench terminal</summary>

The casualty sheet in the workshop has a Base64 note in its margin. Decode it at the CyberChef Workstation: it is the Architect's analyst correcting his casualty figure, and it carries the password for a bench terminal that holds her corrected model. If you completed Mission 2, HaX nudges you to recognise the Base64 shape.

</details>

<details markdown="1">
<summary>The records cupboard</summary>

A records cupboard off the security office is a four-digit PIN lock. A teammate's code opens it, or the cracker. Inside are incident files that fill in how the bunker was built and what the purge circuit does.

</details>

## Try It on the Command Line (Optional) {#command-line}

These short exercises use your own data, not anything from the game. Use any current Linux distribution with `base64`, or any Python install.

### Decode and encode Base64 {#cli-base64}

\==action: Encode a sentence, then decode it back==:

```bash
printf 'True range is higher.' | base64
printf 'VHJ1ZSByYW5nZSBpcyBoaWdoZXIu' | base64 -d; echo
```

> Question: Base64 has no key. Name one scheme that does protect the note, and say what the recipient needs that an attacker does not.

### How much a smudge narrows a PIN {#cli-pin}

\==action: Count the orderings of four known digits, and compare with a blind search==:

```python
import itertools
digits = "0369"                      # the four worn keys, made up
orderings = list(itertools.permutations(digits))
print(len(orderings), "orderings to try")   # 24
print(10 ** 4, "for a blind four-digit guess")  # 10000
```

> Question: If the dust showed only three worn keys for a four-digit PIN, one digit repeats. Does that make the search larger or smaller than the four-distinct-keys case, and why?

## After the Game: Questions and Exercises {#after-the-game}

Work through these after you finish. Use your own run: your choices and your ending may differ from a classmate's.

### 1. The Insider and the Audit Trail {#q-insider}

> Question: You found the sleeper from a door log and an alibi, not from a login or a confession. Explain why the log narrowed the field but could not, on its own, name a person. What was your second source?

> Question: The sleeper held a legitimate badge and seat for years. What kind of control catches a placed insider that no amount of perimeter security will, and why is it harder to run than a firewall?

> Action: Write a six-line door log for an imaginary site and a minute at which something happened, including one planted badge with an alibi that clears its owner. Swap with a classmate and have them name who was really at the door and why.

### 2. Physical Bypasses {#q-bypass}

> Question: The outer lock fell to a dusted plate and a cracker. Walk through why the dust cut the work so sharply, and name two things a keypad could do to defeat the attack.

> Question: Three different things opened the power room: a clone, a picked locker and a conversation. What does having three routes to one door say about how the bunker was actually secured, versus how it was meant to be?

> Action: Write a short physical-security review of the bunker covering card readers, the keypads, the lockers and one control that would catch a cloned card in use. Map each point to something you did.

### 3. Encoding and Disclosure {#q-disclosure}

> Question: The margin note was Base64, not encrypted. Explain the difference to a non-technical colleague and say what the analyst should have used if she wanted the note kept from the Architect.

> Question: You chose what happened to the database. Lay out the case for securing it, for coordinated disclosure, and for wiping it, and say which you chose and what it cost. Where does the Architect's full-disclosure argument fit, and why did you reject or accept it?

> Action: Pick a real flaw class (for example, a bug in a hospital device). Write a one-page disclosure plan: who you would tell, in what order, with how long before going public, and the single hardest trade-off in your plan.

### 4. People and Choices {#q-choices}

> Question: Did you name anyone as the sleeper, and on what evidence? If you got it wrong, what did it cost, and what would you check first next time?

> Question: You decided what happened to the Architect. What did you weigh, and what did you not know that you would have wanted to? Was the ending you reached the one you set out to reach?

> Action: Write a short debrief of your own run, as if to Agent HaX. State the ending you reached, what happened to the database and to him, whether the sleeper was named, and one thing you would do differently.

### 5. The Servers {#q-servers}

These questions are about the work you did on the three servers. The steps are in the companion sheet; the questions here do not need them.

> Question: You took three hosts, one at a time, across the bunker. Why does taking the monitoring host first make the two behind it easier, and what does that say about how a defender should place a monitoring system?

> Question: Each server you took opened a door or a stage in the raid. Why did the operation need both the physical work and the server work, and what could neither do on its own?

> Action: Write a one-page note for whoever rebuilds this network, listing what each host exposed and the control that would have closed it. Map each point to a flag you submitted.

## Further Reading {#further-reading}

- The companion [VM Technical Steps](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/m10-full-disclosure-vm-technical-steps/) for the work on the three servers.
- Guides for techniques this mission reuses: [RFID Cloning](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/rfid-cloning/), [Lockpicking](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/lockpicking/) and [Encoding and Decoding with CyberChef](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/encoding-and-decoding-with-cyberchef/).
- The Cyber Security Body of Knowledge (CyBOK) chapters on Adversarial Behaviours, Forensics, Authentication, Authorisation and Accountability, the Law and Regulation chapter on disclosure, and the Secure Software Lifecycle chapter.
- For the disclosure debate: coordinated vulnerability disclosure guidance (for example, ISO/IEC 29147 and the CERT/CC guide), and the historical full-disclosure arguments.
