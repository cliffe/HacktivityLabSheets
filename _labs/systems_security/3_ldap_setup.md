---
title: "LDAP Authentication Setup Guide"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Learn how to set up centralized LDAP authentication between an OpenLDAP server and Linux clients using nslcd and PAM for enterprise identity management."
overview: |
  This lab provides a comprehensive guide to setting up LDAP (Lightweight Directory Access Protocol) authentication in a networked environment. You will learn how to configure an OpenLDAP server using phpLDAPadmin for user management, and configure Linux client systems to authenticate against the LDAP directory using nslcd. The lab covers creating organizational units, POSIX groups, and user accounts with proper UID/GID management to avoid conflicts with local users. You will also learn how to configure NSS (Name Service Switch) and PAM (Pluggable Authentication Modules) to enable centralized authentication and automatic home directory creation. By the end of this lab, you will understand the fundamentals of directory services and centralized authentication, which are essential components of enterprise identity management systems.
tags: ["ldap", "authentication", "identity-management", "openldap", "nslcd", "pam", "directory-services", "phpldapadmin", "linux"]
categories: ["systems_security"]
type: ["lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AAA"
    topic: "Authentication"
    keywords: ["identity management", "user authentication", "facets of authentication", "authentication in distributed systems"]
  - ka: "AAA"
    topic: "Authorisation"
    keywords: ["AUTHORIZATION - LDAP (LIGHTWEIGHT DIRECTORY ACCESS PROTOCOL)"]
---

# LDAP Authentication Setup Guide

This guide will walk you through setting up LDAP authentication between the `auth_servr` (LDAP server) and `staff_desktop` (LDAP client).

## Overview

- **auth_server**: Running OpenLDAP server (slapd) with phpLDAPadmin web interface
- **staff_desktop**: Desktop system that will authenticate against LDAP

## Step 1: Find the auth_server IP Address

1. ==VM: Log in to auth_server==

2. ==action: Find the IP address:==

```bash
ip addr show \| grep "inet "
```

Or simply:

```bash
hostname -I
```

3. ==action: Note this IP address== - you'll need it for the client configuration later
   
Example output might be: `10.9.8.7`

> Note: Throughout this guide, replace `<AUTH_SERVER_IP>` with your actual auth_server IP address.

## Step 2: Access phpLDAPadmin

1. ==VM: On the auth_server==, ==action: open a web browser==

2. ==action: Navigate to the phpLDAPadmin web interface:==

```
http://localhost/phpldapadmin/
```

3. You should see the phpLDAPadmin login page

## Step 3: Log in to phpLDAPadmin

1. ==action: Click on "login" in the left sidebar== (or look for the login section)

2. ==action: Enter the administrator credentials:==
   - **Login DN:** `cn=admin,dc=safetynet,dc=local`
   - **Password:** tiaspbiqe2r

3. ==action: Click "Authenticate"==

4. You should now see the LDAP directory tree on the left, with `dc=safetynet,dc=local` as the root

## Step 3.5: Verify phpLDAPadmin Auto-Increment UIDs Configuration

The `ldap_server` SecGen module has already configured phpLDAPadmin to auto-increment UIDs starting at 10000 instead of the default 1000. This avoids conflicts with local system users (which typically use UIDs 1000-9999).

==VM: You can verify this configuration on the `auth_server`:==

```bash
sudo grep "auto_number.*uidNumber" /etc/phpldapadmin/config.php
```

You should see:

```php
$servers->setValue('auto_number','min',array('uidNumber'=>10000,'gidNumber'=>500));
```

This means when you create new LDAP users, phpLDAPadmin will automatically assign UIDs starting from 10000, 10001, 10002, etc.

> Note: If for some reason the configuration wasn't applied, you can manually edit `/etc/phpldapadmin/config.php` and change the `uidNumber` value from 1000 to 10000.

## Step 4: Create Organizational Units

Before creating users, it's good practice to organize your directory structure.

1. ==action: Click on `dc=safetynet,dc=com` in the tree==

> Tip: It's safe to ignore the "Automatically removed objectClass from template" messages.

2. ==action: Click "Create a child entry"==

3. ==action: Select "Generic: Organisational Unit"==

4. ==action: Enter the OU name: "people"==

5. ==action: Click "Create Object" then "Commit"==

6. ==action: Repeat steps 1-5 to create another OU named "groups"==

Your directory structure should now look like:

```
dc=safetynet,dc=local
├── ou=people
└── ou=groups
```

## Step 5: Create a Posix Group

Before creating users, you need to create at least one group for them to belong to.

1. ==action: Click on "ou=groups" in the tree==

2. ==action: Click "Create a child entry"==

3. ==action: Select "Generic: Posix Group"==

4. ==action: Fill in the group details:==
   - **Group name (cn):** staff
   - **GID Number:** 500

5. ==action: Click "Create Object" then "Commit"==

Your group DN will be: `cn=staff,ou=groups,dc=safetynet,dc=local`

## Step 6: Create an LDAP User

1. ==action: Click on `ou=people` in the tree==

2. ==action: Click "Create a child entry"==

3. ==action: Select "Generic: User Account"==

4. ==action: Fill in the user details:==
   - **First name:** John
   - **Last name:** Doe
   - **Common Name:** John Doe
   - **User ID:** jdoe
   - **Password:** tiaspbiqe2r ==warning: ← CRITICAL: Must set password!==

5. ==action: Scroll down and verify/edit additional required attributes:==
   - **uidNumber:** Should be automatically set to `10000` (or next available). This is configured to start at 10000+ to avoid conflicts with local system users
   - **gidNumber:** 500 (Linux group ID - use the GID number from the staff group you created)
   - **Home Directory:** /home/jdoe
   - **Login Shell:** /bin/bash

> Warning: The **Password** field is REQUIRED - authentication will fail if not set. The **uidNumber** should automatically be 10000 or higher (configured in Step 3.5). If it shows 1000, manually change it to 10000. All POSIX attributes (uidNumber, gidNumber, loginShell, homeDirectory) are REQUIRED for system login to work.

6. ==action: Click "Create Object" then "Commit"==

Your user DN will be: `uid=jdoe,ou=people,dc=safetynet,dc=local`

7. ==action: Verify the user was created correctly:==
   
==VM: On the auth_server==, ==action: test the user exists with all required attributes:==

```bash
ldapsearch -x -H ldap://localhost -b "dc=safetynet,dc=local" "(uid=jdoe)" uidNumber gidNumber loginShell homeDirectory userPassword
```
   
You should see:

```
uidNumber: 10000
gidNumber: 500
loginShell: /bin/bash
homeDirectory: /home/jdoe
```

> Warning: `uidNumber` should be 10000+ to avoid conflicts with local users. If any attributes are missing, go back to phpLDAPadmin and edit the user to add them.


## Step 7: Configure LDAP Client Authentication on staff_desktop

Now we'll configure the `staff_desktop` to authenticate against the LDAP server using **nslcd** (the NSS LDAP daemon).

> Note: **Why nslcd?** This guide uses nslcd because it's straightforward and easy to configure - just set the LDAP server IP and credentials, and it works. An alternative is SSSD (System Security Services Daemon), which offers more advanced features like offline caching and multiple identity providers, but is more complex to set up. For this lab, nslcd is the simpler, more direct approach.

### 7.1: Install Required Packages (already done for you)

Hacktivity/SecGen has already installed:
- ldap-utils (LDAP command-line tools)
- libnss-ldap (NSS module for LDAP lookups)
- libpam-ldap (PAM module for LDAP authentication)
- nslcd (NSS LDAP connection daemon)
- nscd (Name Service Cache Daemon)
- sssd (alternative daemon, not used in this guide)

### 7.2: Configure nslcd

The nslcd daemon handles LDAP queries for the system. Configure it to connect to your auth_server:

1. ==VM: SSH or log in to staff_desktop==

2. ==action: Edit the nslcd configuration:==

```bash
sudo nano /etc/nslcd.conf
```

3. ==action: Find and update the following lines (or add them if missing):==

```
uri ldap://==edit:<AUTH_SERVER_IP>==
base dc=safetynet,dc=local

# Bind credentials for searching LDAP
binddn cn=admin,dc=safetynet,dc=local
bindpw tiaspbiqe2r
```

> Note: Replace `<AUTH_SERVER_IP>` with your actual auth_server IP from Step 1.

4. ==action: Save and exit (Ctrl+X, Y, Enter)==

### 7.3: Configure NSS to use LDAP

Edit the Name Service Switch configuration to use LDAP:

1. ==action: Edit `/etc/nsswitch.conf`:==

```bash
sudo nano /etc/nsswitch.conf
```

2. ==action: Update the passwd, group, and shadow lines to include ldap:==

```
passwd:         compat systemd ldap
group:          compat systemd ldap
shadow:         compat ldap
```

> Note: This tells the system to check local files first, then query LDAP for user/group information.

3. ==action: Save and exit (Ctrl+X, Y, Enter)==

### 7.4: Restart nslcd Service

1. ==action: Restart the nslcd daemon to apply the configuration:==

```bash
sudo systemctl restart nslcd
sudo systemctl enable nslcd
```

2. ==action: Check that nslcd is running:==

```bash
sudo systemctl status nslcd
```

> Note: Should show `active (running)`.

### 7.5: Enable PAM Authentication

==action: Configure PAM to create home directories automatically:==

```bash
sudo pam-auth-update
```

==action: Make sure the following are enabled (marked with `[*]`):==
- `Unix authentication`
- `LDAP Authentication`
- `Create home directory on login`

> Tip: Use spacebar to toggle, then Tab to OK, and Enter to save.

### 7.6: Verify LDAP User Lookup

==action: Test that the LDAP user can be retrieved:==

```bash
getent passwd jdoe
```

You should see output like:

```
jdoe:*:10000:500:John Doe:/home/jdoe:/bin/bash
```

> Note: The UID should be 10000+ (LDAP user range).

> Warning: **If you see nothing**, nslcd isn't connecting to LDAP properly. Check:
> - The auth_server IP is correct in `/etc/nslcd.conf`
> - The LDAP server is reachable: `ping <AUTH_SERVER_IP>`
> - The bind credentials are correct in `/etc/nslcd.conf`
> - Test LDAP directly: `ldapsearch -x -H ldap://<AUTH_SERVER_IP> -b "dc=safetynet,dc=local" "(uid=jdoe)"`
> - Check nslcd logs: `sudo journalctl -u nslcd -n 50`

> Warning: If `getent passwd jdoe` returns nothing, fix the issue before proceeding to authentication testing.

## Step 8: Test LDAP Authentication

Now that nslcd is configured and can retrieve the user (verified in Step 7.6), test authentication:

1. ==action: Try to log in as the LDAP user:==

```bash
su - jdoe
```

2. ==action: Enter the password you set in phpLDAPadmin== (e.g., `tiaspbiqe2r`)

3. If successful, you should be logged in as `jdoe` with a home directory automatically created at `/home/jdoe`

4. ==action: Verify with:==

```bash
whoami    # Should output: jdoe
pwd       # Should output: /home/jdoe
id        # Should show UID 10000, GID 500
```

**Success!** You're now authenticated via LDAP!

## Step 9: Troubleshooting

### Check LDAP Server Status

==VM: On `auth_server`:==

```bash
sudo systemctl status slapd
sudo slapcat \| head -20
```

### Check Client Configuration

==VM: On `staff_desktop`:==

```bash
# Check nslcd status
sudo systemctl status nslcd

# Check nslcd logs
sudo journalctl -u nslcd -n 50

# Test LDAP connectivity
ldapsearch -x -H ldap://==edit:<AUTH_SERVER_IP>== -b "dc=safetynet,dc=local"

# Check authentication logs
sudo tail -50 /var/log/auth.log

# Test user lookup
getent passwd jdoe
```

### Common Issues

1. **"nslcd: Can't contact LDAP server" / "failed to bind to LDAP server ldap://127.0.0.1/"**:
   
   The `nslcd` service is trying to connect to localhost instead of your auth_server.
   
   **Fix:** ==action: Update `/etc/nslcd.conf` with the correct server IP:==

```bash
sudo nano /etc/nslcd.conf
```

==action: Make sure these lines are correct:==

```
uri ldap://==edit:<AUTH_SERVER_IP>==
base dc=safetynet,dc=local
binddn cn=admin,dc=safetynet,dc=local
bindpw tiaspbiqe2r
```

> Note: Replace `<AUTH_SERVER_IP>` with your actual auth_server IP address.

==action: Then restart nslcd:==

```bash
sudo systemctl restart nslcd
sudo systemctl status nslcd
```

2. **"User not found" / `getent passwd jdoe` returns nothing**:

> Hint: Verify LDAP server is running on auth_server: `sudo systemctl status slapd`
> - Test connectivity from staff_desktop: `ldapsearch -x -H ldap://<AUTH_SERVER_IP> -b "dc=safetynet,dc=local" "(uid=jdoe)"`
> - Check nslcd is running: `sudo systemctl status nslcd`
> - Check nslcd logs: `sudo journalctl -u nslcd -n 50`
> - Verify `/etc/nslcd.conf` has correct server IP and bind credentials
> - Restart nslcd: `sudo systemctl restart nslcd`

3. **"Authentication failure" / Wrong password**:
   
   If `getent passwd jdoe` works but `su - jdoe` fails with wrong password:
   
   ==action: Test LDAP authentication directly:==

```bash
ldapwhoami -x -H ldap://==edit:<AUTH_SERVER_IP>== -D "cn=John Doe,ou=people,dc=safetynet,dc=local" -W
```

Or if the DN is `uid=jdoe`:

```bash
ldapwhoami -x -H ldap://==edit:<AUTH_SERVER_IP>== -D "uid=jdoe,ou=people,dc=safetynet,dc=local" -W
```

==action: Enter the password when prompted.==

> Note: **If this succeeds:** Password is correct, issue is with PAM/nslcd configuration. **If this fails with "Invalid credentials":** Password is wrong or not set in phpLDAPadmin.

==action: Check the user has a password set:==

```bash
ldapsearch -x -H ldap://==edit:<AUTH_SERVER_IP>== -b "dc=safetynet,dc=local" "(uid=jdoe)" userPassword
```

> Note: Should show: `userPassword: {SSHA}...` or `{MD5}...`. If empty, set the password in phpLDAPadmin.

4. **PAM configuration issues**:

==action: Run:==

```bash
sudo pam-auth-update
```

==action: Make sure these are enabled (marked with `[*]`):==
- `Unix authentication`
- `LDAP Authentication`
- `Create home directory on login`

5. **Home directory not created**:

> Hint: Ensure "Create home directory on login" is enabled in PAM. Check PAM configuration: `sudo pam-auth-update`. Or manually add to PAM config: `session required pam_mkhomedir.so skel=/etc/skel umask=0022`

## Step 10: Additional Tasks

### Create Additional Users

==action: Repeat Step 6 to create more users with different UIDs (10001, 10002, 10003, etc.)==

> Tip: phpLDAPadmin will auto-increment UIDs starting from 10000.

### Create LDAP Groups

1. ==action: In phpLDAPadmin, click on `ou=groups`==
2. ==action: Create a child entry==
3. ==action: Select "Generic: Posix Group"==
4. ==action: Set group name (e.g., "developers")==
5. ==action: After creating the group, add members:==
   - Click on the group entry
   - Add attribute: `memberUid`
   - Enter username: `jdoe`
   - Click "Update Object"
   - Repeat to add more members

### Advanced: Use SSSD Instead of nslcd (Optional)

For an advanced exercise, you could choose to configure SSSD instead of nslcd:

1. ==action: Stop and disable nslcd:==

```bash
sudo systemctl stop nslcd
sudo systemctl disable nslcd
```

2. ==action: Create `/etc/sssd/sssd.conf`:==

```ini
[sssd]
services = nss, pam
config_file_version = 2
domains = safetynet.local

[domain/safetynet.local]
id_provider = ldap
auth_provider = ldap
access_provider = permit
ldap_uri = ldap://==edit:<AUTH_SERVER_IP>==
ldap_search_base = dc=safetynet,dc=local
ldap_default_bind_dn = cn=admin,dc=safetynet,dc=local
ldap_default_authtok = tiaspbiqe2r
ldap_id_use_start_tls = false
ldap_tls_reqcert = never
```

3. ==action: Set permissions and restart:==

```bash
sudo chmod 600 /etc/sssd/sssd.conf
sudo systemctl restart sssd
sudo systemctl enable sssd
```

4. ==action: Update `/etc/nsswitch.conf` to use `sss` instead of `ldap`:==

```
passwd:         files systemd sss
group:          files systemd sss
shadow:         files sss
```

5. ==action: Test:==

```bash
getent passwd jdoe
su - jdoe
```

> Note: **Why use SSSD?** It provides offline authentication caching, better performance, and supports multiple identity providers (LDAP, AD, Kerberos). However, it's more complex to configure -- and these instructions are likely an incomplete starting point.



## Security Considerations

> Warning: For production environments, consider the following security enhancements:
> - **LDAPS**: Enable TLS/SSL (ldaps://)
> - **Strong Passwords**: Enforce password policies in LDAP
> - **Access Control**: Use LDAP ACLs to restrict who can read/modify entries
> - **Firewall**: Restrict LDAP port (389) access to authorized systems only
> - **Monitoring**: Monitor authentication logs for suspicious activity

## Conclusion

You now have a working LDAP authentication system where:
- Users are stored centrally on the `auth_server`
- The `staff_desktop` authenticates users against LDAP
- User accounts are managed through phpLDAPadmin
- Home directories are created automatically on first login

This setup demonstrates centralized authentication, a key component of enterprise identity management systems.
