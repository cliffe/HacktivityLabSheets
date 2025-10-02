---
title: "Web Security: Additional Challenges"
author: ["Thalita Vergilio", "Z. Cliffe Schreuders", "Andrew Scholey"]
license: "CC BY-SA 4.0"
description: "Complete additional web security challenges using Security Shepherd platform, focusing on cryptographic storage vulnerabilities and unvalidated redirects."
overview: |
  In this web security lab, you will work through additional challenges using the Security Shepherd platform. These challenges focus on cryptographic storage vulnerabilities and unvalidated redirects, providing hands-on experience with real-world web security issues. You'll learn to identify and exploit insecure cryptographic implementations and understand the risks associated with unvalidated redirects and forwards in web applications.
tags: ["web-security", "cryptographic-storage", "redirects", "security-shepherd", "ctf"]
categories: ["web_security"]
lab_sheet_url: "https://docs.google.com/document/d/1DDjyBGtB9vaFD6S2s1jQn7_bpVn4UlK-njbmVX5_UiM/edit?usp=sharing"
type: ["lab-environment", "ctf-lab"]
cybok:
  - ka: "WAM"
    topic: "Fundamental Concepts and Approaches"
    keywords: ["web PKI and HTTPS", "authentication", "ACCESS CONTROL", "cookies", "passwords and alternatives", "JAVASCRIPT", "HYPERTEXT MARKUP LANGUAGE (HTML)", "CASCADING STYLE SHEETS (CSS)", "HYPERTEXT TRANSFER PROTOCOL (HTTP)", "HYPERTEXT TRANSFER PROTOCOL (HTTP) - PROXYING", "DATABASE", "Broken Access Control / Insecure Direct Object References", "SESSION HIJACKING", "CERTIFICATES", "REPRESENTATIONAL STATE TRANSFER (REST)", "PERMISSION DIALOG BASED ACCESS CONTROL", "CLIENT-SERVER MODELS"]
  - ka: "WAM"
    topic: "Client-Side Vulnerabilities and Mitigations"
    keywords: ["client-side storage", "CLIENT-SIDE VALIDATION", "clickjacking"]
  - ka: "WAM"
    topic: "Server-Side Vulnerabilities and Mitigations"
    keywords: ["injection vulnerabilities", "server-side misconfiguration and vulnerable components", "CROSS-SITE SCRIPTING (XSS)", "SAME ORIGIN POLICY (SOP)", "COMMAND INJECTION", "SQL-INJECTION", "CROSS-SITE REQUEST FORGERY (CSRF)", "CONFUSED DEPUTY ATTACKS", "BACK-END", "BLIND ATTACKS"]
  - ka: "SS"
    topic: "Categories of Vulnerabilities"
    keywords: ["Web vulnerabilities / OWASP Top 10", "API vulnerabilities"]
  - ka: "SS"
    topic: "Prevention of Vulnerabilities"
    keywords: ["coding practices", "Protecting against session management attacks, XSS, SQLi, CSRF", "API design"]
  - ka: "SS"
    topic: "Detection of Vulnerabilities"
    keywords: ["dynamic detection"]
---

## General notes about the labs {#general-notes-about-the-labs}

Often the lab instructions are intentionally open-ended, and you will have to figure some things out for yourselves. This module is designed to be challenging, as well as fun!

However, we aim to provide a well planned and fluent experience. If you notice any mistakes in the lab instructions or you feel some important information is missing, please let us know and we will try to address any issues.

## Preparation {#preparation}

> Action: Start by logging into Hacktivity.

[**Click here for a guide to using Hacktivity.**](https://docs.google.com/document/d/17d5nUx2OtnvkgBcCQcNZhZ8TJBO94GMKF4CHBy1VPjg/edit?usp=sharing) This includes some important information about how to use the lab environment and how to troubleshoot during lab exercises. If you haven't already, have a read through.

## Log into Security Shepherd and work through assessed tasks {#log-into-security-shepherd-and-work-through-assessed-tasks}

For this week's Security Shepherd Challenges you need to use the 'Additional Web Challenges' VMs on Hacktivity.

> Note: Remember the login details for the Kali VM is Kali/Kali.

You have the **lesson and challenges to complete for:**

* **3 x Insecure Cryptographic Storage**  
* **1 x Unvalidated Redirects and Forwards (Lesson)**

> Hint: The tips below are optional. Try to complete the challenges without them if you can.

### Insecure Cryptographic Storage Challenge 2 Tips {#insecure-cryptographic-storage-challenge-2-tips}

> Hint: You may want to use an online decoder for the Vigenere Cipher. Can you find the String and the key to use?

### Insecure Cryptographic Storage Challenge 3 Tips {#insecure-cryptographic-storage-challenge-3-tips}

> Hint: The encryption/decryption happens server-side, so you need to experiment with re-sending the request to decrypt. One of the letters of the alphabet, when used repeatedly, will translate into the key you need.

## Conclusion {#conclusion}

At this point you have:

* Learned about cryptographic storage vulnerabilities and how to identify insecure implementations

* Gained experience with various cryptographic attacks including cipher analysis and key recovery

* Understood the risks associated with unvalidated redirects and forwards in web applications

* Completed additional web security challenges using the Security Shepherd platform

Congratulations! These additional challenges have provided you with hands-on experience in identifying and exploiting cryptographic vulnerabilities, as well as understanding the security implications of unvalidated redirects in web applications.