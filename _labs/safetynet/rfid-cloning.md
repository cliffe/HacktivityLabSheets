---
title: SAFETYNET Field Guide - RFID Cloning
layout: lab
description: Optional in-game guide for reading and cloning MIFARE access cards to move through a building
game_fragment: true
permalink: /labs/safetynet/rfid-cloning/
redirect_from:
  - /labs/m03_ghost_in_the_machine/safetynet-field-guide-rfid-cloning/
---

# SAFETYNET Field Guide: RFID Cloning

## Objective

Use this guide when a door is gated by an RFID reader and someone in the building is carrying the card that opens it. The workflow is always the same three steps: **read** the card, **crack** its keys if it is encrypted, then **emulate** the cloned card at the reader. What changes between cards is how much work the crack takes.

## Quick Reference

- Cards used here are 13.56 MHz **MIFARE Classic**. Data lives in sectors, each protected by a key.
- **Weak-default cards** use factory or well-known keys. A dictionary of default keys recovers them almost instantly.
- **Custom-key cards** use non-default keys. You recover them with a key-recovery attack (darkside / nested / hardnested), which takes longer — expect it to grind through the sectors rather than pop instantly.
- Read → crack → **emulate**. A door reader wants the card presented, not a file on a laptop.

Real-world tooling this models (Proxmark3 / Flipper Zero):

```bash
# Read the card and attempt default keys
hf mf autopwn                 # try dictionary of known/default keys

# When defaults fail (custom keys), run a recovery attack
hf mf darkside                # recover a first key with no known key
hf mf nested                  # expand from one known key to the rest

# Save, then present the clone to the target reader
hf mf sim                     # emulate the recovered card
```

## Core Workflow

1. Get the reader (or your cloner) within range of the card — a few centimetres. In the field that means proximity to the person carrying it; keep them still and unbothered.
2. Read the sectors. If the card answers with default keys, you are done in seconds.
3. If the card uses custom keys, launch the recovery attack and let it work through the sectors. Stay in range until it completes.
4. Save the recovered card.
5. Walk to the locked reader and emulate the saved card to open the door.

## Common Failure Modes

- Read fails or drops partway: You lost proximity. Get back in range and restart the read; a half-read card cannot be emulated.
- Dictionary attack finds nothing: The card is not using defaults. Switch to the key-recovery attack instead of retrying the dictionary.
- Recovery attack seems stuck: It is slow by design on custom keys. Keep the card in range and let it finish rather than aborting and starting over.
- Door still will not open with a saved card: Confirm you saved the *right* card and that you are emulating rather than trying to read again.

## Mission Application

This building has two cards worth taking. The receptionist's staff badge uses weak defaults and opens the conference area — a near-instant dictionary clone, learned by necessity because you cannot reach Victoria without it. Victoria's executive keycard uses custom keys and opens the server room — capture it during the meeting and let the recovery attack run while you keep her talking. If you would rather not be subtle, a downed cardholder drops the physical card, and a physical keycard opens the reader just the same.
