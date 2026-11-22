---
title: "Cyber Aware: Facilitator Guide"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "For the people who run Cyber Aware with their staff: training leads, HR and L&D teams, and IT managers. How the course runs, what each episode covers and roughly how long it takes, what the before-and-after checks measure, what you can and cannot change in Hacktivity, how reporting works, and what the course does and does not yet offer for accessibility."
overview: |
  Cyber Aware is a security-awareness course made of short, browser-based episodes. Each one is set at a fictional company. In most episodes the learner first sees how a scam is put together, from the attacker's side, on an authorised exercise. Then they swap seats and sort the messages, calls, pages or visitors that arrive, and a debrief explains every answer. A short check before and after a course shows what changed.

  This guide is for organisers deciding whether and how to run it. You do not need a security background. It covers the course flow, the episodes, the checks, your controls in Hacktivity, reporting and accessibility, and ends with a checklist for launch. It does not give puzzle answers: the episodes explain themselves as learners play.
tags: ["security-awareness", "cyber-aware", "phishing", "social-engineering", "facilitator-guide", "organisers", "break-escape", "game-based-learning"]
categories: ["cyber_aware"]
type: ["game-based-learning", "guide"]
source: "https://github.com/cliffe/BreakEscape/tree/main/scenarios"
cybok:
  - ka: "HF"
    topic: "Human Factors"
    keywords: ["Security awareness", "Phishing", "Social engineering", "Reporting", "Usable security"]
---

## Who This Guide Is For {#who}

You run training for a team or an organisation and you are thinking of using Cyber Aware. This guide tells you what your staff will do, how long it is likely to take, what you will see afterwards, and which settings are yours to change.

> **About the times in this guide.** Every time given here is an estimate. The figures come from the course's own descriptions, which say "about 15 minutes" for a full episode. Timed runs with real staff have not yet been done, so plan with some slack.

## The Attacker's Side {#attackers-side}

Most awareness training tells people what to look out for. Cyber Aware shows them how the trick is made first.

In a typical episode the learner joins an authorised exercise at a fictional company. They look at what the company has made public, then put together one message, call or page the way a criminal would: picking a believable reason to get in touch, borrowing someone's authority, adding a little time pressure. The episode then shows what that gets the attacker. Only after that does the learner sit in the target's seat and meet the same kind of attack in a normal working day.

Why do it this way round:

- **The tells make sense.** Once someone has chosen an urgent deadline or a senior name to make a request land, they recognise those choices when they arrive in their own inbox.
- **It explains why careful people get caught.** The attack works because it looks like ordinary work. That keeps the tone away from blame.
- **It is more interesting.** Learners make choices and see what follows, rather than reading slides.

What learners build stays at the level of the pattern: the kind of message, the reason it is believable, and the check that would stop it. They work from templates and made-up details inside the game. Nothing they do would help them attack a real organisation, the course never asks for real passwords or personal details, and every sign-in page or form in it is a model that captures nothing.

Treat this approach as a reasoned design choice. There is good evidence from security teaching that seeing the attacker's reasoning helps people defend, but no controlled study yet shows that a short attacker-view game makes non-technical staff safer. Your before-and-after checks are the way to see whether it works for your people.

Five episodes have no attacker to play (see [Consequence episodes](#consequence-episodes)). In those the learner makes everyday choices under ordinary pressure, then sees where each choice led.

## How a Course Runs {#course-flow}

A Cyber Aware course is a list of missions, meant to be played in the order shown. Most courses look like this:

| Step | What it is | Scored? | Estimated time |
|---|---|---|---|
| 1. Before you start | A short brief at the first company: how the course works, that nothing real is asked for, what is recorded and who sees it, the habit to keep, and how to report. It opens every course except Refresher drills and Annual refresher. Nothing in it is scored. | No | About 5 minutes |
| 2. Starting check | Ten items to sort, taken once before the episodes. | Kept for comparison | About 8 to 10 minutes |
| 3. Episodes | Two to four episodes on the course's topic (the Complete programme has all of them). | The defend half only | About 15 minutes each (full) |
| 4. Final check | Ten new items of the same kinds, compared with the starting check. | Yes | About 8 to 10 minutes |

### Inside a full episode

Each full episode runs at a kiosk in a company training room and steps through five parts:

1. **Brief.** The company, the role and the job for today.
2. **Attack half.** The learner researches what the company has made public and builds one message, call or page. This half is never scored.
3. **Flip.** The learner sees their own attack arrive in an inbox, from the target's side.
4. **Defend half.** The learner sorts what arrives. For most items they choose Trust, Report, Delete or (on some) Verify; calls, sign-in prompts and a few cards have their own answers, such as Ring back or Ask first. Then they tick what gave it away. This half is scored.
5. **Debrief.** Every answer explained, including the real items, then the habit to keep, your organisation's way to report, and a no-blame line.

Reporting a real item is never marked down: in the defend half a Report on a genuine message scores the same as trusting it. The course wants people who are unsure to report.

The debrief opens with a short headline. The default bands are "Well done", "Getting there" and "Worth practising". Some answers count as critical, such as trusting a phish email, approving a sign-in prompt the learner did not start, or doing what an unchecked caller asks, because in real life they hand over the account. A critical miss keeps the round out of the top band.

### Spot-it versions

Every episode also has a **spot-it** version: no attack half, just the defend half and the debrief, in about 8 minutes. The Refresher drills course is all twenty of them. They suit second-year learners and sessions under half an hour.

### Consequence episodes {#consequence-episodes}

Episodes 11, 15, 16, 19 and 20 have no attacker to play. In the first half the learner makes the ordinary choices anyone makes on a busy day, then sees, some months later in the story, where each one led. Then they sort a set of items as usual. Episode 17 (acceptable use) exists only as a spot-it version.

## The Courses {#courses}

Hacktivity offers twelve Cyber Aware courses (Hacktivity also lists Cyber Security Foundations, a separate hands-on course). Eleven are built from the episodes below; the twelfth, Incident simulations, is a separate set of longer cases and is not covered here.

The rough totals add up the per-mission estimates (brief 5, each check about 9, full episode 15 or 16, spot-it 8 or so). They are planning figures only.

| Course | What is in it | Check pair | Rough total |
|---|---|---|---|
| Introduction to cyber threats | Brief, starting check, E5, E8, E1, E9, final check | All staff | About 85 minutes |
| Payment fraud | Brief, starting check, E1, E4, E7, final check | Finance | About 70 minutes |
| Social engineering | Brief, starting check, E3, E12, E14, final check | All staff | About 70 minutes |
| Phishing and fake messages | Brief, starting check, E2, E5, E8, final check | All staff | About 70 minutes |
| AI and new scams | Brief, starting check, E6, E10, E13, final check | All staff | About 70 minutes |
| Passwords and accounts | Brief, starting check, E9, E18, final check | All staff | About 55 minutes |
| Handling data and conduct | Brief, starting check, E11, E16, E17 (spot-it), final check | Data and conduct | About 65 minutes |
| Devices and working away | Brief, starting check, E15, E19, E20, final check | All staff | About 70 minutes |
| Complete programme | Brief, starting check, every full episode once, E17 (spot-it), year-end review, final check | All staff | About 5½ hours, over several sittings |
| Refresher drills | The twenty spot-it versions, in any order. No checks. | None | About 8 minutes each (E17 about 12) |
| Annual refresher | Year-end review (a spot-it run of the year's tricks), then the final check | All staff (final only) | About 20 minutes |

Each course also has its own one-line habit, shown in the debrief. For example, Payment fraud's is: "Before you pay, or change anyone's bank details, ring a number you already hold. Never use the one in the message, however senior it sounds."

Learners can stop between missions and come back later. A course does not need to be done in one sitting.

## The Episodes {#episodes}

Five fictional companies host the episodes: Brightwell Foods, Tarrowby Logistics (a haulier), Quayholt Insurance, Merrin & Sallow Architects, and Carrholme Services (a support-services firm). The "for" column is who each episode was written for; any member of staff can play any episode.

| # | Episode | Company | Written for | What the learner does | Full | Spot-it |
|---|---|---|---|---|---|---|
| E1 | Invoice fraud | Brightwell Foods | Finance | Sends one look-alike invoice email, then guards the payments inbox | ~15 min | ~8 min |
| E2 | CV lures | Tarrowby Logistics | HR and recruitment | Uses a real vacancy to send one job-application lure, then sorts the recruitment inbox | ~15 min | ~8 min |
| E3 | Help desk password resets | Quayholt Insurance | IT service desk | Rings the service desk as a locked-out member of staff, then takes the desk seat for three callers | ~15 min | ~8 min |
| E4 | Executive impersonation | Merrin & Sallow Architects | Executive assistants and PAs | Poses as a travelling managing partner, then covers the PA's inbox and voicemail | ~15 min | ~8 min |
| E5 | Fake sign-in pages | Quayholt Insurance | All staff | Builds a look-alike sign-in page and sends one email, then tells real sign-in pages from fakes | ~15 min | ~8 min |
| E6 | Texts and QR codes | Tarrowby Logistics | Staff with a work phone | Sends one fake parking text, then sorts texts and printed QR notices on a phone | ~16 min | ~8 min |
| E7 | Cloned voices and the CEO | Brightwell Foods | All staff (the cross-role finale) | Writes one urgent payment request in the chief executive's name, then covers the finance office's phone and inbox, where a cloned voice turns up | ~16 min | ~8 min |
| E8 | After the click | Quayholt Insurance | All staff | Sends one email dressed up as IT, then sits in the seat of a colleague who clicked and works out what to do next | ~15 min | ~8 min |
| E9 | Passwords and password managers | Tarrowby Logistics | All staff | Sees how public details and a reused password open accounts, then defends their own account | ~15 min | ~8 min |
| E10 | Fake downloads and checks | Quayholt Insurance | All staff | Builds a fake "verify you are human" check, then sorts a morning of web pages, prompts and downloads | ~15 min | ~8 min |
| E11 | Misdirected data | Carrholme Services | All staff | Consequence episode: a busy morning's choices about personal data, and where they led | ~15 min | ~8 min |
| E12 | Visitors and tailgating | Merrin & Sallow Architects | All staff | As the red team in a courier's hi-vis, tries the front desk, then covers reception | ~15 min | ~8 min |
| E13 | The AI assistant | Brightwell Foods | All staff | As the red team, writes a supplier brief for the firm's AI assistant, then works beside the assistant | ~15 min | ~8 min |
| E14 | Social media and oversharing | Merrin & Sallow Architects | All staff | Finds what one colleague's public posts give away, then sorts a feed and an inbox | ~15 min | ~8 min |
| E15 | Shadow IT | Tarrowby Logistics | All staff | Consequence episode: shortcuts under a Friday deadline, and where they led | ~15 min | ~8 min |
| E16 | Insider risk | Quayholt Insurance | All staff | Consequence episode: a leaver's last week, and how to raise a concern as facts, not a verdict | ~15 min | ~8 min |
| E17 | Acceptable use | Tarrowby Logistics | All staff | Spot-it only: everyday "can I?" questions against the firm's rules, and a short inbox | n/a | ~12 min |
| E18 | Password guessing at scale | Merrin & Sallow Architects | All staff | Sees how attackers try one common password across every account at once, then tells genuine security alerts from fakes | ~15 min | ~8 min |
| E19 | Malware, ransomware and updates | Quayholt Insurance | All staff | Consequence episode: everyday calls at a desk, and where they led | ~15 min | ~8 min |
| E20 | Working away from the office | Tarrowby Logistics | Staff who work away from the office | Consequence episode: two days on the road (a train, a café, a hotel) and a morning at home | ~15 min | ~8 min |

All times are estimates from the episodes' own descriptions. The opening brief says episodes take "roughly 10 to 15" minutes; a careful first-timer may take longer.

## The Checks {#checks}

Each course except Refresher drills and Annual refresher has a pair of checks: a **starting check** before the episodes and a **final check** after them. Annual refresher has the final check only. Each is ten items from a fictional company's inbox, phone or queue, such as emails, a sign-in prompt, a web page, calls or texts. The learner sorts each one the same way as in the episodes. Answers are explained at the end of a check, not item by item. The final check uses new items of the same kinds, and its end screen compares the result with the starting check.

### Default and role versions

Each course comes with one check pair. Most use the all-staff pair; Payment fraud uses the finance pair and Handling data and conduct uses the data and conduct pair. Each check listing has this note for organisers:

> This is the course's default check pair. Role versions of this check (finance, HR, helpdesk, executive, mobile, data and conduct) are available; contact Hacktivity to switch.

Each role version tests the channel that role meets in its episodes. The help-desk check, for instance, uses calls, a voicemail, emails and a sign-in prompt from a service-desk queue. You cannot swap the check yourself (see [What you can and cannot change](#hacktivity)).

### What the checks measure

Each check records the items, the learner's answers, the clues they ticked and the times. It stores no free text. You see a result for each learner (see [What you see](#what-you-see)). The rule for reading it is:

> Measurement: the first course a learner takes is the measure. Read its before-and-after pair as the result. Later courses reuse the same items, so treat their pairs as practice, not a fresh measure.

In practice:

- Use the first course each person takes as your baseline-and-result. If you want a clean measure, pick that first course with care.
- Reporting a genuine item is never marked down, so a high result on its own does not show careful judgement: a learner who reports everything can still score well. The game keeps a separate figure that tells the two apart, but Hacktivity does not show it yet (see [What you see](#what-you-see)).
- A rise from the starting check to the final check within one sitting tells you about that course. It does not prove people will behave differently months later.

## Running Cyber Aware in Hacktivity {#hacktivity}

Organisations take Cyber Aware in one of two ways:

1. **Opt your members in to the shared courses.** You choose which of your plan's courses your members can play. The shared courses are the same for every organisation, and you cannot change them.
2. **Copy a course for your organisation.** Each course has a template titled "Cyber Aware: &lt;course&gt;". Copying it gives your organisation its own course, with its own dates, enrolment, settings and progress page. This needs a plan that includes Cyber Aware and free seats.

If you want your own reporting route in the debrief, your own dates, or a progress page for your learners, use option 2.

### What you can and cannot change {#can-cannot}

"Organiser" here means a member of your organisation with organiser rights in Hacktivity (a VIP or account manager).

| You can | You cannot |
|---|---|
| Choose which shared courses your members can play | Change a shared course |
| Copy a course template into your organisation, if your plan includes Cyber Aware and you have free seats | Copy a course that is already your organisation's copy, or a template outside your plan |
| On your copy: change the title, description, start and end dates, the FAQ link and the scoreboard setting | Change your organisation's other settings |
| On your copy: invite learners by email | Take one learner off one course only (ask Hacktivity) |
| Remove a member's access to all your organisation's courses (the organisation page's Remove access/seat) | Create a course from scratch, or delete one |
| On your copy: set the reporting route, rule of thumb and team size | Set the course's habit line |
| On your copy: choose whether learners see their check result, which attempt counts, and a pass mark for the final check | Edit any mission listing: add, remove or reorder episodes, swap a check for a role version, or change a listing's settings |
| Set your organisation's default reporting route | Edit the organiser note on a check listing |
| See progress and results for your learners, and download them as CSV | See learners' written feedback on the course |

Copying duplicates the template as it is. When you copy, a box marked "Copy awareness settings (reporting route, rule of thumb, team size)" is ticked by default. Leave it ticked to keep the course's own habit line and default settings, then set your own reporting route on the copy, or clear the copy's route (see [Reporting](#reporting)). Any change to the list of missions, including a role check, goes through Hacktivity.

If you set a rule of thumb, it replaces the course's habit line in every debrief. Leave it blank to keep the habit line.

The copy form's "Weeks offset for dates" starts at 52, which moves the course a year ahead. Set it to 0 (or the weeks you want) before you copy, or your learners will not be able to start.

After copying, sign up to your copy yourself. Hacktivity only lets you edit it and see its progress page once you are enrolled.

### What you see {#what-you-see}

The progress page for your copy shows, for each learner: how far they have got, who is inactive, and for each Cyber Aware mission a result as a percentage, a report rate, and their first and best results. By default the first attempt counts for the checks and the best attempt counts for episodes. You can change that, and you can hide percentages from learners (they still see counts such as "Phish caught 3 of 4"). You can export the page as CSV (percentages and status; the report rate and first and best results are on the page only).

The game also records a figure that tells careful reporters apart from people who report everything. It is meant for organisers in aggregate, but Hacktivity does not show it yet, and there is no cohort-level before-and-after view yet either.

### What learners are told about their data

The opening brief tells every learner that the course records items, verdicts, ticked clues and times, with no free text, and that their organiser can see their name, email, progress and results. It points them to your organisation's privacy notice. Make sure that notice covers this before you launch.

## Reporting {#reporting}

### Reporting inside the course

In almost every defend half and check, **Report** (or a check-first answer such as Ring back or Ask first) is one of the answers. The course teaches that reporting when unsure is never wrong and that reporting your own mistake quickly is thanked, not blamed.

### Your real reporting route

Every debrief ends with a "How to report here" box, and the feedback on a Report answer adds a line beginning "At work, that means:". Both show the reporting route set for the course. Set it so it matches what your staff should really do.

You build the route from up to four standard options, filling in your own details, plus an optional "anything else" paragraph:

- Use the Report button in your mail app
- Forward it to an address, then delete it
- Call the service desk on a number
- Log it with the service desk (portal or ticket)
- Where to report suspicious calls and texts
- Tell your manager
- What to do if someone has already clicked

All text is plain text, with no links or formatting. The heading can be up to 80 characters and the whole route up to 600. Email addresses and phone numbers are checked when you save, and hidden or control characters are removed.

**Where to set it.** The route is taken from the first of these that has one: the mission listing, then the course, then the organisation that owns the course.

- On a copied course with the box ticked, the template's general route comes across and hides your organisation's default. Either set your own route on the copy, or clear the copy's route so your organisation default shows.
- Your organisation's default (on the organisation's "Reporting route" page) applies to your organisation's courses that set no route of their own.
- On the shared courses, learners see the general default: use the Report button, tell your manager, and "If you are not sure which route your organisation uses, ask your IT or security team today."

### Reporting a problem with the course

When a learner finishes a mission, its page offers a rating from 1 to 5 and an optional comment of up to 2,000 characters. Comments are cleaned before they are stored and go to Hacktivity staff; organisers cannot read them. For anything you need answered, such as a fault, a wrong answer or a request to switch a check, contact Hacktivity directly.

## Accessibility {#accessibility}

Full accessibility work on the course has been deferred. This section describes only what the course offers today. No accessibility statement has been published.

### What exists now

| Area | What the course does today |
|---|---|
| Keyboard | Arrow keys or WASD to walk, E to interact. In conversations, number keys 1 to 9 pick a choice and Space continues. Esc closes a window. The course windows (inbox, pages, builder, debrief) can be used by keyboard. A mouse or tap also works. |
| Spoken lines | Character lines are always shown as text on screen, whether or not audio plays. Voicemail items are shown with a transcript. |
| Volume | Separate sliders for music, sound effects, voices and overall volume. |
| Display | The pause menu's Display page has a theme, HUD size and game zoom. |
| Reading text | Messages, web addresses and pages are set in a plain, readable typeface (Source Sans 3), with look-alike web addresses drawn exactly as typed. |
| Pausing | Esc or the menu button opens a pause menu. The checks and episodes have no countdowns and no time limits. |
| Colour | Right and wrong answers are marked with a tick or a cross as well as colour. |
| Motion | Animations in the course windows are turned off when the device asks for reduced motion. The training rooms have no flickering lights. |
| Screen readers | The course windows have labels and announce score changes politely. |
| Small screens | Course windows switch to a single column on narrow screens, with large touch targets. |

### What is not there yet

- No caption on or off setting (lines are always shown as text) and no text-size setting beyond HUD size, game zoom and browser zoom.
- No text-only version of the course. The walking parts of each episode are drawn on a canvas, which a screen reader cannot read.
- No full screen-reader test and no formal accessibility audit.
- Pausing stops the game scene but may not stop every in-game clock.
- Sound effects such as ringtones have no text alternative.

If someone on your team may struggle with any of these, try the course with them before launch, or start them on the spot-it versions, which are shorter and skip the attack half.

## Before You Launch: Checklist {#checklist}

- [ ] Choose a course for each group. For most staff, Introduction to cyber threats is the usual first course. Remember that the first course anyone takes is the one to measure.
- [ ] Decide whether to opt members in to a shared course or copy one. Copy it if you want your own reporting route, dates or progress page.
- [ ] If a group needs a role check (finance, HR, help desk, executive, mobile, data and conduct), contact Hacktivity before learners start.
- [ ] On your copy, set the reporting route to match what staff really do, and check it reads well in a debrief.
- [ ] Decide whether learners see their check percentage, which attempt counts, and whether to set a pass mark for the final check.
- [ ] Check your privacy notice covers what the course records and who can see it.
- [ ] Play the opening brief and one episode yourself.
- [ ] Tell staff it is practice at fictional companies, that nothing real is asked for, that reporting when unsure is never wrong, and roughly how long to set aside.
