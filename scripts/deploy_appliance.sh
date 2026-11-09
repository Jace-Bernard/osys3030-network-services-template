#!/bin/bash
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root (use sudo)." >&2
  exit 1
fi

echo "=== Starting Appliance Deployment ==="

echo "--> Installing packages..."
apt update -y
apt install -y bind9 bind9utils dnsutils kea-dhcp4-server ufw iptables openssh-server

echo "--> Configuring SSH Hardening..."
if [ -f "hardening/sshd_config" ]; then 
    cp hardening/sshd_config /etc/ssh/sshd_config
    systemctl restart ssh
fi

echo "--> Configuring BIND9 DNS..."
mkdir -p /etc/bind/zones
if [ -f "dns/named.conf.options" ]; then cp dns/named.conf.options /etc/bind/named.conf.options; fi
if [ -f "dns/named.conf.local" ]; then cp dns/named.conf.local /etc/bind/named.conf.local; fi
if [ -f "dns/db.innovate.lab" ]; then cp dns/db.innovate.lab /etc/bind/zones/; fi
if [ -f "dns/db.10.104.0" ]; then cp dns/db.10.104.0 /etc/bind/zones/; fi
chown -R bind:bind /etc/bind/zones || true
named-checkconf

echo "--> Configuring Kea DHCPv4..."
if [ -f "dhcp/kea-dhcp4.conf" ]; then cp dhcp/kea-dhcp4.conf /etc/kea/kea-dhcp4.conf; fi
kea-dhcp4 -t /etc/kea/kea-dhcp4.conf

echo "--> Enabling IPv4 Forwarding & UFW NAT..."
sysctl -w net.ipv4.ip_forward=1
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf || true

if [ -f "fw/before.rules" ]; then cp fw/before.rules /etc/ufw/before.rules; fi

echo "--> Configuring UFW Firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw default allow routed
ufw allow in on ens18 to any port 22 proto tcp comment 'SSH'
ufw allow in on ens19 to any port 53 comment 'DNS'
ufw allow in on ens19 to any port 67 proto udp comment 'DHCP'
ufw --force enable

echo "--> Starting services..."
systemctl restart named && systemctl enable named
systemctl restart kea-dhcp4-server && systemctl enable kea-dhcp4-server

echo "=== Deployment Complete! Run ./scripts/verify_appliance.sh to test ==="
