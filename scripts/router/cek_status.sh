#!/bin/sh

echo "======================================"
echo "       STATUS ROUTER LAIN (K-65)"
echo "======================================"

echo ""
echo "[INTERFACE STATUS & IP ADDRESS]"
echo "--------------------------------------"
ip -br a

echo ""
echo "[ROUTING TABLE]"
echo "--------------------------------------"
ip route

echo ""
echo "[IP FORWARDING STATUS]"
echo "--------------------------------------"
sysctl net.ipv4.ip_forward

echo ""
echo "[NAT POSTROUTING TABLE]"
echo "--------------------------------------"
iptables -t nat -L -v -n

echo ""
echo "======================================"
echo "       VERIFIKASI ROUTER SELESAI"
echo "======================================"
