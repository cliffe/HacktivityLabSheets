---
title: "Phishing and Social Engineering (Break Escape)"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Play a browser-based engagement as a penetration tester at Tarnside Assurance: get the rules of engagement signed, research a client from public sources, write spear-phishing email, build a look-alike login page, work a pretext call past a service desk, report the gaps without naming anyone, then switch sides and defend against your own attack. No virtual machine."
overview: |
  Ledgerwell Ltd has hired your consultancy to find out how far a phishing and social-engineering campaign could get against its staff, with one condition from the client: nobody gets named and shamed. You play the tester. You settle what is in scope and get it in writing, research Ledgerwell's people from public sources only, craft messages tailored to three targets, build a look-alike payroll page, and talk a friendly service desk into filling the gaps your research could not. Then you turn the engagement around: you triage a mixed inbox from the defender's chair, read the sender-authentication results, and turn each finding into a fix.

  The lab teaches social engineering at the level a defender needs: why open-source research makes a tailored message land, how a From line is only a label, what SPF, DKIM and DMARC actually check, how a look-alike domain is read letter by letter, and why the cheapest fixes are a report button and a call-back rule. Every outcome in the game is explained, including the ones that fail. There is no malware, no payload and no virtual machine; the companion [Human Factors and Social Engineering: Phishing]({{ site.baseurl }}/labs/cyber_security_landscape/3-phishing/) lab covers the hands-on delivery of malicious attachments on a Kali VM.

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
- plan an engagement so it measures the process, not the people, and say why naming who fell for a test is both unfair and counter-productive
- gather open-source intelligence (OSINT) about an organisation's staff, and name the kinds of tool a tester uses and what each one reveals
- explain why a tailored (spear-phishing) message lands when a generic one does not: trust, relevance, a name, a plausible attachment and timing
- describe what SPF, DKIM and DMARC each check, why a From line is only a label, and why a message that fails one check can still be genuine or still be delivered
- read a web address letter by letter and spot a look-alike domain (typo-squat, homograph, extra word, misleading subdomain), and say why a padlock does not prove who you are talking to
- recognise a pretext phone call, and explain why calling back on a number already on file defeats it
- turn findings into mitigations a small organisation can actually afford, and explain why a report button and a call-back rule beat most of the alternatives

The game teaches by doing. The questions are in this sheet, after the game.

## How to Use This Sheet {#how-to-use}

1. Read **Getting Started** and launch the game. You do not need any prior knowledge; the engagement teaches each idea as you reach it.
2. Play. Dip into **Concepts** when you reach a new idea, or come back to it afterwards.
3. If you get stuck, open **Stuck? Hints, Stage by Stage** and find the stage you are on. Each stage has a hint you can read straight away, then a stronger nudge and full steps hidden behind "Show" buttons. Open one at a time, and go back to the game after each. Ruth, your engagement lead, gives the same hints on your in-game phone.
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

You move with the arrow keys or by clicking. Click objects, people, doors and workstations to interact. Keys you collect go to the inventory bar at the bottom of the screen. Each workstation runs one tool as a small on-screen app (the research browser, the mail client, the page builder, the phone, the report, the triage inbox and the defender board).

The engagement runs through four rooms off the Engagement Office: you unlock the **Recon Room**, the **Operations Room** and the **Blue Team Room** in turn, each with a key Ruth hands you when the stage before it is done.

> Tip: Nothing in this game is scored by catching you out, and no choice is a dead end. A wrong pick comes back with the reason it was wrong, so read the feedback rather than guessing again. The "wrong" answers are there to teach, so it is worth reading why they are wrong even when you picked the right one.

> Warning: Watch the people you are attacking as well as the machines. The service desk operator, Dev, is friendly and helpful, but push him too hard and he will get suspicious, stop helping, and report your call to his manager. That is realistic, and it is recoverable, but it costs you time.

## Concepts {#concepts}

You do not need to read all of this before you play. Use it when you reach each idea, and again when you answer the questions afterwards.

### Authorisation: the line between a test and a crime {#authorisation}

Attacking an organisation's people and systems is a criminal offence under the **Computer Misuse Act 1990**, unless the organisation has agreed to it in writing first. A signed **scope** is what makes a penetration test lawful. It says what is in scope (what you may attack) and what is out of scope (what you must leave alone), who the point of contact is, and what you do if something goes wrong.

In this engagement the signed sheet puts work email to named staff, the published service-desk phone line and public OSINT in scope, and keeps personal accounts, physical entry, real customers and anything that disrupts a live service out of scope. Ruth's line sums it up: the client's signature is the difference between a test and a crime.

A good scope also has a **stop-rule**: if you stumble on a real compromise, or a real person in distress, you stop and escalate to the named contact rather than carrying on, fixing it yourself or sitting on it. A real incident is not yours to touch, and touching it could destroy evidence.

> Question: The engagement is authorised by the company that owns the systems and the staff accounts. The individual members of staff never agreed to be tested. Is it right to test people who did not personally consent? What makes it acceptable, and where would it stop being acceptable?

### Planning: measure the process, not the people {#planning}

Before you send anything, you decide what the engagement is for and what you will measure. The point here is not "disrupt payroll to prove the risk" and not "collect as many passwords as you can"; it is to find how far email and a phone pretext get, and report the gaps. A simulated sign-in is recorded as having happened and then dropped. No password leaves the test.

How you measure matters just as much. Counting **which named staff fell for it** is the tempting measure and the wrong one. Gareth's one condition is that no names appear in anything he reads, and there is a hard reason behind it: the moment people are named and blamed, they stop reporting their mistakes, and reporting is the single most useful thing a defender has. So you measure **how far each attempt got**: sent, failed, landed, page visits, and what the call gave away. That shows the risk without pointing at a person.

There is a neat twist in this stage. You might want to measure **whether staff reported the attack**, which really is the best signal there is. The problem is that Ledgerwell has no button or inbox for staff to report a suspect email, so there is nothing to count. That missing channel is itself a finding, and you will meet it again in the report.

> Question: "Reporting rate is the best measure, but we can't measure it because there's no way to report." Explain why a report button is worth more to a defender than another round of awareness training.

### Reconnaissance and OSINT {#osint}

**Open-source intelligence** is everything an attacker can learn about a target from public sources, without touching the target's systems. For a social-engineering attack it is the groundwork: the more you know about a person, the more your message looks like one they were expecting.

In the Recon Room you work three kinds of source:

| Source | What it gives up |
| --- | --- |
| The company website (team page, careers page, team notes, an old archived page) | Who works there, their roles, how to contact them, what they are busy with, and stale facts that no longer hold |
| Staff social-media posts | Who a person trusts, what they are waiting for, and small personal details that make a message feel personal |
| A published document's properties (metadata) | The author's username, the software used and file paths, left in the file because nobody cleared them |

Real testers run tools to do this at scale. You meet them as concept cards in the game:

- **Hunter** reports the address pattern a company uses, such as first-initial then surname. Read the pattern and you can write a working address for anyone you can name.
- **theHarvester** collects names, addresses and sub-domains from public sources. Its results are noisy: two people can share a name, so each hit has to be checked against what the company's own site says.
- **Recon-ng** runs many such lookups from one place. A lookup that returns nothing is a result too; it tells you not to waste time on that lead.
- **exiftool** reads a file's metadata, including the author field, which often gives away the username convention.

Two of Ledgerwell's leads are traps, and spotting them is the lesson. An **archived 2019 org chart** shows an old structure that no longer holds; acting on it sends your message to the wrong team. A **name search** turns up a second J. Baker at a plumbing firm in Leeds, no relation to the Ledgerwell colleague of the same name. Stale and mistaken-identity results are normal in OSINT, which is why you confirm a fact against a second, current source before you rely on it.

> Question: Ledgerwell's team page gives outsiders a single role inbox, `careers@ledgerwell.example`, rather than each recruiter's personal address. Why is that better for them, and what does the Hunter result tell you about the addresses they have leaked elsewhere over the years?

### Why a tailored message lands {#spear-phishing}

**Phishing** is a message that tricks someone into acting against their own interest: opening a file, following a link, or giving something away. Bulk phishing is sent to thousands and barely tailored. **Spear phishing** is aimed at one person and built from what you learned about them, which is why it is far more convincing.

A message lands when it clears the checks the target makes, usually without noticing they are making them:

- **Trust** — it appears to come from someone or something they already trust. The From line is only a label an attacker can set, so "appears to" is doing the work.
- **A name** — it greets them the way someone who actually knows them would.
- **Relevance** — it fits what they do and what they are expecting right now.
- **A plausible attachment or link** — the right kind of file from the right kind of sender, or a link that looks like the real site.
- **Timing and a little pressure** — a believable reason it matters now, pitched so it does not feel forced.

The three targets in the game show a range. An open careers inbox trusts anyone who looks like an applicant, so it is easy. A finance officer acts on mail from a colleague she trusts, so you have to borrow that colleague's identity and send the file she was expecting. A new intern only trusts notices from the payroll portal itself, so you have to get the portal's details exactly right, which your OSINT cannot give you. Each target teaches a different lever.

> Question: For each of the three targets, name the single thing that made the message believable. Which of the three would be hardest to defend, and why?

### Email spoofing and sender authentication: SPF, DKIM and DMARC {#authentication}

The From line you see in an email is just text. Nothing about plain email stops someone writing `Jed Baker <j.baker@ledgerwell.example>` in a message they sent from anywhere. **Spoofing** is exactly that: setting the From line to someone you are not. Three standards exist to catch it, and the game uses them accurately.

- **SPF** (Sender Policy Framework) answers one question: was the server that sent this message allowed to send for that domain? The domain owner publishes a list of permitted servers; the receiver checks the sending server against it.
- **DKIM** (DomainKeys Identified Mail) answers a different one: did the domain actually sign this message, and arrive unchanged? The sending domain adds a cryptographic signature; the receiver checks it with the domain's published key.
- **DMARC** (Domain-based Message Authentication, Reporting and Conformance) ties the two to the visible From address. It checks that a passing SPF or DKIM result **aligns** with the domain in the From line, and it tells receivers what to do when nothing aligns: `p=none` (deliver anyway), `p=quarantine` (send to junk) or `p=reject` (refuse it).

The catch in the game is that Ledgerwell publishes `p=none`. So your spoof of Jed Baker fails SPF and has no DKIM signature, DMARC fails, and the receiver delivers it anyway, looking as if it came from inside the company. SPF and DKIM only report; DMARC's policy decides what happens, and a policy of `none` decides nothing.

A passing check does not prove a message is safe, and a failing one does not prove it is an attack. In the defender half you meet a genuine message forwarded by a finance mailing list: SPF **fails** because the list re-sent it from its own server, but the original sender's DKIM signature survived and still aligns, so DMARC **passes**. It is real. The headers, not a gut feeling, are what tell the two apart.

```
Message              SPF    DKIM   DMARC   Verdict
Your Jed Baker spoof  fail   none   fail    phish, but delivered (p=none)
Real mail via a list  fail   pass   pass    genuine (DKIM still aligns)
```

> Question: A colleague says "the email passed DMARC, so it must be safe." Give one reason that is not quite right. Then explain what moving Ledgerwell from `p=none` to `p=quarantine` would have done to your spoof.

### Look-alike domains and links {#lookalike}

When you cannot send from the real domain, the next best thing is one that reads like it. These are the tricks, in roughly rising order of nastiness:

| Trick | Example against ledgerwell.example | How to catch it |
| --- | --- | --- |
| Unrelated name | payroll-online.example | It has no connection to the real name at all |
| One wrong letter | ledgerwall.example | Read every letter |
| An extra word | ledgerwell-hr.example | The real name is not the whole address |
| A misleading subdomain | login.ledgerwell.account-help.example | Read right to left: the real site is the label just before `.example`, here `account-help.example` |
| Typo-squat with look-alike pairs | ledgervvell.example (two v's for a w) | Read letter by letter |
| Homograph | a letter from another alphabet that looks identical | Some browsers show the `xn--` punycode form to give it away |

Two habits matter for links. **Hover** before you click: the words of a link and where it actually goes are two different things, and the status bar shows the real destination. And remember that a **padlock** only means the connection is private, not that the site is who it claims to be; a look-alike page gets a padlock just as easily as the real one.

> Question: The address `login.ledgerwell.account-help.example` is designed to make you relax when you see "ledgerwell" near the front. Which part is the real registered site, and why does reading right to left defeat the trick?

### Pretexting: social engineering by phone {#pretexting}

A **pretext** is the false identity and story you use to get someone to help you: here, a busy colleague helping a nervous new intern. Pretexting over the phone works because a helpful person on a service desk wants to solve your problem, and the checks they make are only as good as the policy they were given.

Dev, the service desk operator, is good at his job. His policy is to check a caller's claimed facts against the new-starter list: a name and a team. Both of those are on Ledgerwell's public pages, so an attacker can pass the check. What his policy does not tell him to do is call back on a number already on file, and that is the gap, not Dev.

The call is a balance. Being a calm, candid colleague keeps Dev helping. Leaning on him with false **urgency** ("she's panicking, it's her first payslip") or **borrowed authority** ("her manager said you'd sort this") makes him wary; keep pushing and he refuses, then reports the call and will not take another for a while. If you get a fact wrong and own the correction early (**candour**), it costs you less than defending it. The lesson for a defender is at the end: an attacker can fake a name and a team, but not a call back to the number the company already holds.

> Question: Dev did nothing against his policy, yet he gave away enough to make the intern's email believable. Whose problem is that, and what one change to the policy would have stopped it without making Dev's job harder?

### Defending: triage, and turning findings into fixes {#defending}

The last room flips the engagement. From the defender's chair you **triage** a mixed inbox: for each message, decide whether to trust it, report it or delete it, reading the SPF, DKIM and DMARC results and the actual addresses rather than the display names. Two of the messages are your own sends from earlier, and from this side the headers give them away. The inbox also includes a genuine message that looks suspicious (the mailing-list forward) and a phish that looks normal (a clean-looking look-alike domain), so you practise not judging by first impressions.

Then you turn each finding into a **mitigation**. The game is careful about what counts as a good fix, and the cheapest ones are often the best:

- A **report button** turns a staff member's doubt into a warning for everyone, and makes the best measure (reporting rate) possible at last.
- A **call-back rule** on the service desk defeats every pretext call, because an attacker cannot answer a call to the number on file.
- **Moving DMARC to enforcement** (quarantine or reject) plus an **external-sender banner** stops the spoof at the gateway and marks look-alike mail that DMARC cannot catch.
- **Keeping staff addresses out of published material** and **stripping metadata** from files reduce what the next attacker can learn for free.

Fixes that sound sensible but miss the point get rejected with the reason: a padlock check does not help against a padlocked fake page, forced password changes do not stop someone typing today's password into a fake page, and blaming "careless staff" hides the control gap and stops people reporting.

> Question: Tomasz, the security lead, says he will get budget for one fix this year. Which of the four above would you spend it on, and what does your choice say about where the real weakness is?

## Stuck? Hints, Stage by Stage {#hints}

Find the stage you are on. Read the hint, then go back and try. If you are still stuck, open **Nudge**. Open **Steps** last. Ruth gives the same hints on your phone, one stage at a time.

> Tip: Before you open any hint, ask yourself three questions. What check is this person or system making? What do I already know that would pass it? And where would I find what I am missing: a public page, a file's properties, or the service desk?

### Before You Start: Getting It in Writing {#hints-authorise}

**Where:** the Engagement Office, at the start. **Goal:** sort the scope, answer the stop-rule, and get Gareth to sign.

![The Rules of Engagement scope sort]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/02-rules-of-engagement.png)

> Hint: Nothing you do is lawful until the client signs the sheet. Read it, sort each card into in or out of scope, and think about what you would do if you found a real break-in mid-test.

<details markdown="1">
<summary>Nudge</summary>

Work email to named staff and the published service-desk line are the sort of thing the client is paying you to test. Personal accounts and anything that touches real customers or a live service are not, however tempting. The stop-rule is about a real compromise you did not cause: a real incident is not yours to touch, fix or ignore, so there is only one safe answer.

When you answer Gareth's opening question, the honest answer is the one that keeps people reporting: the test is about the gaps in his process, not about catching anyone out.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Read the Rules of Engagement sheet== on the table.
2. \==action: Sort each scope card== into in scope or out of scope; a wrong pile bounces back with the reason.
3. \==action: Answer the stop-rule question==.
4. \==action: Take the sheet to Gareth by the window and let him sign it==. Listen for his one condition.

</details>

> Warning: Gareth signs in person, and he has a condition about names. Hear it; it shapes how you plan and how you write the report.

### Planning the Engagement {#hints-plan}

**Where:** the Planning Whiteboard, Engagement Office. **Goal:** pick the objective and the success measure.

![The planning whiteboard]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/03-planning-whiteboard.png)

> Hint: Pick the objective that ends in a report of the gaps, with nothing broken and nobody's password kept. For the measure, think about what you can count without naming a single person.

<details markdown="1">
<summary>Nudge</summary>

The objective is about learning how far an attack gets, not about disrupting payroll or hoarding passwords. The measure is about the process, not the people: how far each attempt got. The measure that names who fell for it breaks Gareth's condition, and the measure about who reported sounds ideal but cannot be counted here, because there is no way to report yet. Noticing that gap is the point.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Open the Planning Whiteboard== and read the choices under each heading.
2. \==action: Pick the objective about finding and reporting the gaps==.
3. \==action: Pick the measure about how far each attempt got==.
4. \==action: Talk to Ruth, and take the Recon Room key== once the plan holds and Gareth has signed.

</details>

### Reconnaissance: the Recon Room {#hints-recon}

**Where:** the Recon Room (west), at the OSINT Workstation and the Case File board. **Goal:** learn enough about three people to approach them, from public sources only.

![The OSINT research browser]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/04-osint-workstation.png)

> Hint: The Case File board has a card for each target with "missing" rows. Each gap tells you what is short, and a "Stuck?" link under it points you at the source. Everything you need is public.

<details markdown="1">
<summary>Nudge: filling the cards</summary>

Use the research browser on the OSINT Workstation. The team page gives roles; the team notes and the staff social posts give what each person trusts and is waiting for; a lookup tool gives the email pattern, so you can write any staff address. One card needs the company's **username** convention, not just the address pattern, and that comes from a different kind of source.

Watch for two decoys. The archived 2019 org chart is marked as old; the second J. Baker is a plumber in Leeds. A fact you confirm from a current source beats a fact that merely fits.

</details>

<details markdown="1">
<summary>Nudge: the username pattern</summary>

A published document keeps its author's name in its properties, whether or not the author meant to leave it there. Open the company's published PDF and read its properties; the author field gives away how usernames are built. Ruth will nudge you towards it if the board says recon is otherwise complete.

**Learn it:** ==action: Open the PDF's Document properties and read the Author field== before you let the game tick the card, so you see where the leak is.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Open the OSINT Workstation and read the company site, the social profiles and the team notes==.
2. \==action: Run the lookup tool for the email pattern==, and the name search (noticing the plumber).
3. \==action: Open the published PDF's properties and read the author==.
4. \==action: Fill all three cards on the Case File board==, then take the Operations Room key from Ruth.

</details>

> Warning: If a source will only open behind a login, it is off the sheet. Recon here is public sources only.

### First Two Sends: the Operations Room {#hints-easy-sends}

**Where:** the Operations Room (east), at the Mail Workstation. **Goal:** get the careers inbox and then Melanie Pierce to act on a message.

![The mail composer, building a spear-phish]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/06-mail-composer.png)

> Hint: The careers inbox trusts anyone who looks like an applicant. Melanie only acts on mail from a colleague she trusts, so the question is how to look like that colleague.

<details markdown="1">
<summary>Nudge: the careers inbox</summary>

An inbox whose whole job is to open files from strangers will open yours. Apply as a candidate, attach the kind of file the careers page asks applicants to send, and it lands. Real applicants write from a webmail address, so a throwaway account looks the part; you can also create one in the mail client, though for a quick test the guest workstation works and Ruth will tell you what that costs.

</details>

<details markdown="1">
<summary>Nudge: Melanie Pierce</summary>

Melanie checks who a message is from, whether it greets her properly, whether it is relevant, and whether the attachment is one she would expect. Your recon tells you who she trusts in Finance, what she is expecting from him, and when. Send as that person, at his real address built from the pattern, greet her by the name a colleague would use, and attach the file she was expecting.

One trap: the throwaway webmail account can only send as itself. To set the From line to the colleague's address you need the account that allows it. If the sender's **name** and **address** belong to two different people, she will not bite.

**Learn it:** ==action: Before you send, say out loud which of Melanie's four checks each part of your message is meant to pass==.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Send to the careers inbox as an applicant, with the file type the careers page asks for==.
2. \==action: Switch to the account that lets you set the From line==.
3. \==action: Compose to Melanie as the colleague she trusts==: his real address, her name, the file she expects.
4. \==action: Send, and read the reply or the factor feedback== if it did not land.

</details>

> Warning: "Delivered" is not "landed". A message lands only when the target would act on it the way they would a real one. If it fails, the feedback names which check it failed; fix that one thing.

### Preparing for Sofia: the Page and the Call {#hints-prepare}

**Where:** the Operations Room, at the Desk Phone and the Page Builder. **Goal:** call the service desk for the portal's name, its sender and the payslip date, then build a look-alike payroll page. Call first: the Page Builder waits until you know what Sofia would expect to see.

![The page builder and its look-alike domain choices]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/07-page-builder.png)

> Hint: Sofia the intern only trusts her payroll portal's own notices. Your recon knows she uses a portal, but not its name, its sender or when payslips go out. The service desk knows all three.

<details markdown="1">
<summary>Nudge: the look-alike page</summary>

The Page Builder scores your page against what would convince Sofia: the brand (the portal she actually uses), the domain, the logo and the wording. The domain is the hard part. A domain that reads nothing like the real one, or has an obvious extra word, scores low; the convincing ones are the look-alikes that pass a quick glance. Match the wording to a real payslip notice, and avoid the version riddled with spelling slips.

</details>

<details markdown="1">
<summary>Nudge: the pretext call</summary>

Ring the service desk from the desk phone as a colleague helping the new intern. Know her name and team before you dial; Dev checks both against the new-starter list, and both are on the public pages. Then ask for what you are missing: the portal's name and sending address, and the release date.

Stay calm and candid. False urgency or dropping a manager's name makes Dev wary; keep it up and he refuses and reports the call, and you wait before he will talk again. If you named the wrong team, own the correction straight away rather than arguing it.

![The pretext call to Dev on the service desk]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/08-service-desk-call.png)

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Call the service desk from the desk phone==, opening as the intern's colleague with her name and team.
2. \==action: Ask for the portal's name and sender, and the payslip release date==.
3. \==action: Keep Dev calm==: avoid urgency and borrowed authority, and correct any mistake openly.
4. \==action: Open the Page Builder==, match the brand, a convincing look-alike domain and the right wording, and build to its pass score.

</details>

> Warning: The careers page names Ledgerwell's finance tools, but that is not Sofia's payslip portal. If a system blank will not take what you tried, you have the wrong system; ask the desk for the real one.

### The Hard Send: Sofia Lord {#hints-hard-send}

**Where:** the Mail Workstation. **Goal:** put the page and the call facts together and land a message on Sofia.

> Hint: Now you have everything Sofia checks: the portal's sender, its name, the release date, and a page that looks like her portal. Use all of it in one message.

<details markdown="1">
<summary>Steps</summary>

1. \==action: Compose to Sofia as the portal's own notification sender==.
2. \==action: Greet her by her first name, the way the portal would==.
3. \==action: Write a payslip-ready pretext with the portal's name and the release date==.
4. \==action: Attach the look-alike page as the link, and send==.

</details>

> Warning: Sofia will not act on a link with no page behind it, or a page that fell short in the builder. If the send fails on the link, open the page in the builder and see which part lost the score.

### Writing the Report {#hints-report}

**Where:** the Report Workstation, Engagement Office (it unlocks once all three targets have acted). **Goal:** answer two questions on the results, then pair each finding with a cause and a control. No names.

![The report workstation]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/09-report-workstation.png)

> Hint: The results table counts sends, landings, page visits and the call outcome. One thing it cannot count is whether anyone reported the attack, because there is no way to report. For the findings, the right cause and control name a gap the organisation can close, never a person to blame.

<details markdown="1">
<summary>Nudge</summary>

For the first question, look at what the tables actually count and ask which thing is missing from all of them. For the second, think about what a "first send landed" column tells you that "landed in the end" does not: a target who fell to the first try had no warning, and every failed send was a chance to spot it.

For each finding, some wrong causes sound reasonable (a spam filter, a careless member of staff) and some wrong controls sound sensible (training, SPF alone, password expiry, checking the padlock). Read why each is wrong before you pick again; the explanations are the lesson.

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Read the results table==, then answer the two questions under it.
2. \==action: Pair each of the three findings with a cause and a control==, reading the feedback on any wrong pick.
3. \==action: File the report==, take the Blue Team Room key from Ruth, and hear Gareth's reply by the window.

</details>

> Warning: A cause or control that blames a person is always the wrong one. Blame on paper stops the whole floor owning up.

### Defending: the Blue Team Room {#hints-defend}

**Where:** the Blue Team Room (north), at the Triage Workstation and the SOC Board, with Tomasz. **Goal:** triage a mixed inbox and choose a fix for each exposure.

![The triage inbox with header results]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/10-triage-inbox.png)

> Hint: Sort each message into trust, report or delete, reading the SPF, DKIM and DMARC results and the real addresses, not the display names. A passing check only proves which domain sent it; read the domain itself, letter by letter.

<details markdown="1">
<summary>Nudge: the triage</summary>

Two of these messages are your own earlier sends, and the headers give them away now. One genuine message fails SPF because a mailing list forwarded it, yet its DKIM signature still aligns, so it is real. One phish passes every authentication check because a look-alike domain really sent it; the trick is in the address, not the headers. Read addresses right to left and letter by letter. You need to clear the pass mark; if you fall short, Try again is offered and nothing is lost.

</details>

<details markdown="1">
<summary>Nudge: the SOC board</summary>

The board asks for one fix per exposure your recon exploited: the leaked address pattern, and the username leaking through file metadata. For each, one option actually closes the gap and the others only look busy. Read why the weak options fall short.

![The SOC board defender choices]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/11-soc-board.png)

</details>

<details markdown="1">
<summary>Steps</summary>

1. \==action: Triage every message== in the inbox, reading the authentication results and the addresses.
2. \==action: Pass the triage==, retrying if your first pass is short.
3. \==action: Choose a mitigation for each exposure on the SOC Board==.
4. \==action: Take Tomasz's debrief== to close the engagement.

</details>

> Note: Tomasz warns you before the debrief, because it closes the engagement and rolls the credits. If you want to finish anything first, including hearing Gareth's reply to your report, choose "Not yet"; the debrief waits.

### The Debrief {#hints-debrief}

**Where:** Tomasz, in the Blue Team Room. **Goal:** close the engagement.

![The closing credits]({{ site.baseurl }}/assets/images/cyber_security_landscape/phishing_and_social_engineering_game/12-credits.png)

> Hint: Tomasz asks which one fix he should spend his only budget on this year. There is no wrong answer, but each choice says something about where the real weakness is. Pick the one you would defend, then read what he says back.

## What the Tools and the Game Are Telling You {#error-messages}

| You see | It usually means |
| --- | --- |
| A scope card bounces back | You sorted it into the wrong pile; the line tells you which rule it breaks |
| The Recon Room / Operations Room / Blue Team Room door is locked | The stage before it is not finished; Ruth hands you each key when it is |
| The board says a target card is incomplete | A "missing" row still needs a public source; the "Stuck?" link points at it |
| The board says recon is done but Ruth asks about the PDF | You have not read the published PDF's properties yet, so the username card is still open |
| A send fails with a factor marked "✗" | That one check failed; read the line and fix only that part |
| "The name and the address belong to two different people" | Your From name and From address do not match; use the trusted person's real address |
| "You're still sending as yourself" | You are on an account that cannot spoof; switch to the one that sets the From line |
| The "which system" blank will not take your answer | You used a finance tool, not Sofia's payslip portal; ask the desk for the real one |
| "There's no page behind that link" | Build the look-alike page in the Page Builder and attach it before sending to Sofia |
| Dev says he will run it past his manager, and the phone locks out | You pushed too hard; wait a little, then call back calmly with your facts straight |
| The report workstation says there is nothing to write up | All three targets have to act on a message first |
| A finding pick comes back "Not enough" | The cause or control you chose misses the gap or blames a person; read the reason |
| The triage ends below the pass mark | Re-read the authentication results and the addresses, then Try again |

## After the Game: Questions and Exercises {#after-the-game}

Work through these after you finish.

### 1. Authorisation and Planning {#q-authorise}

> Question: Explain, in your own words, what the signed rules of engagement protect, and name three things the game kept out of scope. For each, say why a tester might be tempted and why it stays out.

> Question: The game measures how far each attempt got and refuses to name who fell for it. Give the practical reason, not just the ethical one, that naming people would make Ledgerwell less safe.

> Action: Write a one-page rules-of-engagement outline for a phishing and social-engineering test of a small company. Cover what is in and out of scope, the point of contact, the stop-rule, how results will be reported without naming individuals, and what happens to any simulated sign-ins. Map each point to something you saw in the game.

### 2. Reconnaissance and OSINT {#q-osint}

> Question: List the public sources you used in the Recon Room and the single most useful fact each one gave up. Which fact did a defender leave exposed by accident rather than on purpose?

> Question: Two of your leads were traps: an archived org chart and a namesake at another company. What general rule about OSINT do they teach, and how would you apply it on a real engagement?

> Action: Pick an organisation you are allowed to look at (your own university or a company that has published a responsible-research or bug-bounty policy). Without touching any of its systems, write down what you can learn from its public website alone about how it is structured and how it might be contacted. Note where it is careful and where it leaks. Do not contact anyone.

### 3. Spoofing and Sender Authentication {#q-authentication}

> Question: Explain what SPF, DKIM and DMARC each check, in one sentence apiece. Then explain why your spoof of a trusted colleague was delivered anyway.

> Question: In the defender's inbox, one genuine message failed SPF and one phishing message passed every check. Explain how each of those is possible, and what it tells you about trusting a single authentication result.

> Action: Find out whether a domain you control, or your university's domain, publishes SPF and DMARC records, and what the DMARC policy is set to. (You can read a domain's published DNS `TXT` records with an online lookup tool.) Write down what you found and what, if anything, you would change.

### 4. Pretexting and the Human Layer {#q-pretext}

> Question: Dev followed his policy and still gave away what the attack needed. Explain why "the operator should have known better" is the wrong finding, and name the control that actually closes the gap.

> Question: Describe the pressure techniques you could use on Dev and what each one cost you. Why does a calm, candid approach beat leaning on urgency or authority?

> Action: Write the short call-back script you would give a service desk so it can help genuine callers quickly while defeating a pretext like yours. Keep it to five steps or fewer.

### 5. Defending and Choosing Fixes {#q-defend}

> Question: For each of the three findings in the report, state the cause and the control the game treated as correct, and explain in one line why each rejected alternative fell short.

> Question: Tomasz can afford one fix. Say which you would pick and why, and name one fix from the list you would not spend the money on, with your reason.

> Action: Turn your run into a short defender's note for Gareth: the three gaps the engagement found, the one fix you would do first, and one measurement Ledgerwell cannot take today but could after that fix. No names.

## Further Reading {#further-reading}

- The companion lab [Human Factors and Social Engineering: Phishing]({{ site.baseurl }}/labs/cyber_security_landscape/3-phishing/), which takes the attacker's side further on a Kali VM: crafting malicious attachments and payloads and delivering them to simulated victims. This game sheet covers the human factors, reconnaissance, sender authentication and defence without any malware; the two together make a fuller picture.
- The National Cyber Security Centre guidance on phishing attacks and on using DMARC, SPF and DKIM to protect a domain, for how real organisations defend against a day like this one.
- The APWG and the NCSC "Suspicious Email Reporting Service" as examples of the report channel the game keeps asking for.
- The Cyber Security Body of Knowledge (CyBOK) chapters on Human Factors, on Adversarial Behaviours, and on Law and Regulation.
