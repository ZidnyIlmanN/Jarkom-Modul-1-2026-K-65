#!/bin/bash

# ==============================================================================
# SOAL 1: Setup Topologi Jaringan GNS3
# Praktikum Jaringan Komputer 2026 - Modul 1 (Kelompok K-65)
# Topologi: 1 Router (Lain), 3 Switch, 5 Client (Alice, Mika, Chisa, Knights, Eiri)
# ==============================================================================

echo "=== SOAL 1: SETUP TOPOLOGI JARINGAN GNS3 ==="
echo "Topologi dirancang dan dibangun pada simulator GNS3 dengan topologi:"
echo "1. Router 'Lain' terhubung ke Internet NAT (nat0 <-> eth0)"
echo "2. Subnet 1 (10.96.1.0/24): Router Lain (eth1) <-> Switch1 <-> Alice (eth0), Mika (eth0)"
echo "3. Subnet 2 (10.96.2.0/24): Router Lain (eth2) <-> Switch2 <-> Chisa (eth0)"
echo "4. Subnet 3 (10.96.3.0/24): Router Lain (eth3) <-> Switch3 <-> Knights (eth0), Eiri (eth0)"
echo "Topologi telah berhasil dikonfigurasi dan semua node aktif (indikator hijau)."
