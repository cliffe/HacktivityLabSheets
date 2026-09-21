---
title: "Symmetric Encryption with Advanced Encryption Standard (AES)"
author: ["Mohamed Hassan", "Thomas Shaw", "Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Explore symmetric encryption with the Advanced Encryption Standard (AES), and work with GPG and Python3/Cryptodome to encrypt and decrypt messages and files, while completing Hackerbot's challenges."
overview: |
  Symmetric encryption involves using the same key for both the encryption and decryption of data. In this lab, you will explore symmetric encryption with a focus on the Advanced Encryption Standard (AES). AES is a widely used block cipher that plays a significant role in securing data in various applications, from secure communications to data protection. This lab aims to provide you with a high-level understanding of AES and its fundamental operations, such as Substitution (SubBytes), Permutation (ShiftRows and MixColumns), and Key Addition (Round Key). You will also explore how to work with AES encryption and decryption using both the GPG tool and Python3 with the Cryptodome module. This practical hands-on experience will equip you with the knowledge and skills necessary to apply AES encryption to secure your data.

  Throughout this lab, you will have the opportunity to complete a series of tasks and challenges. These practical exercises will help you understand the underlying principles of AES and equip you with the skills to apply this encryption technique to real-world scenarios, ensuring the security and confidentiality of your data.

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

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop

### Your login details for the "desktop" VM {#your-login-details-for-the-desktop-vm}

\==VM: On the desktop VM==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the hackerbot_server, but the VM needs to be running to complete the lab.

### For marks in the module {#for-marks-in-the-module}

1. **You need to submit flags**. Note that the flags and the challenges in your VMs are different to other's in the class. Flags will be revealed to you as you complete challenges throughout the module. Flags look like this: `flag{somethingrandom}`. Submit your flags in Hacktivity to register your progress in the lab.
2. **You need to document the work and your solutions in a Log Book**. This needs to include screenshots (including the flags) of how you solved each Hackerbot challenge and a writeup describing your solution to each challenge. The Log Book will be submitted later in the semester.

{% include hackerbot-intro.md role="attack your system" pidgin="full" %}

# Purpose {#purpose}

The purpose of this lab is to understand the application of the **A**dvanced **E**ncryption **S**tandard (**AES**) cipher and to work with a couple of the common encryption modes it provides, such as **C**ipher **B**lock **C**haining (**CBC**) and **E**lectronic **C**ode **B**ook (**ECB**).

# Advanced Encryption Standard (AES) {#advanced-encryption-standard-aes}

AES is a block cipher based on a symmetric key cryptosystem and it is an iterated cipher (up to 14 rounds of iteration, based on the key size). It uses key sizes of 128, 192, or 256 bits. However, it operates on a block size of 128-bit.

## AES: A High Level Description {#aes-a-high-level-description}

This is a basic description of AES (Stinson and Paterson, 2019).

1. Given a message (plaintext) *m*, initialise **State**[1](#user-content-fn-1) to be *m*, add Round Key[2](#user-content-fn-2) (**ROUNDKEY**), then XOR it with **State**.
2. For each N - 1 rounds, do a substitution operation (**SUBBYTES**)[3](#user-content-fn-3) on **State** using pre-defined s-box (substitution-box); then perform permutation using (**SHIFTROWS**)[4](#user-content-fn-4) followed by (**MIXCOLUMNS**)[5](#user-content-fn-5) on **State** and then add (**ROUNDKEY**).
3. On the last round perform all of the operations in stage 2 **except** the **MIXCOLUMNS** operation.
4. Generate the ciphertext *y*.

# AES using GPG {#aes-using-gpg}

\==action: Create a file and name it msg.txt using the following command:==

```bash
echo '"Science does not aim at establishing immutable truths and eternal dogmas; its aim is to approach the truth by successive approximations, without claiming that at any stage final and complete accuracy has been achieved." - Bertrand Russell' > msg.txt
```

\==action: Encrypt msg.txt producing ciphertext as output (msg.enc):==

```bash
gpg --cipher-algo AES128 -o msg.enc --symmetric msg.txt
```

\==action: Decrypt msg.enc and instruct gpg to store the plaintext output in msg.txt-decrypted:==

```bash
gpg -o msg.txt-decrypted -d msg.enc
```

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

From the Linux shell (command prompt) ==action: open the python3 REPL[6](#user-content-fn-6) with the following command:==

```bash
python3
```

\==action: Import the AES cipher implementation from the Cryptodome module:==

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

\==action: Create new AES cipher object, initialised with the key *k* using ECB mode:==[7](#user-content-fn-7)

```python
>>> e = AES.new(k, AES.MODE_ECB)
```

\==action: Encrypt message *m* and generate ciphertext *c*:==

```python
>>> c = e.encrypt(m)
```

Inspect the message *m* after the encryption (ciphertext):

```python
>>> print(c)
b'b\xe8\x90l\xfaT\x04\x12\xc4\\\xE7)\x84\xdc\x84H'
>>> print(c.hex())
>>>62e8906cfa540412c45ce72984dc8448
>>>
```

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

We can also convert hexadecimal representations of byte data back into the byte format with:

```python
new_ct = bytes.fromhex("da499ebff95df3e293e3e359cb20d28d")
```

> Question: Now decrypt the ciphertext above using the same key as above to reveal another message.

#### Hackerbot Attack #3 {#hackerbot-attack-3}

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

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the decrypted message*"==.

Don't forget to ==action: save and submit any flags!==

# File encryption using AES and python3 {#file-encryption-using-aes-and-python3}

We will encrypt the /etc/hosts file using python3 and the Cryptodome module. Feel free to use any other file.

\==action: Open the python3 REPL in your terminal:==

```bash
python3
```

\==action: Import the required modules:==[8](#user-content-fn-8)

```python
>>> from Cryptodome.Cipher import AES
>>> from Cryptodome.Util.Padding import pad, unpad
```

\==action: Open and read from the /etc/hosts file:==

```python
>>> with open("/etc/hosts", "rb") as f:
...   file = f.read()
...
>>>
```

\==tip: You can generate a random key using this command in a bash shell:==

```bash
head -c16 /dev/random | xxd -ps
```

> Note: `-c16` is the number of bytes we're reading from the /dev/random pseudorandom number generator using the head command. The raw data is passed to xxd which represents it in hexadecimal.

Now let's encrypt the /etc/hosts file, using the key randomly generated above.

```python
>>> key = b"71830edfe47b1b808af76fb62114b349"
>>> e = AES.new(key, AES.MODE_CBC)
>>> c = e.encrypt(pad(file,16))
```

You can inspect the contents of the ciphertext:

```python
>>> print(c)
```

\==action: To write data to a file, open the file in write binary mode:==

```python
>>> with open("~/hosts.enc", "wb") as f:
...   f.write(c)
...
>>>
```

\==action: To decrypt:==

```python
>>> d = AES.new(key, AES.MODE_CBC)
>>> getMsg = d.decrypt(c)
>>> print(unpad(getMsg,16))
```

#### Hackerbot Attack #5 {#hackerbot-attack-5}

You can skip the bot to here, by saying **goto 5**.

> Hackerbot: Using Python3 and Cryptodome with AES in ECB mode and a key Hackerbot gives you, encrypt the file Hackerbot names in the chat and write the ciphertext binary data to a `ciphertext` file inside a directory you create in your home directory.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

> Note: Create the destination directory Hackerbot names before encrypting, write the ciphertext there as raw binary (not hex or base64), and pad the plaintext with `pad()` before encrypting.

Don't forget to ==action: save and submit any flags!==

## References {#references}

[1] Stinson, Douglas R. and Paterson, Maura B. *Cryptography Theory and Practice*. 4th edition. CRC Press, 2019.

## Footnotes

1. In AES State is a 4x4 matrix. [↩](#user-content-fnref-1)
2. Individual Round Keys are generated for each round of encryption, based on the encryption key using a key schedule AES uses the four transformations above. [↩](#user-content-fnref-2)
3. The SubBytes transformation replaces the values in State with other values, making use of the Rijndael S-box (see: https://en.wikipedia.org/wiki/Rijndael_S-box). [↩](#user-content-fnref-3)
4. The ShiftRows transformation shifts the data in the rows 4x4 state matrix based on an offset. (see: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard#The_ShiftRows_step). [↩](#user-content-fnref-4)
5. The MixColumns transformation switches the values of the columns in the 4x4 state matrix using matrix multiplication (see: https://en.wikipedia.org/wiki/Rijndael_MixColumns). [↩](#user-content-fnref-5)
6. **R**ead-**E**valuate-**P**rint **L**oop - an interactive interpreter. [↩](#user-content-fnref-6)
7. AES can run in different modes, including Cipher Block Chaining (CBC) and Electronic Code Book (ECB). Review the documentation for the Cryptodome AES class here: https://pycryptodome.readthedocs.io/en/latest/src/cipher/aes.html [↩](#user-content-fnref-7)
8. The pad and unpad functions are needed for ECB and/or CBC mode(s). [↩](#user-content-fnref-8)
