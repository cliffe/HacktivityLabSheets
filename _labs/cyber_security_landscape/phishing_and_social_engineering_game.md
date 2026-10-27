---
title: "Phishing and Social Engineering (Break Escape)"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Play a browser-based engagement as a penetration tester at Tarnside Assurance: get the rules of engagement signed, research a client from public sources, craft messages tailored to the people you find, report what the engagement showed, then switch sides and defend against your own attack. No virtual machine."
overview: |
  Ledgerwell Ltd has hired your consultancy to find out how far a phishing and social-engineering campaign could get against its staff, with one condition from the client: nobody gets named and shamed. You play the tester. You settle what is in scope and get it in writing, research Ledgerwell's people from public sources only, and work out what each person you find would trust. Then you turn the engagement around: you triage a mixed inbox from the defender's chair, read the sender-authentication results, and turn each finding into a fix.

  The lab teaches social engineering at the level a defender needs: why open-source research makes a tailored message land, what the email authentication standards actually check, how to read a web address, and which fixes give a small organisation the most for the least. Every outcome in the game is explained, including the ones that fail. There is no malware, no payload and no virtual machine; the companion [Human Factors and Social Engineering: Phishing]({{ site.baseurl }}/labs/cyber_security_landscape/3-phishing/) lab covers the hands-on delivery of malicious attachments on a Kali VM.

  This sheet gets you started, explains the ideas behind each stage, walks you through the engagement room by room with layered hints for when you are stuck, and ends with reflection questions. There are no real answers printed: the whole point is to find them in the game.
tags: ["phishing", "spear-phishing", "social-engineering", "pretexting", "osint", "reconnaissance", "email-spoofing", "spf-dkim-dmarc", "look-alike-domains", "security-awareness", "rules-of-engagement", "computer-misuse-act", "blue-team", "break-escape", "game-based-learning"]
categories: ["cyber_security_landscape"]
type: ["game-based-learning", "lab-sheet"]
difficulty: "beginner"
source: "https://github.com/cliffe/BreakEscape/tree/main/scenarios/lab_social_engineering"
cybok:
  - ka: "HF"
    topic: "Human Factors"
    keywords: ["Social engineering", "Phishing", "Pretexting", "Security awareness", "Usable security"]
  - ka: "AB"
    topic: "Adversarial Behaviours"
    keywords: ["Reconnaissance and OSINT", "Email spoofing", "Look-alike domains", "SPF DKIM DMARC"]
  - ka: "LR"
    topic: "Law and Regulation"
    keywords: ["Computer Misuse Act 1990", "Rules of engagement", "Authorisation"]
---

## Purpose {#purpose}

By the end of this lab you should be able to:

- explain why an attack on people has to be authorised in writing first, and what the rules of engagement, the stop-rule and the Computer Misuse Act 1990 have to do with it
- plan an engagement with an objective you can check and a fair measure of success, and justify what you chose to count
- gather open-source intelligence (OSINT) about an organisation's staff, and name the kinds of tool a tester uses and what each one reveals
- explain why a tailored (spear-phishing) message lands when a generic one does not: trust, relevance, a name, a plausible attachment and timing
- describe what SPF, DKIM and DMARC each check, why a From line is only a label, and why a message that fails one check can still be genuine or still be delivered
- read a web address letter by letter and spot a look-alike domain (typo-squat, homograph, extra word, misleading subdomain), and say why a padlock does not prove who you are talking to
- recognise a pretext phone call, and explain what kind of control defeats it
- turn findings into mitigations a small organisation can actually afford, and justify your choice among them

The game teaches by doing. The questions are in this sheet, after the game.

## How to Use This Sheet {#how-to-use}

1. Read **Getting Started** and launch the game. You do not need any prior knowledge; the engagement teaches each idea as you reach it.
2. Play. Dip into **Concepts** when you reach a new idea, or come back to it afterwards.
3. If you get stuck, open **Stuck? Hints, Stage by Stage** and find the stage you are on. Each stage has a hint you can read straight away, then a stronger nudge and full steps in collapsed sections headed **Nudge** and **Steps**. Open one at a time, and go back to the game after each. Ruth, your engagement lead, gives the same hints on your in-game phone.
4. After the game, work through **After the Game: Questions and Exercises**.

> Note: This is a training exercise against a fictional company, Ledgerwell Ltd. Everything you do is authorised inside the game's story. Doing any of it to a real organisation without written permission is a criminal offence. The first stage of the game is about exactly that line.

## Getting Started {#getting-started}

You are a penetration tester at Tarnside Assurance. Ledgerwell Ltd, a small finance firm, has hired Tarnside after one of its staff nearly wired a five-figure invoice to a spoofed supplier last quarter. The managing director, Gareth Fairbairn, is not angry at his staff; he is scared the next attempt gets through. Your job is to find out how far a phishing and social-engineering campaign would get, and to report the gaps so he can close them. Your engagement lead, Ruth Adeyemi, runs you through the day and is on your phone whenever you are stuck.

![The Engagement Office, where the day starts]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/01-engagement-office.png)

1. \==action: Start the Break Escape scenario **Phishing and Social Engineering**==, and choose an avatar when asked.
2. \==action: Listen to Ruth's briefing, and answer Gareth's question about his staff==.
3. \==action: Read the **Rules of Engagement** sheet on the table== before you touch anything else.
4. \==action: Open your phone whenever you are unsure==. Ruth gives you a hint for the stage you are on.

A first run takes about 60 to 90 minutes, depending on how much you read and how much you repeat. In a 60-minute class, a good stopping point is once your report is filed and Ruth hands you the Blue Team Room key; the defender half picks up cleanly next time. Your progress is kept between sessions.

### How to Play {#how-to-play}

You move with the arrow keys or by clicking. Click objects, people, doors and workstations to interact. Keys you collect go to the inventory bar at the bottom of the screen. Each workstation runs one tool as a small on-screen app. The people are voiced, including on the phone, so turn your sound on; every line is also shown as text.

The engagement runs through four rooms in all: the Engagement Office, and three rooms off it. You unlock the **Recon Room**, the **Operations Room** and the **Blue Team Room** in turn, each with a key Ruth hands you when the stage before it is done.

> Tip: Most tools put a **Stuck? Show me where to look** link under anything you have not found yet: each missing row on the Case File, and each empty blank in the mail composer. Open it and it names the source to check, never the answer.

> Tip: Stuck on a term? Research tools and some of the other workstations have **What is this?** buttons that open a short concept card, and the triage inbox has a **What's this?** glossary for SPF, DKIM and DMARC.

> Tip: Nothing in this game is scored by catching you out, and no choice is a dead end. A wrong pick comes back with the reason it was wrong, so read the feedback rather than guessing again. The "wrong" answers are there to teach, so it is worth reading why they are wrong even when you picked the right one.

> Warning: Watch the people you are dealing with as well as the machines. A friendly person on the phone will get suspicious if you push too hard, stop helping, and report your call. That is realistic, and it is recoverable, but they will not take another call from you for about two minutes.

## Concepts {#concepts}

You do not need to read all of this before you play. Use it when you reach each idea, and again when you answer the questions afterwards. The examples use made-up companies and people, so you can check the reasoning by hand without it giving away anything in the game.

### Authorisation: the line between a test and a crime {#authorisation}

Attacking an organisation's people and systems is a criminal offence under the **Computer Misuse Act 1990**, unless the organisation has agreed to it in writing first. A signed **scope** is what makes a penetration test lawful. Rules of engagement normally cover:

- what is in scope (the systems, channels and kinds of public information you may use) and what is out of scope (what you must leave alone);
- who the point of contact is, and how to reach them;
- what you do if something goes wrong.

Scope tends to be drawn around the client's own estate and the channels the client controls. Things that belong to someone else or could hurt a third party, such as staff personal accounts, physical entry, real customers and anything that could disrupt a live service, are usually excluded unless the client has specifically agreed and has the right to agree. Your work is only as lawful as the signature behind it, so a test starts with the paperwork, not the tools.

A good scope also has a **stop-rule**: if you stumble on evidence of a real compromise, or a real person in distress, you stop and escalate to the named contact rather than carrying on, fixing it yourself or sitting on it. A real incident is not yours to touch, and touching it could destroy evidence.

> Question: The engagement is authorised by the company that owns the systems and the staff accounts. The individual members of staff never agreed to be tested. Is it right to test people who did not personally consent? What makes it acceptable, and where would it stop being acceptable?

### Planning: measure the process, not the people {#planning}

Before you send anything, you decide what the engagement is for and what you will measure. A useful objective is one you can check at the end. "Find out how far an email campaign gets against a small team" can be measured; "prove the company is vulnerable" cannot, because nothing could ever show you had failed to prove it. Agree up front, too, what happens to anything you capture, so that a test of the process never turns into collecting real credentials.

How you measure matters just as much as what. Counting **which named staff fell for it** is the tempting measure and the usually wrong one. When people are named and blamed, they stop reporting their mistakes, and reporting is one of the most useful things a defender has. A measure that counts **how far each attempt got** (delivered, opened, clicked, what a phone call gave away) shows the risk without pointing at a person.

A worked example. A tester at an invented firm, Harbourline Ltd, plans a campaign of 40 messages. Afterwards she records: 40 sent, 3 bounced, 37 delivered, 12 links clicked, 5 forms submitted and then discarded. Check it by hand: 37 of 40 delivered is 92.5%, 12 of 37 clicked is about 32%, and 5 of 12 submitted is about 42%. Each figure describes the process (filtering, link caution, form caution) and none of them names a person. One more measure is worth planning for if the organisation gives you a way to take it: how many recipients **reported** the message. If there is no way to report, that rate is simply unavailable, and the missing channel is itself something to put in the findings.

> Question: "Reporting rate is the best measure, but we can't measure it because there's no way to report." Explain why a way to report suspicious mail is worth more to a defender than another round of awareness training.

### Reconnaissance and OSINT {#osint}

**Open-source intelligence** is everything an attacker can learn about a target from public sources, without touching the target's systems. For a social-engineering attack it is the groundwork: the more you know about a person, the more your message looks like one they were expecting.

In the Recon Room you work three kinds of source:

| Source | What it gives up |
| --- | --- |
| The company website (team and careers pages, news and notes, old archived pages) | Who works there, their roles, how to contact them, what they are busy with, and stale facts that no longer hold |
| Staff social-media posts | Who a person trusts, what they are waiting for, and small personal details that make a message feel personal |
| A published document's properties (metadata) | The software used, file paths and often the name of whoever made it, left in the file because nobody cleared them |

Real testers run tools to do this at scale. You meet them as concept cards in the game:

- **Hunter** reports the address pattern a company uses. Companies tend to follow one convention, for example an initial and a surname (`a.nwosu@`) or first name, dot, surname (`amara.nwosu@`). Learn the pattern and you can write a plausible address for anyone you can name.
- **theHarvester** collects names, addresses and sub-domains from public sources. Its results are noisy: two people can share a name, so each hit has to be checked against what the company's own site says.
- **Recon-ng** runs many such lookups from one place. A lookup that returns nothing is a result too; it tells you not to waste time on that lead.
- **exiftool** reads a file's metadata, which can reveal who created a document and with what, and sometimes how the organisation names its accounts.

Not every result is a good one, and spotting the bad ones is part of the skill. An **archived page marked as old** shows a structure that may no longer hold, and acting on it sends your message to the wrong place. A **search hit that shares a name** with someone at a different company is a mistaken identity, however neat the match looks. Stale and mistaken-identity results are normal in OSINT, which is why you confirm a fact against a second, current source before you rely on it.

> Question: Many organisations publish a single role inbox for outsiders, such as `careers@` or `info@`, rather than each person's personal address. Why is that better for them, and what could an attacker still work out about the addresses they use internally?

### Why a tailored message lands {#spear-phishing}

**Phishing** is a message that tricks someone into acting against their own interest: opening a file, following a link, or giving something away. Bulk phishing is sent to thousands and barely tailored. **Spear phishing** is aimed at one person and built from what you learned about them, which is why it is far more convincing.

A message lands when it clears the checks the target makes, usually without noticing they are making them:

- **Trust** — it appears to come from someone or something they already trust. The From line is only a label an attacker can set, so "appears to" is doing the work.
- **A name** — it greets them the way someone who actually knows them would.
- **Relevance** — it fits what they do and what they are expecting right now.
- **A plausible attachment or link** — the right kind of file from the right kind of sender, or a link that looks like the real site.
- **Timing and a little pressure** — a believable reason it matters now, pitched so it does not feel forced.

Different targets are persuaded by different levers. A shared inbox that exists to hear from strangers will trust anything that looks like its normal traffic. Someone who routinely acts on mail from a named colleague can be reached by borrowing that colleague's identity and sending what they were expecting. Someone new, who only knows the official notices from the systems they have been told about, needs those systems' details to be right, and public research alone may not supply every detail. As you play, ask of each target which of the checks above they rely on most.

> Question: For each of the three targets, name the single thing that made the message believable. Which of the three would be hardest to defend, and why?

### Email spoofing and sender authentication: SPF, DKIM and DMARC {#authentication}

The From line you see in an email is just text. Nothing about plain email stops someone writing `Dana Okafor <d.okafor@brightwater.example>` in a message they sent from anywhere. **Spoofing** is exactly that: setting the From line to someone you are not. Three standards exist to catch it.

- **SPF** (Sender Policy Framework) answers one question: was the server that sent this message allowed to send for that domain? The domain owner publishes a list of permitted servers; the receiver checks the sending server against it.
- **DKIM** (DomainKeys Identified Mail) answers a different one: did the domain actually sign this message, and arrive unchanged? The sending domain adds a cryptographic signature; the receiver checks it with the domain's published key.
- **DMARC** (Domain-based Message Authentication, Reporting and Conformance) ties the two to the visible From address. It checks that a passing SPF or DKIM result **aligns** with the domain in the From line, and it tells receivers what to do when nothing aligns: `p=none` (deliver anyway), `p=quarantine` (send to junk) or `p=reject` (refuse it).

SPF and DKIM only report; DMARC's policy decides what happens. Take the invented Brightwater above. Someone sends the Dana Okafor message from their own server. The server is not on Brightwater's SPF list, so SPF fails. They hold no signing key, so there is no DKIM signature. Nothing aligns, so DMARC fails. If Brightwater publishes `p=none`, the receiver delivers it anyway, looking as if it came from inside the company. With `p=quarantine` it goes to junk, and with `p=reject` it never arrives. A policy of `none` decides nothing.

A passing check does not prove a message is safe, and a failing one does not prove it is an attack. Forwarding is the classic case. Suppose a genuine message from `accounts@northfield-supplies.example` is forwarded by a mailing list run by an invented trade body. The list re-sends it from its own server, which is not on Northfield's SPF list, so SPF **fails**. But the list left the message body and signed headers untouched, so Northfield's DKIM signature is still valid and still aligns with the From domain, and DMARC **passes**. It is real, and the headers, not a gut feeling, are what show it. The reverse also happens: an attacker who registers their own look-alike domain can set up SPF, DKIM and DMARC for it correctly, and every check passes for a message that is still a phish, because the checks say who sent it, not whether the sender is who you think.

```
Message                                  SPF    DKIM   DMARC   Verdict
Spoof of d.okafor@brightwater.example    fail   none   fail    phish (delivered if p=none)
Genuine mail forwarded by a list         fail   pass   pass    genuine (DKIM still aligns)
Phish from a look-alike domain the
attacker set up properly                 pass   pass   pass    still a phish
```

> Question: A colleague says "the email passed DMARC, so it must be safe." Give one reason that is not quite right. Then explain what moving a domain from `p=none` to `p=quarantine` does to a spoof of that domain.

### Look-alike domains and links {#lookalike}

When you cannot send from the real domain, the next best thing is one that reads like it. These are the tricks, in roughly rising order of nastiness. The examples are against an invented brand whose real address is `examplebank.example`:

| Trick | Example | How to catch it |
| --- | --- | --- |
| Unrelated generic name | secure-banking-portal.example | It has no connection to the real name at all |
| One wrong letter | examplebnak.example | Read every letter |
| An extra word | examplebank-support.example | The real name is not the whole address |
| A misleading subdomain | login.examplebank.verify-now.example | Read right to left: the registered site is the label just before `.example`, here `verify-now.example` |
| Look-alike letter pairs | exarnplebank.example (r and n for an m) | Read letter by letter; `rn` and `vv` pass for `m` and `w` |
| Homograph | a letter from another alphabet that looks identical | Some browsers show the `xn--` punycode form to give it away |

Check the subdomain row by hand. Split `login.examplebank.verify-now.example` at the dots and read from the right: `example` is the top-level label, `verify-now` sits immediately left of it, and everything further left (`examplebank`, `login`) is a sub-domain the owner of `verify-now.example` chose for themselves. They could call it `examplebank` just as easily as anything else. The address belongs to whoever owns `verify-now.example`, not to the bank.

Two habits matter for links. **Hover** before you click: the words of a link and where it actually goes are two different things, and the status bar shows the real destination. And remember that a **padlock** only means the connection is private, not that the site is who it claims to be; a look-alike page gets a padlock just as easily as the real one.

> Question: Using the invented brand above, the address `login.examplebank.verify-now.example` is designed to make you relax when you see the brand name near the front. Which part is the real registered site, and why does reading right to left defeat the trick?

### Pretexting: social engineering by phone {#pretexting}

A **pretext** is the false identity and story you use to get someone to help you, such as a busy colleague helping a nervous new starter. Pretexting over the phone works because a helpful person on a service desk wants to solve your problem, and the checks they make are only as good as the policy they were given.

Verification that relies on facts an outsider can find, such as a name and a team that appear on public pages, proves little. If the policy never asks for something an attacker cannot supply, the operator can follow it perfectly and still hand over what the attack needs. The gap is in the policy, not in the person. The control that closes it is one the caller cannot fake, such as calling back on a number the organisation already holds.

How you handle the call matters. Being a calm, candid colleague keeps the operator helping. Leaning on them with false **urgency** or **borrowed authority** makes them wary, and a wary operator may refuse and report the call. If you get a fact wrong, owning the correction early (**candour**) costs you less than defending it. This is realistic: people are a defence too, and a good one when they are not being rushed.

> Question: The service desk operator did nothing against his policy, yet he gave away enough to make the intern's email believable. Whose problem is that, and what one change to the policy would have stopped it without making his job harder?

### Defending: triage, and turning findings into fixes {#defending}

The last room flips the engagement. From the defender's chair you **triage** a mixed inbox: for each message, decide whether to trust it, report it or delete it, reading the SPF, DKIM and DMARC results and the actual addresses rather than the display names. Some of the messages are your own sends from earlier, and from this side the headers give them away. Expect genuine mail that looks suspicious and phish that looks perfectly normal, so you practise not judging by first impressions.

Then you turn each finding into a **mitigation**. Match the kind of control to the kind of gap:

- A gap where **people notice but have nowhere to send the doubt** is a detection and reporting gap. The control is a simple way to report, so one person's suspicion becomes a warning for everyone.
- A gap where **a process can be talked round** is a policy gap. The control is a step the attacker cannot fake, such as verifying out of band, rather than a stricter script or a sterner reminder.
- A gap where **a message can claim to be from your own domain or one that looks like it** is a technical email-authentication gap. Policy at the receiving end and visible marking of outside mail address it, because authentication results alone cannot catch look-alike domains.
- A gap where **an attacker learned too much for free** is an exposure gap. Reduce what is published and what files carry with them.

Prefer controls that work when a person makes a mistake, and be wary of ones that sound sensible but miss the point. A padlock on a page tells you nothing about who runs it. Forcing password changes does not help if someone types the new password into a fake page. And **blaming staff** as "careless" hides the control gap, makes people afraid to report, and so removes the best early warning you had.

> Question: A security lead says there is budget for one fix this year. Think of the kinds of control above (a way to report, an out-of-band check for sensitive requests, tighter email authentication with marking of outside mail). Which would you spend it on in an organisation like the one you attacked, and what does your choice say about where the real weakness is?

## Stuck? Hints, Stage by Stage {#hints}

Find the stage you are on. Read the hint, then go back and try. If you are still stuck, open **Nudge**. Open **Steps** last. Ruth gives the same hints on your phone, one stage at a time.

> Tip: Before you open any hint, ask yourself three questions. What check is this person or system making? What do I already know that would pass it? And where could I find what I am missing?

### Before You Start: Getting It in Writing {#hints-authorise}

**Where:** the Engagement Office, at the start. **Goal:** sort the scope, answer the stop-rule, and get Gareth to sign.

> Hint: Nothing you do is lawful until the client signs the sheet. Read it, sort each card into in or out of scope, and think about what you would do if you found a real break-in mid-test.

<details markdown="1">
<summary>Nudge</summary>

Work email to named staff and the published service-desk line are the sort of thing the client is paying you to test. Staff's personal addresses are not, however tempting, and nor is anything that touches real customers or a live service. The stop-rule is about a real compromise you did not cause: a real incident is not yours to touch, fix or ignore, so there is only one safe answer.

Answer Gareth's opening question how you honestly would. Neither answer blocks the game, and Ruth reacts to both.

If a card keeps bouncing back, read the line it comes back with. It names the rule the card breaks.

</details>

<details markdown="1">
<summary>Steps</summary>

![The Rules of Engagement scope sort]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/02-rules-of-engagement.png)

1. \==action: Read the Rules of Engagement sheet== on the table.
2. \==action: Sort each scope card== into in scope or out of scope; a wrong pile bounces back with the reason.
3. \==action: Answer the stop-rule question==.
4. \==action: Take the sheet to Gareth by the window and let him sign it==. Listen to what he says as he signs.

</details>

> Warning: Ruth will not hand over the Recon Room key until Gareth has signed in person and your plan is done. If the door is locked, check you have been to see him.

### Planning the Engagement {#hints-plan}

**Where:** the Planning Whiteboard, Engagement Office. **Goal:** pick the objective and the success measure.

> Hint: Decide what the engagement is for, and how you will tell afterwards whether it worked. Gareth's condition tells you something about what you should not be counting.

<details markdown="1">
<summary>Nudge</summary>

The objective is about learning how far an attack gets and reporting the gaps, not about disrupting payroll or hoarding passwords. The measure is about the process, not the people: how far each attempt got. A measure that names who fell for it breaks Gareth's condition. A measure about who reported sounds ideal but cannot be counted here, because there is no way to report yet. Noticing that gap is the point.

</details>

<details markdown="1">
<summary>Steps</summary>

![The planning whiteboard]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/03-planning-whiteboard.png)

1. \==action: Open the Planning Whiteboard== and read the choices under each heading.
2. \==action: Pick the objective about finding and reporting the gaps==, with nothing broken and no passwords kept.
3. \==action: Pick the measure about how far each attempt got==.
4. \==action: Talk to Ruth, and take the Recon Room key== once the plan holds and Gareth has signed. If she has nothing to give you, one of those two is still outstanding.

</details>

### Reconnaissance: the Recon Room {#hints-recon}

**Where:** the Recon Room (west), at the OSINT Workstation, and the Case File board in the Engagement Office (the research browser also opens it from its **Case file** button). **Goal:** learn enough about three people to approach them, from public sources only.

![The OSINT research browser]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/04-osint-workstation.png)

> Hint: The Case File has a card for each target with **Missing** rows. Each one says what you still don't know, and the **Stuck? Show me where to look** link under it names the source. Everything you need is public.

<details markdown="1">
<summary>Nudge: filling the cards</summary>

![The Case File, with a Stuck? pointer open on Chris's card]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/05-case-file-board.png)

Use the research browser on the OSINT Workstation. You record a fact by selecting the line that says it. The team page gives roles; the team notes and the staff social posts on Friendface give what each person trusts and is waiting for; the How to apply page says what files the careers inbox takes; a lookup under **Tools** gives the email pattern, so you can write any staff address (Hunter and the name search only appear in Tools once you have read Our Team). One card needs the company's **username** convention, not just the address pattern, and that comes from a different kind of source.

Chris's Friendface profile is hidden at first. It appears once you select the careers inbox line on the company's Careers page, so a card that will not fill often means a line you read but did not select. The **Stuck?** pointer on Chris's card names that line and the profile.

Watch for decoys: a source that is marked as old, and a search result that only shares a name with someone you want. A fact you confirm from a current source beats a fact that merely fits.

</details>

<details markdown="1">
<summary>Nudge: the username pattern</summary>

A published document keeps its author's name in its properties, whether or not the author meant to leave it there. Open the company's published PDF and read its properties; the author field gives away how usernames are built. Melanie's card keeps a "sign-in name" row open until you do, and Ruth will not hand over the Operations Room key without it.

**Learn it:** ==action: Open the PDF's Document properties and read the Author field== before you let the game tick the card, so you see where the leak is.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Open the OSINT Workstation and read the company site: Our Team, Team notes, Careers, How to apply and the Archive==, selecting each line you want to keep.
2. \==action: On the Careers page, select the careers inbox line==, then read Chris's posts, which now show on Friendface, along with Melanie's and Sofia's.
3. \==action: Once you have read Our Team, run the Hunter lookup for the email pattern under Tools==, and the name search. Check each result against the company's own pages; the archived org chart and the second J. Baker are the decoys.
4. \==action: Open the published PDF and read its properties, including the author==.
5. \==action: Check the Case File until all three cards are ready==, then take the Operations Room key from Ruth.

</details>

> Warning: If a source will only open behind a login, it is off the sheet. Recon here is public sources only.

### First Two Sends: the Operations Room {#hints-easy-sends}

**Where:** the Operations Room (east), at the Mail Workstation. **Goal:** get the careers inbox and then Melanie Pierce to act on a message.

> Hint: Every inbox has its own idea of who is worth listening to. For each of these two people, ask who they would open a file from without a second thought, and what they would expect that person to send. Your recon notes say.

<details markdown="1">
<summary>Nudge: the careers inbox</summary>

An inbox whose whole job is to open files from strangers will open yours. Apply as a candidate, attach the kind of file the How to apply page asks for, and it lands. Real applicants write from a webmail address, so Ruth suggests making a throwaway one first (it is optional): choose **Create account** in the account drop-down at the top of the mail client.

</details>

<details markdown="1">
<summary>Nudge: Melanie Pierce</summary>

Melanie checks who a message is from, whether it greets her properly, whether it is relevant, and whether the attachment is one she would expect. Your recon tells you who she trusts in Finance, what she is expecting from him, and when. Send as that person, at his real address built from the pattern, greet her by the name a colleague would use, and attach the file she was expecting.

One trap: the throwaway webmail account can only send as itself. To set the From line to the colleague's address you need the account that allows it. If the sender's **name** and **address** belong to two different people, she will not bite.

**Learn it:** ==action: Before you send, say out loud which of Melanie's four checks each part of your message is meant to pass==.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Optionally, create a throwaway webmail account from the same drop-down, and send to the careers inbox from it as an applicant==, with the file type the How to apply page asks for.
2. \==action: Switch to `Consultant <guest@workstation.example>` in the account drop-down==, the account that lets you set the From line.
3. \==action: Compose to Melanie as the colleague she trusts==: his real address (first initial, dot, surname, at the company's domain, as the lookup showed), her first name, and the file she expects.
4. \==action: Send, and read the reply or the factor feedback== if it did not land. **Edit & resend** keeps your message so you can change one part.

</details>

> Warning: "Delivered" is not "landed". A message lands only when the target would act on it the way they would a real one. If it fails, the feedback names which check it failed; fix that one thing.

### Preparing for Sofia {#hints-prepare}

**Where:** the Operations Room. **Goal:** find what Sofia would expect that your recon could not tell you, and have it ready. Her message cannot be written until you do.

> Hint: Sofia is new, and she only acts on things that look like they came from systems she has been told about. Open her card on the Case File and the blanks in her message: what do they say you still don't know, and who inside Ledgerwell would? Two things in this room besides the mail workstation are for exactly this, and you can do them in either order.

<details markdown="1">
<summary>Nudge: what to find out, and from whom</summary>

Her payslip system's name, the address its notices come from, and the date payslips are released are all things only the company's own service desk will tell you. The **Stuck? Show me where to look** pointers on her card and in the mail composer say the same: ring the service desk from the Desk Phone. The other object is the Page Builder, where you make the page the message will link to. Until you have called, the Page Builder's "What Sofia is expecting" box stays empty, but you can still build.

</details>

<details markdown="1">
<summary>Nudge: the pretext call</summary>

Ring the service desk from the desk phone as a colleague helping the new intern. Know her name and team before you dial; Dev checks both against the new-starter list, and both are on the public pages. Take the team from a current page, not the archived one. Then ask for what you are missing. There are two separate questions: one for the portal's name and sending address, one for the release date. Dev answers each on its own, so the call is not finished until you have had both. If you only got one, the phone and Ruth both say which is missing; ring back for it.

Stay calm and candid. The influence meter at the top of the call shows how Dev feels, and asking can cost a little of it. False urgency or dropping a manager's name makes him wary; keep it up and he refuses and reports the call, and then he will not take another call for about two minutes. The phone tells you how long is left. If he refuses an ask but has not reported you, you can hang up and ring again. If you named the wrong team, own the correction straight away rather than arguing it.

![The pretext call to Dev on the service desk]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/08-service-desk-call.png)

</details>

<details markdown="1">
<summary>Nudge: the look-alike page</summary>

![The page builder refusing the company's real domain]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/07-page-builder.png)

The Page Builder scores your page against what would convince Sofia: the service (the **Which service?** row lists only the portal she actually uses), what the page says it is for, the address, the logo, the wording, which details the form asks for, and the padlock. The address is the hard part. One that reads nothing like the real one, or has one obviously wrong letter, scores low; the convincing ones are the look-alikes that pass a quick glance. Match the wording to a real payslip notice, avoid the version riddled with spelling slips, and do not ask for more than the real portal does.

The company's real address is on the list, drawn as a locked, dashed note: you cannot use it, because you do not own it. If you press **Score** with no address chosen, the Score panel says why it cannot score the page and asks you to pick a look-alike. One look-alike is drawn almost the same as the real address (a letter from another alphabet), so if Score says you have no address, check which one you actually picked.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Call the service desk from the desk phone==: fill in the **Prepare the call** card with her name and team, then choose **Make the call**, opening as the intern's colleague.
2. \==action: Ask for the portal's name and sender==, then \==action: ask for the payslip release date==.
3. \==action: Keep Dev calm==: avoid urgency and borrowed authority, and correct any mistake openly. If he reports the call, wait out the time the phone shows (about two minutes), then ring again with your facts straight.
4. \==action: Open the Page Builder==, pick Sofia's portal, the payslip purpose, a convincing look-alike address, the right wording and only the details the real portal asks for, then press **Score** until it says the page is convincing enough for her, and finish with **Attach to email** (**Attach anyway** if the score is low). Only that marks the page as built.

</details>

> Warning: A system that sounds right is not necessarily the one she uses. If a send later fails on the system it names, go back to where you got the name and ask whether anything there says she signs in to it.

### The Hard Send: Sofia Lord {#hints-hard-send}

**Where:** the Mail Workstation. **Goal:** put what you have together and land a message on Sofia.

> Hint: The blanks that were empty for Sofia should be filled in by now. A message lands when every part of it matches what she would expect, so use everything you found rather than most of it.

<details markdown="1">
<summary>Nudge: a blank will not fill</summary>

![Sofia's message before the call, with the Stuck? pointer under the sender]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/06-mail-composer.png)

If a blank in the composer reads **no evidence yet** or offers nothing that fits, Send stays greyed out ("A blank needs evidence you haven't found yet") or the message fails. Open **Stuck? Show me where to look** under that blank: for Sofia's sender, sending address, system and release date it points you back to the desk phone. The Careers page also names some finance tools, and the composer may offer one in the "which system" blank. That is not her payslip portal, and a message naming it will not land. Only the desk knows the real one.

</details>

<details markdown="1">
<summary>Nudge: the send fails</summary>

Sofia checks the same kinds of thing as the others: whether the sender is who she expects (name and address together), whether it greets her the way her portal would, whether it reads like a payslip notice, and whether the link looks right. The factor feedback names the one that missed. A link that failed usually means the page was never built and attached, or it fell short when you scored it. Open the Page Builder and see which part lost the score.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Compose to Sofia as the portal's own notification sender==, using the name and address Dev gave you.
2. \==action: Greet her by her first name, the way the portal would==.
3. \==action: Write a payslip-ready pretext with the portal's name and the release date==.
4. \==action: Check the page is built (**Attach to email** in the Page Builder), attach it as the link, and send==.

</details>

> Warning: A failed send is information, not a penalty. Read which factor missed and change that one part.

### Writing the Report {#hints-report}

**Where:** the Report Workstation, Engagement Office. **Goal:** answer two questions on the results, then pair each finding with a cause and a control.

> Hint: The report only opens once all three targets have acted, in any order, so if it will not open, work out who is left. Once it does, read what the results table counts and ask what it cannot. For each finding, choose a cause and a control that fit the evidence.

<details markdown="1">
<summary>Nudge</summary>

For the first question, look at what the tables actually count and ask which thing is missing from all of them. The line just above the question, "Email and page reports received: none", says why. For the second, think about what a "first send landed" column tells you that "landed in the end" does not: a target who fell to the first try had no warning, and every failed send was a chance to spot it.

For each finding, some wrong causes sound reasonable (a spam filter, a careless member of staff) and some wrong controls sound sensible (training, SPF alone, password expiry, checking the padlock). Read why each is wrong before you pick again; the explanations are the lesson. A cause or control that blames a person is always a wrong one, because blame stops people owning up.

</details>

<details markdown="1">
<summary>Steps</summary>

![The report workstation]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/09-report-workstation.png)

1. \==action: Read the results table==, then answer the two questions under it.
2. \==action: Pair each of the three findings with a cause and a control==, reading the feedback on any wrong pick.
3. \==action: File the report==, take the Blue Team Room key from Ruth, and hear Gareth's reply by the window.

</details>

> Warning: If the workstation says there is nothing to write up, one of the three targets has not acted yet. Ruth and your phone say which.

### Defending: the Blue Team Room {#hints-defend}

**Where:** the Blue Team Room (north), at the Triage Workstation and the SOC Board, with Tomasz. **Goal:** triage a mixed inbox and choose a fix for each exposure.

> Hint: Sort each message into trust, report or delete. Work out what each of the SPF, DKIM and DMARC results does and does not prove, and what you can still check for yourself in the address.

<details markdown="1">
<summary>Nudge: the triage</summary>

![The triage inbox with header results]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/10-triage-inbox.png)

Two of these messages are your own earlier sends, and the headers give them away now. One genuine message fails SPF because a mailing list forwarded it, yet its DKIM signature still aligns, so it is real. Some phish pass every authentication check because a look-alike domain really sent them; the trick is in the address, not the headers. Read addresses letter by letter, and check for extra words. When you mark a message, a "What made you say that?" list may ask which signs you saw; tick only the ones you found, and scroll it to see every option. You need to clear the pass mark; if you fall short, **Try again** is offered and nothing is lost.

</details>

<details markdown="1">
<summary>Nudge: the SOC board</summary>

The board asks for one fix per exposure your recon exploited: the leaked address pattern, and the username leaking through file metadata. For each, one option actually closes the gap and the others only look busy. Read why the weak options fall short.

</details>

<details markdown="1">
<summary>Steps</summary>

![The SOC board defender choices]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/11-soc-board.png)

1. \==action: Triage every message== in the inbox, reading the authentication results and the addresses.
2. \==action: Pass the triage==, retrying if your first pass is short.
3. \==action: Choose a mitigation for each exposure on the SOC Board==.
4. \==action: Take Tomasz's debrief== to close the engagement (see the next stage).

</details>

### The Debrief {#hints-debrief}

**Where:** Tomasz, in the Blue Team Room. **Goal:** close the engagement.

![The closing credits]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/12-credits.png)

> Hint: Tomasz asks which one fix he should spend his only budget on this year. There is no wrong answer, but each choice says something about where the real weakness is. Pick the one you would defend, then read what he says back.

<details markdown="1">
<summary>Nudge</summary>

The **Debrief me.** option only appears once both the triage and the SOC board are done. Until then Tomasz says which half is missing. Before he starts he warns you that the debrief closes the engagement and rolls the credits, and offers a way back. If you want to hear Gareth's reply to your report or finish anything else first, take it; the debrief waits. His questions about SPF, DKIM and DMARC, and about Dev, are optional and repeatable.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Finish the triage and the SOC board== if you have not, then \==action: talk to Tomasz==.
2. \==action: Choose "Debrief me."== Tomasz warns you that this closes the engagement.
3. \==action: Choose "Go ahead. Close it out."== (or "Not yet, I want to finish something." to go back).
4. \==action: Pick the fix you would spend the budget on== and read his reply. The credits roll.

</details>

> Note: Tomasz warns you before the debrief, because it closes the engagement and rolls the credits. If you want to finish anything first, including hearing Gareth's reply to your report, choose "Not yet, I want to finish something."; the debrief waits.

## What the Tools and the Game Are Telling You {#error-messages}

| You see | It usually means |
| --- | --- |
| A scope card bounces back | You sorted it into the wrong pile; the line tells you which rule it breaks |
| The Recon Room / Operations Room / Blue Team Room door is locked | The stage before it is not finished; Ruth hands you each key when it is, and the Recon Room key also waits for Gareth's signature |
| The board says a target card is incomplete | A **Missing** row still needs a public source; **Stuck? Show me where to look** under it names the source |
| A card will not fill and a person's posts are nowhere to be seen | A line you read but did not select, or a source you have not opened yet; see the Recon hints |
| "You still don't know the name she signs in with" | A published file you have not examined closely enough yet; the Operations Room stays locked until you do (see the Recon hints) |
| A send fails with a factor marked "✗" | That one check failed; read the line and fix only that part |
| "The name and the address belong to two different people" | Your From name and From address do not match; use the trusted person's real address |
| "You're still sending as yourself" | You are on an account that cannot spoof; switch to the one that sets the From line |
| A blank reads "no evidence yet" and Send is greyed out | You have not found that fact yet; open **Stuck? Show me where to look** under the blank |
| A send fails on a system or link it names | The name you used is not the one the target uses, or the link has nothing behind it; see the hints for Sofia |
| "Blocked address", and Score says the address belongs to the company | The page cannot use an address you do not own; read the message under Score and choose again |
| Dev says he will run it past his manager, and the phone will not ring him | You pushed too hard; the message says how long to wait (about two minutes), then call back calmly with your facts straight |
| Dev gave you only one of the two facts you need | Ring him back for the other; Ruth and your phone say which is missing |
| The report workstation says there is nothing to write up | All three targets have to act on a message first |
| A finding pick comes back "Not quite" or "Blaming staff" | The cause or control you chose misses the gap or blames a person; read the reason. (The SOC Board words its version "Not enough".) |
| The triage ends below the pass mark | Re-read the authentication results and the addresses, then Try again |

## After the Game: Questions and Exercises {#after-the-game}

Work through these after you finish.

### 1. Authorisation and Planning {#q-authorise}

> Question: Explain, in your own words, what the signed rules of engagement protect. Which things on the scope sheet did you have to sort out, and why might a tester be tempted by each one that stayed out?

> Question: Gareth set one condition about how results are reported. Argue for or against it from a defender's point of view, using a practical reason as well as an ethical one.

> Action: Write a one-page rules-of-engagement outline for a phishing and social-engineering test of a small company. Cover what is in and out of scope, the point of contact, the stop-rule, how results will be reported without naming individuals, and what happens to any simulated sign-ins. Map each point to something you saw in the game.

### 2. Reconnaissance and OSINT {#q-osint}

> Question: List the public sources you used in the Recon Room and the single most useful fact each one gave up. Which fact did a defender leave exposed by accident rather than on purpose?

> Question: Some of your leads turned out to be unreliable. Which ones, and what general rule about OSINT do they teach? How would you apply it on a real engagement?

> Action: Pick an organisation you are allowed to look at (your own university or a company that has published a responsible-research or bug-bounty policy). Without touching any of its systems, write down what you can learn from its public website alone about how it is structured and how it might be contacted. Note where it is careful and where it leaks. Do not contact anyone.

### 3. Spoofing and Sender Authentication {#q-authentication}

> Question: Explain what SPF, DKIM and DMARC each check, in one sentence apiece. Then explain what the headers of your own spoofed message showed, and why it was or was not delivered.

> Question: Look back at the authentication results in the defender's inbox. Find cases where the results and the truth disagreed, and explain how each is possible. What does that tell you about trusting a single authentication result?

> Action: Find out whether a domain you control, or your university's domain, publishes SPF and DMARC records, and what the DMARC policy is set to. (You can read a domain's published DNS `TXT` records with an online lookup tool.) Write down what you found and what, if anything, you would change.

### 4. Pretexting and the Human Layer {#q-pretext}

> Question: Think about what came out of the service desk call. Whose problem was that: the operator's or the organisation's? Name the control you would put in place, and say why it works even when the person is helpful and well meaning.

> Question: Describe the approaches you tried on the phone and what each one cost you. What does that tell you about how people respond to pressure compared with a calm, honest approach?

> Action: Write the short script you would give a service desk so it can help genuine callers quickly while defeating a pretext like yours. Keep it to five steps or fewer.

### 5. Defending and Choosing Fixes {#q-defend}

> Question: For each finding in your report, state the cause and the control you chose, and explain in one line why you rejected each alternative.

> Question: Tomasz can afford one fix. Say which you would pick and why, and name one fix from the list you would not spend the money on, with your reason.

> Action: Turn your run into a short defender's note for Gareth: the gaps the engagement found, the one fix you would do first, and one measurement Ledgerwell cannot take today but could after that fix. No names.

## Further Reading {#further-reading}

- The companion lab [Human Factors and Social Engineering: Phishing]({{ site.baseurl }}/labs/cyber_security_landscape/3-phishing/), which takes the attacker's side further on a Kali VM: crafting malicious attachments and payloads and delivering them to simulated victims. This game sheet covers the human factors, reconnaissance, sender authentication and defence without any malware; the two together make a fuller picture.
- The National Cyber Security Centre guidance on phishing attacks and on using DMARC, SPF and DKIM to protect a domain, for how real organisations defend against a day like this one.
- The APWG and the NCSC "Suspicious Email Reporting Service" as examples of the report channel the game keeps asking for.
- The Cyber Security Body of Knowledge (CyBOK) chapters on Human Factors, on Adversarial Behaviours, and on Law and Regulation.
