#!/bin/bash

# ==============================================================================
# SOAL 10: Analisis ICMP Ping Knights ke Chisa
# Source: Knights (10.96.3.2) -> Destination: Chisa (10.96.2.2)
# Spesifikasi: 77 paket, payload 128 bytes, interval 0.3 detik
# ==============================================================================

# ---- NODE KNIGHTS (10.96.3.2) ----
echo "Mengirimkan 77 paket ICMP Echo Request ke Chisa (10.96.2.2)..."
ping -c 77 -s 128 -i 0.3 10.96.2.2

# Wireshark Display Filter:
# icmp && ip.addr == 10.96.3.2 && ip.addr == 10.96.2.2
