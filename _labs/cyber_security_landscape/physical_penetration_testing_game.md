---
title: "Physical Penetration Testing (Break Escape)"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Play a browser-based engagement as a penetration tester at Tarnside Assurance on an authorised physical test of a small finance firm, Ledgerwell Ltd: read the rules of engagement, then show how a hardware keylogger, a dropped BadUSB, a held door, a picked cupboard, a pocket rogue access point and a network drop box each reach a little further, and what one captured password opens once you are inside. Report what the engagement showed. All simulated, no virtual machine."
overview: |
  Ledgerwell Ltd has already had Tarnside Assurance test its staff by email. This follow-on engagement puts physical entry in scope: you walk the floor as the tester, with a letter of authority and a condition from the client that nobody gets named and shamed. You plant a hardware keylogger on a staff PC, drop a booby-trapped USB for someone to find, tailgate through a badge-only door, pick a cupboard that was never issued a key, and, if you want the harder optional work, stand up a rogue copy of the staff Wi-Fi and plant a drop box on a live network port. Each step is a finding, and every finding comes with the control that would have stopped it.

  The lab teaches physical and wireless security at the level a defender needs: why a signed scope is what makes any of this lawful, how a second factor at a door or a sign-in breaks a single captured secret, why a shared Wi-Fi key is one secret for the whole office, and how segmentation, port security and a clean-desk habit each close a specific gap. Every outcome in the game is explained, including the ones that fail or are refused. All of it is simulated. No real device captures anything, no network is really joined, and there is no virtual machine to break.

  This sheet gets you started, explains the ideas behind each stage, walks you through the engagement room by room with layered hints for when you are stuck, and ends with reflection questions. No real PINs, passwords or keys are printed: the point is to find them in the game.
tags: ["physical-penetration-testing", "physical-security", "tailgating", "hardware-keylogger", "badusb", "rfid-cloning", "badge-cloning", "lockpicking", "rogue-access-point", "evil-twin", "network-drop-box", "patch-panel", "vlan", "port-security", "password-reuse", "unlocked-session", "clean-desk", "rules-of-engagement", "computer-misuse-act", "wireless-telegraphy-act", "security-awareness", "break-escape", "game-based-learning"]
categories: ["cyber_security_landscape"]
type: ["game-based-learning", "lab-sheet"]
difficulty: "beginner"
source: "https://github.com/cliffe/BreakEscape/tree/main/scenarios/lab_physical_pentest"
cybok:
  - ka: "PLT"
    topic: "Physical Layer and Telecommunications Security"
    keywords: ["Physical security", "Tailgating", "Hardware implants", "Rogue access point"]
  - ka: "HF"
    topic: "Human Factors"
    keywords: ["Physical social engineering", "Security awareness"]
  - ka: "LR"
    topic: "Law and Regulation"
    keywords: ["Computer Misuse Act 1990", "Wireless Telegraphy Act 2006", "Rules of engagement", "Authorisation"]
  - ka: "AAA"
    topic: "Authentication, Authorisation & Accountability"
    keywords: ["Access control", "Badge cloning", "Unlocked sessions"]
---

## Purpose {#purpose}

By the end of this lab you should be able to:

- explain why a physical penetration test has to be authorised in writing first, and what the rules of engagement, the challenge rule and the Computer Misuse Act 1990 have to do with it
- describe the layered access control on a door (a badge plus a PIN) and say why reading the PIN alone never opened it
- explain what a hardware keylogger captures, why a screen lock does not stop it, and what does
- explain why a dropped USB, a malicious charging cable or a QR-code card works: the finder, not the file, is the way in
- describe what cloning a staff badge gets an attacker, and why copying a card in place beats pocketing it
- explain why a cupboard behind a cheap cylinder lock can matter as much as the room it protects
- explain how a rogue access point copies a Wi-Fi network's name, why it needs a person to pick it, and why a shared Wi-Fi key is one secret for the whole office
- describe what a network drop box on a live wall port reaches, and how segmentation, port security, 802.1X and shut unused ports each limit it
- trace how one captured password turns into access to another system through password reuse, and name the controls that break that chain
- turn each finding into a mitigation a small organisation can afford, and justify your choice

The game teaches by doing. The questions are in this sheet, after the game.

## How to Use This Sheet {#how-to-use}

1. Read **Getting Started** and launch the game. You do not need any prior knowledge; the engagement teaches each idea as you reach it.
2. Play. Dip into **Concepts** when you reach a new idea, or come back to it afterwards.
3. If you get stuck, open **Stuck? Hints, Stage by Stage** and find the stage you are on. Each stage has a hint you can read straight away, then a stronger nudge and full steps in collapsed sections headed **Nudge** and **Steps**. Open one at a time, and go back to the game after each. Ruth, your engagement lead, gives the same hints on your in-game phone.
4. After the game, work through **After the Game: Questions and Exercises**.

> Note: This is a training exercise against a fictional company, Ledgerwell Ltd. Everything you do is authorised inside the game's story. Doing any of it to a real organisation without written permission is a criminal offence. The first stage of the game is about exactly that line.

## Getting Started {#getting-started}

You are a penetration tester at Tarnside Assurance. Ledgerwell Ltd, a small finance firm, has already had its staff tested by email, and has now signed off a physical test: can someone walk in off the street and reach the records office and the systems behind it? Gareth Fairbairn, the firm's owner, signed the engagement off and wants to see the gaps for himself. Your engagement lead, Ruth Adeyemi, briefs you in the briefing room and is on your phone whenever you are stuck. The client's one condition carries over from last time: report the gaps, name no individuals.

1. \==action: Start the Break Escape scenario **Physical Penetration Testing**==, and choose an avatar when asked.
2. \==action: Take Ruth's briefing== in the briefing room.
3. \==action: Read the **Rules of Engagement** board== on the briefing-room wall before you touch anything else. It lists every method that is in scope and every thing that is not.
4. \==action: Collect your kit from the briefing-room table== (the **Hardware keylogger** at least), then head east through reception onto the floor.
5. \==action: Open your phone whenever you are unsure==. Ruth gives you a hint for the stage you are on.

A first run takes about 60 to 90 minutes, depending on how much you explore the optional findings. In a 60-minute class, a good stopping point is once the four core beats (keylogger, dropped device, tailgating and the mechanical lock) are done and before you take Ruth's debrief; the debrief closes the engagement, so leave it until you are ready. Your progress is kept between sessions.

### How to Play {#how-to-play}

You move with the arrow keys or by clicking. Click objects, people, doors, PCs and card readers to interact. Items you collect go to the inventory bar at the bottom of the screen; a device is used by clicking it there and choosing what to do (for example **Drop here**, **Put on** or **Plug it in**), or by clicking the thing you want to use it on. The people are voiced, so turn your sound on; every line is also shown as text.

The building runs west to east: the **briefing_room**, then **reception**, the **hall** (the main corridor), and the **open_plan** office. Off the corridor are the **store_room** (a stationery cupboard), **P1** (the post and print room), **P3** (the comms cupboard, with the **P5** server riser above it). Off the open-plan floor are the **secure_area** (the records office, behind the badge door) and **P2** (the staff kitchen), with **P4** (the deeds and archive room) beyond the records office.

> Tip: Captured secrets go to the **Harvested Credentials** tablet in your kit. Whenever the game says it recorded a password or a PIN, that is where you read it. In the report those same values are shown masked; your tablet shows them in full, because it is your evidence.

> Tip: Nearly everything on the floor can be examined. Read a device, a PC or a reader before you use it: the observation text usually tells you what it is for and what would stop it. That is where the defensive lesson lives.

> Tip: Nothing in this game is scored by catching you out, and a refused action is information, not a penalty. A refusal (a door that will not open, a device nobody runs, a clone that is rejected) comes back with the reason, so read it rather than repeating the same move.

> Warning: Stay inside the Rules of Engagement board. Some actions are deliberately out of scope (opening a client deed box, cloning a neighbour's Wi-Fi, knocking a real device off the network yourself). Doing the out-of-scope version is a breach you would note and not repeat, not a tick. The game marks the difference.

### Warm-up: read the scope {#warm-up}

Before you leave the briefing room, do one thing by hand. The Rules of Engagement board sorts every method into in scope and out of scope. Pick three methods you expect to use (say, the keylogger, tailgating and the rogue access point) and, for each, find the single line on the board that authorises it and the matching line under **Out of scope** that limits it. You will meet all three on the floor; knowing where the line is before you cross it is the whole point of the first stage.

## Concepts {#concepts}

You do not need to read all of this before you play. Use it when you reach each idea, and again when you answer the questions afterwards. The examples use made-up values so you can follow the reasoning without it giving anything away in the game.

### Authorisation: the line between a test and a crime {#authorisation}

Walking into an office and plugging a device into its network is a criminal offence unless the organisation has agreed to it in writing first. The **Computer Misuse Act 1990** makes unauthorised access to a computer an offence, and signing in with someone else's password is exactly that unless the system's owner has agreed. A signed **scope**, the rules of engagement, is what makes a physical penetration test lawful. It normally covers:

- which rooms, systems and methods are in scope, and what is out of scope;
- who the point of contact is and how to reach them;
- what you do when challenged, and what you do if something goes wrong.

Ledgerwell's board goes further than many, because the client wants to see the consequences: a captured password may be used to sign in to Ledgerwell's own PCs as that member of staff. That line is on the board on purpose. It stops at Ledgerwell's own systems: a saved password for the finance portal, webmail or the bank is out of scope, because those suppliers signed nothing. Your work is only as lawful as the signature behind it.

Two laws sit behind the wireless stage. Jamming radio is an offence under the **Wireless Telegraphy Act 2006**, and sending forced disconnects can count as interference, so a real test avoids it or works in a shielded lab. The game only simulates the disconnect that knocks a laptop onto the rogue network. Joining a network with a key you were not given permission to use can again be a Computer Misuse Act offence.

A professional engagement also has a challenge rule: if a member of staff stops you, you stop, you do not argue or push past, and you drop the cover and show the letter of authority. A challenge is the control working, so you note it for the report rather than treating it as a failure. The rule that never changes, in Ledgerwell's own words: do not harm the people you test, and never go past what the client signed.

> Question: The engagement is authorised by the company, but the individual members of staff never agreed to be keylogged, cloned or followed through a door. What makes that acceptable, and where would it stop being acceptable?

### Physical access control: badges, PINs and layers {#access-control}

A door like the records door uses two things: a **badge** (something you have) and a **PIN** (something you know). The badge is what opens the door; the PIN alone will not. In practice Ledgerwell's reader treats the PIN as a nominal second step that the badge alone already satisfies, so a cloned badge with no PIN opens the door, and that is itself the weakness. It is why shoulder-surfing the PIN from the ledger shelves is a finding on its own but never opens the door for you. To get through you still need the badge, or someone else's badge read, which is what tailgating borrows.

The lesson cuts both ways. A layer only helps if both parts are really required and really independent. If staff prop the door, lend a badge, or let a stranger walk in on their read, the layers collapse to nothing. Good physical access control is as much about the habits around the door as the reader on it.

> Question: The records door needs a badge and a PIN, yet the engagement gets through it without a badge of your own. Name two separate ways that happens in the game, and say which one a better door policy would stop.

### Hardware keyloggers and inline implants {#keyloggers}

A **hardware keylogger** is a small device that sits inline on the keyboard's own cable or USB port and records every key pressed. It does not touch the operating system, so antivirus does not see it, and it does not need the screen unlocked: it reads the keyboard, not the session. Chris Hampshire locks her screen whenever she leaves her desk, which feels careful, but it does not help here. She types her password every time she comes back and unlocks, and the keylogger records it then.

That is the point worth holding on to. A screen lock protects an unlocked session; it does nothing against a device on the wire. What catches a keylogger is physical: checking the cable run behind the machine and a tamper seal on the keyboard connection. And a **second factor** on the sign-in means a captured password is not enough on its own.

> Question: Locking the screen is normally good advice. Explain why it does not defend against the keylogger, and name the one control that would make Chris's captured password useless to you.

### Unlocked sessions and the clean desk {#clean-desk}

The desk next to Chris's belongs to Melanie Pierce, and it teaches the opposite habit. Melanie steps away for coffee without locking her screen. Anyone who sits down is already her, with no password needed: whatever is saved in the session (her browser's saved logins, for example) is shown to whoever is sitting there, because being signed in is enough. A keylogger took a planted device and a wait; an unlocked screen takes nothing.

The same family of failures is the **clean desk**: an ID badge left on an empty desk, a printout left in the tray, a combination written on a card near the safe. Each is a secret left in the open. The control is a habit (lock the screen every time you stand up, never leave a badge or sensitive paper out) with an automatic policy as the backstop for the day someone forgets.

> Question: Compare the effort it took to get a password out of Chris's locked machine with the effort it took at Melanie's unlocked one. What does that tell you about where a small organisation should spend its first hour of training?

### Dropped devices: BadUSB, lures, cables and QR codes {#dropped-devices}

Leaving a device for someone to find turns the finder into your way in. The game has several, and they work differently:

| Device | What it is | What runs it |
| --- | --- | --- |
| BadUSB (keystroke injector) | A stick that pretends to be a keyboard and types commands the moment it is plugged in | Someone plugs it in |
| Storage USB stick (a lure) | An ordinary-looking stick; the finder opens a file on it to find the owner | A curious double-click on the file |
| Malicious charging cable | A cable with electronics hidden inside; it acts while it charges a phone | Someone charges a device on it |
| QR-code card | A printed code that leads to a look-alike sign-in page | Someone scans it and signs in |

None of these is clever on its own. Each needs a person: Sofia Lord tidies up stray devices, and when she finds the BadUSB she plugs it in to see whose it is, which is the gap. A trained member of staff would hand a found device to IT instead. The defence is **device control** on the endpoints (so an unknown keyboard or stick is blocked), macros off by default, and that habit of handing a found device in rather than plugging it in or scanning it.

> Question: A BadUSB and a found storage stick both start from "someone picked up a device", yet they compromise the machine in different ways. Describe each route, and name one control that stops both.

### Badge cloning {#cloning}

Many access badges are simple RFID cards that broadcast a fixed number when a reader powers them. A low-frequency EM4100 card, a common type, stores a 40-bit identity number, which is ten hexadecimal digits:

```
40 bits / 4 bits per hex digit = 10 hex digits
e.g. a card reads out:  7A 00 1B 2C 9F   (five bytes, made up)
```

A cloner held near the card reads that number and writes a copy that the reader cannot tell from the original, because the card proves nothing beyond the number. In the game you clone Len Okafor's badge by carrying the RFID cloner and chatting to him close up; it reads the badge from your pocket without him noticing, and the copy is then accepted at the records door.

Cloning a card **in place**, where it lies on a desk, beats pocketing it: a card that is taken is missed and cancelled, and then it opens nothing, while a card that never moved is never missed. The control is a smartcard the reader **challenges** (so a copied number is useless), plus staff who never leave a card unattended and a log of who went where.

> Question: Copying Len's badge and pocketing a badge left on a desk both get you a card. Explain why the tester prefers to clone rather than take, and what a challenge-response smartcard changes about the whole attack.

### Mechanical locks and lockpicking {#locks}

A door or cupboard is only as strong as its cylinder and its key policy. The stationery cupboard was never issued a key, so nobody notices it is effectively open to anyone with a lockpick set and a minute. Behind that cheap cylinder sits the door-entry controller that runs the whole badge system, records-door zone included. A weak lock on a store cupboard turns out to protect something that matters.

The lesson is proportion: match the lock to what is behind it, issue and track keys, and do not assume a cupboard nobody thinks about is safe because nobody thinks about it. A high-security cylinder, keys on a register, and the controller moved into a properly secured comms room would each close this gap.

> Question: The cupboard is cheap and the room behind it is low-value stationery, yet picking it is one of the engagement's more serious findings. Explain why, and what you would change first.

### Rogue access points and shared Wi-Fi keys {#rogue-ap}

An **evil twin** is a rogue access point that broadcasts a copy of a real network's name. Against WPA2 with a shared key it cannot complete the real handshake, so the copy is an **open** network, and a laptop with a saved profile does not join an open copy on its own. The attack needs a person: their device is knocked off the real network (simulated here), they see the familiar name, pick it, and a captive portal asks for something.

The game's pocket rogue AP, hidden in a reception plant, offers two portal templates, and you choose which to show:

- a **Wi-Fi key page** ("the router has been updated, enter the Wi-Fi key to reconnect"), which harvests the shared staff Wi-Fi key;
- a **staff sign-in page** ("sign in with your Ledgerwell account"), which harvests one person's staff password.

Both are a tell a defender can teach: a corporate network never asks for its Wi-Fi key on a web page, and a network with a shared key never needs an account to connect. The two harvests differ in what they open. The shared key is one secret for the whole office; once harvested it is everyone's way in, and because Ledgerwell's staff Wi-Fi is the office LAN, that key reaches the internal machines. The password is one person's identity: it opens what that account opens and is logged under their name. The real defences are **WPA2/WPA3-Enterprise (802.1X)** with certificate validation (no shared key to phish and no twin to pass as real), protected management frames to stop forged disconnects, staff Wi-Fi segmented from the office LAN, and a second factor on every sign-in.

> Question: The same rogue box can ask for a Wi-Fi key or a staff password. For each, say what an attacker gains and which single control would have made the harvest worthless.

### Network drop boxes, patch panels and segmentation {#drop-box}

A **network drop box** is a small computer an attacker plants on a live wall port or patch-panel socket. It joins whatever network that port is patched to and calls home over its own mobile modem, so its traffic never crosses the office firewall and **egress filtering cannot see it**. From the briefing room, far from the building, you can then open the box's view of the office network and list the machines that answer, the door controller among them.

A port is only as useful as the VLAN it is patched to. The comms cupboard's patch panel is labelled by VLAN, which is free reconnaissance: a **data** port reaches the office machines, while a **voice** port reaches only the phones and a **guest** port reaches nothing worth having. Segmentation works when it is done: the wrong VLAN is a real foothold onto the wrong things. A **managed** port refuses an unknown device outright, which is port security and 802.1X doing their job. The defences stack up: disable unused ports, require known addresses (port security) or device authentication (802.1X), lock comms cabinets, and look for devices that should not be there.

> Question: The drop box sidesteps the office firewall entirely by calling home over 4G. Explain why that makes physical access control and port security matter more than the firewall here, and name the control that stops the box getting a network to look at in the first place.

### Password reuse: one secret, many doors {#reuse}

The findings join up through a habit almost everyone has. Chris's front-of-house account also administers the badge system, so her captured password, reached through the drop box or over the staff Wi-Fi, signs in to the door controller's admin page. Two small gaps (a live port and one password, or one shared Wi-Fi key and one password) make one large one. A single captured credential is rarely one account; it is every account and system that credential opens. The controls that break the chain are unique passwords (so one capture opens one thing) and a **second factor** on every sign-in, especially for anything that administers access.

> Question: Chris's password was captured at a keyboard but ended up opening the door controller. Name the point in that chain where reuse did the damage, and one control for the person and one for the organisation that each break it.

### Turning findings into fixes {#defending}

Every beat in the game ends with a control, and they fall into a few kinds. Match the control to the gap:

- A gap where **a secret sits in the open** (an unlocked screen, a badge on a desk, a combination on a card) is a habit-and-backstop gap: train the habit, add an automatic policy as the backstop.
- A gap where **one secret opens many things** is a reuse gap: unique credentials and a second factor.
- A gap where **an unknown device gets onto the network or the keyboard** is a control-the-endpoint gap: device control, port security, 802.1X, disabled unused ports.
- A gap where **a physical layer is bypassed** (a propped door, a tailgate, a cheap cylinder, a cloned card) is a physical-control gap: self-closers and door-held alarms, challenge-response smartcards, proportionate locks, and staff who do not let a stranger in on their read.

Be wary of controls that sound sensible but miss the point: a screen lock against a keylogger, a firewall against a 4G drop box, a sterner reminder against a service-desk pretext. And blaming staff as careless hides the control gap and stops people reporting, which removes the best early warning a defender has.

> Question: Ledgerwell can afford one fix this year. Pick it, and say what your choice says about where the real weakness is. Name one fix from the list you would not spend the money on, and why.

## Stuck? Hints, Stage by Stage {#hints}

Find the stage you are on. Read the hint, then go back and try. If you are still stuck, open **Nudge**. Open **Steps** last. Ruth gives the same hints on your phone, one stage at a time.

> Tip: Before you open any hint, ask yourself three questions. What layer or check is this door, device or person relying on? What do I already hold that would get past it? And what did the thing's own description tell me when I examined it?

### Before You Start: Getting It in Writing {#hints-authorise}

**Where:** the briefing room, at the start. **Goal:** take Ruth's briefing, read the Rules of Engagement board, and collect your kit.

> Hint: Nothing you do is lawful until you have read the scope. Take the briefing, read the board, and pick your kit up off the table before you leave.

<details markdown="1">
<summary>Steps</summary>

1. \==action: Talk to Ruth== and hear the briefing.
2. \==action: Read the **Rules of Engagement** board== on the wall. It lists every in-scope method and every out-of-scope limit; the warm-up above asks you to match three of them.
3. \==action: Collect your kit from the table==: the **Hardware keylogger** at least, and the rest of the devices while you are there (the **Lockpick set**, **BadUSB**, **Storage USB stick**, **RFID cloner**, **Malicious charging cable**, **QR-code card**, **Network drop box**, **Pocket rogue AP**, **Visitor lanyard**, courier hi-vis and the **Harvested Credentials** tablet).
4. \==action: Head east through reception onto the floor==.

</details>

> Warning: The floor aims stay locked until the authorise aim is done. If a device seems to do nothing, check you have taken the briefing and read the board.

### The Hardware Keylogger {#hints-keylogger}

**Where:** the open-plan floor, at **Chris's PC** (staff_pc). **Goal:** plant the keylogger, capture Chris's password when she unlocks, then use it at the **Hot desk PC**.

> Hint: Chris locks her screen every time she goes for coffee, so you cannot use her session. A keylogger does not need her session: it reads the keyboard. Plant it while she is away, then wait for her to come back and type.

<details markdown="1">
<summary>Nudge: planting and capturing</summary>

Watch for the coffee cup over Chris's head: that means she has stepped away. Plant the **Hardware keylogger** behind **Chris's PC** then. The capture does not happen on planting; it happens when she returns and unlocks her screen (the padlock on the screen clears). Read the planted keylogger, or your **Harvested Credentials** tablet, once she is back.

**Learn it:** ==action: Before you plant it, read the keylogger's own description== and note why locking the screen will not stop it.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Wait for the coffee cup over Chris's head==, then \==action: plant the keylogger behind **Chris's PC**==.
2. \==action: Do something else for a moment, then come back when Chris has returned and unlocked her screen== (the padlock clears).
3. \==action: Read the captured password on the **Harvested Credentials** tablet==.
4. \==action: Sign in as Chris at the **Hot desk PC**==, the spare desk below Melanie's, and see what her account reaches.

</details>

> Warning: While Chris's screen shows the padlock, you cannot capture anything yet. The keylogger records at the moment she types her password to unlock, so you have to wait for her to come back.

### The Rogue Device Drop {#hints-usb}

**Where:** the open-plan floor. **Goal:** drop the BadUSB and watch what Sofia Lord does with it.

> Hint: The test is not whether you can drop a device, it is what a member of staff does when they find one. Sofia tidies up stray devices, one at a time, when she is free. Drop it and get on with something else.

<details markdown="1">
<summary>Nudge</summary>

Click the **BadUSB (keystroke injector)** in your inventory and choose **Drop here** anywhere on the open-plan floor, near Sofia's desk (below Chris's). Sofia takes dropped devices when she is free, so leave it and do another beat. She will plug the BadUSB in to see whose it is, and a remote session lands in your inventory: that is the foothold, and it is what the finding needs.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Click the **BadUSB** in your inventory and choose **Drop here**== on the open-plan floor.
2. \==action: Go and do another beat== while Sofia gets to it.
3. \==action: Come back and read what happened==: Sofia plugs the BadUSB in, so a foothold (a remote session) lands in your inventory.

</details>

> Note: The **Storage USB stick** is a separate optional beat, a found-media lure: someone opens a file on it to find the owner. The BadUSB types commands the moment it is plugged in. See [Optional findings](#optional).

### Tailgating the Records Door {#hints-tailgate}

**Where:** the records door, between the open-plan floor and the records office (secure_area). **Goal:** get through the badge-only door without a badge of your own.

> Hint: The door needs a badge, and you have none. Two routes get you through: follow a member of staff in on their badge read, or present a copy of their badge. The board says the courier hi-vis is required cover for following someone in.

<details markdown="1">
<summary>Nudge: tailgating behind Len</summary>

Put the courier hi-vis on first (click it in your kit and choose **Put on**); the visitor lanyard on its own is not enough. Then wait a few steps to the right of the records door, by the ledger shelves. Len Okafor badges in about every 17 seconds. When the door opens for him, walk in behind him. If he turns away, that is staff not badging in with a stranger at their shoulder; step back by the shelves and let him come round again.

</details>

<details markdown="1">
<summary>Nudge: the cloned badge</summary>

The other route needs no following. Carry the **RFID cloner** and chat to Len close up; it reads his badge from your pocket without him noticing. Present the clone at the records door, which accepts it and stays open a few seconds after a read. Cloning Len's badge, or an unattended card in place, counts; taking a card risks it being cancelled.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Put the courier hi-vis on== from your kit.
2. \==action: Wait by the ledger shelves to the right of the records door==, and \==action: walk in behind Len when the door opens for him==. Or:
3. \==action: Carry the **RFID cloner**, chat to Len close up to read his badge==, then \==action: present the clone at the records door==.

</details>

> Tip: Before you suit up, there is an optional beat here: shoulder-surf the records door PIN from the ledger shelves while Len keys it. The PIN alone never opens the door, but reading it is a finding. Do it before you put the hi-vis on.

> Warning: The lanyard is not enough on its own for the records door; the board makes the hi-vis the required cover. Wearing only the lanyard, you still read as a visitor.

### The Mechanical Lock {#hints-locks}

**Where:** the stationery cupboard (store_room), off the corridor. **Goal:** pick the lock and see what Ledgerwell keeps behind a cheap cylinder.

> Hint: No key was ever issued for the stationery cupboard, so a lockpick is the only way in, and it is in scope. Carry the lockpick set and work the lock.

<details markdown="1">
<summary>Steps</summary>

1. \==action: Go to the stationery cupboard off the corridor== (north of the hall).
2. \==action: Pick the lock with your **Lockpick set**==.
3. \==action: Look at what is inside==: the spare blank badges and the door-entry controller. Reading the controller's admin folder is an optional finding on top.

</details>

> Note: These four beats (keylogger, dropped device, tailgating, mechanical lock) are what the engagement needs. Once all four are done the debrief unlocks. This is the natural stopping point for a 60-minute class. The wireless and drop-box stages below are optional and can wait.

### Optional: The Pocket Rogue AP {#hints-rogue-ap}

**Where:** reception. **Goal:** stand up a copy of the staff Wi-Fi and harvest either the Wi-Fi key or Kieran's staff sign-in.

> Hint: A rogue access point copies a network's name, but nobody's laptop joins an open copy on its own; it needs a person to pick it. Hide the box in reception, pick which page it shows, and wait for Kieran's laptop to bite.

<details markdown="1">
<summary>Nudge: planting and cloning</summary>

Hide the **Pocket rogue AP** in one of the reception plants, then click it to open its console. Pick the **Ledgerwell-Staff** network (not a neighbour's, which is out of scope and refused, and not the guest network, which harvests nothing worth having), and choose one template: the **Wi-Fi key page** or the **staff sign-in page**. The lab knocks Kieran's laptop off the real network for you, so he picks the copy and types whatever the page you chose asks for. One plant can try both templates over time: harvest on one, re-clone onto the other, and wait again.

**Learn it:** ==action: Before you clone, say which tell a trained member of staff would notice== (a web page asking for the Wi-Fi key, or a sign-in prompt on a network that uses a shared key).

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Hide the **Pocket rogue AP** in a reception plant==, then open its console.
2. \==action: Clone **Ledgerwell-Staff** and pick a template== (Wi-Fi key page or staff sign-in page).
3. \==action: Wait for Kieran's laptop to pick the copy==, then read what it harvested on the **Harvested Credentials** tablet.
4. \==action: Use it==: for the key, try it on the staff access point in reception and open the network view; for the sign-in, sign in as Kieran at the **Hot desk PC**.

</details>

> Warning: Cloning a neighbour's network (for example Corrigan Dental) is out of scope and refused at Start; it harvests nothing. Cloning the guest network sets nothing useful, because the guest key is printed on a card and staff laptops hold the staff network, not the guest one.

### Optional: The Network Drop Box {#hints-drop-box}

**Where:** the comms cupboard (P3), with the patch panel. **Goal:** plant the drop box on a live port and see what the office network exposes, then reach the door controller.

> Hint: A wall port is only as useful as the VLAN it is patched to. The patch panel is labelled by VLAN. Plant the box on the right one, then open its view from anywhere, because the box calls home over its own mobile link.

<details markdown="1">
<summary>Nudge</summary>

In the comms cupboard, carry the **Network drop box** and use the patch panel (or the **Live wall network port**). The data VLAN reaches the office machines; the voice VLAN reaches only phones and the guest VLAN reaches nothing, which is the segmentation lesson. The **Managed wall network port** refuses an unknown device, which is port security. Once a foothold is planted, open its view from any room, including the briefing room, to see the out-of-band remote finding. With Chris's captured password you can then sign in to the door controller through the box.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Plant the **Network drop box** on a live port== at the patch panel in the comms cupboard.
2. \==action: Open the box's view== and read the machines that answer; try the voice and guest ports to see segmentation.
3. \==action: Open the view again from the briefing room== for the out-of-band remote finding.
4. \==action: Sign in to the door controller with Chris's captured password== through the box.

</details>

> Warning: The managed port refuses an unknown device on purpose: that is the control working, not a bug. The voice and guest ports give real footholds that reach the wrong things, which is the point.

### The Debrief {#hints-debrief}

**Where:** Ruth, in the records office (secure_area). **Goal:** close the engagement.

> Hint: Once the four core beats are done, find Ruth in the records office to turn the morning into findings. Gareth Fairbairn, the owner who signed the test off, is in there with her when you arrive, so it is worth hearing him out before the debrief closes. She warns you before she starts, because the debrief closes the engagement.

<details markdown="1">
<summary>Steps</summary>

1. \==action: Finish any optional findings you want first== (the debrief rolls the credits).
2. \==action: Go into the records office and talk to Ruth==.
3. \==action: Take the debrief== and hear which findings the engagement produced and the control for each.

</details>

> Note: If you want to explore the deeds and archive room behind the records office, do it before the debrief. Reaching it is in scope; opening a client deed box is a breach you note, not a tick. The debrief waits until you are ready.

## What the Game Is Telling You {#error-messages}

| You see | It usually means |
| --- | --- |
| A floor device does nothing | The authorise aim is not finished; take Ruth's briefing, read the board and collect your kit |
| Chris's screen shows a padlock | She is signed in and locked; you cannot use her session, and the keylogger has not caught her yet. Wait for her to leave and come back |
| "No password captured yet" on the keylogger | It is planted and recording, but Chris has not returned and unlocked since you planted it |
| Len turns away from the records door | Staff do not badge in with a stranger at their shoulder; step back by the ledger shelves and wait for him to come round |
| The lanyard alone will not get you through the records door | The hi-vis is the required cover for tailgating; put it on. The lanyard is not enough by itself |
| The cloned badge is accepted but you did not follow Len | That is the point: the clone opens the door on its own, and it stays open a few seconds after a read |
| The managed wall port refuses the drop box | Port security or 802.1X refusing an unknown device; that is the control working. Use a live unmanaged port |
| The voice or guest port's view lists almost nothing | Segmentation: that VLAN reaches the phones or nothing. The data VLAN is the one that reaches the office machines |
| The rogue AP refuses an SSID at Start | You picked a neighbour's network; that is out of scope. Clone Ledgerwell-Staff |
| "Out of scope" on a client deed box or a neighbour's Wi-Fi | Doing the out-of-scope version is a breach to note, not a tick; reaching the room or seeing the network was the finding |
| The debrief warns you it will close the engagement | It rolls the credits; choose to go back if you want to finish other findings first |

## Optional Side Content {#optional}

The engagement finishes on the four core beats, but the floor is full of optional findings, each its own small lesson. Open the ones you are curious about.

<details markdown="1">
<summary>Compare the desks: Melanie's unlocked screen</summary>

When a coffee cup shows over Melanie Pierce's head she is away for a minute. Try **Melanie's PC** (staff_pc_2), next to Chris's. Chris locked her screen; Melanie did not, so you are straight into her session with its saved logins, no password or device needed. The lesson is in [Unlocked sessions and the clean desk](#clean-desk).
</details>

<details markdown="1">
<summary>Shoulder-surf the records door PIN</summary>

Before you put the hi-vis on, browse the ledger shelves to the right of the records door and look across when Len keys the PIN. It lands on your **Harvested Credentials** tablet. The PIN alone never opens the door (you still need a badge), so this is a finding on its own.
</details>

<details markdown="1">
<summary>Clone Melanie's comms card in place</summary>

Melanie's spare **Comms cupboard card** lies on her desk. Clone it where it lies with the RFID cloner rather than taking it: a card taken is missed and cancelled, a card copied in place is never missed. The clone opens the server riser (P5) above the comms cupboard.
</details>

<details markdown="1">
<summary>Pocket a badge left on a desk (clean-desk failure)</summary>

Chris leaves her ID badge on the desk when she goes for coffee. Pocketing it is a clean-desk finding. It is an ordinary staff lanyard, not the records badge, so it opens no door; the finding is that it was there for the taking.
</details>

<details markdown="1">
<summary>Dropped storage USB, charging cable and QR-code card</summary>

Beyond the BadUSB, drop the plain **Storage USB stick** (a found-media lure someone opens a file on), the **Malicious charging cable** (it acts while Sofia charges her phone), or the **QR-code card** (a look-alike sign-in reached from a scanned code). Each is a different route from "someone found a device" to a capture. See [Dropped devices](#dropped-devices).
</details>

<details markdown="1">
<summary>The propped post-room door</summary>

The post and print room (P1) is badge-only, but someone has wedged its door open with a fire extinguisher to save tapping in for a jammed printer. Walk in through the propped door: no badge, no tailgate, nothing forced. The control is a door-held-open alarm, self-closers that are never wedged, and fixing the printer that made the door a nuisance.
</details>

<details markdown="1">
<summary>Talk past reception on a pretext</summary>

Read the visitor book on Dev's counter at reception to see who is expected, then give him a reason to be there and watch whether he checks your name against the booking. The desk, not the person, is the gap.
</details>

<details markdown="1">
<summary>The door-entry controller in the stationery cupboard</summary>

Inside the picked stationery cupboard, read the door-entry controller's admin folder. Its service login is still the factory default, written on a label inside the lid. The box that runs the badge system sits behind a cheap cylinder in an unlocked store, which is why a weak lock there is a serious finding.
</details>

<details markdown="1">
<summary>The deeds room and the archive safe (scope)</summary>

Behind the records office is the deeds and archive room (P4). Reaching it is in scope; the clients' deed boxes are their property and stay shut. Ledgerwell's own archive safe is in scope: opening it with a combination left written on a card nearby is a finding, not a breach. Respecting the deed boxes while reaching the room is itself credited at the debrief.
</details>

## Try It Yourself (Optional) {#try-it}

You cannot run the game's attacks on anything real, and you should never try. These are safe, legal things you can do to understand the ideas:

- \==action: Look up what kind of access card your own building uses==, and whether it is a plain number card (like EM4100) or a challenge-response smartcard. Do not clone anything; just read about the difference.
- \==action: On a service you use that offers it, turn on a second factor and set a unique password== (a password manager makes the unique part easy). Write a short note on which step in the game's capture-to-door-controller chain each change would have broken.
- \==action: Read a domain or network you control for its Wi-Fi security type== (open, WPA2-Personal with a shared key, or WPA2/WPA3-Enterprise with 802.1X), and note which the rogue-AP stage would and would not defeat.

## After the Game: Questions and Exercises {#after-the-game}

Work through these after you finish.

### 1. Authorisation and Scope {#q-authorise}

> Question: Explain, in your own words, what Ledgerwell's signed Rules of Engagement protect, for the tester and for the client. Pick three methods that were in scope and three that were out, and say why each line is drawn where it is.

> Question: The board lists using a captured password on Ledgerwell's own PCs as in scope, but a saved password for the finance portal or webmail as out of scope. Explain the distinction and why it matters legally.

> Action: Write a one-page rules-of-engagement outline for a physical penetration test of a small office. Cover the rooms and methods in and out of scope, the point of contact, the challenge rule, what happens to anything you capture, and how findings are reported without naming individuals. Map each point to something you saw in the game.

### 2. Physical Access Control {#q-access}

> Question: The records door needs a badge and a PIN. Describe every route the engagement found through or around it, and for each name the control that would have stopped it without stopping legitimate staff.

> Question: Compare the keylogger on Chris's locked machine with the unlocked session at Melanie's desk. What does the pair teach about where physical security actually lives?

> Action: Walk your own building (only where you are allowed to be) and note, without touching anything, three physical controls and three habits around doors and desks. Say which habit, if it slipped, would undo which control.

### 3. Devices and Networks {#q-devices}

> Question: Explain how a hardware keylogger, a BadUSB and a network drop box each get an attacker what they want, and why a screen lock, antivirus and the office firewall respectively do not stop them.

> Question: The rogue access point can harvest a shared Wi-Fi key or one person's staff password. Compare what each gives the attacker, and explain why the staff Wi-Fi being the office LAN makes the key so valuable here.

> Action: Find out whether a network you control uses a shared Wi-Fi key or 802.1X, and whether its guest network is segmented from the rest. Write down what you found and what you would change, and which game finding each change addresses.

### 4. From Findings to Fixes {#q-defend}

> Question: For three findings in the engagement, state the gap, the control you would recommend, and one control that sounds sensible but misses the point, with your reason.

> Question: Chris's one password opened a keyboard and then the door controller. Trace that chain and name the single control that, added once, would have broken it in the most places.

> Action: Turn your run into a short defender's note for Ledgerwell: the gaps the engagement found, the one fix you would do first, and one measurement the firm could take after that fix to show it worked. No names.

## Further Reading {#further-reading}

- The companion lab [Phishing and Social Engineering (Break Escape)]({{ site.baseurl }}/labs/cyber_security_landscape/phishing-and-social-engineering-game/), the earlier Tarnside engagement against the same kind of client, which covers the email and human-factors side this physical test follows on from.
- The National Cyber Security Centre guidance on physical security, device control and securing Wi-Fi networks, for how real organisations defend against a day like this one.
- Guidance on RFID and smartcard access control (challenge-response versus plain-number cards), and on 802.1X and network segmentation, for the badge-cloning and drop-box stages.
- The Cyber Security Body of Knowledge (CyBOK) chapters on Physical Layer and Telecommunications Security, on Human Factors, on Authentication, Authorisation and Accountability, and on Law and Regulation.
</content>
</invoke>
