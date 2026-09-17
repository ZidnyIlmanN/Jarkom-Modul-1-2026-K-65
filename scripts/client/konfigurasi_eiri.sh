#!/bin/sh
# Konfigurasi Client: Eiri (Subnet 3 - 10.96.3.0/24)

ip link set eth0 up
ip addr add 10.96.3.3/24 dev eth0 2>/dev/null || true
ip route del default 2>/dev/null || true
ip route add default via 10.96.3.1 2>/dev/null || true
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "Konfigurasi Eiri selesai."
