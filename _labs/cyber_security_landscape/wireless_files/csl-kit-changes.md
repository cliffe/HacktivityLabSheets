# Kit change list (wifi-lab-staff-kit, base df65ad4)

1. windows/CslLab.Common.psm1 — Technitium back to the DnsService Windows service.
   Removed $script:TechnitiumRunner, Get-CslTechnitiumRunner. Rewrote Get-CslTechnitiumLog
   (now Technitium's own <data>\logs\<UTC date>.log), Start-CslTechnitium, Stop-CslTechnitium.
   Added Get-CslTechnitiumDataDir, Get-CslTechnitiumStray.
   Start-CslTechnitium: kills df65ad4 runner leftovers and stray DnsService.exe copies,
   icacls grant NT SERVICE\DnsService:(OI)(CI)M on the data folder, StartupType Automatic,
   sc failure restart actions, sc start, waits for 5380 (on timeout reports the Application-log error).
   Why: service crash-looped with UnauthorizedAccessException on logs\<date>.log, because
   admin-run console copies had created files there; the grant fixed it on the PC.
2. windows/Setup-StaffImage.ps1 — dotnet check falls back to %ProgramFiles%\dotnet\dotnet.exe when
   PATH is stale; missing-runtime message points to the Application log instead of running
   DnsService.exe by hand; Invoke-Dns comment ("restarted by Windows").
   Invoke-Dns also sends the session token as "Authorization: Bearer <token>" (Technitium 15+),
   keeping the token form field for older versions.
   user/changePassword now sends pass = current password, newPass = new password
   (15.6.2 failed with "Parameter 'newPass' missing" when only pass was sent).
3. windows/Start-StaffLab.ps1 — .DESCRIPTION item 2 wording only (code unchanged: it already calls
   Start-/Stop-CslTechnitium).
4. windows/Cleanup-BeforeImage.ps1 — after Stop-CslTechnitium deletes Technitium's logs and the old
   console log; warns if DnsService is NOT Automatic (was: warned if not Disabled).
5. README.md — Technitium section: service mode, data folder, don't run DnsService.exe as admin,
   the crash-loop symptom and fix.
6. windows/Setup-StudentImage.ps1 — new step 5b "Chrome policies" (HKLM\SOFTWARE\Policies\Google\Chrome):
   ManagedBookmarks (same CSL Cafe list as Edge's ManagedFavorites), BookmarkBarEnabled = 1,
   HttpsUpgradesEnabled = 0 and HttpsOnlyMode = disallowed (both skipped with -KeepHttpsUpgrade);
   warns if Chrome isn't installed; proxy report also lists Chrome proxy policies; header and
   final hand-check text mention Chrome. Cleanup-BeforeImage.ps1 header and README section 4 / known
   unknowns updated to match.
7. windows/CslLab.Common.psm1 — Get-CslDownload skips the copy when the local source is already the
   destination (re-running Setup-StudentImage.ps1 -CertFile C:\ProgramData\CSL-Lab\downloads\csl-lab-root.crt
   failed with "Cannot overwrite the item ... with itself"). On the staff PC (v4); not on the student PC.
8. windows/Setup-StudentImage.ps1 — Wireshark "already installed" check also looks in the WOW6432Node
   uninstall key and for Wireshark.exe in Program Files / Program Files (x86) (a re-run re-downloaded
   and reinstalled Wireshark; 4.6.10 x64 registers only under WOW6432Node, confirmed on the student PC). On the staff PC (v4); not on the student PC.
9. windows/Start-StaffLab.ps1 — lab addresses: throws if the adapter isn't Up (with a Wi-Fi or cable
   hint) instead of warning and carrying on; -ErrorAction Stop on Set-NetIPInterface and New-NetIPAddress
   (module cmdlets don't inherit the script's $ErrorActionPreference, so a failure printed "OK");
   checks both addresses are present afterwards. Seen on the staff PC: disconnected Wi-Fi dongle,
   "Inconsistent parameters PolicyStore PersistentStore and Dhcp Enabled", then "OK 192.168.75.10/24".
10. windows/Start-StaffLab.ps1 — "DNS recursion refused" check passes only on a "refused" answer
   (it passed on a timeout when DNS wasn't reachable at all).
11. README.md section 2 (router) — channel width 20 MHz, Hide SSID off, guest network off, and why only
   1/6/11 (the Archer was found on channel 9 with a hidden guest SSID; the university's APs use 1, 6 and 11).
12. windows/Start-StaffLab.ps1 — new -RouterIp (default 192.168.75.1 and 192.168.75.254, the two rooms'
   routers); the router ping check passes if any answers and reports which. README section 2 notes the
   second room's router at .254.
13. README.md section 2 (router) — DHCP: set both primary and secondary DNS to 192.168.75.10; with the
   secondary blank or 0.0.0.0 the Archer hands out itself (192.168.75.1) as secondary (seen on the
   room-1 router); check with ipconfig /all on a client.
14. windows/Setup-StudentImage.ps1 — after setting the Edge policies, warns if only legacy (EdgeHTML) Edge
   is installed (no msedge.exe), because it ignores them. Seen on the student PC: Edge had no favourites,
   edge://policy didn't open, msedge.exe not found.
15. WITHDRAWN 2026-11-24: captive-portal page on .11:8080. The captive-portal part is dropped for this
   year (revisit next year with the Evil Portal module). Don't apply csl-kit-change15-portal.patch.
16. staff_server/Caddyfile.attacker, windows/csl-cred-logger.ps1 (new), windows/Start-StaffLab.ps1,
   windows/Cleanup-BeforeImage.ps1 — "credential harvesting" for Part 5 (DNS redirect to the fake shop).
   Caddyfile.attacker: new snippet (harvest) sends every form POST on the fake shop (http://, any name)
   and fake bank to 127.0.0.1:8099 (Host rewritten for HttpListener; X-Csl-Site = the name the victim
   used; Caddy adds X-Forwarded-For); /inputs.txt served from sites/fake-shop with no-store.
   csl-cred-logger.ps1: HttpListener on 127.0.0.1:8099 (not reachable from the network), appends
   "time | site | from | fields" to sites\fake-shop\inputs.txt (line breaks stripped, length capped),
   answers with the old "checkout unavailable" page. "from" is the Pineapple's address on the cafe
   network, so lines can be told apart by team.
   Start-StaffLab.ps1: starts the logger in a minimised window after Caddy, with a new empty inputs.txt
   on every run; Stop-LabCaddy (also used by -Stop) stops it; new checks "credential logger
   (127.0.0.1:8099)" and "attacker inputs.txt (.11) 200".
   Cleanup-BeforeImage.ps1: stops the logger, deletes inputs.txt so nothing typed ends up in the image.
   Base: csl-kit-fixed5 + the staff_server Caddyfiles copied from the staff PC (not in the fixed5 zip).
   Diff: csl-kit-change16-harvester.patch; built kit: csl-kit-fixed6.zip (staff_server/sites not
   included: unchanged). Tested 2026-11-24 on the staff PC and a victim: logins appear in inputs.txt.
Full diff against df65ad4 for 1-14: csl-kit-service-mode.patch.

## One-off PC fixes (not kit changes)
- PC: icacls grant on C:\ProgramData\Technitium DNS Server (now done by the kit too).
- PC: a grant briefly put on C:\Program Files (x86)\Technitium\DNS Server\config was removed again.


## Lab sheet change (HacktivityLabSheets, _labs/cyber_security_landscape/8_wireless_security.md, branch wifi_update)
L1. "The lab network" table, row "Café router": `192.168.75.1`, hands out addresses in `192.168.75.0/24`
    -> `192.168.75.1` or `192.168.75.254`, depending on the room (it's on the router's sticker); hands out addresses in `192.168.75.0/24`
L2. Browser-neutral wording (Chrome or Edge; "bookmarks/favourites bar") wherever the sheet names Edge or the favourites bar. Details in the hand-off message.
