# CSL Wi-Fi lab: setup and troubleshooting notes

Notes from setting up the lab PCs, routers and Pineapples, for the lab sheet and the kit README.
Staff notes: keep this file itself out of the public lab sheet repo.

## Pineapple (WiFi Pineapple Mark VII)

### Reaching the web portal

- Each Pineapple has its management IP printed on a label on the unit (e.g. `172.22.252.102`).
- The portal is on **port 1471**: browse to `http://<IP on the label>:1471/`. Without `:1471` you get a blank page or nothing.
- Login: username `root`, password `hak5pineapple`.
- If the browser shows the university proxy's "Access denied" page, the Pineapple's subnet isn't in the account's proxy bypass list. Add `172.22.252.*` (and `172.16.42.*`, the Pineapple default) to the bypass list, then fully close and reopen the browser.
- Forgotten password: boot the Pineapple fully, then hold Reset for 10 s or more. The LED flashes a rainbow sequence and it reboots. You can then set a new password; other settings are kept. This works on firmware 1.1.0 and later.

### Problem: no network interface for the Pineapple on the PC

**Symptom:** the Pineapple is powered (LED on) but the PC gets no 172.x address, no "Remote NDIS" or USB Ethernet adapter appears, and nothing answers on port 1471.

**Cause (found 2026-11-24):** the USB-A to USB-C cable was **charge-only**. It powered the Pineapple but carried no data. A different cable fixed it.

**Check:** run this in PowerShell on the PC the Pineapple is plugged into. It shows the adapters, any 172.x address with its gateway, which addresses answer on port 1471, and the proxy setting:

```powershell
$o = New-Object System.Collections.Generic.List[string]
$o.Add("PC: $env:COMPUTERNAME  user: $env:USERNAME")
$o.Add('== Adapters that are up ==')
Get-NetAdapter | Where-Object Status -eq 'Up' | ForEach-Object { $o.Add(('  {0,-28} {1}' -f $_.Name, $_.InterfaceDescription)) }
$o.Add('== Addresses in 172.16-31.x.x (the Pineapple link) ==')
$cands = New-Object System.Collections.Generic.List[string]
Get-NetIPConfiguration | Where-Object { $_.IPv4Address.IPAddress -match '^172\.(1[6-9]|2\d|3[01])\.' } | ForEach-Object {
    $gw = $_.IPv4DefaultGateway.NextHop
    $o.Add("  $($_.InterfaceAlias): PC address $($_.IPv4Address.IPAddress)/$($_.IPv4Address.PrefixLength)  gateway $gw  DNS $(@($_.DNSServer | Where-Object AddressFamily -eq 2 | ForEach-Object ServerAddresses) -join ', ')")
    if ($gw) { $cands.Add($gw) }
    $net = ($_.IPv4Address.IPAddress -replace '\.\d+$', '')
    $cands.Add("$net.1")
}
foreach ($c in '172.16.42.1', '172.22.252.1', '172.22.252.102') { $cands.Add($c) }
$o.Add('== Who answers on port 1471 ==')
foreach ($h in $cands | Select-Object -Unique) {
    $t = New-Object Net.Sockets.TcpClient
    $ok = try { $t.ConnectAsync($h, 1471).Wait(2000) } catch { $false } finally { $t.Close() }
    $o.Add("  ${h}:1471 open: $ok")
}
$ie = Get-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings'
$o.Add("Proxy: ProxyEnable=$($ie.ProxyEnable) ProxyServer=$($ie.ProxyServer) Bypass=$($ie.ProxyOverride)")
$o | Out-String -Width 300 | Set-Clipboard
$o
```

- **No 172.x address and no new USB adapter:** check the cable first (try one known to carry data). Give the Pineapple 2-3 minutes to boot, then try another USB port.
- **A 172.x address, but nothing answers on 1471:** the Pineapple is still booting, or its IP differs from the label. The gateway shown is usually the Pineapple.

If a device appears but no address does, check whether Windows has a driver for it. Run this once with the Pineapple plugged in, then again after unplugging and replugging it. The line that changes is the Pineapple:

```powershell
Get-PnpDevice -PresentOnly -ErrorAction SilentlyContinue | Where-Object {
    $_.Status -ne 'OK' -or $_.FriendlyName -match 'RNDIS|NDIS|CDC|ECM|Gadget|Pineapple|Hak5|USB Ethernet|Linux'
} | Format-Table Status, Class, FriendlyName, InstanceId -AutoSize | Out-String -Width 300
Get-NetAdapter -IncludeHidden | Format-Table Name, InterfaceDescription, Status -AutoSize | Out-String -Width 300
```

A device with Status `Error` or `Unknown` means Windows sees the Pineapple but has no driver for it.

### For the lab sheet

- **To do:** replace "Log in with the details your tutor gives you" with the actual login: username `root`, password `hak5pineapple`.
  - Decided 2026-11-24, so students aren't held up waiting for the tutor.
  - The sheet is public, so anyone who can reach a Pineapple's portal could log in. Each portal is reachable only from the PC it's plugged into (over USB), and from the Pineapple's management Wi-Fi if that's switched on. So keep the management Wi-Fi off or password-protected.
- Possible sheet additions: "The Pineapple's address is on its label; add `:1471`", and "If your PC doesn't see the Pineapple, try another USB-C cable: some only charge."
- **To do:** rephrase "You don't need to document every page; you will use the important ones below." It's in Getting started > Attacker PC, after the list of Pineapple interface pages and before the SSH check. "Document" reads as if students have to write something up. Suggested wording: "This is just to find your way around: the pages you need are covered step by step later on."
- **To do:** fix the SSH code block in Getting started > Attacker PC. The command is written as ``ssh root@==edit: your Pineapple's IP address==`` inside a code block. Highlight markup isn't processed inside code blocks, so the `==edit: ...==` shows literally as part of the command. Fix: put a plain placeholder in the block, e.g. `ssh root@PINEAPPLE-IP`, or the label address format, e.g. `ssh root@172.22.252.102`. Then add a line outside the block: "Replace `PINEAPPLE-IP` with the address on your Pineapple's label." Also check that the `==action: ...==` line just above it renders as an action and not as raw `==` text.
- **To do:** lengthen the Recon scan. On 2026-11-24, a 30-second scan on the Pineapple's Recon page didn't pick up the `CSL-Cafe` access point the first time. It scans channel by channel, and the room is full of university networks on 1, 6 and 11. Suggested change: "Start a 2-minute scan (or a continuous one, stopping it once `CSL-Cafe` appears). If `CSL-Cafe` isn't listed, scan again before asking for help." Re-test on the day with all the Pineapples running, and set the duration to whatever reliably finds it.
- **Deferred (come back later):** the PMF part of the sheet. Two findings on 2026-11-24:
  - The Pineapple's Recon page labels the column **MFP** (Management Frame Protection), not PMF. Both names mean IEEE 802.11w. Wherever the sheet says "PMF", say "MFP (also called PMF)" so students can find the column. The kit README's pre-lab check 7 ("the PMF column reads 'no'") needs the same change.
  - **No network in range uses it**, not even the university's. `CSL-Cafe` can't, because it's open. Any task or question that expects students to find a protected network in Recon has nothing to show unless the tutor runs the optional WPA2 "PMF required" demo network from the README. Options when we come back to it: set up that demo network, turn the question into a "why would this stop the deauth attack?" discussion, or drop it.
- **To do:** make "Leave them alone." stand out in Part 1: Surveying the network. It's currently buried in a Note that starts "Expect to see a large number of other networks, including the university's own Wi-Fi." Pull it out of the Note into its own **Warning** callout (the sheet already has Warning callouts), as a big red, exclamation-style warning above the Note. For example:

  > Warning: ⚠️ **Do not attack, deauthenticate or connect to any network except `CSL-Cafe`.** The university's Wi-Fi and every other network you see are real, in use, and not part of this lab. Interfering with them is against university rules and may be illegal. Leave them alone.

  Check how the sheet's theme styles Warning callouts. If they aren't red, use the sheet's existing danger/red style if it has one, or add a class for it.
- **To do:** add a step for checking which network the victim PC is on:
  1. Open **Control Panel → Network and Internet → Network and Sharing Center**.
  2. Under "View your active networks", check that the active network is the **Wi-Fi** connection to `CSL-Cafe`.
  3. The name on the left may read **`CSL-Cafe`** or **`CSL-Cafe 2`**. Both are fine. Windows adds " 2" when it has already saved another network with the same name (e.g. from an earlier session or the other room's router).

  4. Click the **Wi-Fi (CSL-Cafe)** link next to "Connections" to open **Wi-Fi Status**, then click **Details...**. The Network Connection Details window shows the victim's IPv4 address, default gateway and DNS server. That tells students whether they're on the real router (address `192.168.75.x`, gateway `192.168.75.1` or `.254`) or on a Pineapple (the Pineapple's subnet, gateway the Pineapple).

  Screenshots: `network settings.png` (step 2) and `wifi_connection_details.png` (step 4), to add to the sheet's images.
- **To do (confirmed 2026-11-24):** replace the PineAP step in the sheet. Current text: "Set PineAP to Advanced mode and enable "Beacon Response", "Broadcast SSID Pool" and "Allow Associations", then save the settings." Those labels are from older firmware and don't exist on our Mark VIIs (2.x). New text:

  > ⚡ Set PineAP to **Advanced** mode and turn on **Impersonate All Networks** and **Advertise AP Impersonation Pool**, then ⚡ save the settings. Your Pineapple is now broadcasting `CSL-Cafe` and will accept connections to it, but only from your victim, because of the filters you set earlier.

  How the old settings map across, for reference:
  - "Beacon Response" (answering clients' requests for a network) → **Impersonate All Networks**.
  - "Broadcast SSID Pool" → **Advertise AP Impersonation Pool**.
  - "Allow Associations" → no separate option. The **Filters** decide who may connect (Client filter: Allow, victim's MAC only; SSID filter: Allow, `CSL-Cafe` only), and the sheet already has students set those.
  - `CSL-Cafe` must be in the **Impersonation pool**, or "Advertise" has nothing to broadcast. If the sheet doesn't already have students add it, add a step (Recon: select `CSL-Cafe` > add to PineAP pool, or type it in on the Impersonation tab).

## Evil twin test (2026-11-24, room-2 router, one Pineapple, one victim)

- **The Pineapple's open copy of `CSL-Cafe` works.** With PineAP in Advanced mode, Impersonate All Networks and Advertise AP Impersonation Pool on, and `CSL-Cafe` in the pool, the victim saw a second, **open** `CSL-Cafe` from the Pineapple (BSSID `00:13:37:a9:c1:f9`, channel 11) next to the router's (`28:87:ba:83:11:4c`, channel 6).
- **The Pineapple's Evil WPA also showed up as a *secured* `CSL-Cafe`** (BSSID `00:13:37:be:ef:00`). Windows treats open and secured networks of the same name as different networks, so it's no use as the evil twin and only confuses students. **To do:** add "turn off Evil WPA" to the Pineapple setup (README section 5) or to the sheet's PineAP step.
- **The victim would not leave the router.** Both copies showed 100% signal on the victim, so Windows had no reason to switch, even after reconnecting. The router was assumed to be on Low transmit power (not checked: the admin password for the room-2 router wasn't to hand). **Switching the router off** made the victim join the Pineapple straight away.
  - So router placement, plus Low power, is the deciding factor. Put the router as far from the victims as the room allows (README section 7a layout: router in the middle, victims at the corners), and keep each Pineapple right next to its victim's dongle.
  - Windows' "Signal" % tops out at 100%, so `netsh wlan show networks mode=bssid` can't show which of two strong signals is stronger. A victim that stays on the router means the router is still too loud there.
  - **To test on the day:** the room layout with all four Pineapples, and whether victims move after Wi-Fi off/on. If not, the fallbacks are the README's contingency ladder (e.g. B: Open AP renamed `CSL-Cafe-TeamN`, victim joins by hand).
- Check which network a victim is on by BSSID: `00:13:37:...` is a Hak5 Pineapple, `28:87:ba:...` is a TP-Link router. Or check the gateway in the Wi-Fi Details window.
- **Router admin passwords:** not recorded here. Keep them with the staff kit. If one is lost, factory-reset the router (hold Reset ~10 s) and set it up again (LAN IP `.1` room 1, `.254` room 2).
- **Signal tests (same session):** with the router in a cupboard, then with an anti-static bag over its antennas (Low transmit power throughout), the victim's scan showed the router at about **59%** (roughly −70 dBm) and the Pineapple, an inch from the dongle, at 100%. **Windows still chose the router** every time, including after forgetting the network. Once connected, the dongle reports 100% whatever the real signal (driver quirk), so only the disconnected scan figure, or the Pineapple's Recon dBm, means anything. Conclusion: a stronger evil twin alone does **not** pull a Windows 10 victim off the router. Weakening the router (cupboard, foil or a metal tin over the antennas, distance) helps but isn't enough on its own.
- **Deauth worked first time.** On the Pineapple's Recon page: select the victim client (`30:de:4b:67:33:4b`) under the router's `CSL-Cafe` (`28:87:ba:...`) → **Deauth**. The victim dropped off the router and reconnected to the Pineapple's `CSL-Cafe`. It works because `CSL-Cafe` is open, so no MFP.
  - **To do (sheet, Part 2):** make deauth the main way to get the victim onto the evil twin. Rough draft: "On Recon, find your victim under the router's `CSL-Cafe` and send a **Deauth**. Your victim is disconnected from the café router and reconnects, this time to your Pineapple. Check the victim's gateway in its Wi-Fi Details." Pair it with the "only ever deauth your own victim" warning, and link it to the MFP discussion: a network with MFP would ignore these forged disconnects. Keep contingency B (`CSL-Cafe-TeamN`, joined by hand) as the fallback.
  - **To do (README section 6/7a):** update "Getting the victim onto the evil twin": Wi-Fi off/on and router placement weren't enough in testing, so deauth is the method. Re-test on the day with four Pineapples deauthing their own victims at once.
- **To do (sheet, Part 2):** remove the **"The victim arrives"** subsection (the "walking into the café" simulation). It starts "Rather than knocking your victim off the network, you will simulate them walking into the café." and ends with the discussion question "...Would a typical customer notice either?". In testing, Windows never moved to the evil twin this way, so it's unreliable. The **Deauthentication** subsection that follows becomes the way the victim gets onto the Pineapple. Its opening note currently treats deauth as a tutor demonstration or needing permission: reword it as the main step (deauth **your own victim only**).
  - Don't lose the useful steps from "The victim arrives". Move them to after the deauth: run `ipconfig` on the victim, browse to the café sites, and on the attacker PC open the **Clients** page ("Your victim should appear as connected to your Pineapple"). Keep the discussion question if it still fits (e.g. "Would a typical customer notice being moved to another network?").
- **To do (sheet):** in "Run `ipconfig` again, and browse to two or three of the café's sites.", add the links so students don't have to type them. Same as the CSL Cafe bookmarks:
  - Intranet: <http://intranet.csl.internal>
  - Shop: <http://shop.csl.internal> (deliberately `http://`)
  - Bank: <https://bank.csl.internal>
  - Health: <https://health.csl.internal>
  - Jobs: <https://jobs.csl.internal>

  E.g. "...browse to two or three of the café's sites, for example [Intranet](http://intranet.csl.internal), [Shop](http://shop.csl.internal) and [Bank](https://bank.csl.internal) (also in the CSL Cafe bookmarks)." This sentence is currently inside "The victim arrives", so move it along with the other steps.

## Café sites through the Pineapple (2026-11-24)

Chain: victim → Pineapple Open AP → Pineapple wlan2 → router → staff PC. Working, after four fixes:

1. **The Pineapple's wlan2 must be connected to the router's `CSL-Cafe`.** It had dropped while the router was switched off for testing, and didn't reconnect by itself. Symptom: the Pineapple answers every DNS lookup with "refused" (no upstream DNS). Fix: Pineapple **Settings → Networking**, Wi-Fi client (wlan2): scan and join `CSL-Cafe`. **Pick the router's access point (channel 6, BSSID `28:87:ba:...`), not the Pineapple's own Open AP** (also called `CSL-Cafe`, channel 11). Check over SSH: `iw dev wlan2 link` shows `Connected to 28:87:ba:...`, and `ip -4 addr show wlan2` shows `192.168.75.x`. Signal was −79 dBm with the router under an anti-static bag: take shielding off now that deauth is the method.
2. **DNS rebind protection blocked every lab answer.** The Pineapple's dnsmasq discards upstream answers that point to private addresses; its log shows "possible DNS-rebind attack detected: intranet.csl.internal". Fix (persists across reboots), in the Pineapple's shell:
   ```
   uci add_list dhcp.@dnsmasq[0].rebind_domain='csl.internal'
   uci commit dhcp
   /etc/init.d/dnsmasq restart
   ```
   Check: `uci get dhcp.@dnsmasq[0].rebind_domain` prints `csl.internal`; `nslookup intranet.csl.internal 127.0.0.1` gives `192.168.75.10`.
3. **Use only the staff PC for DNS** (optional but avoids slow lookups: the automatic list had `8.8.8.8`, unreachable, before `192.168.75.10`):
   ```
   uci set dhcp.@dnsmasq[0].noresolv='1'
   uci -q delete dhcp.@dnsmasq[0].server
   uci add_list dhcp.@dnsmasq[0].server='192.168.75.10'
   uci commit dhcp
   /etc/init.d/dnsmasq restart
   ```
   Undo before module store / firmware updates (they need internet DNS): `uci set dhcp.@dnsmasq[0].noresolv='0'; uci -q delete dhcp.@dnsmasq[0].server; uci commit dhcp; /etc/init.d/dnsmasq restart`.
4. **The victim's network cable must be unplugged.** Symptom: names resolve (DNS goes to the Pineapple over Wi-Fi) but every site times out. With the cable in, traffic for `192.168.75.10` leaves via the university's wired gateway, because on the Pineapple the lab subnet is no longer local. On the router it worked with the cable in, which hides the problem until the evil twin step. Check: `Find-NetRoute -RemoteIPAddress 192.168.75.10` should show `Wi-Fi` via the Pineapple. Temporary workaround if a cable is needed for testing: `route add 192.168.75.0 mask 255.255.255.0 172.22.252.102` (gone after restart; `route delete 192.168.75.0` to remove).

Other findings:
- **Don't restart dnsmasq while victims are connected.** The victim dropped off the Pineapple when it was restarted (dnsmasq is also the DHCP server) and went back to the router. Do the DNS settings during setup.
- The Pineapple's NAT was already right: `wcli` (wlan2) is in the `wan` zone with `masq='1'`, and there's a `lan` → `wan` forwarding rule. Nothing to change.
- The Pineapple's **clock shows 2021**: no internet, so no time sync. Harmless, but log and capture timestamps are wrong. Optional: set it before the session (`date -s "2026-11-24 12:00"`), or let it sync during setup with internet.
- Pasting long lines into the Pineapple's shell (`root@mk7`) can add `^[[200~` and `~` (terminal paste markers). Paste short lines, or run commands as `ssh root@<IP> "..."` from PowerShell.
- Busybox `wget` on the Pineapple has no `-S`. Use `wget -q -T 8 -O - <url> | head -c 200`.
- On the staff PC, a browser can't open `*.csl.internal`. That's expected: Windows there uses the university DNS. `Start-StaffLab.ps1 -Test` is the real check.

**To do (README section 5, Pineapple setup):** add fixes 1–3 as setup steps for every Pineapple (wlan2 on the router's BSSID; `rebind_domain`; `noresolv` + server), plus "turn off Evil WPA". **To do (sheet):** in the victim setup, make "unplug the network cable" prominent, and add the symptom (sites time out even though names resolve) to the troubleshooting notes.
- **To do (sheet): students run the Pineapple DNS fix as a setup step.** Put it in "Connecting the Pineapple", **after** wlan2 is connected to `CSL-Cafe`, and **before** the victim joins the Pineapple (restarting dnsmasq drops connected clients). Students run it in the Pineapple's **Terminal**: in the Pineapple's web page, click the **Terminal** button, then paste this single line and press Enter. `del_list` first keeps it safe to run twice:

  ```
  uci -q del_list dhcp.@dnsmasq[0].rebind_domain='csl.internal'; uci add_list dhcp.@dnsmasq[0].rebind_domain='csl.internal'; uci commit dhcp; /etc/init.d/dnsmasq restart; sleep 2; nslookup intranet.csl.internal 127.0.0.1
  ```

  Expected: the last lines show `Address 1: 192.168.75.10` (an extra "No answer" for IPv6 and `udhcpc` lines are normal). Suggested sheet text: "Your Pineapple blocks DNS answers that point to private addresses (DNS rebind protection), which would stop the café sites working through it. Allow the café's domain: ⚡ click **Terminal** on the Pineapple's page and ⚡ run [command]. You should see `192.168.75.10`." Short explanation, because rebind protection is itself a useful security idea.
  - The `noresolv` change (staff PC only for DNS) stays optional: leave it out of the sheet, or do it in staff setup (README section 5) if lookups are slow on the day.
  - Alternatively the staff can do this once per Pineapple during setup (README section 5), since it persists across reboots. Then the sheet step becomes a check only. Decide which; doing it in staff setup saves student time, putting it in the sheet teaches rebind protection.

## Live capture into Wireshark (2026-11-24)

- **Works**, from a **Command Prompt (cmd)** on the attacker PC, with the password typed when asked:
  ```
  ssh root@PINEAPPLE-IP "tcpdump -i any -U -w - not port 22 and not port 1471" | "C:\Program Files\Wireshark\Wireshark.exe" -k -i -
  ```
- **To do (sheet): fix the capture command.** The published sheet shows `\|` instead of `|` (leftover escaping, probably from a Markdown table). In cmd the stray `\` is passed to ssh as part of the remote command, tcpdump gets a filter ending in `\` and exits with "can't parse filter expression", and Wireshark then reports end of file on the "pipe magic". That message means tcpdump quit, not a timeout. Also, the `root@==edit: your Pineapple's IP address==` part isn't formatted correctly: inside the code block the `@==edit: ...==` placeholder isn't processed, so students see the raw `==edit:` markup in the command. Replace it with `root@PINEAPPLE-IP`, plus a line outside the block saying to use the address on the Pineapple's label (same problem as the SSH block).
- **To do (sheet):** say to run it in a **Command Prompt**, not PowerShell. Windows PowerShell 5.1 corrupts binary data piped between programs.
- **To do (sheet):** tell students to expect a Wireshark notice that **Npcap isn't installed** / local interfaces are unavailable, and to ignore it. The capture comes from the Pineapple over SSH (`-i -`), so Npcap isn't needed.
- Password prompt: typing it promptly worked. If Wireshark gives up while waiting, set up an SSH key once (cmd):
  ```
  ssh-keygen -t ed25519 -N "" -f "%USERPROFILE%\.ssh\id_ed25519"
  type "%USERPROFILE%\.ssh\id_ed25519.pub" | ssh root@PINEAPPLE-IP "k=$(cat); mkdir -p /root/.ssh /etc/dropbear; echo $k >> /root/.ssh/authorized_keys; echo $k >> /etc/dropbear/authorized_keys; chmod 700 /root/.ssh; chmod 600 /root/.ssh/authorized_keys /etc/dropbear/authorized_keys"
  ssh root@PINEAPPLE-IP "echo ok"
  ```
  (Not tested; the last line should print `ok` with no password.) If keys are used, the README clean-up step should clear them from the Pineapples between groups.
- The first SSH connection to each Pineapple asks "Are you sure you want to continue connecting (yes/no)?". Having students do the plain SSH login check earlier in the sheet ("Check that you can also log in to the Pineapple over SSH") answers it before the capture step, so keep that check before the capture.
- **To do (sheet, Part 3): rewrite the "read an HTTPS page" step so the point is obvious.** Current text: "Try to read the content of one of the HTTPS pages (right-click a packet, Follow, TLS Stream)." It doesn't say what students should see, and an empty window just looks like they did it wrong. Tested 2026-11-24: Follow → TLS Stream shows nothing; Follow → TCP Stream shows only scrambled data (as a hex dump by default). Suggested replacement:

  > ⚡ Try to read the content of one of the HTTPS pages: right-click a **Client Hello** for one of the HTTPS sites (e.g. `bank.csl.internal`) and choose **Follow → TLS Stream**. The window is **empty**: Wireshark can't decrypt the connection, because only the victim's browser and the café's server have the keys.
  >
  > ⚡ Close it, right-click the same packet and choose **Follow → TCP Stream**, then set **Show data as** to **ASCII**. Near the start you can read the site's name (the SNI). Everything after the handshake is scrambled: that is the encrypted page.
  >
  > So the network can see **which** HTTPS site the victim visited, but not **what** was on it. In Part 4 you will compare this with a page sent without encryption.

  - Follow replaces the display filter with one for that connection (e.g. `tcp.stream eq 7`). After closing the Follow window, add "⚡ Clear the display filter (the ✕ at the right of the filter bar)" before moving on, so students see all the traffic again for the Note about Windows background traffic.
- **To do (sheet, Part 3): remove Submission Question 4.** Currently: "Submission Question 4. Include a screenshot showing the sites your victim visited, as revealed by DNS and SNI. Which parts of the victim's browsing could you see, and which could you not? Explain why HTTPS hides some of it but not the rest. Name and briefly explain technologies that would hide what you could see (consider DNS over HTTPS, Encrypted Client Hello and VPNs). Why might a list of sites visited be sensitive on its own, even without the content?" Replace the whole question (screenshot included) with a short prompt that isn't submitted, e.g.:

  > Note: Consider why a list of the sites someone visited might be sensitive on its own, even without seeing what was on them.

  Use the sheet's Note (or Tip) callout rather than "Question", which the sheet uses for submission questions.
  - **Renumber the later submission questions** (5 becomes 4, and so on), and update every reference to them, e.g. Part 4's heading "Reading unencrypted traffic (Submission Question 5)", and any marking scheme or submission template that lists the question numbers.

## Screenshots and capture file (for rewriting the lab sheet)

**To do:** download the `screenshots_and_pcap.zip` attached in the chat on 2026-11-24 and use these when rewriting the sheet. They were captured on the real kit this session, so they match what students will see. Add them to the sheet's images folder.

Files in the zip:
- `network settings.png` - Network and Sharing Center, active network = Wi-Fi (CSL-Cafe). (The notes above referred to this as step 2's screenshot.)
- `network_connection_details.png` - Wi-Fi Status > Details (IP, gateway, DNS). (This is the file the notes earlier called `wifi_connection_details.png` - use this actual name.)
- `ipconfig.PNG` - victim `ipconfig`, for the before/after comparison on the evil twin.
- `client connected.png` - Pineapple Clients page showing the victim connected.
- `RECON.PNG` - Pineapple Recon page (networks/clients; MFP column).
- `Filters.PNG` - PineAP client/SSID filters.
- `dns_filter.PNG` - Wireshark filtered by DNS.
- `SNI.PNG` - Wireshark Client Hello with the SNI / server_name field.
- `web_shell.png` - the Pineapple web Terminal.
- `web_browsing.pcapng` - the capture itself (~6 MB). Useful as the ready-made capture for contingency C (no victim: students analyse this file for Part 3). Put it where the sheet/README points (README mentions `C:\csl-lab\csl-cafe-capture.pcapng` - either rename this to that, or update the path to match).

## Stretch task: DNS spoofing persists (2026-11-24)

- The sheet's stretch task uses `uci add_list dhcp.@dnsmasq[0].address=... ; uci commit dhcp`. That is
  **persistent**: it's written to `/etc/config/dhcp` and survives reboots. If a team skips the clean-up
  step, the next group's victim gets the fake shop and bank, and nobody knows why.
- It also ends with `/etc/init.d/dnsmasq restart`, which (see above) **drops the victim off the Pineapple**,
  and it may go back to the router. So the step can quietly undo the evil twin just before it's needed.
- **To do (sheet, stretch):** replace it with a non-persistent version that doesn't restart dnsmasq:
  ```
  echo '192.168.75.11 shop.csl.internal bank.csl.internal' > /tmp/hosts/csl-spoof; killall -HUP dnsmasq; nslookup shop.csl.internal 127.0.0.1
  ```
  and to undo it:
  ```
  rm -f /tmp/hosts/csl-spoof; killall -HUP dnsmasq; nslookup shop.csl.internal 127.0.0.1
  ```
  OpenWrt's dnsmasq reads every file in `/tmp/hosts` (`addn-hosts`), `/tmp` is in RAM (gone on reboot),
  and SIGHUP re-reads the hosts files and clears the cache without touching DHCP. **Tested 2026-11-24 on
  a Mark VII: works.** `addn-hosts=/tmp/hosts` is present, nslookup gives `192.168.75.11` then
  `192.168.75.10` after the undo, and the victim stayed connected throughout. Shop and Bank behaved as
  expected (fake shop over HTTP, login visible; Bank: certificate error with no way past it).
- **To do (README clean-up between groups):** check every Pineapple for leftovers:
  `uci -q get dhcp.@dnsmasq[0].address` should print nothing (or remove with `uci -q delete dhcp.@dnsmasq[0].address; uci commit dhcp`).
- The stretch text also still says "Close Edge", "Open Edge", "Shop/Bank favourite" (covered by L2), and
  "as in Part 4": check that part number after Submission Question 4 is removed and parts are renumbered.

## Captive portal: dropped for this year (decided 2026-11-24)

- **To do (sheet):** remove the Evil Portal / captive-portal part (README calls it Part 4), renumber the
  later parts and submission questions, and update cross-references ("as in Part 4", the session timetable
  in README section 7, the Pineapple setup in README section 5 that installs Evil Portal, and contingency C's
  "Part 4 as a tutor demo").
- Next year: install Evil Portal on each Pineapple with internet (e.g. phone hotspot), or use the
  Option A sketch (fake sign-in page on `192.168.75.11:8080` + one iptables DNAT rule on the Pineapple;
  draft in csl-kit-change15-portal.patch, never tested).

## Stretch task: why the browser must be closed (correction, 2026-11-24)

- The hand-off for the sheet edit (L2) says to close the browser "so it forgets HSTS state that isn't
  preloaded". **That's wrong.** Chrome and Edge save HSTS to the profile on disk; closing the browser
  keeps it (only InPrivate/Incognito windows start without it). That's what makes the Bank step work:
  the victim visited the bank in Getting started, so its HSTS is still cached.
- The real reasons to close the browser: it has its own DNS cache and kept-alive connections to the real
  servers on `.10`, so after the spoof it could keep using the real shop. Closing it plus
  `ipconfig /flushdns` makes the next lookup go to the Pineapple.
- **To do (sheet, stretch):** keep "close the browser fully, then flush DNS", give that reason, and say
  **don't** use an InPrivate/Incognito window (it has no cached HSTS, so the Bank step would show a
  certificate warning with a "Continue" link instead of a hard block).

## New structure for this year (decided 2026-11-24)

Parts 1-4 as now (with the fixes above), then the old stretch task becomes **Part 5**. The captive-portal
part is removed (see above). Nothing new to build in the kit: the fake shop and bank on `192.168.75.11`
already exist and `Start-StaffLab.ps1` already checks them.

Why Part 5 matters (the point Parts 1-4 don't make): on an open network anyone nearby can sniff
passively, so reading traffic alone doesn't show why the evil twin matters. Being the AP adds two things:
- **Control, not just observation.** The Pineapple is the victim's DNS server and gateway, so the attacker
  decides where the victim goes.
- **It defeats Wi-Fi encryption.** WPA2 with a shared password, or encrypted "open" Wi-Fi (OWE / Enhanced
  Open), stops outsiders reading traffic, but clients don't authenticate the access point, so an evil twin
  with the same name (and password) still gets the victim's traffic in the clear. Discussion only.

**Draft sheet text, Part 5: Sending the victim to the wrong site**

> On an open network, anyone nearby could read the traffic you captured in Parts 3 and 4. As the victim's
> access point, you can do more: your Pineapple answers the victim's DNS lookups, so you decide where
> their browser goes.
>
> 🖥️ On the attacker PC, ⚡ in the Pineapple's Terminal (or over SSH), point the shop and the bank at the
> attacker's server:
> ```
> echo '192.168.75.11 shop.csl.internal bank.csl.internal' > /tmp/hosts/csl-spoof; killall -HUP dnsmasq; sleep 1; nslookup shop.csl.internal 127.0.0.1
> ```
> You should see `192.168.75.11`. (This only lasts until the Pineapple restarts.)
>
> 🖥️ On the victim PC, ⚡ close your browser completely (every window), then ⚡ run `ipconfig /flushdns`
> in a Command Prompt. The browser and Windows both remember addresses they looked up earlier. Don't use
> an Incognito/InPrivate window.
>
> Warning: Use **made-up details only** from here on. Anything typed into the fake sites is saved in a
> file that anyone on the café network can open.
>
> ⚡ Open your browser (Chrome or Edge) and **click the Shop bookmark**. Don't type the address: the
> bookmark starts with `http://`, like an old bookmark or a link in an email. ⚡ Log in with made-up details.
> Look at the address bar: what does it say, and is there a padlock?
>
> ⚡ Now try typing `shop.csl.internal` into the address bar instead. You get "This site can't provide a
> secure connection". Typed addresses go to `https://` (the browser remembers the real shop's HTTPS
> address from earlier), and the attacker's server can't prove it is the shop, so the browser stops.
> Modern browsers going to HTTPS by default is one of the main defences against this attack.
> ⚡ Now click the **Bank** bookmark. You should see a full-page warning: **"Your connection is not
> private"** (Edge: "Your connection isn't private"), saying that attackers might be trying to steal your
> information from `bank.csl.internal`. ⚡ Click **Advanced** and read what it says. Is there a link to
> continue to the site anyway? ⚡ Take a screenshot of the warning to compare with the Shop page.
>
> 🖥️ On the attacker PC, ⚡ find the Shop login in Wireshark, as in Part 4.
> ⚡ Then see what the attacker's server has been quietly collecting. In the Pineapple's Terminal:
> ```
> wget -q -O - http://192.168.75.11/inputs.txt
> ```
> Find your victim's login: the "from" column is your Pineapple's address on the café network. (On the
> victim PC you can also open `http://192.168.75.11/inputs.txt` in the browser.) Wireshark showed you one
> packet; a real attacker's server keeps a list of everyone's.
>
> ⚡ Undo the change (you should see `192.168.75.10` again):
> ```
> rm -f /tmp/hosts/csl-spoof; killall -HUP dnsmasq; sleep 1; nslookup shop.csl.internal 127.0.0.1
> ```
> 🖥️ On the victim PC, ⚡ close the browser and run `ipconfig /flushdns` again, so it goes back to the real
> shop.
>
> #### Why the bank warned you but the shop didn't
>
> Both bookmarks led to the same place: the attacker's server, because your Pineapple gave the victim its
> address for both names. The difference is what the browser expected to find there.
>
> **The shop** bookmark starts with `http://`. Plain HTTP has no way to check who is answering: any
> server can reply, and the browser simply shows what it gets. The real shop would have answered by
> redirecting the browser to `https://`, but the attacker's server never does, so the victim stayed on
> plain HTTP on a page the attacker controls. The only clue was the small "Not secure" label in the
> address bar. This is the idea behind **SSL stripping**: keep the victim on HTTP, and HTTPS never
> gets the chance to protect them.
>
> **The bank** is different in two ways:
>
> 1. **HTTPS checks who is answering.** To set up an HTTPS connection, the server must show a
>    certificate for `bank.csl.internal`, signed by an authority the browser trusts. The real bank's
>    certificate is signed by the lab's authority, which the lab PCs trust. The attacker could make a
>    certificate with the right name, but only signed by their own authority, which the PCs don't trust.
>    So the browser can tell this isn't the real bank, and stops before sending anything: no page, no
>    password. That is what the warning means.
> 2. **HSTS removes the "continue anyway" option.** When the victim visited the real bank earlier, its
>    reply included a header (`Strict-Transport-Security`) telling the browser: "for the next year, only
>    ever use HTTPS for this site". The browser remembered. So even a link starting `http://` is
>    turned into `https://` before anything is sent, and when the certificate is wrong the browser
>    won't let the user click past it. **Advanced** says so: the site uses HSTS, so you can't visit it
>    right now. Without HSTS, many users would click "Continue" and the attack would still work.
>
> | | Shop | Bank |
> |---|---|---|
> | Bookmark | `http://` | `https://` (and HSTS remembered) |
> | What the browser checked | Nothing: plain HTTP | The server's certificate |
> | What the victim saw | The fake shop; a small "Not secure" label | A full-page warning, no way past it |
> | Did the attacker get the password? | Yes | No |
> | What would have protected it | HTTPS for every page, a redirect *and* HSTS, browsers going to HTTPS by default | Already protected |
>
> Note: HSTS only works once the browser has seen the site over HTTPS at least once. That's why you
> visited the bank at the start of the lab. Big sites close this gap by being on the **HSTS preload
> list** built into every browser, so even the very first visit uses HTTPS.

Discussion / submission ideas for Part 5 (pick one):
- Why did the Shop attack work but the Bank attack fail? What would have protected the shop?
- HSTS only works after the browser has visited the site once. How do browsers protect the very first
  visit? (HSTS preload list; browsers now trying HTTPS first. The kit turns that off on the student PCs,
  which is why the Shop step works.)
- If `CSL-Cafe` used WPA2 with the password on the café wall, could a passive eavesdropper still read the
  traffic? Could your evil twin? What does that say about what Wi-Fi encryption protects against?

To do with this:
- Sheet: remove the old stretch-task section and its `uci` commands; renumber parts and questions;
  remove the captive-portal part. Victim steps use L2's browser-neutral wording.
- Sheet: Part 5 relies on the victim having visited `https://bank.csl.internal` earlier in the same
  browser profile (Getting started does this). Check that's still true after the rewrite.
- README section 6 (expected results) and section 7 (timetable): replace "Part 4, Evil Portal" and the
  stretch-task text with Part 5 above; remove the Evil Portal install from section 5's Pineapple setup.
- README clean-up between groups: `rm -f /tmp/hosts/csl-spoof; killall -HUP dnsmasq` on each Pineapple
  (or just reboot it), and check `uci -q get dhcp.@dnsmasq[0].address` prints nothing.

## Part 5: credential harvesting page (kit change 16, 2026-11-24; tested)

- Anything typed into the fake shop (or fake bank) is appended to `http://192.168.75.11/inputs.txt`:
  time | site | from | form fields. "from" is the Pineapple's café-network address, so with four
  teams sharing one attacker server each team can find its own line.
- Where students look at it: on the **victim PC** browse to `http://192.168.75.11/inputs.txt` (the
  attacker PC has no route to `192.168.75.0/24`: its default route is the university cable), or on the
  **attacker PC** in the Pineapple's Terminal: `wget -q -O - http://192.168.75.11/inputs.txt`.
- New empty list each time `Start-StaffLab.ps1` runs; `Cleanup-BeforeImage.ps1` deletes it.
- **Tested 2026-11-24 on the staff PC and victim: works.** Self-test POST and a real Shop login both
  appeared in inputs.txt. (First attempt failed only because Caddyfile.attacker hadn't been copied to
  C:\csl-lab: the copy was run from the windows folder. Setup-StaffImage.ps1 copies it; by hand, copy
  from the kit's staff_server folder.)
- **Done in the draft Part 5 text above:** the step to view the list, and the made-up-details warning.
- (Old to-do, now in the draft:) add a step after the Shop login: "⚡ See what the attacker collected:
  [command/URL]. Find your own login." Point: Wireshark showed one packet; a real attacker's server
  quietly keeps a list of everyone's.
- **Screenshot to take for the sheet:** the Bank warning on the victim during Part 5, with
  **Advanced** open (shows the HSTS line and no "Continue" link). Also the fake shop with "Not secure".
- **To do (sheet):** a Warning before Part 5's login: use made-up details only. Everything typed is
  saved in a file that anyone on the café network can open.

## Part 5 commands (Pineapple, tested 2026-11-24)

Non-persistent: lives in `/tmp` (RAM), gone on reboot. `killall -HUP dnsmasq` re-reads the hosts files
and clears dnsmasq's cache **without** restarting it, so the victim stays connected (a full
`/etc/init.d/dnsmasq restart` drops the victim off the Pineapple).

Start the redirect (expect `192.168.75.11`):
```
echo '192.168.75.11 shop.csl.internal bank.csl.internal' > /tmp/hosts/csl-spoof; killall -HUP dnsmasq; sleep 1; nslookup shop.csl.internal 127.0.0.1
```
See what was collected:
```
wget -q -O - http://192.168.75.11/inputs.txt
```
Undo (expect `192.168.75.10`):
```
rm -f /tmp/hosts/csl-spoof; killall -HUP dnsmasq; sleep 1; nslookup shop.csl.internal 127.0.0.1
```
Victim, before and after: close the browser completely, then `ipconfig /flushdns`.

Victim results (tested):
- **Shop bookmark** (`http://`): fake shop, "Not secure", login in Wireshark and in inputs.txt.
- **Typed `shop.csl.internal`**: "This site can't provide a secure connection". Chrome goes to `https://`
  (history from the earlier real HTTPS visit, and HTTPS-first for typed addresses); `.11:443` has no
  certificate for `shop`. Expected: it's the browser's defence. The sheet must say to use the bookmark.
- **Bank bookmark**: certificate error, no way past it (HSTS).
- If the Shop bookmark also gives the HTTPS error, check `chrome://policy` on the victim:
  `HttpsUpgradesEnabled` = false, `HttpsOnlyMode` = disallowed (set by Setup-StudentImage.ps1).
