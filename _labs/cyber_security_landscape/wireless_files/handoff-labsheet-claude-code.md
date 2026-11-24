# Hand-off: update the CSL Wi-Fi lab sheet and staff kit

I've been setting up a university Wi-Fi security lab on real kit: Windows 10 PCs, TP-Link Archer routers and WiFi Pineapple Mark VIIs. Students use the Pineapple to run an evil-twin attack on a victim PC on a fake café network, `CSL-Cafe`. Everything below was found and tested on the real hardware on 2026-11-24.

Two repos need updating:

1. **The staff kit**: `wifi-lab-staff-kit`, base commit `df65ad4`.
2. **The lab sheet**: HacktivityLabSheets, `_labs/cyber_security_landscape/8_wireless_security.md`, branch `wifi_update` on the thomashaw fork. Published at https://cliffe.github.io/HacktivityLabSheets/labs/cyber_security_landscape/8-wireless-security/

## Files attached

- **`notes.md`: the main to-do list. Read all of it before you start.** It's the running list of everything found while testing: what to change in the sheet, the README and the Pineapple setup, with draft wording. Where this message and `notes.md` disagree, the later sections of `notes.md` win, because it was updated as decisions changed. **`notes.md` is staff-only: don't commit it to the public lab sheet repo.** Some of it is fine for the kit README.
- `csl-kit-changes.md`: the numbered list of kit changes 1–16 and why each was made. Use it for commit messages. Change 15 is **withdrawn**: don't apply it.
- `csl-kit-service-mode.patch`: changes 1–14, a `diff -ru` against `df65ad4` (paths `df65ad4-orig/...` and `edited/...`).
- `csl-kit-change16-harvester.patch`: change 16, a `diff -ruN` (paths `base/...` and `work/...`).
- `csl-kit-fixed6.zip`: final versions of `README.md`, `windows\*` and `staff_server\Caddyfile*` after changes 1–14 and 16. `staff_server/sites/` isn't in it and hasn't changed.
- `handoff-for-claude-code.md`: an earlier hand-off for the same job. Parts of it still apply (see below). Where it disagrees with this message or `notes.md`, ignore it.
- `screenshots_and_pcap.zip`: screenshots and `web_browsing.pcapng` from today's testing, for the sheet.

## Decisions since the earlier hand-off

- **The lab is now Parts 1–4, then a new Part 5** (sending the victim to the wrong site with DNS). The **Evil Portal / captive-portal part is removed this year**: it needs a Pineapple module that can't be installed without internet. The **old stretch task (HTTPS downgrade) becomes Part 5**, rewritten: draft text in `notes.md` under "New structure for this year". The draft includes the "Why the bank warned you but the shop didn't" reading section and the comparison table.
- **Part 5's DNS commands are non-persistent.** They use `/tmp/hosts` plus `killall -HUP dnsmasq`, replacing the old `uci add_list … ; uci commit; /etc/init.d/dnsmasq restart`. The old way persisted across reboots and knocked the victim off the Pineapple. Tested commands: "Part 5 commands" in `notes.md`.
- **Part 5 includes credential harvesting** (kit change 16, tested). Logins typed into the fake shop are saved to `http://192.168.75.11/inputs.txt`, and students view it with `wget` from the Pineapple's Terminal. The sheet needs a "made-up details only" warning before the login.
- **Students must click the Shop bookmark, not type the address.** A typed address goes to `https://` and fails, which is expected. The draft turns this into a teaching point.
- **Correction to the earlier hand-off:** closing the browser does **not** make it forget HSTS (Chrome and Edge save HSTS to disk). The browser has to be closed because it keeps its own DNS cache and open connections. Students must **not** use Incognito/InPrivate. See "Stretch task: why the browser must be closed" in `notes.md`.
- **The Pineapple login goes in the sheet** (`root` / `hak5pineapple`), so students aren't held up. Don't put any router or Technitium passwords anywhere.

## 1. Staff kit (`wifi-lab-staff-kit`)

1. Apply `csl-kit-service-mode.patch` with `git apply -p1`. Add `--directory=<subfolder>` if the kit lives in a subfolder of the repo. If it doesn't apply cleanly, take the files from `csl-kit-fixed6.zip`. Follow the checks in the earlier hand-off's section 1: no console-runner leftovers, and the README describes service mode.
2. Apply `csl-kit-change16-harvester.patch` (`-p1`). It touches `staff_server/Caddyfile.attacker`, `windows/Start-StaffLab.ps1`, `windows/Cleanup-BeforeImage.ps1`, and adds `windows/csl-cred-logger.ps1`. Its `Caddyfile.attacker` base is the copy from the staff PC. Check that it matches the repo's `df65ad4` version before applying, and tell me if it doesn't. Afterwards the files should match `csl-kit-fixed6.zip` exactly.
3. Make the README changes listed in `notes.md` (search for "README"). These include:
   - section 5, Pineapple setup: wlan2 on the router's BSSID, `rebind_domain`, optional `noresolv`, turn off Evil WPA, remove the Evil Portal install;
   - sections 6 and 7: expected results and the timetable, with the Evil Portal part removed and Part 5 added;
   - getting the victim onto the evil twin by deauth;
   - the clean-up steps between groups;
   - the pcap path for contingency C;
   - the MFP/PMF naming;
   - and, from the earlier hand-off's section 1, the notes still to add: the Wi-Fi dongle versus a cable, the room-2 CA, the two rooms sharing an SSID, and legacy Edge.
4. Separate commits, for example: service mode and fixes 1–14; credential logger 16; README. Use `csl-kit-changes.md` for the messages.

## 2. Lab sheet (`8_wireless_security.md`)

Work through every "To do (sheet…)" item in `notes.md`, plus L1 and L2 from the earlier hand-off (router `.1`/`.254`; browser-neutral Chrome/Edge wording, "bookmarks/favourites bar"). In short:

- **Getting started:**
  - Pineapple address on the label plus `:1471`; the login;
  - the charge-only cable tip;
  - the "document every page" wording;
  - fix the SSH code block (the `==edit:==` placeholder shows literally inside code; use `PINEAPPLE-IP` plus a line outside the block);
  - unplug the victim's network cable, made prominent;
  - the "which network am I on" check, with screenshots.
- **Pineapple DNS rebind fix:** `notes.md` leaves open whether students run it as a step or staff do it in setup. **Ask me before choosing.**
- **Part 1:**
  - "Leave them alone" as a prominent red Warning, checking how the theme styles it;
  - a longer Recon scan;
  - MFP (also called PMF) naming. The rest of the PMF material is **deferred**: leave it as it is, but list it for me.
- **Part 2:**
  - firmware 2.x PineAP labels;
  - `CSL-Cafe` in the impersonation pool;
  - turn off Evil WPA;
  - remove "The victim arrives" and make deauth the main step (own victim only), moving the useful steps after it;
  - café site links.
- **Part 3 and Part 4:**
  - capture command: cmd not PowerShell, the stray `\|`, the placeholder;
  - expect the Npcap notice;
  - rewrite the "read an HTTPS page" step;
  - clear the display filter;
  - replace Submission Question 4 with a Note, renumber the later questions and update every reference.
- **Remove** the captive-portal part and the old stretch task. **Add Part 5** from the draft in `notes.md`. Renumber parts, questions and cross-references (e.g. "as in Part 4").
- **Images:** add the screenshots from `screenshots_and_pcap.zip`, using their real file names (several are `.PNG`; see the "Screenshots and capture file" section of `notes.md`). Two more Part 5 screenshots are still to come from me (the Bank warning with Advanced open, and the fake shop with "Not secure"). Leave clearly marked placeholders for them.

Keep the sheet's existing style: the ⚡/🖥️ step markers, its Note/Tip/Warning callouts, and "Question" only for submission questions. Write in UK English. Change only what `notes.md` and this message ask for. If a to-do doesn't match what you find in the sheet, tell me rather than guess.

## How to work

- Read `notes.md`, the earlier hand-off and both repos first. Then give me a short plan: the list of sheet edits in order, and anything that conflicts or is unclear.
- **Show me the diffs before committing**, for each repo.
- Afterwards, give me a list of any `notes.md` to-dos you didn't do, and why. Some are for the day itself (four Pineapples at once, room layout).
