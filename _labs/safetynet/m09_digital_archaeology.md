---
title: "Digital Archaeology (Break Escape Mission 9)"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Play a browser-based after-hours infiltration of a records archive: get in past a night guard, clone a director's keycard and lift her fingerprint while she talks, open a biometric cabinet by comparing prints, crack a reused safe code, decode a Vigenere-keyed archive lock in CyberChef, and decide what you take off a recruiter who offers a name for a price."
overview: |
  The Season 1 finale begins. A courier carried the Architect's order to a records archive in Helena, Montana: burn Helena before the Publication. Tonight the archive's director is feeding a shredder box by box, and the paper that names the man behind ENTROPY is somewhere in her restricted stacks. You have until Task Force Null lands to get in, take the restricted series before it is ash, and follow the paper to the person who signed the order.

  You play Agent 0x00. You slip in after hours, set up a field terminal in the reading room, clone the director's stacks card and lift her print off a rubber stamp while she talks across the counter, open her biometric plan cabinet, crack a safe whose code she reused from a date on her own lease, and decode a Vigenere-locked salvage cage with the shelf marks painted on the wall. A recruiter rings mid-job and offers a codename for the price of a tape deck. The night ends with a confrontation you do not expect and a decision about a vendor notice.

  This sheet gets you started, explains the ideas behind each lock with small worked examples you can check by hand, and has a stage-by-stage set of hints for when you are stuck, from a gentle nudge up to the exact steps. The work on the two servers (the catalogue server and Tomb Beta's server) has its own companion sheet. There are moral choices and more than one ending; the hints help you understand what you hold, not which choice to make.
tags: ["insider-threat", "physical-access", "rfid", "cloning", "fingerprints", "biometrics", "lockpicking", "pin-cracking", "vigenere", "polyalphabetic-cipher", "cyberchef", "social-engineering", "vulnerability-disclosure", "break-escape"]
categories: ["safetynet"]
type: ["game-based-learning", "lab-sheet"]
difficulty: "advanced"
source: "https://github.com/cliffe/BreakEscape/blob/main/scenarios/m09_digital_archaeology/labsheet.md"
cybok:
  - ka: "AAA"
    topic: "Authentication"
    keywords: ["User authentication", "Biometrics", "Smart cards", "Personal identification number and memorable information"]
  - ka: "AB"
    topic: "Characterisation of Adversaries"
    keywords: ["The insider threat", "Social engineering"]
  - ka: "C"
    topic: "Symmetric Cryptography"
    keywords: ["Ciphers - polyalphabetic", "Encoding"]
  - ka: "LR"
    topic: "Ethics"
    keywords: ["Vulnerability testing", "Vulnerability disclosure", "Public disclosure"]
---

## Purpose {#purpose}

By the end of this lab you should be able to:

- explain why an archive is a security problem, and why physical access after hours undoes a careful access policy
- describe how a keycard with custom keys is cloned, and how a fingerprint left on an everyday object defeats a biometric lock
- compare two fingerprints by pattern and by the small marks around the core, and say why a thumb is a worse secret than a PIN
- find a PIN that a person reused from a date in their own paperwork, and say what a better policy would ask for
- recognise a Vigenere cipher, decode one by hand and in CyberChef with a key you have to find, and say why a polyalphabetic cipher is harder to break than a single-shift one
- weigh a sale offered against the evidence, and a decision about disclosing a flaw, with the cost in view

The game teaches by doing. The questions are in this sheet, after the game.

## How to Use This Sheet {#how-to-use}

1. Read **Getting Started** and do the short CyberChef warm-up. It takes a few minutes and saves you time at the salvage cage later.
2. Play. Skim **Concepts** as you reach each new idea, or come back to it when something in the game leaves you wanting more.
3. If you get stuck, go to **Stuck? Hints, Stage by Stage** and find the stage you are on. Each stage has a hint you can read straight away, then a stronger nudge and the exact steps hidden behind "Show" buttons. Open one at a time, and go back to the game after each.
4. After the game, work through **After the Game: Questions and Exercises**.

The work on the two servers is in the linked companion sheet, [VM Technical Steps](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/m09-digital-archaeology-vm-technical-steps/), so you can play the rest of the mission without server spoilers and tackle it when you want.

> Note: The codes and passwords in the archive are the same every game, but you still work them out from clues in the building. This sheet says where each clue is and what shape the answer takes, never what it reads. The evidence you pull from the servers is generated for your game, and the companion sheet covers how to get it.

## Getting Started {#getting-started}

You are Agent 0x00, a SAFETYNET field agent. SAFETYNET read ENTROPY's order to burn this archive and let it go on; your handler, Agent HaX, had the Architect's name the night two agents died and said nothing. Tonight you are inside Mountain States Records & Retention in Helena while the director, Margaret Sorensen, feeds a shredder. Task Force Null is in the air behind you, and Director Netherton wants a name he can say in court.

You do not need any prior knowledge before you start. The Vigenere cipher is taught in the warm-up and in **Concepts**; everything else builds on skills from earlier missions.

1. \==action: Start the Break Escape mission **Digital Archaeology**==.
2. \==action: Watch the opening briefing, then close it==. Agent HaX rings the dock a couple of seconds later.
3. \==action: Go north through the shutter into the open stacks==, or pick the dock office door to the west and go through the front desk.
4. \==action: Open your phone whenever you are unsure==. Agent HaX offers hints and field guides as you go.

The mission takes about 75 to 85 minutes. Your progress, evidence and unlocked rooms are kept between sessions.

![The loading dock at the start, with your agent standing among the pallets]({{ site.baseurl }}/assets/images/safetynet/m09_digital_archaeology/00-starting-room.png)

> Note: A clock shows in the corner. It is story time in UTC, not a countdown you can run out of. It starts at 04:45 (that is 22:45 at night in Helena, Montana) and moves with the night, then jumps to 10:00 at the debrief. Phone messages are stamped with it. Nothing fails if you take your time.

> Tip: A natural stopping point for a 60-minute class is once you have opened the director's office and hold the tape store card. The salvage cage, the confrontation and the debrief make a good second session.

### How to Play {#how-to-play}

You move with the arrow keys or by clicking. Click objects, people and doors to interact. Items you take go to the inventory bar at the bottom of the screen; documents you pick up open as readable pages you can reopen at any time.

Your kit at the start is the phone (Agent HaX), a **Lock Pick Kit**, an **RFID Cloner**, a **Fingerprint Kit**, a **PIN Cracker (Kowalczyk's)** and a **CyberChef Workstation** in the reading room.

The archive is one floor. The loading dock is the start. The open stacks are north; the front desk is west of the dock. The reading room is past the stacks. Beyond a card-locked door lie the restricted stacks, and off them the restricted cage, the director's office, and the tape store, with the salvage cage past the tape store.

Agent HaX's phone is your help system. Open it and you will see options that appear only once you have reached the thing they explain:

- Contextual hints, which read your progress and answer from where you are in the night, so asking again later gives a different answer.
- Field guides, the in-universe lab sheets. Choose the field-guide option and pick the one you want. A guide appears on that menu only once you have reached the challenge it covers. This mission hands out guides for the archive codes and for the server work.

> Tip: Press **Q** to switch between your fists and your open hand. You need the open hand to use things. If you strike someone by accident, HaX texts you how to put the fists away.

> Tip: The locks want exact values. A password is case-sensitive, with no extra spaces. The safe is six digits. Copy decoded text with the mouse rather than retyping it.

> Warning: Several people can be knocked out: the clerk, the night guard, the contractor and the director herself. None of it is needed, and each has a cost that shows up in the credits. The stages below note where a quiet route exists.

### Warm-up: Your First CyberChef Vigenere Decode {#warm-up}

Do this once you are at the **CyberChef Workstation** in the reading room. It uses made-up data, not anything from the game.

![The CyberChef workstation with an empty recipe, input and output]({{ site.baseurl }}/assets/images/safetynet/m09_digital_archaeology/11-cyberchef-workstation-blank.png)

1. \==action: Open CyberChef and clear the recipe== if anything is in it.
2. \==action: Type `LXFOPVEFRNHR` into **Input**==.
3. \==action: Search for `vigen` and double-click **Vigenère Decode**==.
4. \==action: Set the **Key** to `LEMON`==. The output reads `ATTACKATDAWN`.
5. \==action: Change the key to `MELON` and watch the output turn to gibberish==. The wrong key gives wrong letters, not an error. The key has to be exact.

You have just run the operation the salvage cage needs. The real coded line and its key come from inside the game, and **Concepts** explains how the cipher works.

## Concepts {#concepts}

You do not need to read all of this before you play. Use it when you reach each idea, and again when you answer the questions afterwards.

### The Archive and Physical Access {#physical}

An archive is a building full of other people's secrets, and it is defended mostly by a locked front door and the hour. After hours, with the staff gone and one director inside, the controls that matter are the card readers, the safe and the cabinets, and every one of them has a human habit behind it. A good policy on paper fails when a card can be read across a counter, a thumb is left on a stamp, and a safe code is a date the owner writes on everything else.

This mission is an insider's building run by an insider. Margaret Sorensen is burning eleven years of placements on the Architect's order. You are inside to take the paper before it is ash, so speed and quiet both matter, and the quiet routes are worth finding.

### Weak Authentication and Reused Secrets {#codes}

A lock is only as strong as the way its secret is kept. Several in this building are kept badly.

| Lock in the building | What it wants | Shape of the answer |
| --- | --- | --- |
| Restricted cage gate | An RFID card | A cloned keycard, or a maintenance code |
| Plan cabinet | A fingerprint | The director's print, lifted and matched |
| Director's floor safe | A PIN | Six digits |
| Salvage cage keypad | A password | Text, decoded from a coded line and a key |
| Harwick & Lowe dead-files box (optional) | A password | A reference printed on the record inside the bay |

The safe is the clearest lesson. The policy says choose your own code, so the director chose a date that means something to her, and that date is printed on her own lease and rent paperwork in the same room. A PIN that is also written somewhere public is not a secret. A better policy would not let a person pick a date, and would not keep the paperwork that gives it away in the same room as the safe.

> Question: The safe code is a date. Name two other kinds of number a person reuses as a PIN, and say how an attacker would find each one without the person's help.

### RFID Cloning: Simple Cards and Custom Keys {#rfid}

A keycard is a small chip that answers a reader at short range. The cloner has three steps: **read** the card, **crack** its keys if they are not defaults, then **emulate** the saved card at a reader.

Some cards are simple (an EM4100 badge answers with a fixed number and copies in one read). Others are harder: a MIFARE Classic with custom keys makes the cloner run a recovery attack before it can read it, which takes about half a minute. The cloner is passive until you start it, so the trick is to stand close to the owner and keep them there, in conversation, until it finishes. A card anyone can read from an arm's length away is a key you have handed out.

When the keys are cracked, press **Save**. The read is not kept until you do. To use the copy, open the cloner at the reader, choose the card from **Saved**, and emulate it.

> Question: The director's card is cloned while she talks to you across a counter. What would a reader have to check, besides the card, for the clone to fail, and what would that cost the staff who badge in every day?

### Fingerprints: Lifting and Matching {#fingerprints}

A fingerprint reader trusts a thumb. A thumb is left on everything the owner touches, so a print lock is only as private as the owner's habits. In this building the director fitted a fingerprint reader to her own plan cabinet, and she stamps documents all night with a rubber stamp she holds in the same hand.

Lifting a print has two parts. First you **dust** a surface: powder sticks to the oils a finger leaves, and a brush clears the rest. A textured handle takes powder differently from smooth glass, so the game tells you the surface and which lifter suits it. Then you **compare** the lift against candidate cards to decide whose it is.

A comparison goes in two passes, the way a real examiner works:

1. **Class first.** The overall pattern is a **loop**, a **whorl** or an **arch**. A loop also opens to one side. If the lift is a whorl and a card is a loop, they are not the same finger, and you can stop there.
2. **Then the small marks.** Around the centre of the print are **minutiae**: places where a ridge ends, and places where one ridge forks into two. Their type and their position relative to the centre have to line up. One mark of the right type in the wrong place, or missing, rules a card out.

In the game the lift and each candidate card are drawn with the same markers, so you compare them by eye:

- a green cross marks the **core**, the centre you measure everything from
- triangles mark the **deltas**, the points where ridge flows meet
- a red ring marks a **ridge ending**
- a red square marks a **fork** (a bifurcation)

Use **View large** on a card to see the markers close up, and press **V** to cycle the cards. Pick the one that agrees on pattern class first and then on every mark. If you pick wrong, the game names the feature that differs, so read that and look again.

![The fingerprint kit at the compare step, asking which pattern your lift shows]({{ site.baseurl }}/assets/images/safetynet/m09_digital_archaeology/06-fingerprint-compare.png)

```
Lift:        whorl; green cross at the core
             red square (a fork) above and to the right of the core
             red ring (a ridge ending) below the core

Card A:      loop opening left         -> wrong class, rule out
Card B:      whorl; a red ring above the core, no red square
                                       -> the fork is missing, rule out
Card C:      whorl; red square above-right, red ring below
                                       -> class and both marks agree
```

The lesson HaX gives you says it best: the owner can change a PIN tomorrow, but she cannot change her thumb, and she has left it on every stamp she owns.

> Question: A print lock and a PIN lock both failed in this building. Which is worse to rely on once an attacker has one clean lift, and why can the owner not simply reset the one that leaked?

### The Vigenere Cipher {#vigenere}

Earlier missions used ROT13, a Caesar cipher that shifts every letter by the same amount. A single shift is easy to break: there are only 25 of them, and the letter frequencies give it away. The **Vigenere cipher** is **polyalphabetic**: it uses a keyword, and each letter of the message is shifted by a different amount, set by the matching letter of the key. The key repeats across the message.

Each letter of the key gives a shift: `A` shifts by 0, `B` by 1, `C` by 2, and so on up to `Z` by 25. You line the key up under the message, repeating it, and shift each letter of the message by the key letter above it.

```
message  A T T A C K A T D A W N
key      L E M O N L E M O N L E
shift    11 4 12 14 13 11 4 12 14 13 11 4
cipher   L X F O P V E F R N H R
```

So `ATTACK AT DAWN` with the key `LEMON` becomes `LXFOPVEFRNHR`. To decode, you do the reverse: subtract the key letter's shift from each cipher letter. CyberChef's **Vigenère Decode** does this for you once you give it the key.

Because the shift changes along the message, the same plaintext letter can come out as different cipher letters, so a simple frequency count no longer reads it. That is why a polyalphabetic cipher is harder than a Caesar shift. It still has no real secret beyond the key, so once you find the key it falls open.

| What you see | What it probably is | What to try |
| --- | --- | --- |
| Letters only, no spaces, reads as nonsense, normal-looking letter mix | A substitution or polyalphabetic cipher with a key | Look for a key nearby, then Vigenère Decode |
| Scrambled letters that keep spaces and word shapes | A Caesar shift such as ROT13 | ROT13 |
| One block of mixed-case letters, digits, `+`/`/`, maybe `=` | Base64 | From Base64 |

In the game the coded line comes from your handler, and the key is painted on the wall of the tape store as "shelf marks". You read the key off the wall, type the coded line into CyberChef, set the key, and the decoded word is what the salvage cage keypad wants.

> Question: You have a Vigenere ciphertext and you try the key `BONE`. The output is readable for the first four letters and then turns to nonsense. What does that tell you about the key, and what would you try next?

### Matching a Hand {#handwriting}

Two documents in the restricted area carry the same handwriting: an old training notebook that HaX scanned, and a candidate assessment from the plan cabinet. Comparing them is not a cipher, it is a reading: the same hand on both pages ties the person who wrote the notebook to the person assessed in the file. The game asks you to hold them side by side and say whether it is the same hand. This is how an investigator ties a document to a person when there is no signature to trust.

### The Choices and Their Cost {#choices}

This mission puts several decisions in front of you, and it tells you the cost before you answer. A recruiter offers a codename in exchange for letting a tape deck wipe; you can take the name, take it and double-cross her, refuse and pull her file, or refuse and take the recordings instead. Later you answer your handler's confession, and decide whether to send a vendor a notice about a flaw that four hundred sites still run. None of these is scored right or wrong. The hints help you understand what each choice holds; they do not pick for you.

## Stuck? Hints, Stage by Stage {#hints}

Find the stage you are on. The stages are in the order most players meet them, and the game lets you do several in a different order. Read the hint, then go back and try. If you are still stuck, open **Nudge**. Open **Steps** or **Recipe** last.

> Tip: Before you open any hint, ask yourself three questions. What is this clue made of, and what does its own description say? What shape does the lock or the character want: a code, a card, a print, a password, a reading of the evidence? And have I actually looked everywhere the last room offered?

### Before the First Lock: Getting Inside {#hints-start}

**Where:** the loading dock, then the open stacks or the front desk. **Goal:** get in and reach the reading room.

> Hint: There are two ways in. The shutter to the north is already open. The dock office to the west is locked, and leads to the front desk and the night clerk.

![Cody Old Coyote, the night guard, stopping you in the open stacks with his torch on]({{ site.baseurl }}/assets/images/safetynet/m09_digital_archaeology/01-open-stacks-guard.png)

![Noor Haddad at the front desk, with three ways to answer her first question]({{ site.baseurl }}/assets/images/safetynet/m09_digital_archaeology/02-noor-front-desk.png)

<details markdown="1">
<summary>Nudge</summary>

The quick way is north through the open shutter into the open stacks. The night guard, Cody Old Coyote, challenges you on sight; any cover story passes, and telling him the truth sends him off and is remembered kindly later.

The other way is west: pick the dock office door (an easy key lock, or use the guard's key ring), go through the front desk, and talk to the clerk, Noor Haddad. She hands over a staff card for the card-locked door to the reading room. Either route reaches the reading room.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Go north through the shutter into the open stacks==, and give the guard any answer when he challenges you.
2. \==action: Carry on into the reading room==.
3. \==action: Or, from the dock, pick the west door and talk to Noor Haddad at the front desk==, take her staff card, and use it on the card door to the reading room.

</details>

### The Reading Room and the Drop Terminal {#hints-drop}

**Where:** the reading room. **Goal:** set up the field laptop and submit the catalogue flag at the drop terminal. This is where the restricted stacks open.

> Hint: Set the field laptop up first. The drop terminal takes the flags from the catalogue server, and the first one opens the door north.

![The reading room, with the field laptop on the desk and the drop terminal against the wall]({{ site.baseurl }}/assets/images/safetynet/m09_digital_archaeology/03-reading-room.png)

<details markdown="1">
<summary>Steps</summary>

1. \==action: Click the **Field Laptop** in the reading room== to set up the drop terminal. HaX offers the catalogue field guide.
2. \==action: Submit the catalogue flag at the **SAFETYNET Drop Terminal**==. The server work for the flag is in the companion sheet.
3. \==action: When the catalogue flag goes in, HaX opens the restricted stacks to the north==. Read the drop terminal screen: it ends with a coded line you will need at the salvage cage.

</details>

> Note: How to get the catalogue and ledger flags off the server is its own sheet, so you can play the rest spoiler-free. Open [VM Technical Steps](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/m09-digital-archaeology-vm-technical-steps/) when you want the server hints.

> Tip: The **Field Laptop** in the reading room is the thing to click to set the drop terminal up. If you go to the terminal first, the game nudges you back to the laptop after a moment.

### The Hatch: Clone the Card and Lift the Print {#hints-hatch}

**Where:** the restricted stacks. **Goal:** talk to the director across the hatch, clone her card, choose what to save from the bins, and lift her print.

> Hint: The director is burning boxes on the far side of a counter. Keep her talking while the cloner reads her card. Her card has custom keys, so give it time.

![Margaret Sorensen at the hatch, offering a chair and a conversation]({{ site.baseurl }}/assets/images/safetynet/m09_digital_archaeology/04-sorensen-hatch.png)

![The RFID cloner reading her stacks card, with no keys recovered yet]({{ site.baseurl }}/assets/images/safetynet/m09_digital_archaeology/05-rfid-cloner-read.png)

<details markdown="1">
<summary>Nudge: the card</summary>

Talk to Margaret Sorensen at the hatch. While she talks, the cloner reads her stacks card. It is a MIFARE Classic with custom keys, so the cloner runs a recovery attack first, about half a minute, and you have to keep her there. When the keys crack, press **Save**.

HaX's field guide and the Concepts section on RFID both cover read, crack and emulate.

**Learn it:** ==action: Watch the cloner's three steps go by== (read, crack, emulate) and note which step is slow. The slow one is the custom-keys crack.

</details>

<details markdown="1">
<summary>Nudge: the bins and the print</summary>

At the hatch she is feeding a shredder, and you can pull one thing from the bins before it goes in. That is a choice with a cost, and the game tells you the cost: an asset's file, a set of letters, or a copy cleared from a locker. Pick the one you want to save.

Her **Rubber Stamp** sits on the shelf by the hatch. Dust it with the Fingerprint Kit and lift her print. The handle is textured, so the magnetic wand suits it. You use the print at the cage's plan cabinet.

**Learn it:** ==action: Dust the stamp and look at the lift== before you move on. Note the pattern (loop, whorl or arch) so you can recognise it at the cabinet.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Talk to Margaret Sorensen at the hatch== and keep the conversation going while the cloner reads her card; press **Save** when it finishes.
2. \==action: Choose which item to pull from the bins== when she offers it.
3. \==action: Dust the **Rubber Stamp** on the shelf and lift the print==.

</details>

> Warning: Knocking the director out skips the conversation, but her shredder runs on, and the credits record it. The clone and the print are both reachable without a fight.

### The Restricted Cage and the Plan Cabinet {#hints-cage}

**Where:** the restricted cage, east of the restricted stacks. **Lock:** the gate takes the cloned card; the plan cabinet takes a fingerprint. **Goal:** open the cabinet and take Nightshade's file.


> Hint: The gate wants the card you just cloned. The cabinet at the back wants a thumb, and you are carrying the director's.

![The restricted cage, with Sorensen, the shredder and the plan cabinet at the back]({{ site.baseurl }}/assets/images/safetynet/m09_digital_archaeology/07-restricted-cage.png)

<details markdown="1">
<summary>Nudge</summary>

At the cage gate, open the cloner, choose the director's stacks card from **Saved**, and emulate it. Inside, the **Plan Cabinet** has a fingerprint reader. Use the lifted print on it. The reader shows your lift beside candidate cards, all drawn with the same markers (green cross core, triangle deltas, a red ring for a ridge ending, a red square for a fork). Confirm which is the director's: match the pattern class first, then the marks around the core, pressing **V** to cycle the cards and **View large** to compare them closely. A wrong pick names the feature that differs, so read it and look again.

Take the **Candidate Assessment, Intake 2011** from the cabinet. This is Nightshade's file.

**Learn it:** ==action: Rule out one candidate card by its pattern alone== before you look at the marks. A loop and a whorl are never the same finger.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Emulate the cloned card at the cage gate== and go in.
2. \==action: Use the lifted print on the **Plan Cabinet**== and confirm it is the director's.
3. \==action: Take the **Candidate Assessment, Intake 2011**==.

</details>

> Warning: If Victoria's people are helping you from an earlier mission, a maintenance code can open the gate instead of the clone. Either route gets you in.

### Match the Hand {#hints-hand}

**Where:** the reading room, with HaX's case file. **Goal:** confirm the notebook and the file are the same hand.

> Hint: HaX scanned an old training notebook. The file you just took is assessed in the same hand. Hold them together.

<details markdown="1">
<summary>Steps</summary>

1. \==action: Read the **Training Notebook (scan)** in the reading room==.
2. \==action: Open HaX's phone and choose the option about the hand on the file==, then confirm it is the same hand.

</details>

### The Ledger Flag and the Recruiter's Call {#hints-recruiter}

**Where:** the drop terminal, then wherever you are when the call comes. **Goal:** submit the ledger flag, then answer the recruiter.

> Hint: The second flag is the Initiative's ledger. Once it is in, a recruiter rings, and the call is forced. She offers a name for a price.

<details markdown="1">
<summary>Nudge</summary>

Submit the ledger flag at the drop terminal (the server work is in the companion). Soon after, the recruiter rings on a voiced, forced call. She offers WREN's codename in exchange for letting a tape deck wipe. You have four answers, and the game states the cost of each before you commit:

- take the name and let the deck wipe
- take the name and pull her file anyway (a double-cross)
- refuse, and pull her file
- refuse, and pull the Alpha recordings instead

None is scored right or wrong. Answer, then make the deck choice she asks for. The office opens after the call.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Submit the ledger flag at the drop terminal==.
2. \==action: Answer the recruiter's call==, then make the deck choice.

</details>

> Warning: The call is forced and cannot be put off. Read the cost line before you pick; it is the clearest statement of what each answer does.

### The Director's Office and the Safe {#hints-safe}

**Where:** the director's office, west of the restricted stacks. **Lock:** a six-digit floor safe. **Goal:** open the safe for the Reading and the tape store card.

> Hint: The safe is six digits. The director chose a date that means something to her, and she has written that date on her own paperwork in this room.

![The director's office, with the floor safe in the corner]({{ site.baseurl }}/assets/images/safetynet/m09_digital_archaeology/08-directors-office-safe.png)

![The floor safe keypad with the PIN cracker fitted and no guesses yet]({{ site.baseurl }}/assets/images/safetynet/m09_digital_archaeology/09-safe-pin-keypad.png)

<details markdown="1">
<summary>Nudge</summary>

Read the **Rent Ledger** and the **Lease Abstract and Construction File** on the desk. Both carry the same date in two forms: the ledger header and the lease's written-out date. The safe wants that date as six digits. If you would rather not hunt for it, the **PIN Cracker (Kowalczyk's)** opens the safe by force.

Inside are the **Reading** (several pages), the **Key Card, Tape Store**, and the master destruction schedule. Take the card; you need it for the tape room.

**Learn it:** ==action: Write the date from the lease out as six digits== before you try the safe. Decide whether it is day, month, year or month, day, year from how the ledger header is written.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Read the **Rent Ledger** and the **Lease Abstract and Construction File**== for the date.
2. \==action: Enter the date as six digits on the **Floor Safe**==, or use the PIN Cracker.
3. \==action: Take the **Reading** and the **Key Card, Tape Store**==.

</details>

> Warning: The office door opens for you after the recruiter's call. If it refuses before that, you have not made the deck choice yet.

### The Tape Store and the Salvage Cage {#hints-salvage}

**Where:** the tape store, north of the restricted stacks, then the salvage cage past it. **Lock:** the salvage cage keypad wants a decoded password. **Goal:** decode the coded line with the shelf marks as the key.

> Hint: The drop terminal gave you a coded line. The tape store wall gives you the key. Put them through CyberChef's Vigenère Decode.

![The salvage cage, with the rack server, the two crates and the printouts on the benches]({{ site.baseurl }}/assets/images/safetynet/m09_digital_archaeology/10-salvage-cage.png)

<details markdown="1">
<summary>Nudge</summary>

Use the tape store card to get in. The **Shelf Marks** chart on the wall is the key for the cipher. The coded line is the one HaX sent you at the first flag (it is on the drop terminal screen and in your notes). At the CyberChef Workstation, paste the coded line, add **Vigenère Decode**, and set the key to the word the shelf marks spell. The decoded word opens the salvage cage keypad.

HaX hands out an archive-codes field guide once you reach the keypad.

**Learn it:** ==action: Read the shelf marks and write the key word down== before you touch CyberChef. The key is a word, not the marks themselves.

</details>

<details markdown="1">
<summary>Recipe</summary>

1. \==action: Enter the tape store with the tape store card== and read the **Shelf Marks** for the key.
2. \==action: Paste the coded line from the drop terminal screen into **Input** at the CyberChef Workstation==.
3. \==action: Add **Vigenère Decode** and set the **Key** to the word the shelf marks spell==.
4. \==action: Type the decoded word into the salvage cage keypad==.

</details>

> Warning: A wrong key gives wrong letters, not an error. If the output is gibberish, check the key against the shelf marks letter for letter.

### The Server Work in the Salvage Cage {#hints-tomb-beta}

**Where:** the salvage cage. **Goal:** submit the Tomb Beta owner and control flags at the drop link.

> Hint: The rack in the cage is Tomb Beta's server. The drop link takes its two flags. The server work is in the companion.

<details markdown="1">
<summary>Steps</summary>

1. \==action: Submit the Tomb Beta owner flag at the drop link==.
2. \==action: Submit the Tomb Beta control flag at the drop link==.

</details>

> Note: How to take Tomb Beta's server is in the companion sheet, [VM Technical Steps](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/m09-digital-archaeology-vm-technical-steps/). The owner flag triggers the confrontation below, so do the server work when you are ready for the night to turn.

### The Confrontation and the Notice {#hints-finale}

**Where:** the salvage cage, after the owner flag. **Goal:** hear the name, answer your handler, and decide about the vendor notice. What you choose is your decision; no ending is a failure.

> Hint: When the owner flag goes in, the night turns. Your handler has something to tell you. Hear her out before you answer.

<details markdown="1">
<summary>Nudge</summary>

The owner flag opens the identity scene: HaX confesses that she had the Architect's name the night two agents died. You answer in one of three ways, and none is scored right or wrong. The control flag brings the hour read and the Architect's own call.

You can also decide the vendor notice. Sending it starts a fix for the four hundred sites that run the flaw; holding it keeps the flaw open. HaX's phone carries the choice as "[His notice.]".

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Submit the owner flag and hear the identity scene==, then answer your handler.
2. \==action: Submit the control flag== and listen to the hour read and the call.
3. \==action: Decide the vendor notice on HaX's phone==.

</details>

<details markdown="1">
<summary>Spoiler: the decisions that carry into the finale</summary>

Twelve choices from this night carry into Mission 10: the recruiter's sale, the tape or the recordings you pulled, whether WREN is named or still a shortlist, your answer to the confession, the notice sent or held, the bin you saved, the legacy files, and the Alpha annotations. Each changes who is in the bunker and what is said. None locks you out of finishing.

</details>

> Warning: Once the confrontation starts it plays through. Read anything else you want first.

### The Debrief {#hints-debrief}

**Where:** the loading dock, after the confrontation. **Goal:** report to Netherton.

> Hint: Once the Architect's call ends, HaX can bring you in. The debrief opens from her phone.

<details markdown="1">
<summary>Steps</summary>

1. \==action: Finish anything you still want to read==.
2. \==action: Choose **[Bring me in.]** on HaX's phone==, and report to Netherton.
3. \==action: Watch the credits==, which list what you did and what you left.

</details>

## What the Tools and Locks Are Telling You {#error-messages}

| You see | It usually means |
| --- | --- |
| The cloner will not save | The custom-keys crack has not finished; keep the director talking and wait |
| The cage gate refuses the card | Open the cloner at the reader and emulate the saved stacks card, not a different one |
| The plan cabinet rejects the print | The lift is not the director's; match the pattern first, then the marks, and dust the stamp again if the lift is poor |
| The floor safe stays shut | The six digits are a date from the rent ledger or the lease; check day/month order, or use the PIN Cracker |
| The salvage keypad refuses | The decoded word is wrong; a wrong Vigenère key gives wrong letters, so check the key against the shelf marks |
| The office door refuses | You have not answered the recruiter and made the deck choice yet |
| The drop terminal refuses the Tomb Beta flags | Those two go to the drop link in the salvage cage, not the reading-room terminal |
| The restricted stacks stay shut | The catalogue flag is not in yet; set up the field laptop and submit it at the drop terminal |

## Optional Side Content {#optional}

None of these is needed to finish. Each adds evidence or context.

<details markdown="1">
<summary>The Harwick &amp; Lowe dead-files box</summary>

In the open stacks, a sealed box of dead files has a password lock. The reference it wants is printed on the placement record inside the bay. The record ties two members of Task Force Null to a recruitment agency, which matters in the finale.

</details>

<details markdown="1">
<summary>The Alpha recordings and annotations</summary>

The tape store holds a reel deck of ALPHA recordings and a set of annotation sheets. One is a coded line with its own key (`ALPHA`), decoded the same way as the salvage code. They are the Architect's teaching, in his own voice and hand.

</details>

<details markdown="1">
<summary>The Reading</summary>

The Reading is a multi-page document in the safe: the Architect's own forecast, including a margin bet about an earlier asset. Which page lands hardest depends on choices you made earlier in the season.

</details>

## Try It on the Command Line (Optional) {#command-line}

These short exercises let you practise the Vigenere technique with your own data, not anything from the game. Use any current Linux distribution, or any Python install.

### Encode and decode a Vigenere cipher {#cli-vigenere}

\==action: Encode a short message with a key, then decode it back==:

```python
def vigenere(text, key, decode=False):
    out = []
    ki = 0
    for c in text:
        if c.isalpha():
            shift = ord(key[ki % len(key)].upper()) - 65
            if decode:
                shift = -shift
            out.append(chr((ord(c.upper()) - 65 + shift) % 26 + 65))
            ki += 1
        else:
            out.append(c)
    return ''.join(out)

print(vigenere("ATTACKATDAWN", "LEMON"))            # LXFOPVEFRNHR
print(vigenere("LXFOPVEFRNHR", "LEMON", decode=True))  # ATTACKATDAWN
```

> Question: Change the key to one letter, such as `C`, and encode a sentence. You have just made a Caesar cipher. Why is a one-letter Vigenere key the same as a fixed shift, and what does that tell you about why a longer key is stronger?

## After the Game: Questions and Exercises {#after-the-game}

Work through these after you finish. Use your own run: your choices and your ending may differ from a classmate's.

### 1. Physical Access and Authentication {#q-access}

> Question: You cloned a card, lifted a print and cracked a safe in one building. For each, say what the smallest change would be that stopped you, and what it would cost the people who work there.

> Question: The director fitted a fingerprint reader to her own cabinet and then left her print on a stamp she used all night. Why is a biometric a poor secret for a thing you touch all day, and what is it actually good for?

> Action: Write a half-page access-control review for the archive. Cover card technology, the biometric cabinet, the safe code policy, and one control that would catch a cloned card being used. Map each point to something you did in the game.

### 2. Encoding and Ciphers {#q-ciphers}

> Question: Explain, to a non-technical colleague, the difference between ROT13, Base64 and the Vigenere cipher, and why none of the three is a safe way to keep a secret.

> Question: The salvage code needed both a coded line and a key, kept in different rooms. Why does splitting the two across the building make the lock no stronger against someone who has walked the whole floor, and when would splitting a secret actually help?

> Action: Take a sentence of your own, Vigenere-encode it with a keyword, and give a classmate the ciphertext and the keyword length but not the keyword. See how far they get, and write down what the length alone told them.

### 3. People, Evidence and Choices {#q-choices}

> Question: The recruiter offered a name for a price and told you the cost first. What did you weigh, and what did you not know when you decided?

> Question: You chose whether to send a vendor a notice about a flaw four hundred sites still run. Lay out the case for sending it and the case for holding it, and say which way you went and why.

> Question: Your handler had the Architect's name the night two agents died and said nothing until tonight. What did you say to her, and what would you have needed to know to answer differently?

> Action: Write a short debrief of your own run, as if to Agent HaX. State what you saved from the bins, what you did with the recruiter's offer, whether you sent the notice, and one thing you would do differently.

### 4. The Servers {#q-servers}

These questions are about the work you did on the two servers. The steps are in the companion sheet; the questions here do not need them.

> Question: The catalogue server kept the Initiative's ledger live, and taking it was what named the people on their books. Why is a live, reachable database of secrets a bigger risk than the same data on paper in a cabinet?

> Question: Taking Tomb Beta's server is what told you who owns it. Why did the paper in the building and the evidence on the server each need the other to make the case?

> Action: Write a one-page note for the archive's IT contractor listing what the two servers exposed and the control that would have closed each one. Map each point to a flag you submitted.

## Further Reading {#further-reading}

- The SAFETYNET field guide on archive codes, handed out at the salvage cage, and the companion [VM Technical Steps](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/m09-digital-archaeology-vm-technical-steps/) for the server work.
- Guides for techniques this mission uses: [RFID Cloning](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/rfid-cloning/) and [Lockpicking](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/lockpicking/).
- [Encoding and Decoding with CyberChef](https://cliffe.github.io/HacktivityLabSheets/labs/safetynet/encoding-and-decoding-with-cyberchef/), and the CyberChef Vigenère Decode operation.
- The Cyber Security Body of Knowledge (CyBOK) chapters on Authentication, Authorisation and Accountability, Adversarial Behaviours, Cryptography, and the Law and Regulation chapter on disclosure.
