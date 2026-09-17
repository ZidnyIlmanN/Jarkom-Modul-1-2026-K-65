#!/bin/bash

# ==============================================================================
# SOAL 2: Konfigurasi Antarmuka Jaringan Router Lain
# Node: Lain (Router)
# Prefix Subnet: 10.96.x.x
# ==============================================================================

# ---- NODE LAIN (ROUTER) ----
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp
    up sysctl -w net.ipv4.ip_forward=1
    up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

auto eth1
iface eth1 inet static
    address 10.96.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.96.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 10.96.3.1
    netmask 255.255.255.0
EOF

# Restart antarmuka jaringan
service networking restart 2>/dev/null || /etc/init.d/networking restart 2>/dev/null || true
