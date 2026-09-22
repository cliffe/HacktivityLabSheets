---
title: "Public-key Cryptography: Asymmetric Key Encryption with RSA"
author: ["Thomas Shaw", "Mo Hassan"]
license: "CC BY-SA 4.0"
description: "Learn public key cryptography through the RSA cipher: generate key pairs, encrypt and decrypt with OpenSSL and Python, and work through the maths by hand."
overview: |
  Public key cryptography (also known as asymmetric encryption) enables secure communication, digital signatures, and data encryption without the need for a shared secret key. In this lab you will explore public key cryptography, specifically the RSA (Rivest-Shamir-Adleman) cipher, one of the most widely used asymmetric encryption methods. This lab will help you understand the fundamental principles of RSA encryption, key pair generation, and encryption/decryption processes. You will also interact with Hackerbot, a chatbot designed to challenge and test your knowledge as you progress through the exercises.

  Throughout this lab, you will learn the key concepts and procedures related to RSA encryption. You will start by generating RSA key pairs and performing encryption and decryption operations using both OpenSSL and Python. You will pick prime numbers, calculate modulus and phi(N), select encryption and decryption keys, and apply these concepts to encrypt and decrypt messages. The lab includes various Hackerbot challenges that you will complete, such as creating key pairs, encrypting and decrypting messages, and solving encryption-related quizzes. These practical exercises will deepen your understanding of RSA encryption and help you gain hands-on experience in using this cryptographic technique to secure information and communication.
tags: ["cryptography", "rsa", "asymmetric-encryption", "public-key", "openssl", "python"]
categories: ["cyber_security_landscape"]
lab_sheet_url: "https://cliffe.github.io/HacktivityLabSheets/labs/cyber_security_landscape/7-asymmetric-enc-rsa/"
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AC"
    topic: "Algorithms, Schemes and Protocols"
    keywords: ["CRYPTOGRAPHY - ASYMMETRIC - RSA", "DIFFIE-HELLMAN ALGORITHM"]
  - ka: "AC"
    topic: "Public-Key Cryptography"
    keywords: ["public-key encryption", "public-key signatures", "RSA MODULUS", "RSA PROBLEM", "RSA TRANSFORM"]
  - ka: "AC"
    topic: "Key Management"
    keywords: ["key generation"]
  - ka: "AC"
    topic: "Cryptographic Implementation"
    keywords: ["Cryptographic Libraries", "ENCRYPTION - TOOLS"]
---

# Public-key Cryptography - Asymmetric Key Encryption with RSA

## Getting started {#getting-started}

### VMs in this lab {#vms-in-this-lab}

==action: Start these VMs== (if you haven't already):
- hackerbot_server (leave it running, you don't log into this)
- desktop

### Your login details for the "desktop" VM {#your-login-details}

==VM: On the desktop VM==, ==action: check who you're logged in as:==

```bash
whoami
```

Password: tiaspbiqe2r (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't login to the hackerbot_server, but the VM needs to be running to complete the lab.

{% include hackerbot-intro.md role="interact with you and challenge you with RSA encryption tasks" chat="full" %}

## Purpose {#purpose}

The purpose of this lab is to understand public key cryptography, specifically the RSA[^1] cipher.

## RSA and PKI[^2] in a nutshell {#rsa-and-pki-in-a-nutshell}

RSA is considered to be the most popular asymmetric cipher out there, which has been used for many years and still stands. RSA is also part of a bigger picture called Public Key Infrastructure or PKI in short.

The problem with establishing a secure communication is the trust:
- How can we confirm the identity of each party who would like to communicate securely (using cryptography)?
- How can we validate the data being transferred?
- How can we confirm this is x person/entity/website's public key?

Consider Alice wants to send a message to Bob, and she has Bob's public key. Who can confirm Bob is really Bob? It could be anyone else impersonating Bob (perhaps a Man In The Middle).

This is where a Certification Authority (CA) comes in. We assume this CA is a trusted, independent entity (usually a company) who will sign (and confirm the identity of) the public key of anyone who wants to communicate securely. The CA is part of PKI, alongside hardware, software, management (and control), and standards such as PKCS[^3].

There is a reading list related to PKI and managing trust in public key cryptosystems provided at the end of the lab sheet (References [1] to [5]).

[^1]: RSA named after the three creators (Ron **R**ivest, Adi **S**hamir and Leonard **A**dleman)
[^2]: Public Key Infrastructure
[^3]: Public Key Cryptography Standards (developed by RSA security LLC) - https://en.wikipedia.org/wiki/PKCS

## A summary of the RSA cipher {#a-summary-of-the-rsa-cipher}

1. Choose two large prime numbers *p* and *q*

2. Compute **N (the modulus):**

    N = p . q

3. Compute **phi(N):**

    phi(N) = (p-1)(q-1)

4. Choose the encryption (exponent) key (public key) **e** (**e** must satisfy two conditions):

- a number in between 1 and phi(N)
- a co-prime with N and phi(N)

5. Choose the decryption key (private key) **d:**

    (e . d) mod phi(N) = 1

We can compute **d** by using the **extended Euclidean algorithm** to get the inverse of **e**

    d = (e^-1) mod phi(N)

**Encryption/Decryption operations:**

Encryption:

    (M^e) mod N

Decryption:

    (C^d) mod N

Where:
- **M** is the message (clear/plain text)
- **e** is the public key (the encryption key)
- **N** is the modulus
- **C** is the ciphertext, and
- **d** is the private key (decryption key)

## An example of RSA using OpenSSL {#an-example-of-rsa-using-openssl}

==action: Create a new message file:==

```bash
echo '"All paid jobs absorb and degrade the mind." - Aristotle' > msg.txt
```

Nice one from Aristotle, but no one will work then :)

The below is just an example of using OpenSSL to encrypt and decrypt a message. Of course a private key should never be shared and/or exported in plaintext.

```bash
# *** Generate a 4096-byte RSA private key using openssl
openssl genrsa -out bobs-private-key.private 4096
# *** Check Bob's private key ***
cat bobs-private-key.private
# * it should start with -----BEGIN RSA PRIVATE KEY-----
# *** Generate a public key from the private key ***
openssl rsa -in bobs-private-key.private -pubout -out bobs-public-key.pub
# *** Check Bob's public key ***
cat bobs-public-key.pub
# * it should start with -----BEGIN PUBLIC KEY-----
# *** Encrypt msg.txt ***
openssl pkeyutl -in msg.txt -encrypt -pubin -inkey bobs-public-key.pub > msg-rsa.enc
# *** Decrypt msg-rsa.enc ***
# *** Step 2 - Decrypt msg-rsa.enc
openssl pkeyutl -in msg-rsa.enc -decrypt -inkey bobs-private-key.private | tee msg-decrypted.txt
```

[^4]: https://www.quoteambition.com/aristotle-quotes/

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Create a public and private RSA key pair, using the file names Hackerbot gives you, within a directory Hackerbot names in the chat.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #2 {#hackerbot-attack-2}

You can skip the bot to here, by saying **goto 2**.

> Hackerbot: Create another public and private RSA key pair, then encrypt a message (given to you in the chat) with the public key and save the encrypted output to a file, all within a directory Hackerbot names in the chat.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

## An example of RSA using Python3 {#an-example-of-rsa-using-python3}

In this example we will go through the following steps:

- Pick 2 prime numbers, *p* and *q*
- Calculate *N*
- Calculate *phi(N)*
- Select exponent *e* (used for encryption)
- Select *d* (used for decryption)

==action: From your Linux shell prompt, open the python3 REPL to begin:==

```bash
python3
```

### Pick 2 prime numbers p and q {#pick-2-prime-numbers-p-and-q}

```
>>> p = 7
>>> q = 23
```

### Calculate N {#calculate-n}

```
>>> N = p * q
```

### Calculate phi(N) {#calculate-phin}

```
>>> phiN = (p-1)*(q-1)
>>> print(p, q, N, phiN)
```

So far we have calculated: *p* = 7, *q* = 23, *N* = 161 and *phiN* = 132

### Find e (exponent / encryption key / public key) {#find-e}

- *e* must be between 1 and 132 (1 and *phi(N)*)
- Also, *e* must be a co-prime with *N* and *phi(N)*

1. Check all of the numbers in the ring (1-132), once the above conditions are met, select *e*
2. Let's keep it simple and choose 5 as e (as it satisfies both conditions)
3. For this example, the public key (e, N) is (5, 161)

### Find d (decryption key / private key) {#find-d}

- *d* must satisfy this condition (*d*.*e*) mod phi(N) = 1
- *d* will always be within the 1-132 ring of integers

To find the decryption key, multiply each number of the ring (modulo 132) until you reach 1

- Such that (d * 5) mod 132 = 1

Let's select *d* as 53

- Such that d = 53

(53 * 5) % 132 = 1

### Encryption {#encryption}

RSA works using numbers, so let's find the integer representation of this message: "The Hobbit"

Python's built in ord() function takes in a character as an argument and returns the integer that represents the character in [ASCII](https://www.rapidtables.com/code/text/ascii-table.html).

e.g. `ord('Z')` will return 90.

```
>>> ord('T')
>>> ord('h')
>>> ord('e')
>>> ord(' ')
>>> ord('H')
>>> ord('o')
>>> ord('b')
>>> ord('i')
>>> ord('t')
>>> ord('t')
*** 84 104 101 32 72 111 98 105 116 116 ***
(84 ** e) % N
(104 ** e) % N
(101 ** e) % N
(32 ** e) % N
(72 ** e) % N
(111 ** e) % N
(98 ** e) % N
(105 ** e) % N
(116 ** e) % N
(116 ** e) % N
*** Ciphertext: 7 41 54 100 151 34 140 119 93 93 ***
*** To decrypt ***
(7 ** d) % N
(41 ** d) % N
... etc ...
... etc ...

*** Decrypted message: 84 104 101 32 72 111 98 105 116 116 ***
>>> chr(84)   # T
>>> chr(104)  # h
>>> chr(101)  # e
... etc ...
... etc ...
```

> Note: `chr()` is the inverse of `ord()`, where `chr` takes an integer representation of a character as a parameter and returns the associated character.

#### Hackerbot Attack #3 {#hackerbot-attack-3}

You can skip the bot to here, by saying **goto 3**.

> Hackerbot: Using the example values above (p = 7, q = 23, N = 161, phiN = 132, e = 5, d = 53), decrypt the ciphertext Hackerbot gives you in the chat.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the decrypted message*"==.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #4 {#hackerbot-attack-4}

You can skip the bot to here, by saying **goto 4**.

> Hackerbot: Using the example values above (p = 7, q = 23, N = 161, phiN = 132, e = 5, d = 53), encrypt the message Hackerbot gives you in the chat.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the encrypted ciphertext*"==.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #5 {#hackerbot-attack-5}

You can skip the bot to here, by saying **goto 5**.

> Hackerbot: Perform RSA encryption by hand with p = 3, q = 5, e = 3, and the message (an integer, not an ASCII character) Hackerbot gives you in the chat.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the ciphertext*"==.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #6 {#hackerbot-attack-6}

You can skip the bot to here, by saying **goto 6**.

> Hackerbot: Perform RSA decryption by hand with p = 3, q = 5, e = 3, and the ciphertext (raw value) Hackerbot gives you in the chat.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the message*"==.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #7 {#hackerbot-attack-7}

You can skip the bot to here, by saying **goto 7**.

> Hackerbot: Perform RSA encryption by hand with p = 7, q = 17, e = 11, and the message (an integer, not an ASCII character) Hackerbot gives you in the chat.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the ciphertext*"==.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #8 {#hackerbot-attack-8}

You can skip the bot to here, by saying **goto 8**.

> Hackerbot: Perform RSA decryption by hand with p = 7, q = 17, e = 11, and the ciphertext (raw value) Hackerbot gives you in the chat.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the message*"==.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #9 {#hackerbot-attack-9}

You can skip the bot to here, by saying **goto 9**.

> Hackerbot: Perform RSA encryption by hand with p = 47, q = 59, e = 17, and the message (an integer, not an ASCII character) Hackerbot gives you in the chat.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the ciphertext*"==.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #10 {#hackerbot-attack-10}

You can skip the bot to here, by saying **goto 10**.

> Hackerbot: Perform RSA decryption by hand with p = 47, q = 59, d = 157, and the ciphertext Hackerbot gives you in the chat.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the message*"==.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #11 {#hackerbot-attack-11}

You can skip the bot to here, by saying **goto 11**.

> Hackerbot: Given p = 7, q = 11, work out the suitable values for e.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the suitable values for e, in ascending order, separated by spaces*"==.

Don't forget to ==action: save and submit any flags!==

#### Hackerbot Attack #12 {#hackerbot-attack-12}

You can skip the bot to here, by saying **goto 12**. This is the final challenge.

> Hackerbot: Given p = 7, q = 11, e = 13, work out d.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

There is a quiz to complete: once Hackerbot has run the attack, ==action: answer with "answer *the value of d*"==.

Don't forget to ==action: save and submit any flags!==

## Resources {#resources}

[1] Terence Spies. "Chapter 39 - Public Key Infrastructure". In: *Computer and Information Security Handbook (Second Edition).* Ed. by John R. Vacca. Second Edition. Boston: Morgan Kaufmann, 2013, p. 703. ISBN: 978-0-12-394397-2. DOI: https://doi.org/10.1016/B978-0-12-394397-2.00039-8. URL: https://www.sciencedirect.com/science/article/pii/B9780123943972000398

[2] Tiffany Hyun-Jin Kim et al. "Accountable key infrastructure (AKI) a proposal for a public-key validation infrastructure". In: *Proceedings of the 22nd international conference on World Wide Web.* 2013, pp. 679-690.

[3] Johannes Buchmann et al. *Introduction to public key infrastructures.* Vol. 36. Springer, 2013.

[4] Aysha Albarqi et al. "Public key infrastructure: A survey". In: *Journal of Information Security* 6.01 (2014), p. 31.

[5] Dimitrios Lekkas. "Establishing and managing trust within the public key infrastructure". In: *Computer Communications* 26.16 (2003), pp. 1815-1825.

[6] S. Stinson Douglas and B. Paterson Maura. *Cryptography Theory and Practice*. 4th edition. CRC Press, 2019.

[7] Bruce Schneier. *Applied Cryptography*. 2nd edition. John Wiley & Sons, 1996.

[8] Keith M. Martin. *Everyday Cryptography*. 2nd edition. Oxford University Press, 2017.
