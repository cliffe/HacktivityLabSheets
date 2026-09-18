---
title: "Containers: Chroot and Docker"
author: ["Z. Cliffe Schreuders"]
license: "CC BY-SA 4.0"
description: "Learn container-based sandboxing with chroot and Docker, then break into and escape confinement on two Hackerbot-controlled target VMs."
overview: |
  Sandboxing involves restricting the capabilities of individual programs or groups of programs, minimising the potential damage a rogue program can inflict on a system. This lab focuses on container-based sandboxes and the use of chroot. You will learn how to create a chroot environment, effectively isolating a set of programs within a directory, and run commands inside this sandbox. The lab also introduces Docker, a popular tool that builds upon the principles of chroot and adds features to automate the creation and deployment of containerised operating systems and applications. You will explore the concept of Docker images as reusable base environments and containers as instances of these images, create and manage containers, observe the speed and efficiency of containerisation compared to traditional chroot, and analyse the level of isolation Docker provides.

  You then need to find a way into, and escape to root from, a Docker container and a chroot container running on two separate target VMs. The flags are stored in `/root/` on each VM, but you first need to find your way in (try a port scan, and try connecting to whatever ports are open), and then escape confinement.

  This is a Hackerbot lab. Work through the lab sheet, then when prompted interact with Hackerbot.
tags: ["containers", "chroot", "docker", "sandboxing", "isolation", "hackerbot"]
categories: ["systems_security"]
type: ["ctf-lab", "hackerbot-lab", "lab-sheet"]
difficulty: "intermediate"
cybok:
  - ka: "AAA"
    topic: "Authorisation"
    keywords: ["SANDBOX", "Application-based access controls: user-based access controls insufficiently limit privileges"]
  - ka: "OSV"
    topic: "Primitives for Isolation and Mediation"
    keywords: ["capabilities", "Container-based sandboxes: chroot, Docker", "Rule-based controls: Course grained: Linux capabilities", "Vulnerabilities and attacks on sandboxing misconfigurations"]
  - ka: "OSV"
    topic: "Role of Operating Systems"
    keywords: ["isolation", "CONTAINERS"]
  - ka: "WAM"
    topic: "Fundamental Concepts and Approaches"
    keywords: ["sandboxing"]
---

## Getting started {#getting-started}

### VMs in this lab {#vms-in-this-lab}

\==action: Start these VMs== (if you haven't already):

- hackerbot_server (leave it running, you don't log into this)
- desktop (you can sudo to get superuser access)
- chroot_esc_server (==edit: IP address, given to you when you claimed the VMs==)
- docker_esc_server (==edit: IP address, given to you when you claimed the VMs==)

### Your login details for the "desktop" VM {#your-login-details}

\==VM: On the desktop VM==, log in using:

- User: ==edit: your username, given to you when you claimed the VMs==
- Password: `tiaspbiqe2r` (**t**his **i**s **a** **s**ecure **p**assword **b**ut **i**s **q**uite **e**asy **2** **r**emember)

You won't log in to the hackerbot_server, chroot_esc_server or docker_esc_server directly at the start of the lab, but all four VMs need to be running to complete it.

{% include hackerbot-intro.md role="task you to sandbox and break out of containers" %}

## Introduction to sandboxing and isolation {#introduction-to-sandboxing-and-isolation}

There are many reasons for not trusting software: the authors may have designed the software to act maliciously (malware), or they may have made design or implementation mistakes that make the software vulnerable to attack. This is where access controls come in. Access controls restrict what each *subject* on a system is authorised to do. Traditionally, access controls (such as Unix file permissions, which are user-oriented) have focused on restricting what each user on a system can do. Over time this has proven insufficient, since it means every program on a system is trusted with all of a user's authorisation: any program can read or delete all of a user's personal documents, web history, and so on.

*Sandboxing* (or application-oriented access controls) involves restricting what a program or group of programs can do. This can significantly improve the security of a system, since a rogue program can do far less damage if it is restricted to only the permissions it requires to function correctly.

One approach to sandboxing is to run applications in isolated environments, with access only to resources (such as files) that are reachable from within the sandbox.

## Container-based sandboxes and chroot {#container-based-sandboxes-and-chroot}

Container-based sandboxes share the kernel but have separate user-space resources. This is more efficient than system-level virtualisation. For example, `chroot()` is a system call on Unix systems that changes the root directory for a process and its children. The new namespace of the application limits it to only accessing files inside the specified directory tree. A wrapper program, `chroot`, can be used to launch programs into a "chroot jail". Only root can perform a chroot, but should change identity as soon as possible, because root can also escape a chroot jail (by performing another `chroot()`), so no program in a chroot should ever stay as root.

There are resources, such as process controls and networking, that are not mediated by chroot. Other mechanisms solve some of these problems, such as FreeBSD Jails.

You will create a chroot environment (a directory containing all the files that the "sandboxed" programs require), and run some programs inside it.

\==VM: On the desktop VM==, ==action: create a directory:==

```bash
sudo mkdir /opt/chrootdir
```

Copy everything needed to run `ls` inside a chroot into that directory. First, look at the details of the `ls` executable:

```bash
ls -la /bin/ls
```

```
-rwxr-xr-x 1 root root 138856 Feb 28  2019 /bin/ls
```

> Note: On some Linux systems, you might see that `/bin/ls` is a symbolic link to `/usr/bin/ls`.

These details show that the file at `/bin/ls` is not a symbolic link.

Now try running `ldd` on `ls`:

```bash
ldd /bin/ls
```

You should get a result that looks something like this:

```
        linux-vdso.so.1 (0x00007ffd17771000)
        libselinux.so.1 => /lib/x86_64-linux-gnu/libselinux.so.1 (0x00007f1410d43000)
        libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f1410b62000)
        libpcre2-8.so.0 => /lib/x86_64-linux-gnu/libpcre2-8.so.0 (0x00007f1410ac8000)
        /lib64/ld-linux-x86-64.so.2 (0x00007f1410dac000)
```

If you are patient, you could copy each required file into your chroot directory. Otherwise, as you can see, all the files can be found in `/lib/` and `/lib64/`.

\==action: Copy all the `/lib/` files into the cage:==

```bash
sudo rsync -av /lib* /opt/chrootdir/
sudo rsync -av /usr/lib* /opt/chrootdir/usr/
```

\==action: Copy `ls` too:==

```bash
sudo rsync -av /bin/ls /opt/chrootdir/bin/
```

\==action: Run `ls` in a chroot:==

```bash
sudo chroot /opt/chrootdir/ /bin/ls
```

Note that `ls` can only see the files that are in the chroot cage.

\==action: Run `ls` in the chroot, attempting to view the root (`/`) directory:==

```bash
sudo chroot /opt/chrootdir/ /bin/ls /
```

Note that, again, as far as anything in the chrooted program is concerned, what the rest of the system calls `/opt/chrootdir/`, it sees as `/`. This is referred to as the program's *namespace*.

\==action: Create a more complete chroot environment==, for running command line programs, including bash (the Linux shell command prompt):

```bash
sudo rsync -av /bin/ /opt/chrootdir/bin/
sudo rsync -av /usr/bin/ /opt/chrootdir/usr/bin/
sudo rsync -av /etc/ /opt/chrootdir/etc/
sudo rsync -av /usr/ /opt/chrootdir/usr/

sudo mkdir /opt/chrootdir/home/
```

> Note: This will take a fair while. You can continue the exercise in another terminal tab, or read about [bind mounting](http://docs.1h.com/Bind_mounts) while you wait. You may also want to work through the Docker section below while this runs.

Once the rsync above is complete, \==action: bind mount `/sys`, `/dev`, and `/proc` into the cage:==

```bash
sudo mkdir /opt/chrootdir/dev /opt/chrootdir/sys /opt/chrootdir/proc

sudo mount --bind /dev /opt/chrootdir/dev
sudo mount --bind /sys /opt/chrootdir/sys
sudo mount --bind /proc /opt/chrootdir/proc
```

\==tip: Read `man mount` to understand what this does, and the security consequences.==

> Question: Why can it be a bad idea to bind mount the entire root ("/") directory into the chroot cage?

\==action: Run bash inside the chroot:==

```bash
sudo chroot /opt/chrootdir /bin/bash
```

\==action: Create a new user within the chroot== (you will be prompted to enter a password for the new user):

```bash
sudo useradd -d /home/username username; sudo passwd username
```

Then, to make bash switch to this new user:

```bash
su - username
```

Note that you can now run commands and (mostly) only affect the chroot directory.

Experiment with what is possible from within the chroot cage. You may wish to copy across further files and their dependencies from the main system to run from inside the chroot.

> Tip: To share the same X server (so you can run graphical programs from the chroot), run `export DISPLAY=:0`.

What can you see in `/`, `/opt`, `/proc`?

> Question: Can you access anything outside of the chroot? As a normal user? As root?

Understand that you can still access the network, and possibly do damage, via the bind-mounted directories.

In general, we would typically create a minimal install for a chroot environment, such as with [Debootstrap](https://wiki.debian.org/Debootstrap).

## Docker {#docker}

Docker builds on chroot, adding virtualisation features to automate the creation and deployment of containerised OSes and applications. Docker improves security compared to chroot by using LXC (and others, such as libcontainer) to provide added isolation, making use of Linux kernel cgroups to limit resources such as CPU, memory, block I/O, and network. Compared to chroot, Docker provides some additional protection against root users escaping confinement.

Docker is portable across Linux systems and makes use of reusable base images, with automated approaches to building containers to specifications.

Docker *images* are reusable bases that can be used to create *containers*, and can be downloaded via the `docker` command, and browsed online at Docker Hub: [https://hub.docker.com/](https://hub.docker.com/)

> Note: The lab VMs have no internet access, so images cannot be pulled directly (for example with `docker pull ubuntu`). We have prepared an isolated environment for you, with some bases already downloaded for you to use.

\==action: View the bases available:==

```bash
sudo docker images
```

The bases available to you already include busybox, ubuntu:xenial, and debian:stretch. Busybox is a very minimal Linux system popular on embedded devices; Ubuntu and Debian are *complete distributions of Linux* — these bases provide a minimal installation of those distros, but you could install pretty much any Ubuntu/Debian packages into these containers.

\==action: Create a container and launch a command into it:==

```bash
sudo docker run busybox echo "hello this is busybox"

sudo docker run busybox echo "busybox!"
```

\==action: And run:==

```bash
sudo docker run debian:stretch echo "debian!"
```

Each of the above commands creates and then runs a command in a new container based on an image. Note the speed with which new containers can be created, compared to the manual work needed for chroot, or how long it can take to create a full VM.

\==action: View a list of all the Docker containers on your system:==

```bash
sudo docker ps -a
```

\==action: Run an interactive command line:==

```bash
sudo docker run -it busybox sh
```

> Tip: Press Ctrl-D to exit.

\==action: Run an interactive Ubuntu command line:==

```bash
sudo docker run -it ubuntu:xenial bash
```

> Question: Using Docker, can you access anything outside of the container? As a normal user? As root? How much isolation does it provide? How does this compare to a full VM, for example in Proxmox?

\==warning: **Before you exit the safety of the Docker container**, run:==

```bash
rm -rf /
```

> Warning: This deletes everything in the container!

What can you see in `/`, `/opt`, `/proc` of the container?

\==action: Press Ctrl-D to exit the container.==

What can you see in `/`, `/opt`, `/proc` now, back on the host?

Docker can grant containers access to files or the network.

\==action: Ensure you have a secret file:==

```bash
cat $HOME/mysecret
```

\==action: Run a container with access to your secret file:==

```bash
sudo docker run -v $HOME/mysecret:/srv/mysecret:ro -it ubuntu:xenial sh
```

\==action: Access the file within the container:==

```bash
cat /srv/mysecret
```

\==action: Attempt to write to the file within the container.==

> Tip: Press Ctrl-D to exit the container.

> Question: How does Docker's file sharing feature work?

Note that our various containers are still running:

```bash
sudo docker ps -a
```

\==action: Containers can be stopped, run:==

```bash
sudo docker stop CONTAINER_ID
```

> Note: Where `CONTAINER_ID` is one of the containers on your system.

Or, to stop them all:

```bash
sudo docker stop $(sudo docker ps -a -q)
```

And containers can be deleted:

```bash
sudo docker rm CONTAINER_ID
```

And to delete all the containers that are stopped:

```bash
sudo docker container prune
```

#### Hackerbot Attack #1 {#hackerbot-attack-1}

You can skip the bot to here, by saying **goto 1**.

> Hackerbot: Break into the docker_esc_server and chroot_esc_server VMs (try a port scan, then try connecting to whatever ports are open), then escape confinement to root on each. The flags are in `/root/`.

When you are ready for the bot to run the attack, ==action: say 'ready'== to Hackerbot.

Don't forget to ==action: save and submit any flags!==

## Resources {#resources}

Schreuders, Z. C., McGill, T. and Payne, C. (2013) "The State of the Art of Application Restrictions and Sandboxes: A Survey of Application-oriented Access Controls and their Shortfalls," *Computers and Security*, Volume 32, Elsevier B.V. DOI: [10.1016/j.cose.2012.09.007](http://z.cliffe.schreuders.org/publications/Computers&Security%20-%20The%20State%20of%20the%20Art%20of%20Application%20Restrictions%20and%20Sandboxes%20-%20Author%20Version.pdf)
