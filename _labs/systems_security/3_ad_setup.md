---
title: "Active Directory Setup Guide"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Learn how to set up Active Directory Domain Services on Windows Server 2016, configure DNS, create users, and join Windows and Linux clients to an Active Directory domain."
overview: |
  This lab provides a comprehensive guide to setting up Active Directory (AD) in a Windows Server environment. You will learn how to configure a Domain Controller (DC) with Active Directory Domain Services (AD DS), assign static IP addresses, configure DNS services, and establish a new forest with a fully qualified domain name (FQDN). The lab covers creating organisational units, managing user accounts, and configuring password policies. You will also learn how to join both Windows 7 and Linux client systems to the Active Directory domain for centralised authentication and management. By the end of this lab, you will understand the fundamentals of directory services, domain controllers, and enterprise identity management using Active Directory, which are essential components of modern Windows-based network infrastructures.
tags: ["active-directory", "windows-server", "domain-controller", "authentication", "identity-management", "dns", "adds", "windows", "directory-services"]
categories: ["systems_security"]
type: ["lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AAA"
    topic: "Authentication"
    keywords: ["identity management", "user authentication", "facets of authentication", "authentication in distributed systems"]
  - ka: "AAA"
    topic: "Authorisation"
    keywords: ["access control", "authorisation models"]

---

# Setting up Active Directory and joining Windows clients

# Introduction {#introduction}

Here is a guide to help you get started by setting up Active Directory on Windows. 

Start by making note of the IP addresses you have been allocated on your VMs. In particular the 10.X.X.X addresses for each VM.

==VM: On your Windows 2016 DC VM:==

# Setting up AD {#setting-up-ad}

## Assigning a static IP {#assigning-a-static-ip}

A static IP address needs to be set on the Domain Controller (DC). The DC will also be configured as a DNS for all computers authenticating via AD. Assigning a static IP address assures the IP will not change. 

==action: Right-click on the Network Status Indicator on the taskbar and click Open Network and Sharing Centre==

![][image1]

==action: Click on the active connection==, in our case 'Ethernet 2' as underlined.

![][image2]

![][image3]

==action: Click Properties on the Status window==

==action: Select Internet Protocol Version 4 then click properties.==

![][image4]

==action: Assign a static IP address in the 'IP address' field.== It must follow the same first 3 octets as the other computers on the network which will be connecting to the AD instance. 

The subnet will be 255.0.0.0, with DNS servers left blank.

==action: Open Server Manager, go to All Servers==

==action: Press the refresh icon== ![][image5]

==action: Ensure that the IP address showing has the 10.X.X.X IP address.==

> Note: If not, restart the server.

![][image6]

## Active Directory Domain Services {#active-directory-domain-services}

Active Directory is used to manage computers, users and groups on a network. AD has several different services, AD domain services open a centralised authentication platform which stores user accounts, metadata, groups, and so on (Microsoft, 2017). This centralised platform is how users will authenticate themselves, it will also control what permissions users have through groups. A server that makes its account database available to other computers on the network is known as a Domain Controller (DC) (Microsoft, 2019).

## Installation {#installation}

==action: Open Server Manager, go to Manage > Add Roles and Features==

![][image7]

Warnings recommend: a strong password for the administrator account, a static IP is set and security updates are installed.

==action: Click "Next" to continue.==

![][image8]

==action: Select Role-based or feature-based installation.== Another option is for setting up AD within a virtualised remote desktop environment (Microsoft, 2017).

![][image9]

==action: Select the current server== which will install the Active Directory Domain Services.

![][image10]

==action: Ensure the DNS Server box is checked.==

![][image11]

==action: Select Active Directory Domain Services.==

Installing Active Directory Domain Services will also install administration tools.

==action: Click "Add Features" to continue.==

![][image12]

Once Active Directory Domain Services has been checked, ==action: click "Next".==

![][image13]

No additional features need to be installed. ==action: Click "Next" to continue.==

![][image14]

Two notes appear. One recommends ensuring there's another domain controller in case of a server or network issue. The other informs that this server will act as a DNS if one is not configured on the network.

==action: Click "Next" to continue.==

![][image15]

A confirmation appears before the installation begins. ==action: Check "Restart the destination server automatically if required"== to automatically restart the server, which is required to apply changes.

==action: Click "Install" to continue.==

Once the installation completes, ==action: click "Promote this server to a domain controller"==

![][image16]

==action: Select "Add a new forest"==, the other options are used for joining existing Active Directory domains. 

Next, ==action: enter a Fully Qualified Domain Name (FQDN) in the "Root domain name" form field.==

==edit: Use cNUMBER.ads.com.==

Hosts will appear under this domain name by their hostname followed by the FQDN. 

 ![][image17]

==action: Set a strong password (**and make a note of it**) for the Directory Services Restore Mode.== The password will be used to boot into recovery mode.

> Warning: This should always be different to your Administrator password.

This is the only DC on the network, ==action: keep the DNS server and Global Catalog checked.==

==action: Click "Next" to continue.==

![][image18]

The next window informs us that we're unable to create a DNS delegation as there is currently no DNS server on the network, the current machine will become a DNS server after installation is complete. DNS delegations refer to hierarchical records in a DNS server which points a child server to a parent DNS server (Microsoft, 2018).

==action: Click "Next" to continue.==

![][image19]

As per the spec, ==action: set the NetBIOS domain name as your ==edit: cNUMBER==.== NetBIOS is a directory service, similar to DNS. NetBIOS was used in older Windows operating systems before Windows adopted DNS (sambawiki, 2020).

![][image20]

Paths to log files are then shown and can be modified if necessary. ==action: Click "Next" to Continue.==

![][image21]

Review options, to continue ==action: click "Next".==

![][image22]

Two notices appear, one which warns us that due to our updated cryptography settings, there may be problems connecting older Operating Systems. Another notice explains that a DNS server will be installed. ==action: Click "Install" to continue.== A restart will occur.

![][image23]

Upon a successful installation of Active Directory Domain Services, "AD DS" will appear in the Server Manager sidebar. There should be new entries under "Tools" including "Active Directory Users and Computers".

![][image24]

## Adding Users {#adding-users}

Add a test user to the domain. ==action: Start by launching the Server Manager > Tools > Active Directory Administrative Centre.==

![][image25]

On the right side of the local server, ==action: click Users > New > User==

![][image26]

==action: Create a test user by entering a name and username, and Click OK.==

![][image27]

==action: Then right click the user to reset the password, and then enable the account.==

![][image28]

# The end of the beginning {#the-end-of-the-beginning}

Note at this point you have completed some of the assignment specifications, but you need to further complete the configuration of these systems to meet the requirements and give a reasonable user experience. For example, make sure user home directories are created when users login for the first time, and ensuring that users can login via the graphical login screen.

[image1]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-1.png
[image2]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-2.png
[image3]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-3.png
[image4]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-4.png
[image5]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-5.png
[image6]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-6.png
[image7]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-7.png
[image8]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-8.png
[image9]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-9.png
[image10]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-10.png
[image11]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-11.png
[image12]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-12.png
[image13]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-13.png
[image14]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-14.png
[image15]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-15.png
[image16]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-16.png
[image17]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-17.png
[image18]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-18.png
[image19]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-19.png
[image20]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-20.png
[image21]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-21.png
[image22]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-22.png
[image23]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-23.png
[image24]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-24.png
[image25]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-25.png
[image26]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-26.png
[image27]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-27.png
[image28]: {{ site.baseurl }}/assets/images/systems_security/active_directory/image-28.png
