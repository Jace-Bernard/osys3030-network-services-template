# AI Automation & Code Audit Log

> **Student Name:** Jace-Bernard
> 
> **Student ID:** w0444779
> 
> **AI Tool Used:** Gemini 3.1 Pro

---

## 1. Executive Summary
I used Gemini 3.1 PRo to assistant with translating my configuration vault and Markdown guides into Bash deployment and verification scripts. I provided the AI with my config files and assignment prompts to generate the initial drafts, which I then audited and corrected for my VM ID-104.

---

## 2. Prompt Log
I opted to just go with the prompt I had been given to us to run with. ¯\_(ツ)_/¯ Seems to have worked out fine. 

### 2.1 Deployment Script Prompt
Paste the exact prompt you gave the AI to generate `deploy_appliance.sh`:

```text
"Act as a Senior Linux DevOps Engineer. Using my attached Markdown guides and configuration files for SSH hardening, BIND9, Kea DHCPv4, and UFW with NAT masquerading on Ubuntu 24.04, generate a production-ready Bash script (scripts/deploy_appliance.sh). The script must install all packages, back up existing configs, deploy my custom config files into /etc/, set strict file permissions, and start/enable services in the correct dependency order."
```

### 2.2 Verification Script Prompt
Paste the exact prompt you gave the AI to generate `verify_appliance.sh`:

```text
"Write a companion Bash verification script (scripts/verify_appliance.sh) with formatted [ PASS ] / [ FAIL ] indicators that tests every service on the appliance: verifies configuration syntax (named-checkconf, kea-dhcp4 -t), confirms systemd active states, checks listening ports (UDP 53, UDP 67, TCP 22), validates UFW rules and iptables NAT table entries, and tests local DNS resolution via dig."
```

---

## 3. Human-in-the-Loop Audit & Hallucination Corrections

AI models frequently introduce errors when writing infrastructure automation. Document at least 2 specific errors, bugs, or omissions the AI made in the generated scripts and how you fixed them:

| # | Service / Component | The AI's Hallucination / Error | The Fix Implemented |
| :--- | :--- | :--- | :--- |
| **1** | SSH Service Check | The AI assumed Ubuntu 24.04 used the standard `ssh.service` for its check, caused a false failure to trigger since 24.04 uses `ssh.socket` by default instead apparently.
| **2** | File Deployment | The AI's first script template forgot to include the commands to copy over the hardened `sshd_config` file and the DNS zone file. | Added `cp` statements in `deploy_appliance.sh` for `hardening/sshd_config` and `dns/db.10.104.0`. |
| **3** | ID Placeholders | The AI left generic `<YourID>` placeholders in the validation tests (like the dig commands and subnet checks). | Manually updated the scripts to hardcode my subnet and ID (VMID 104) & seems to work fine for the moment. |

---

## 4. Testing & Verification Results

* **Date Tested:** 2026-11-11
* **Target Environment:** OSYS3030 Baseline Server (VM ID 104)
* **Verification Script Output:**
  ```text
  test@test-Standard-PC-i440FX-PIIX-1996:~/osys3030-network-services-template$ sudo ./scripts/verify_appliance.sh
[sudo] password for test: 
==========================================================
  OSYS3030 Appliance Health & Verification Suite
==========================================================
--- 1. BIND9 DNS Service ---
  BIND9 service is active                                      [ PASS ]
  BIND9 configuration syntax                                   [ PASS ]
  DNS listening on UDP port 53                                 [ PASS ]
  Local DNS resolution for innovate.lab                        [ PASS ]
--- 2. Kea DHCPv4 Service ---
  Kea DHCPv4 service is active                                 [ PASS ]
  Kea configuration syntax                                     [ PASS ]
  DHCP listening on UDP port 67                                [ PASS ]
--- 3. Host Hardening & SSH ---
  OpenSSH service is active                                    [ PASS ]
  SSH listening on TCP port 22                                 [ PASS ]
--- 4. Firewall & Routing ---
  UFW firewall is active                                       [ PASS ]
  IPv4 packet forwarding enabled                               [ PASS ]
  iptables NAT MASQUERADE rule present                         [ PASS ]
==========================================================
  All appliance health checks passed successfully!

  ```

---

## 5. Attestation
I have reviewed, tested, and understand a decent chunk of code in the generated scripts. I'm semi prepared to explain most parts of these scripts or configuration files during an evaluation.
