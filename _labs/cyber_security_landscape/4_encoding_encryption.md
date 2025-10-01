---
title: "Introduction to Cryptography: Encoding and Encryption"
author: ["Mo Hassan", "Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Learn essential cryptography concepts through hands-on practice with encoding schemes, hash algorithms, OpenSSL, and GPG. Master data encoding, symmetric and asymmetric encryption, and key management."
overview: |
  Cryptography is a fundamental aspect of information security, enabling us to secure data from prying eyes and malicious actors. This hands-on lab will equip you with essential knowledge and skills related to encoding schemes, hash algorithms, and the use of tools like OpenSSL and Gnu Privacy Guard (GPG). You'll explore concepts like encoding data into different formats, encrypting and decrypting information, and managing keys. These skills are crucial for anyone interested in the field of cybersecurity, data protection, or simply understanding how secure communication works in the digital age.

  Throughout the lab, you'll learn to encode strings into various formats, including hexadecimal and Base64. You'll experiment with symmetric key encryption using the Data Encryption Standard (DES) and the Advanced Encryption Standard (AES). Additionally, you'll explore public-key cryptography with GPG, creating and managing keys, encrypting and decrypting data, and understanding the importance of key pairs.

  In the home directory of your VM there are a series of encoding and encryption CTF challenges for you to complete, to put your knowledge into practice.
tags: ["cryptography", "encoding", "encryption", "openssl", "gpg", "base64", "aes", "des"]
categories: ["cyber_security_landscape"]
lab_sheet_url: "https://docs.google.com/document/d/1wKm2c7yxhM-9GnAiS_Mgvk_8-H7FKEBeGeMc6H0KlwA/edit?usp=sharing"
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AC"
    topic: "Algorithms, Schemes and Protocols"
    keywords: ["Encoding vs Cryptography", "Caesar cipher", "Vigenere cipher", "SYMMETRIC CRYPTOGRAPHY - AES (ADVANCED ENCRYPTION STANDARD)"]
  - ka: "F"
    topic: "Artifact Analysis"
    keywords: ["Encoding and alternative data formats"]
  - ka: "WAM"
    topic: "Fundamental Concepts and Approaches"
    keywords: ["ENCODING", "BASE64"]
---



## Purpose

The purpose of this lab is to familiarise students with common encoding schemes, hash algorithms, basic OpenSSL and Gnu Privacy Guard (GPG).

## Introduction to Encoding and Encryption

There are lots of different ways of representing information. **Encoding methods** are designed to be reversible and involve transforming data into different formats. In contrast, **encryption** involves transforming data into a format that is only readable with a key or password.

Encoding and encryption are important concepts, and the ability to identify and apply these are highly relevant skills to develop. In this lab you will familiarise yourself with common encoding methods, and some fundamental and common encryption schemes.

> Note: You will apply these skills time and time again throughout your academic and working life in IT and cyber security. Digital forensics makes extensive use of encoding/decoding, to make sense of digital artefacts, and this also applies to other cyber security topics.

## Are you ready to encode some data?

**Encoding data** involves changing it into a new format using a reversible scheme. Encoding is reversible – data can be encoded into a format then decoded back to the original format. Usually encoding is done using publicly known schemes, and is typically done to make it easier to transfer, store, or use data. Encoding is often applied for compatibility reasons.

> Tip: You can use `iconv -l` command to list all the known coded character sets ☺.  

In this section you learn how to use Linux Command Line Interface (CLI) to encode/decode using some of those schemes.

## Character Encoding and ASCII

For example, the string "hello!" can be represented in ASCII (decimal):
* 104 101 108 108 111

ASCII (American Standard Code for Information Interchange) is a character encoding scheme for electronic communication. Character encoding schemes translate text into a format so that they can be stored and transferred electronically. Most modern character encoding schemes, such as Unicode (UTF-8 being the most common) are based on ASCII, and support many more symbols, such as emoji (😃).

In the above example, we are using a decimal format: base 10, like our typical number system we use in mathematics, using the 10 numbers: 0, 1, 2, 3, 4, 5, 6, 7, 8, and 9.

## Convert a string to byte and then to hex

You can use any Linux distribution for this lab, please refer to Hacktivity guide to create your own VM.

==action: Open Linux CLI and type python3 (to open python3 command prompt) followed by the code below:==

```python
myString="Valhalla!".encode('utf-8')  
myStringInHex=myString.hex()  
print(myStringInHex)  
# Of course you can use print function directly  
print(myString.hex())
```

## Hexadecimal (base 16) and Binary (base 2)

Likewise "hello!" also translates to "68 65 6c 6c 6f 21" in hex (hexadecimal), and "01101000 01100101 01101100 01101100 01101111 00100001" in binary.

==action: Run these commands in a Linux shell:==

```bash
echo hello! | xxd -b
```

```bash
echo hello! | xxd
```

Hexadecimal (also known simply as "hex") is a base 16 numeral system. That is, the information is represented using the 16 symbols: 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, a, b, c, d, e, f.

Hex is also a common way of displaying "binary data"; that is, non-text data, which is not human readable. For example, pixels in an image are not made up of human readable text (if binary data is translated to ASCII it results in gibberish use of symbols).

> Note: There are many practical reasons for doing these translations between formats. For example, if we want to store any data to disk (whether text or an image), the storage medium itself records data in a binary format.

## Base64

Another popular encoding method is Base64, which uses the symbols: 0-9, a-Z, A-Z, +, /, and also uses = for padding. Base64 is often used with Web technologies, as a safe way of encoding binary data (and is more efficient than using hex).

Base-N encoding is simply a representation of sequence octets in a form that allows the use of both upper and lowercase letters but that need not be human readable. In Base-64, a 65-character subset of US-ASCII is used, enabling 6 bits to be represented per printable character. (The extra 65th character, "=", is used "usually" for padding). The encoding process represents 24-bit groups of input bits as output strings of 4 encoded characters. Proceeding from left to right, a 24-bit input group is formed by concatenating 3 8-bit input groups. These 24 bits are then treated as 4 concatenated 6-bit groups, each of which is translated into a single character in the base 64 alphabet. Each 6-bit group is used as an index into an array of 64 printable characters. The character referenced by the index is placed in the output string\[RFC4648\]

![][image-2]
*Figure 1: The Base 64 Alphabet*

![][image-3]
*Figure 2: Example of base64 encoding (no padding used)*

![][image-4]
*Figure 3: Example of base64 encoding (with pad "=")*

==action: Open Linux CLI and type the following commands:==

```bash
echo "0x14fb9c03d97e" | xxd -r -p | base64  
echo "0x14fb9c03" | xxd -r -p | base64  
```

> Note: The output should match the above examples (figures 2 and 3)

==action: Another basic example of encoding and decoding data using base64:==

```bash
echo "Valhalla" | base64  
```

Output: 
```
VmFsaGFsbGEK
```

==action: To decode:==

```bash
echo "VmFsaGFsbGEK" | base64 -d  
```
```
Valhalla
```

> Tip: Congratulations! you are now an expert in encoding and decoding data ☺

## Let's do a bit more

==action: Still using Linux command prompt:==

```bash
echo "Valhalla" | xxd -p  
```
```
56616c68616c6c610a
```

```bash
echo "Valhalla" | base64 | xxd -p  
```
```
566d4673614746736247454b0a
```

```bash
echo "566d4673614746736247454b0a" | xxd -r -p | base64 -d  
```
```
Valhalla
```

==action: Try to understand what is going on and use different words/strings...==  

> Hint: Use `man base64` and `man xxd` to understand the command options/switches...

==action: Let's create a file and name it fruitSalad.txt==

We'll use iconv command, which is a tool to convert text from one character encoding to another.

> Tip: You can use `iconv -l` to list known encoding scheme.

```bash
cat << EOF > fruitSalad.txt  
Banana =+  
Orange ?!  
Apple &^%  
Strawberry $"/  
Appricot ' |Z  
$Grapefruit%  
==-Graps?()  
EOF
```

==action: Convert fruitSalad.txt to something else:==

```bash
iconv -f ASCII fruitSalad.txt -t EBCDIC-CP-GB -o fileEncoded.xyz
```

```bash
cat fruitSalad.txt
```

==action: To reverse the operation (decode), run this command:==

```bash
iconv -f EBCDIC-CP-GB fileEncoded.xyz -t ASCII  
```

> Hint: Use `man iconv` to understand the command options/switches...

## Introduction to Cryptography and Encryption

**Cryptography** is the study of secure communication in the presence of third parties, or "the art and science of concealing meaning" (Matt Bishop). The word "cryptography" is from Greek words meaning "secret writing". Cryptography can maintain data security in an insecure environment. Modern crypto employs complex math to achieve this. The emphasis of this lab is on implementation and system security, not the mathematics itself.

## Simple encryption/decryption using OpenSSL

OpenSSL is a cryptography toolkit implementing the Secure Sockets Layer (SSL v2/v3) and Transport Layer Security (TLS v1) network protocols and related cryptography standards required by them.  
The openssl program is a command line tool for using the various cryptography functions of OpenSSL's crypto library from the shell. It can be used for:

* Creation and management of private keys, public keys and parameters

* Public key cryptographic operations

* Creation of X.509 certiﬁcates, CSRs and CRLs

* Calculation of Message Digests

* Encryption and Decryption with Ciphers

* SSL/TLS Client and Server Tests

* Handling of S/MIME signed or encrypted mail

* Time Stamp requests, generation and veriﬁcation

==action: To list the cipher commands & algorithms supported by OpenSSL, type the following commands:==

```bash
openssl list -cipher-commands
```

```bash
openssl list -cipher-algorithms
```

## Symmetric Key Cryptography

**Symmetric key cryptosystems** use the same key to encrypt and decrypt. As shown in the figure below, the plaintext data is encrypted using a key to produce ciphertext, and using the same key produces the original plaintext.

> Note: Which is more secure: AES or DES?

There are many tools to perform encryption, including OpenSSL.

> Question: What is the name of the high-impact security vulnerability that was discovered in OpenSSL in 2014? Does this affect the security of symmetric key encryption?

## Data Encryption Standard (DES)

Data Encryption Standard (DES) is a block cipher designed by IBM in 1970s and was based on Feistel Cipher. It is a symmetric key algorithm uses key size of 56-bit (keyspace is 256) which is too small to be secure nowadays.

==action: Create a file and name it coconut.txt either using your preferable text editor or directly from the Linux terminal as per the example below:==

```bash
cat << EOF > coconut.txt  
What 8-letter word can have a letter taken away and it still makes  
a word; take another letter away and it still makes a word;  
keep on doing that until you have one letter left. What is the word?  
EOF
```

==action: Now, we'll use DES (symmetric-key) algorithm to encrypt coconut.txt:==

```bash
openssl enc -e -des-cbc -pbkdf2 -in coconut.txt -out coconut.enc
```

> Note: You will be prompt to enter a password (the key)  
> Warning: The password will NOT be echoed (printed to the screen)

The above command will use Data Encryption Standard (DES) cipher with CBC mode to encrypt coconut.txt using a key derived from a password.

| enc | encoding with ciphers |
| \-des-cbc | des algorithm with cipher block chaining (cbc) mode |
| \-pbkdf2 | password-based key derivation function 2 |
| \-in | input ﬁle |
| \-out | output ﬁle |


==action: To decrypt:==

```bash
openssl enc -des-cbc -d -in coconut.enc -out getMyFileBack.txt
```

> Note: `-d` here for decryption

> Question: This nicely illustrates the key distribution problem. What is the "key distribution problem"?

## Advanced Encryption Standard (AES)

* AES is a 128-bit block (symmetric-key based) cipher with a variable key size of 128, 192 or 256 bits. It uses a mix of encryption/decryption techniques such as substitution, permutation, shifting and xoring (for key generation).

==action: In this example we'll encrypt coconut.txt using openssl (aes):==

```bash
openssl enc -e -aes-128-cbc -pbkdf2 -k Hello -in coconut.txt -out coconut-eas-128.enc
```

> Note: `-k` here is for a passphrase

==action: To decrypt:==

```bash
openssl enc -d -aes-128-cbc -pbkdf2 -in coconut-eas-128.enc -out coconut-decrypted-128.txt
```

> Note: You will need to enter the passphrase used ("Hello" as per the above example).

> Tip: You can use key size of 128-bit or 192-bit or 256-bit (-aes-128-cbc, -aes-192-cbc, -aes-256-cbc) in CBC mode or ECB mode (e.g. -aes-256-ecb).

## Public Key (AKA Asymmetric) Cryptography

**Public key (AKA asymmetric) cryptosystems** use separate keys for encryption and decryption. It is safe to tell anyone the encryption key, and only the person holding the decryption key can determine the original message.

Public keys can be made public: for example, used to encrypt messages intended for only the holder of the private key.

> Warning: Private keys must be kept secret (as with asymmetric keys): for example, used to decrypt messages. If a private key is known by a third party they can decrypt and modify any previous communications.

> Question: What are the disadvantages of sharing public keys via insecure channels?

## Gnu Privacy Guard (GPG)

GNU Privacy Guard (GnuPG) is an FOSS alternative to Pretty Good Privacy (PGP), following the OpenPGP standard, which provides public key crypto.

* GPG Manual: http://www.gnupg.org/gph/en/manual.html

==action: To create a key:==

```bash
gpg --gen-key
```

You'll be prompted to enter a password or passphrase (for your private/secret key), you can leave it blank. However, it is highly recommended to create one.

==action: Export a public key into file public.key:==

```bash
gpg --export -a "User Name" > yourname_publicKey.txt
```

> Note: The above command will create a file called yourname_publicKey.txt with the ascii representation of the public key for User Name.

==action: Export a private key:==

```bash
gpg --export-secret-key -a "User Name" > yourname_privateKey.txt
```

> Note: The above command will create a file called yourname_privateKey.txt with the ascii representation of the private key for User Name.

==action: To list the keys in your public key ring:==

```bash
gpg --list-key
```

==action: To list the keys in your secret key ring:==

```bash
gpg --list-secret-keys
```

==action: To generate a short list of numbers that you can use via an alternative method to verify a public key, use:==

```bash
gpg --fingerprint > fingerprint
```

==action: To encrypt data:==

```bash
gpg -e -u "Sender User Name" -r "Receiver User Name" file
```

The recipient (Receiver User Name) public key should be imported to your key ring first.

> Note: File here is the plaintext, after the encryption process a ciphertext will be generated as file.gpg within the current working directory, which can be decrypted as per the example below.

==action: To decrypt data:==

```bash
gpg -d file.gpg
```

==action: To edit/revoke key:==

```bash
gpg --edit-key Username
```

```bash
gpg --gen-revoke Username
```

## Using stand alone VM

You will have generated your public key in step no. 1

You can use a stand alone testing environment and create two users on the same machine, exchange the keys and test using the commands below.

==action: Create two users:==

```bash
sudo useradd -m -s /bin/bash user1 ; sudo useradd -m -s /bin/bash user2
```

==action: Generate pair of keys for each user and export ONLY public key to a file:==

```bash
gpg --gen-key
```

```bash
gpg --export -a "user1" > user1_publicKey.txt
```

> Note: Do the same as above for user2

==action: Exchange public keys between user1 and user2:==

> Note: As user1 import user2 public key (and of course vise versa)

```bash
gpg --import user2_publicKey.txt
```

==action: Create a file (message/plaintext) and encrypt it with user2's public key as per the example in step 7 above.==

==action: User2 can decrypt the message sent from user1 as per the example in step no. 8==

## CTF Challenges

> Flag: We have VMs on Hacktivity containing some challenges related to basic cryptography, mainly encoding, hashing, etc..

==action: Log-in to Hacktivity (https://hacktivity.leedsbeckett.ac.uk/hacktivities/53)==.

==action: Click on Activate and start challenge, then click on Desktop to start the VM, this may take a few minutes==.

Once the VM is up and running, you should be able to login automatically.

You will find all of the challenges in the user's home directory (e.g. /home/random_name) and under /srv directory.

Mainly, there are four directories you need to work on, three under /home/user-name/{encoded, encrypted, secrets} and one under /srv.

> Tip: Also, CyberChef (a nice and handy tool to explore cryptography) will be loaded automatically, feel free to use it for the CTF challenges or any other tool(s) if you wish.

> Flag: All of the flags in the form of: flag{astringofrandomwords} – all lowercase, so if the encoding method doesn't support case, you will need to convert yourself.

> Hint: The string to decimal doesn't separate the values with a space, so you will need to do that part yourself. For example: "97112112108101" would be "apple" but you need to add the separators before CyberChef will translate it: "97 112 112 108 101"

The zip file in /srv needs sudo to access it, the user's password is "tiaspbiqe2r" (this is a secure password but is quite easy 2 remember).

```bash
sudo unzip /srv/protected.zip
```

> Flag: Good luck!

[image-1]: {{ site.baseurl }}/assets/images/cyber_security_landscape/4_encoding_encryption/image-1.png
[image-2]: {{ site.baseurl }}/assets/images/cyber_security_landscape/4_encoding_encryption/image-2.png
[image-3]: {{ site.baseurl }}/assets/images/cyber_security_landscape/4_encoding_encryption/image-3.png
[image-4]: {{ site.baseurl }}/assets/images/cyber_security_landscape/4_encoding_encryption/image-4.png

