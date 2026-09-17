#!/bin/bash

# ==============================================================================
# SOAL 4: Aktivasi IP Forwarding, NAT Masquerade, dan DNS Resolver
# Router: Lain | Clients: Alice, Mika, Chisa, Knights, Eiri
# ==============================================================================

# ---- NODE LAIN (ROUTER) ----
# 1. Aktifkan IP Forwarding di level kernel
sysctl -w net.ipv4.ip_forward=1

# 2. Tambahkan iptables NAT Masquerade menuju antarmuka Internet eth0
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# ---- SEMUA NODE CLIENT (ALICE, MIKA, CHISA, KNIGHTS, EIRI) ----
cat <<EOF > /etc/resolv.conf
nameserver 192.168.122.1
nameserver 8.8.8.8
nameserver 1.1.1.1
EOF

# Uji konektivitas internet dan domain dari client
ping -c 3 8.8.8.8
ping -c 3 google.com
