---
title: "Network Authentication and Directory Services"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Introduction to centralised authentication, directory services, and identity management using Active Directory and LDAP in enterprise environments."
overview: |
  This lab introduces you to centralised authentication and directory services, which are fundamental components of enterprise network security. Instead of managing user accounts separately on each system, organisations use centralised directory services like Active Directory (AD) and LDAP (Lightweight Directory Access Protocol) to manage identities, authentication, and authorisation across their entire infrastructure. You will learn about the differences between these two major directory service technologies, their use cases, and their roles in modern enterprise networks. This lab provides an overview of key concepts including domain controllers, directory schemas, authentication protocols, and group policies, preparing you to implement and secure directory services in real-world environments.
tags: ["active-directory", "ldap", "authentication", "identity-management", "directory-services", "domain-controller", "enterprise-security", "authorisation"]
categories: ["systems_security"]
type: ["lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AAA"
    topic: "Authentication"
    keywords: ["identity management", "user authentication", "facets of authentication", "authentication in distributed systems"]
  - ka: "AAA"
    topic: "Authorisation"
    keywords: ["access control", "authorisation models", "LDAP (Lightweight Directory Access Protocol)"]
  - ka: "NS"
    topic: "Network Security"
    keywords: ["network architecture", "protocols"]
---

# Network Authentication and Directory Services

# Introduction {#introduction}

In modern enterprise environments, managing user accounts and authentication across dozens, hundreds, or even thousands of computers becomes impossible without centralised systems. Imagine having to create a separate user account on every single computer for every employee in an organization – not only would this be time-consuming, but it would also be a security nightmare when employees leave, passwords need to be changed, or access permissions need to be updated.

Directory services solve this problem by providing a centralised database of users, computers, and other network resources, along with a standardised way for systems to authenticate users and query information about them. This lab will introduce you to two major directory service technologies: **Active Directory** (Microsoft's solution) and **LDAP** (an open standard implemented by various systems).

# What are Directory Services? {#what-are-directory-services}

A **directory service** is a centralised system that stores, organizes, and provides access to information about network resources. Think of it as a specialized database optimized for reading and searching, containing information about:

- **Users**: Names, credentials, email addresses, phone numbers, group memberships
- **Computers**: Hostnames, operating systems, network addresses
- **Groups**: Collections of users with similar access rights
- **Policies**: Security settings, software deployment rules, password requirements
- **Resources**: Printers, file shares, applications

Directory services provide several critical functions:

1. **Authentication**: Verifying user identities (who you are)
2. **Authorisation**: Determining what authenticated users can access (what you can do)
3. **Centralised Management**: Single location to manage all users and resources
4. **Single Sign-On (SSO)**: Users authenticate once and access multiple systems
5. **Policy Enforcement**: Consistent security policies across the organization

# Active Directory vs LDAP {#active-directory-vs-ldap}

## Active Directory (AD)

**Active Directory** is Microsoft's proprietary directory service, introduced with Windows 2000 Server. It's the dominant solution in Windows-based enterprise environments.

**Key characteristics:**
- Tightly integrated with Windows operating systems
- Uses Kerberos for authentication
- Includes Group Policy for centralised configuration management
- Hierarchical structure based on domains, trees, and forests
- Includes DNS as a core component
- Supports Windows, and with additional configuration, Linux/Unix systems

**Common use cases:**
- Windows-dominated corporate networks
- Organisations using Microsoft ecosystem (Exchange, SharePoint, etc.)
- Environments requiring Group Policy for desktop management

## LDAP (Lightweight Directory Access Protocol)

**LDAP** is an open standard protocol for accessing and maintaining directory services. It's not a directory service itself, but rather the protocol used to communicate with directory services. OpenLDAP is a popular open-source implementation.

**Key characteristics:**
- Platform-independent and open standard
- Works with Linux, Unix, macOS, and Windows
- Flexible schema that can be customized
- Uses various authentication mechanisms (simple bind, SASL)
- Hierarchical structure based on organisational units (OUs)
- Commonly used with additional tools for web-based management

**Common use cases:**
- Linux/Unix-heavy environments
- Organisations wanting open-source solutions
- Multi-platform heterogeneous networks
- Applications requiring directory integration (web apps, email servers)

## Comparison

| Feature | Active Directory | LDAP/OpenLDAP |
|---------|-----------------|---------------|
| **Platform** | Windows-centric | Cross-platform |
| **Authentication** | Kerberos (primary) | Various (simple, SASL, Kerberos) |
| **Management** | Native Windows tools, PowerShell | Web interfaces (phpLDAPadmin), CLI tools |
| **Schema** | Fixed Microsoft schema | Flexible, customizable schema |
| **Group Policy** | Yes (extensive) | No (requires additional tools) |
| **Cost** | Requires Windows Server licenses | Free and open-source |

> Note: Active Directory actually uses LDAP as one of its protocols! AD implements LDAP for directory queries, but adds many proprietary extensions and features on top.

# Why Centralised Authentication Matters {#why-centralised-authentication-matters}

Centralised authentication provides numerous security and operational benefits:

## Security Benefits

1. **Consistent Password Policies**: Enforce strong password requirements across all systems
2. **Faster Revocation**: Disable an account once to revoke access everywhere
3. **Audit Trail**: centralised logging of authentication attempts
4. **Least Privilege**: Easier to implement principle of least privilege
5. **Multi-Factor Authentication (MFA)**: Deploy MFA centrally for all resources

## Operational Benefits

1. **Reduced Administration**: Manage users in one place, not on every system
2. **Single Sign-On**: Users authenticate once to access multiple resources
3. **Self-Service**: Users can reset passwords without helpdesk intervention
4. **Automation**: Automated provisioning and de-provisioning of accounts
5. **Scalability**: Add systems without exponentially increasing management overhead

## Challenges

While centralised authentication offers many benefits, it also introduces considerations:

- **Single Point of Failure**: Directory service outage affects all systems
- **Security-Critical Asset**: If compromised, attacker gains access to everything
- **Network Dependency**: Systems may need network connectivity to authenticate
- **Complexity**: Requires careful planning and configuration

> Warning: Because directory services are security-critical, they are prime targets for attackers. Securing your directory service is essential to organizational security.

# Key Concepts {#key-concepts}

## Domain Controller (DC)

A **Domain Controller** is a server that responds to authentication requests and verifies users on the network. In Active Directory, DCs store a complete copy of the directory database and handle authentication. Organisations typically deploy multiple DCs for redundancy.

## Organizational Units (OUs)

**Organizational Units** are containers within a directory that organize users, groups, computers, and other objects. They allow administrators to apply policies and delegate administrative control at different levels of the organization.

## Groups

**Groups** are collections of users (or other objects) that simplify permission management. Instead of granting permissions to individual users, you grant them to groups. Common types include:
- **Security groups**: Control access to resources
- **Distribution groups**: Used for email distribution lists (AD)

## LDAP Distinguished Names (DNs)

An **LDAP Distinguished Name** uniquely identifies an entry in the directory tree. For example:
```
cn=John Smith,ou=Users,dc=example,dc=com
```

Where:
- `cn` = Common Name
- `ou` = Organisational Unit  
- `dc` = Domain Component

## Authentication Protocols

- **Kerberos**: Ticket-based authentication protocol used by Active Directory
- **NTLM**: Older Windows authentication protocol, still supported for compatibility
- **LDAP Bind**: Simple username/password authentication against LDAP directory
- **SASL**: Framework for adding authentication to connection-oriented protocols

# Setup Guides {#setup-guides}

To gain hands-on experience with directory services, you'll work through detailed setup guides for both Active Directory and LDAP:

## Active Directory Setup

The Active Directory guide walks you through:
- Setting up Windows Server 2016 as a Domain Controller
- Configuring static IP addresses and DNS
- Installing Active Directory Domain Services (AD DS)
- Creating a new forest and domain
- Adding users to Active Directory
- Joining Windows clients to the domain

==action: [Click here for the Active Directory Setup Guide](3_ad_setup.md)==

## LDAP Setup  

The LDAP guide walks you through:
- Setting up an OpenLDAP server on Linux
- Configuring phpLDAPadmin for web-based management
- Creating organizational units and POSIX groups
- Adding user accounts with proper UID/GID management
- Configuring Linux clients to authenticate against LDAP using nslcd
- Setting up PAM for automatic home directory creation

==action: [Click here for the LDAP Authentication Setup Guide](3_ldap_setup.md)==

# Your Assignment {#your-assignment}

## Getting Started

==action: Work through both the Active Directory and LDAP setup guides== to understand how each directory service works and to get hands-on experience with centralized authentication.

Once you have completed the setup guides:

> Action: Save snapshots of your VMs so you can return to a working baseline if needed.

## Assignment Requirements

Your systems security assignment requires you to implement and secure a directory service for your assigned infrastructure. 

> Note: Refer to your assignment specification document for the complete requirements, including:
> - Specific users and groups you need to create
> - Security policies to implement
> - Client systems that need to be joined to the domain
> - Testing requirements and success criteria

## Documentation

When documenting your implementation in your technical report:

- **Include evidence** that you completed the getting started guides (screenshots of successful authentication)
- **Document all changes** you make beyond the getting started guides
- **Identify and fix** any insecure settings or software you find in the provided VMs
- **Demonstrate each requirement** with screenshots and a testing plan
- **Present a testing results table** with clear success/failure indicators for each requirement

> Note: If you follow the getting started guides provided, you don't need to document those steps in extensive detail in your report, but you should include evidence that it was completed and document anything you do that isn't the same as in the guides (and generally cover any other changes you make to any VMs).

---

**Good luck with your implementation!** Directory services are complex systems, so take your time to understand each step. If you encounter issues, review the troubleshooting sections in the setup guides, and don't hesitate to ask for help.
