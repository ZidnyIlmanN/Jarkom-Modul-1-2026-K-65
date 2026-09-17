#!/bin/bash

# ==============================================================================
# SOAL 3: Konfigurasi Antarmuka Jaringan Client
# Nodes: Alice, Mika, Chisa, Knights, Eiri
# Prefix: 10.96.x.x
# ==============================================================================

# ---- NODE ALICE ----
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.96.1.2
    netmask 255.255.255.0
    gateway 10.96.1.1
EOF

# ---- NODE MIKA ----
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.96.1.3
    netmask 255.255.255.0
    gateway 10.96.1.1
EOF

# ---- NODE CHISA ----
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.96.2.2
    netmask 255.255.255.0
    gateway 10.96.2.1
EOF

# ---- NODE KNIGHTS ----
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.96.3.2
    netmask 255.255.255.0
    gateway 10.96.3.1
EOF

# ---- NODE EIRI ----
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 10.96.3.3
    netmask 255.255.255.0
    gateway 10.96.3.1
EOF
