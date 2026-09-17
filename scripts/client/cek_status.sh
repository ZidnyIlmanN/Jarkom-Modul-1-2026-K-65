#!/bin/sh

echo "======================================"
echo "         STATUS NODE CLIENT"
echo "======================================"

echo ""
echo "[INTERFACE STATUS & IP ADDRESS]"
echo "--------------------------------------"
ip -br a

echo ""
echo "[ROUTING TABLE & DEFAULT GATEWAY]"
echo "--------------------------------------"
ip route

echo ""
echo "[DNS RESOLVER CONFIGURATION]"
echo "--------------------------------------"
cat /etc/resolv.conf

echo ""
echo "======================================"
echo "       VERIFIKASI CLIENT SELESAI"
echo "======================================"
