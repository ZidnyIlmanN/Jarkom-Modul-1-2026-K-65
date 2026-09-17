#!/bin/bash

# ==============================================================================
# SOAL 6: Pemicu Trafik ICMP dan DNS untuk Analisis Wireshark
# Node: Mika (10.96.1.3)
# ==============================================================================

# ---- NODE MIKA (10.96.1.3) ----
echo "=== 1. Pemicu Trafik ICMP Echo Request ==="
# Mengirim paket ping ke Google Public DNS dan Cloudflare DNS
ping -c 5 8.8.8.8
ping -c 5 1.1.1.1

echo "=== 2. Pemicu Trafik Query DNS ==="
# Melakukan resolving domain via DNS resolver
nslookup example.com
nslookup github.com
nslookup its.ac.id
nslookup google.com
nslookup cloudflare.com

# Display Filter Wireshark yang digunakan:
# icmp
# dns
# dns || icmp
