---
title: "Symmetric Encryption with Advanced Encryption Standard (AES)"
author: ["Mohamed Hassan", "Thomas Shaw", "Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Explore symmetric encryption with the Advanced Encryption Standard (AES), and work with GPG and Python3/Cryptodome to encrypt and decrypt messages and files, while completing Hackerbot's challenges."
overview: |
  Symmetric encryption involves using the same key for both the encryption and decryption of data. In this lab, you will explore symmetric encryption with a focus on the Advanced Encryption Standard (AES). AES is a widely used block cipher that is used to protect data in many applications, including secure communications and stored data. This lab aims to provide you with a high-level understanding of AES and its fundamental operations, such as Substitution (SubBytes), Permutation (ShiftRows and MixColumns), and Key Addition (Round Key). You will also explore how to work with AES encryption and decryption using both the GPG tool and Python3 with the Cryptodome module. This practical hands-on experience will equip you with the knowledge and skills necessary to apply AES encryption to secure your data.

  Throughout this lab, you will have the opportunity to complete a series of tasks and challenges. These practical exercises will help you understand the underlying principles of AES and give you practice applying it to real files and messages.

  This is a Hackerbot lab. Work through the labsheet, then when prompted interact with Hackerbot.
tags: ["aes", "encryption", "symmetric-cryptography", "gpg", "python", "cryptodome", "hackerbot"]
categories: ["cyber_security_landscape"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AC"
    topic: "Algorithms, Schemes and Protocols"
    keywords: ["ADVANCED ENCRYPTION STANDARD (AES)", "ECB (ELECTRONIC CODE BOOK) BLOCK CIPHER MODE"]
  - ka: "AC"
    topic: "Symmetric Cryptography"
    keywords: ["symmetric primitives", "symmetric encryption and authentication"]
  - ka: "AC"
    topic: "Cryptographic Implementation"
    keywords: ["Cryptographic Libraries", "ENCRYPTION - TOOLS"]
---

## Getting started {#getting-started}

==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop

### Your login details for the "desktop" VM {#your-login-details-for-the-desktop-vm}

==VM: On the desktop VM==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the hackerbot_server, but the VM needs to be running to complete the lab.

### For marks in the module {#for-marks-in-the-module}

1. **You need to submit flags**. Note that the flags and the challenges in your VMs are different to other's in the class. Flags will be revealed to you as you complete challenges throughout the module. Flags look like this: `flag{somethingrandom}`. Submit your flags in Hacktivity to register your progress in the lab.
2. **You need to document the work and your solutions in a Log Book**. This needs to include screenshots (including the flags) of how you solved each Hackerbot challenge and a writeup describing your solution to each challenge. The Log Book will be submitted later in the semester.

{% include hackerbot-intro.md role="attack your system" chat="full" %}

# Purpose {#purpose}

The purpose of this lab is to understand the application of the **A**dvanced **E**ncryption **S**tandard (**AES**) cipher and to work with a couple of the common encryption modes it provides, such as **C**ipher **B**lock **C**haining (**CBC**) and **E**lectronic **C**ode **B**ook (**ECB**).

# Advanced Encryption Standard (AES) {#advanced-encryption-standard-aes}

AES is a symmetric block cipher: the same secret key encrypts and decrypts, and it works on fixed-size blocks of data. The block size is always 128 bits (16 bytes). The key can be 128, 192 or 256 bits long, and the key length sets how many rounds of scrambling AES applies:

| Variant | Key length | Key length in bytes | Rounds (N) |
| ------- | ---------- | ------------------- | ---------- |
| AES-128 | 128 bits   | 16 bytes            | 10         |
| AES-192 | 192 bits   | 24 bytes            | 12         |
| AES-256 | 256 bits   | 32 bytes            | 14         |

AES is an iterated cipher: it applies the same round of operations again and again, each time mixing in a different round key.

## AES: A High Level Description {#aes-a-high-level-description}

This is a basic description of AES (Stinson and Paterson, 2019).

1. **Key expansion.** From the encryption key, a key schedule derives N + 1 round keys[^1], each 16 bytes.
2. **Initial round key.** Load the 16-byte plaintext block *m* into the **State**[^2], a 4x4 grid of bytes. Combine it with the first round key using **ADDROUNDKEY**, which is a bitwise XOR of State with the round key.
3. **Main rounds.** For each of the next N - 1 rounds:
   - **SUBBYTES**[^3]: replace every byte of State with another byte, looked up in a fixed table called the S-box (substitution box). This is the non-linear step that stops AES being solved as simple algebra.
   - **SHIFTROWS**[^4]: shift row 0 of State by 0 positions, row 1 by 1, row 2 by 2 and row 3 by 3 (wrapping around), so the bytes of each column are spread across different columns.
   - **MIXCOLUMNS**[^5]: mix the four bytes of each column together, so that changing one byte affects the whole column.
   - **ADDROUNDKEY**: XOR State with this round's key.
4. **Final round.** Do SUBBYTES, SHIFTROWS and ADDROUNDKEY, but **not** MIXCOLUMNS.
5. State now holds the ciphertext block *y*.

Decryption runs the inverse of each step, in reverse order, using the same round keys.

SUBBYTES gives **confusion** (the relationship between key and ciphertext is complicated). SHIFTROWS and MIXCOLUMNS give **diffusion** (after a few rounds, changing one bit of the plaintext changes about half the bits of the ciphertext). The other steps are fixed and public; only ADDROUNDKEY brings in the key. AES is designed to stay secure even though everyone knows the algorithm, as long as the key stays secret.

> Question: AES-128 uses 10 rounds. How many round keys does it need, and why is that one more than the number of rounds?

# AES using GPG {#aes-using-gpg}

GPG (GNU Privacy Guard) can encrypt a file symmetrically with AES. You give it a **passphrase**, not an AES key. GPG generates a random **salt** and runs the passphrase and salt through a key derivation function (called S2K, "string-to-key") to produce the actual AES key. The salt and the settings are stored in the output file, along with an integrity check, so GPG has everything it needs to decrypt when you type the passphrase again.

==action: Create a file and name it msg.txt using the following command:==

```bash
echo '"Science does not aim at establishing immutable truths and eternal dogmas; its aim is to approach the truth by successive approximations, without claiming that at any stage final and complete accuracy has been achieved." - Bertrand Russell' > msg.txt
```

==action: Encrypt msg.txt producing ciphertext as output (msg.enc):==

```bash
gpg --cipher-algo AES128 -o msg.enc --symmetric msg.txt
```

==action: Check what kind of file GPG produced:==

```bash
file msg.enc
```

> Note: `file` should report symmetrically encrypted GPG/PGP data using AES (the exact wording depends on the version of `file`). If you used a different `--cipher-algo`, it will say so here. Hackerbot checks the same thing, so don't use `--armor`.

==action: Decrypt msg.enc and instruct gpg to store the plaintext output in msg.txt-decrypted:==

```bash
gpg -o msg.txt-decrypted -d msg.enc
```

> Tip: GPG's agent remembers your passphrase for a few minutes, so decryption may not ask for it. To make GPG forget it (and check you really know the passphrase), run `gpgconf --reload gpg-agent`.

> Question: Encrypt msg.txt a second time to a different output file, using the same passphrase, and compare the two files with `cmp` or `sha256sum`. Are they the same? Why not? (Hint: salt.)

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Use GPG with AES (128-bit key) to encrypt a message Hackerbot gives you in the chat, using a passphrase it also gives you, and store the resulting ciphertext at a path it specifies under your home directory.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Create the destination directory Hackerbot names (under your home directory) before encrypting, and make sure you use AES with a 128-bit key.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Hackerbot will create a directory in your home directory and place a file in it that has been encrypted with GPG using AES with a 128-bit key. Decrypt the file using the passphrase Hackerbot gives you.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the decrypted message*"==.

Don't forget to ==action: save and submit any flags!==

# AES using python3 {#aes-using-python3}

GPG hides the details. A cryptography library such as Cryptodome makes you handle them yourself: the raw key, the mode, the IV and the padding. This is how developers use AES inside their own software, and these details are where most real-world mistakes happen.

From the Linux shell (command prompt) ==action: open the python3 REPL[^6] with the following command:==

```bash
python3
```

==action: Import the AES cipher implementation from the Cryptodome module:==

```python
>>> from Cryptodome.Cipher import AES
>>>
```

Create a message *m* in byte format, hence the *b* before the string. Remember in AES we work on bytes.

```python
>>> m = b"Winter is coming"
```

Create a key *k*, again in byte format.

```python
>>> k = b"ThisIsASecretKey"
```

> Note: This key is 16 characters, so 16 bytes, so this is AES-128. Cryptodome chooses AES-128, -192 or -256 from the length of the key you give it. Try `AES.new(b"short", AES.MODE_ECB)` and read the error.

==action: Create new AES cipher object, initialised with the key *k* using ECB mode:==[^7]

```python
>>> e = AES.new(k, AES.MODE_ECB)
```

==action: Encrypt message *m* and generate ciphertext *c*:==

```python
>>> c = e.encrypt(m)
```

Inspect the ciphertext:

```python
>>> print(c)
b'b\xe8\x90l\xfaT\x04\x12\xc4\\\xe7)\x84\xdc\x84H'
>>> print(c.hex())
62e8906cfa540412c45ce72984dc8448
>>> len(c)
16
```

"Winter is coming" happens to be exactly 16 bytes, one AES block, so it encrypts to exactly 16 bytes of ciphertext.

To summarise, the lines of code used for encryption are:

```python
>>> from Cryptodome.Cipher import AES
>>>
>>> m = b"Winter is coming"
>>>
>>> k = b"ThisIsASecretKey"
>>>
>>> e = AES.new(k, AES.MODE_ECB)
>>>
>>> c = e.encrypt(m)
>>>
```

To decrypt, ==action: pass the ciphertext *c* to the AES object's decrypt() function to reveal the original message:==

```python
>>> print(e.decrypt(c))
b'Winter is coming'
>>>
```

## Bytes, hex and printed byte strings {#bytes-hex-and-printed-byte-strings}

The same 16 bytes of ciphertext can appear in three different forms, and mixing them up is the most common reason for a decryption failing:

| Form                | Example                            | Length        | What it is                                                                                                            |
| ------------------- | ---------------------------------- | ------------- | --------------------------------------------------------------------------------------------------------------------- |
| Raw bytes           | (unprintable)                      | 16 bytes      | The actual ciphertext. This is what `decrypt()` needs, and what you get from `open(path, "rb").read()`.               |
| Hex string          | `62e8906cfa540412c45ce72984dc8448` | 32 characters | Each byte written as two hexadecimal digits. Made with `c.hex()`, turned back into bytes with `bytes.fromhex(...)`.   |
| Printed byte string | `b'b\xe8\x90l\xfaT...'`            | 50 characters | How Python *displays* bytes, for humans to read. Printable bytes are shown as characters, the rest as `\x..` escapes. |

The printed byte string is only a display format. If you copy it into a file, or read text like that from a file, you have 50 characters of text, not 16 bytes of ciphertext, and `decrypt()` fails with an error like `ValueError: Data must be aligned to block boundary in ECB mode`.

To look at the raw bytes in a file from the shell, use `xxd`, which prints the hex alongside any printable characters:

```bash
xxd somefile
```

To read a binary file into Python as raw bytes, open it in **r**ead **b**inary mode:

```python
>>> with open("somefile", "rb") as f:
...   ct = f.read()
...
>>> len(ct)
```

We can also convert hexadecimal representations of byte data back into the byte format with:

```python
>>> new_ct = bytes.fromhex("da499ebff95df3e293e3e359cb20d28d")
```

> Question: Now decrypt the ciphertext above using the same key as above to reveal another message.

#### Hackerbot Attack #3 {#hackerbot-attack-3}

> Note: For attacks 3, 4 and 5, use Hackerbot's key exactly as given, as a `b"..."` byte string. Don't pass it through `bytes.fromhex()`: it is 16 characters, so 16 bytes, an AES-128 key.

You can skip the bot to here, by saying **goto 3**.

> Hackerbot: Using Python3 and Cryptodome with AES in ECB mode and a key Hackerbot gives you, encrypt a message it also gives you.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the ciphertext, in hexadecimal*"==.

> Hint: Use the byte string's `.hex()` function.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #4 {#hackerbot-attack-4}

You can skip the bot to here, by saying **goto 4**.

> Hackerbot: Hackerbot will create a directory in your home directory containing a ciphertext file. Use Python3 and Cryptodome with AES in ECB mode and a key Hackerbot gives you to decrypt the message.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Hint: The file holds raw binary ciphertext. Look at it with `xxd` first, then read it into Python with `open(..., "rb")` as shown above.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the decrypted message*"==.

Don't forget to ==action: save and submit any flags!==

# Padding and block cipher modes {#padding-and-block-cipher-modes}

## Padding {#padding}

AES only encrypts whole 16-byte blocks, so a message that isn't a multiple of 16 bytes has to be **padded** before encryption, and the padding removed after decryption. Cryptodome's `pad()` uses PKCS#7 padding: if *n* bytes are needed to fill the last block, it adds *n* bytes, each with the value *n*.

```python
>>> from Cryptodome.Util.Padding import pad, unpad
>>> pad(b"hello", 16)
b'hello\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b\x0b'
>>> pad(b"Winter is coming", 16)
b'Winter is coming\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10\x10'
```

"hello" is 5 bytes, so 11 bytes are added, each with the value 11 (`0x0b`). A message that already fills a block gets a whole extra block of padding, so `unpad()` can always tell how much to remove.

> Question: Why can't the padding scheme just skip padding when the message is already a multiple of 16 bytes?

## ECB and CBC {#ecb-and-cbc}

A **mode of operation** decides how a block cipher is applied to a message longer than one block.

**ECB** (Electronic Code Book) encrypts each block on its own, with the same key. That means identical plaintext blocks always produce identical ciphertext blocks, which leaks patterns in the data. ==action: Try it:==

```python
>>> e = AES.new(b"ThisIsASecretKey", AES.MODE_ECB)
>>> e.encrypt(b"YELLOW SUBMARINE" * 2).hex()
'd3efc21e50836380d9dc231650ceeaf7d3efc21e50836380d9dc231650ceeaf7'
```

The two halves of the ciphertext are identical, so an attacker learns that the two plaintext blocks were the same without knowing the key.

**CBC** (Cipher Block Chaining) XORs each plaintext block with the previous ciphertext block before encrypting it. The first block has no previous block, so it is XORed with an **initialisation vector (IV)**: 16 random bytes chosen fresh for each encryption. ==action: Try the same message in CBC mode:==

```python
>>> e = AES.new(b"ThisIsASecretKey", AES.MODE_CBC)
>>> e.iv.hex()
>>> e.encrypt(b"YELLOW SUBMARINE" * 2).hex()
```

The two ciphertext blocks are now different, and if you run it again you get a new IV and different ciphertext. The IV is not secret, but the person decrypting needs it, so it is normally stored or sent alongside the ciphertext.

> Question: In your own words, why is ECB a poor choice for encrypting a file that contains repeated content (for example, an image with large areas of one colour)?

# File encryption using AES and python3 {#file-encryption-using-aes-and-python3}

We will encrypt the /etc/hosts file using python3 and the Cryptodome module. Feel free to use any other file.

==tip: Generate a random key using this command in a bash shell:==

```bash
head -c16 /dev/random | xxd -ps
```

> Note: `-c16` is the number of bytes we're reading from /dev/random, the kernel's random number generator, using the head command. The raw data is passed to xxd which represents it in hexadecimal: 16 bytes become 32 hex characters.

==action: Open the python3 REPL in your terminal:==

```bash
python3
```

==action: Import the required modules:==[^8]

```python
>>> from Cryptodome.Cipher import AES
>>> from Cryptodome.Util.Padding import pad, unpad
```

==action: Open and read from the /etc/hosts file:==

```python
>>> with open("/etc/hosts", "rb") as f:
...   file = f.read()
...
>>>
```

Now let's encrypt the /etc/hosts file in CBC mode, using the key generated above (paste in your own hex key). `bytes.fromhex()` turns the 32 hex characters into the 16 raw bytes of an AES-128 key.

```python
>>> key = bytes.fromhex("71830edfe47b1b808af76fb62114b349")
>>> e = AES.new(key, AES.MODE_CBC)
>>> iv = e.iv
>>> c = e.encrypt(pad(file,16))
```

> Note: Writing `key = b"71830edfe47b1b808af76fb62114b349"` instead would give you a 32-*character* key, which Cryptodome silently treats as a 32-byte AES-256 key made only of the characters 0-9 and a-f. It works, but it isn't the random key you generated.

You can inspect the contents of the ciphertext:

```python
>>> print(c)
>>> len(file), len(c)
```

==action: To write data to a file, open the file in write binary mode:==

```python
>>> import os
>>> with open(os.path.expanduser("~/hosts.enc"), "wb") as f:
...   f.write(c)
...
>>>
```

> Note: Python does not expand `~` to your home directory the way the shell does, so `open("~/hosts.enc", "wb")` would look for a directory literally named `~`. `os.path.expanduser()` does the expansion, or you can write the full path, `/home/yourusername/hosts.enc`.

==action: Check the file from a bash shell:==

```bash
xxd ~/hosts.enc | head
```

==action: To decrypt, create a new cipher object with the same key and the same IV:==

```python
>>> d = AES.new(key, AES.MODE_CBC, iv=iv)
>>> getMsg = d.decrypt(c)
>>> print(unpad(getMsg,16))
```

> Question: Try decrypting with `AES.new(key, AES.MODE_CBC)` (no IV, so Cryptodome picks a new random one). Which part of the output is wrong, and why only that part? (Hint: look at how CBC uses the IV.)

#### Hackerbot Attack #5 {#hackerbot-attack-5}

You can skip the bot to here, by saying **goto 5**.

> Hackerbot: Using Python3 and Cryptodome with AES in ECB mode and a key Hackerbot gives you, encrypt the file Hackerbot names in the chat and write the ciphertext binary data to a `ciphertext` file inside a directory you create in your home directory.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Create the destination directory Hackerbot names before encrypting, write the ciphertext there as raw binary (not hex, base64 or a printed byte string), and pad the plaintext with `pad()` before encrypting. This attack uses ECB mode, so there is no IV.

Don't forget to ==action: save and submit any flags!==

## References {#references}

[1] Stinson, Douglas R. and Paterson, Maura B. *Cryptography Theory and Practice*. 4th edition. CRC Press, 2019.

[^1]: Each round key is 16 bytes, derived from the encryption key by the AES key schedule, so every round mixes in different key material.
[^2]: In AES, State is a 4x4 grid of bytes (16 bytes = one 128-bit block). The bytes fill it column by column.
[^3]: SubBytes uses the Rijndael S-box (see: <https://en.wikipedia.org/wiki/Rijndael_S-box>).
[^4]: See: <https://en.wikipedia.org/wiki/Advanced_Encryption_Standard#The_ShiftRows_step>.
[^5]: MixColumns multiplies each column (four bytes) by a fixed 4x4 matrix, using arithmetic in the finite field GF(2^8) (see: <https://en.wikipedia.org/wiki/Rijndael_MixColumns>).
[^6]: **R**ead-**E**valuate-**P**rint **L**oop: an interactive interpreter.
[^7]: AES can run in different modes, including Cipher Block Chaining (CBC) and Electronic Code Book (ECB). Review the documentation for the Cryptodome AES class here: <https://pycryptodome.readthedocs.io/en/latest/src/cipher/aes.html>
[^8]: ECB and CBC only work on whole 16-byte blocks, so always `pad()` before encrypting and `unpad()` after decrypting. See [Padding](#padding).
