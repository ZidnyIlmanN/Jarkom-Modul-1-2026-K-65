#!/bin/sh

echo "======================================"
echo "   KONFIGURASI ROUTER LAIN (K-65)"
echo "======================================"

# 1. Aktifkan interface LAN
ip link set eth1 up
ip link set eth2 up
ip link set eth3 up

# 2. Konfigurasi IP LAN (Prefix 10.96.x.x)
ip addr add 10.96.1.1/24 dev eth1 2>/dev/null || true
ip addr add 10.96.2.1/24 dev eth2 2>/dev/null || true
ip addr add 10.96.3.1/24 dev eth3 2>/dev/null || true

# 3. Aktifkan DHCP pada interface Internet (eth0)
dhclient eth0 2>/dev/null || true

# 4. Aktifkan IP forwarding
sysctl -w net.ipv4.ip_forward=1

# 5. NAT Masquerade (Idempotent: Cek dulu sebelum menambahkan)
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo ""
echo "Konfigurasi Router Lain selesai."
