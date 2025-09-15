---
title: "Lab 3: Digital Forensics and Incident Response"
description: "Learn digital forensics techniques to investigate security incidents and analyze evidence"
difficulty: "Advanced"
duration: "120 minutes"
prerequisites: "Understanding of file systems, basic scripting, and incident response procedures"
tags: ["forensics", "incident response", "evidence analysis", "volatility", "disk imaging"]
---

## Objectives

By the end of this lab, you will be able to:

- Create forensically sound disk images
- Analyze volatile memory dumps for indicators of compromise
- Extract and examine digital artifacts from compromised systems
- Document findings following proper chain of custody procedures
- Use industry-standard forensics tools and techniques

## Prerequisites

- Understanding of file systems (NTFS, FAT, ext4)
- Basic knowledge of Windows and Linux operating systems
- Familiarity with command-line tools
- Understanding of incident response procedures

## Lab Environment Setup

1. **Forensics Workstation**
   - Kali Linux or SIFT (SANS Investigative Forensics Toolkit)
   - Volatility Framework
   - Autopsy or Sleuth Kit
   - dc3dd or dd for imaging

2. **Evidence Files**
   - Sample memory dump (provided)
   - Disk image of compromised system
   - Network packet captures (PCAP files)

3. **Documentation Tools**
   - Case management system or documentation template
   - Hash verification tools (md5sum, sha256sum)

## Exercise 1: Memory Analysis

### Step 1: Memory Dump Analysis Setup

1. **Install Volatility**
   ```bash
   git clone https://github.com/volatilityfoundation/volatility.git
   cd volatility
   python setup.py install
   ```

2. **Verify Memory Dump**
   ```bash
   # Calculate hash for chain of custody
   sha256sum memory_dump.vmem
   
   # Identify the memory dump profile
   python vol.py -f memory_dump.vmem imageinfo
   ```

### Step 2: Process Analysis

Analyze running processes in the memory dump:

```bash
# List all processes
python vol.py -f memory_dump.vmem --profile=Win7SP1x64 pslist

# Show process tree
python vol.py -f memory_dump.vmem --profile=Win7SP1x64 pstree

# Find hidden processes
python vol.py -f memory_dump.vmem --profile=Win7SP1x64 psxview
```

**Questions:**
1. What suspicious processes are running?
2. Are there any processes that seem out of place?
3. Which processes are hidden from normal detection?

### Step 3: Network Connections

Examine network activity:

```bash
# Show network connections
python vol.py -f memory_dump.vmem --profile=Win7SP1x64 netscan

# Display network statistics
python vol.py -f memory_dump.vmem --profile=Win7SP1x64 netstat
```

**Questions:**
1. What external connections were established?
2. Are there any suspicious IP addresses or ports?
3. Which processes initiated network connections?

### Step 4: Malware Detection

Look for indicators of malware:

```bash
# Scan for malware
python vol.py -f memory_dump.vmem --profile=Win7SP1x64 malfind

# Check for code injection
python vol.py -f memory_dump.vmem --profile=Win7SP1x64 hollowfind

# Examine suspicious processes
python vol.py -f memory_dump.vmem --profile=Win7SP1x64 procdump -p [PID] -D output/
```

**Questions:**
1. What malware indicators were found?
2. Which processes show signs of code injection?
3. Can you extract malware samples for further analysis?

## Exercise 2: Disk Forensics

### Step 1: Creating Forensic Images

Create a forensically sound image of the evidence disk:

```bash
# Create disk image with verification
dc3dd if=/dev/sdb of=evidence_disk.img hash=sha256 log=imaging.log

# Alternative with dd
dd if=/dev/sdb of=evidence_disk.img bs=4096 conv=noerror,sync
sha256sum evidence_disk.img > evidence_disk.img.sha256
```

### Step 2: File System Analysis

Mount and analyze the disk image:

```bash
# Mount as read-only
mkdir /mnt/evidence
mount -o ro,loop evidence_disk.img /mnt/evidence

# Analyze with Sleuth Kit
fls -r evidence_disk.img > file_listing.txt
mactime -b file_listing.txt > timeline.txt
```

**Questions:**
1. What file systems are present on the disk?
2. When was the system last accessed?
3. Are there any deleted files of interest?

### Step 3: Artifact Recovery

Search for specific artifacts:

```bash
# Search for specific files
grep -r "password" /mnt/evidence/
find /mnt/evidence -name "*.log" -type f

# Extract browser history
firefox_history_extractor.py /mnt/evidence/Users/*/AppData/

# Examine registry files (Windows)
regripper -r /mnt/evidence/Windows/System32/config/SOFTWARE -p software
```

**Questions:**
1. What user activity artifacts were found?
2. Are there any credentials or sensitive data?
3. What applications were recently used?

## Exercise 3: Timeline Analysis

### Step 1: Create System Timeline

Generate a comprehensive timeline:

```bash
# Create super timeline with log2timeline
log2timeline.py --storage-file timeline.plaso evidence_disk.img

# Convert to readable format
psort.py -o dynamic timeline.plaso > system_timeline.csv
```

### Step 2: Timeline Filtering

Filter timeline for relevant events:

```bash
# Filter by date range
psort.py -o dynamic --slice "2023-01-01,2023-01-31" timeline.plaso

# Filter by keywords
psort.py -o dynamic --strings malware timeline.plaso
```

**Questions:**
1. What significant events occurred during the incident timeframe?
2. Can you identify the initial compromise vector?
3. What actions did the attacker take on the system?

## Exercise 4: Network Forensics

### Step 1: PCAP Analysis

Analyze network traffic captures:

```bash
# Basic statistics
capinfos capture.pcap

# Examine protocols
tshark -r capture.pcap -q -z io,phs

# Extract HTTP traffic
tshark -r capture.pcap -Y "http" -T fields -e http.host -e http.uri
```

### Step 2: Suspicious Traffic Detection

Look for indicators of compromise in network traffic:

```bash
# Search for suspicious domains
tshark -r capture.pcap -Y "dns" -T fields -e dns.qry.name | sort | uniq

# Examine file transfers
tshark -r capture.pcap -Y "ftp-data" --export-objects ftp,extracted_files/
```

**Questions:**
1. What suspicious network activity was detected?
2. Were any files transferred during the incident?
3. Can you identify command and control traffic?

## Exercise 5: Report Generation

### Step 1: Evidence Documentation

Create proper documentation:

1. **Chain of Custody Form**
   - Date and time of acquisition
   - Hash values for verification
   - Personnel involved
   - Storage location

2. **Technical Analysis Report**
   - Executive summary
   - Methodology used
   - Key findings
   - Supporting evidence

### Step 2: Indicators of Compromise (IOCs)

Document IOCs for threat intelligence:

- File hashes (MD5, SHA-1, SHA-256)
- IP addresses and domains
- Registry keys
- File paths
- Network signatures

## Case Study: Putting It All Together

### Scenario
A company reports that their web server has been compromised. You have been provided with:
- Memory dump from the server
- Disk image of the web server
- Network traffic logs
- System event logs

### Investigation Steps

1. **Initial Triage**
   - Verify evidence integrity
   - Identify the scope of compromise
   - Preserve volatile data

2. **Deep Analysis**
   - Memory analysis for running threats
   - Disk forensics for persistence mechanisms
   - Timeline reconstruction
   - Network analysis for data exfiltration

3. **Reporting**
   - Document all findings
   - Provide remediation recommendations
   - Create IOCs for monitoring

## Advanced Challenges

1. **Encrypted Evidence**: Analyze encrypted disk images
2. **Anti-Forensics**: Investigate systems with anti-forensics tools
3. **Mobile Forensics**: Extend techniques to mobile devices
4. **Cloud Forensics**: Analyze cloud-based incidents

## Tools Reference

### Memory Analysis
- Volatility Framework
- Rekall
- WinDbg

### Disk Forensics
- Autopsy
- Sleuth Kit
- EnCase
- FTK

### Network Forensics
- Wireshark
- NetworkMiner
- Moloch

### Reporting
- CaseFile
- Maltego
- Custom scripts

## Best Practices

1. **Evidence Handling**
   - Always work with copies
   - Maintain chain of custody
   - Document everything
   - Use write-blockers for physical media

2. **Analysis Methodology**
   - Follow established procedures
   - Use multiple tools for verification
   - Document all steps taken
   - Preserve original evidence

3. **Reporting**
   - Use clear, non-technical language for executives
   - Include technical details for IT teams
   - Provide actionable recommendations
   - Support findings with evidence

## Resources

- [SANS Digital Forensics and Incident Response](https://www.sans.org/cyber-security-courses/digital-forensics-incident-response/)
- [Volatility Documentation](https://github.com/volatilityfoundation/volatility/wiki)
- [Sleuth Kit Documentation](http://www.sleuthkit.org/sleuthkit/docs.php)
- [NIST Computer Forensics Guidelines](https://csrc.nist.gov/publications/detail/sp/800-86/final)

## Conclusion

This lab provided comprehensive experience in digital forensics and incident response. You learned to analyze memory dumps, perform disk forensics, create timelines, and document findings properly. These skills are essential for investigating security incidents and providing evidence for legal proceedings.

Key takeaways:
- Proper evidence handling is crucial for legal admissibility
- Multiple analysis techniques provide comprehensive understanding
- Timeline analysis helps reconstruct incident sequences
- Documentation must be thorough and accurate
- Continuous learning is essential as attack techniques evolve

Always ensure you have proper authorization and follow legal requirements when conducting forensic investigations!