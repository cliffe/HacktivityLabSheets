---
title: "Lab 1: Basic Network Scanning"
description: "Learn the fundamentals of network scanning using Nmap and other reconnaissance tools"
difficulty: "Beginner"
duration: "45 minutes"
prerequisites: "Basic understanding of networking concepts"
tags: ["networking", "reconnaissance", "nmap", "scanning"]
---

## Objectives

By the end of this lab, you will be able to:

- Understand the basics of network scanning
- Use Nmap for port scanning and service detection
- Interpret scan results and identify potential security vulnerabilities
- Apply basic reconnaissance techniques in a controlled environment

## Prerequisites

- Basic knowledge of IP addressing and networking
- Access to a virtual lab environment or isolated network
- Kali Linux or similar penetration testing distribution

## Lab Environment Setup

1. **Virtual Machine Setup**
   - Ensure you have Kali Linux running in a virtual machine
   - Verify network connectivity to the target systems
   - Confirm Nmap is installed: `nmap --version`

2. **Target Environment**
   - This lab uses intentionally vulnerable systems for educational purposes
   - Never perform these techniques on systems you don't own or lack permission to test

## Exercise 1: Basic Port Scanning

### Step 1: Discover Live Hosts

First, let's discover what hosts are alive on the network:

```bash
nmap -sn 192.168.1.0/24
```

**Questions:**
1. What does the `-sn` flag do?
2. How many hosts were discovered?

### Step 2: Basic TCP Port Scan

Perform a basic TCP port scan on a target host:

```bash
nmap -sS 192.168.1.10
```

**Questions:**
1. What does the `-sS` flag specify?
2. Which ports are open on the target?
3. What services are likely running on these ports?

### Step 3: Service Detection

Now let's identify the services running on open ports:

```bash
nmap -sV 192.168.1.10
```

**Questions:**
1. What additional information does `-sV` provide?
2. Are there any outdated services that might be vulnerable?

## Exercise 2: Advanced Scanning Techniques

### Step 1: OS Detection

Attempt to identify the operating system:

```bash
nmap -O 192.168.1.10
```

**Questions:**
1. What operating system is the target running?
2. How accurate is the detection?

### Step 2: Script Scanning

Use Nmap scripts for vulnerability detection:

```bash
nmap --script vuln 192.168.1.10
```

**Questions:**
1. What vulnerabilities were identified?
2. Which scripts were executed?

## Exercise 3: Stealth and Evasion

### Step 1: Timing Templates

Experiment with different timing templates:

```bash
nmap -T1 192.168.1.10  # Paranoid
nmap -T3 192.168.1.10  # Normal (default)
nmap -T5 192.168.1.10  # Insane
```

**Questions:**
1. How do the different timing templates affect scan speed?
2. When might you use slower timing templates?

### Step 2: Decoy Scanning

Use decoy hosts to mask your scan:

```bash
nmap -D RND:10 192.168.1.10
```

**Questions:**
1. How does decoy scanning work?
2. What are the limitations of this technique?

## Analysis and Documentation

### Scan Results Analysis

1. **Create a target inventory** listing all discovered hosts and their open ports
2. **Identify potential attack vectors** based on the services found
3. **Prioritize targets** based on the services and potential vulnerabilities

### Documentation Template

Create a brief report including:

- Network topology discovered
- List of active hosts
- Open ports and services per host
- Potential vulnerabilities identified
- Recommendations for further testing

## Cleanup

1. Document all scan results
2. Save any interesting output files
3. Clean up temporary files
4. Shut down any test systems properly

## Additional Challenges

1. **Research Challenge**: Look up CVEs for any outdated services you discovered
2. **Automation Challenge**: Write a bash script to automate the scanning process
3. **Stealth Challenge**: Research additional evasion techniques and test them

## Resources

- [Nmap Official Documentation](https://nmap.org/docs.html)
- [Nmap Scripting Engine Guide](https://nmap.org/book/nse.html)
- [Common Port Reference](https://www.speedguide.net/ports.php)

## Conclusion

This lab introduced you to the fundamentals of network scanning using Nmap. You learned how to discover hosts, identify open ports, detect services, and use advanced scanning techniques. These skills form the foundation of network reconnaissance in cybersecurity.

Remember: Always ensure you have proper authorization before scanning any network or system!