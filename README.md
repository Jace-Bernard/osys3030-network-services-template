# OSYS3030 - Linux Network Appliance Documentation

> **Student Name:** Jace  
> **Student ID / VMID:** w0444779 / 104
> 
> **Repository:** https://github.com/Jace-Bernard/osys3030-network-services-template
> 
> **Instructor:** Matt Redmond  
> **Course:** OSYS3030 - Network Services Using Linux  

---

## 1. Appliance Overview
A high-level summary of your multi-homed Linux server appliance, its purpose, and its role as a gateway/router for the private internal network.

* **Operating System:** Ubuntu Server 24.04 LTS (Noble Numbat)
* **Hostname:** `server-104` 
* **Primary Roles:**
  * Router & Firewall (UFW + iptables NAT masquerading)
  * Recursive & Authoritative DNS (BIND9)
  * Dynamic Host Configuration Protocol (Kea DHCPv4)
  * Secure Remote Administration (OpenSSH)

---

## 2. Network Topology & Interfaces

```text
              +------------------------------------------+
              |           WAN / NSCC Network             |
              |             10.20.0.153/24               |
              +---------------------+--------------------+
                                    |
                                    | (DHCP / Static IP)
                                 [ens18] (10.20.0.153/23)
                       +------------+------------+
                       |   OSYS3030 Linux Server |
                       |      (Your Appliance)   |
                       +------------+------------+
                                 [ens19]
                                    | (10.104.0.250/24)
                                    |
              +---------------------+--------------------+
              |        Isolated Private VLAN (vmbr5)      |
              |             10.104.0.0/24                 |
              +---------------------+--------------------+
                                    |
                                    | (DHCP: 10.104.0.10 - .200)
                                 [eth0]
                       +------------+------------+
                       |    Alpine Client VM     |
                       |       (VM 91 104)       |
                       +-------------------------+
```

| Interface | Network Zone | IP Address / Subnet | Purpose |
| :--- | :--- | :--- | :--- |
| `ens18` | WAN / External | `10.20.0.153>/23` | Upstream internet & SSH management |
| `ens19` | LAN / Internal | `10.104.0.250/24` | Default gateway & service binding for clients |

---

## 3. Implemented Services

| Directory | Service | Daemon | Listening Ports | Description |
| :--- | :--- | :--- | :--- | :--- |
| [`hardening/`](./hardening/) | SSH / Host Security | `sshd` | TCP 22 | Hardened SSH configuration, root restrictions |
| [`dns/`](./dns/) | BIND9 DNS | `named` | UDP/TCP 53 | Authoritative for `innovate.lab` & recursive forwarder |
| [`dhcp/`](./dhcp/) | Kea DHCPv4 | `kea-dhcp4` | UDP 67 | Scoped dynamic IP lease allocation for LAN |
| [`fw/`](./fw/) | UFW Firewall & NAT | `ufw` / `iptables` | N/A | State-tracking firewall & packet masquerading |
| [`scripts/`](./scripts/) | Automation | Bash | N/A | Automated deployment and verification scripts |

---

## 4. Base OS & Netplan Prerequisites
Document any one-time operating system setup steps, package manager configurations, and your `/etc/netplan/*.yaml` static interface definitions required before services can be installed.

The base operating system is pre-configured with a static Netplan layout. The `/etc/netplan/50-cloud-init.yaml` or relevant netplan config assigns `10.104.0.250/24` to `ens19` with standard multi-homing rules.

---

## 5. Automated Recovery & Verification

This appliance includes automated deployment and verification scripts located in [`scripts/`](./scripts/):

* **Deployment / Disaster Recovery:**
  ```bash
  sudo ./scripts/deploy_appliance.sh
  ```
* **Automated Health Check & Verification:**
  ```bash
  sudo ./scripts/verify_appliance.sh
  ```

See [`AI_AUDIT.md`](./AI_AUDIT.md) for documentation on how these scripts were generated using AI and audited for accuracy.

---

## 6. Peer Review Audit

* **Audited Classmate:** Milkmaq (My own Alt account) (https://github.com/Milkmaq/osys3030-network-services-template/blob/main/README.md)
* **Classmate Appliance Subnet:** `10.20.0.153/23`
* **Audit Summary:** He did a God awful Job (Its a Joke since its my own account) at working on the documentation and has only made changes in the main README.md file.
