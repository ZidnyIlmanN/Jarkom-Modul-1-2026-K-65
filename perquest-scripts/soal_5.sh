#!/bin/bash

# ==============================================================================
# SOAL 5: Persistensi Konfigurasi Pasca-Reboot (Automation Script)
# ==============================================================================

# ---- NODE LAIN (ROUTER) ----
cat << 'EOF' > /root/konfigurasi_lain.sh
#!/bin/sh
ip link set eth1 up
ip link set eth2 up
ip link set eth3 up

ip addr add 10.96.1.1/24 dev eth1 2>/dev/null || true
ip addr add 10.96.2.1/24 dev eth2 2>/dev/null || true
ip addr add 10.96.3.1/24 dev eth3 2>/dev/null || true

udhcpc -i eth0 -n -q 2>/dev/null || dhclient eth0 2>/dev/null || true
sysctl -w net.ipv4.ip_forward=1

iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
EOF
chmod +x /root/konfigurasi_lain.sh

# ---- NODE ALICE ----
cat << 'EOF' > /root/konfigurasi_alice.sh
#!/bin/sh
ip link set eth0 up
ip addr add 10.96.1.2/24 dev eth0 2>/dev/null || true
ip route add default via 10.96.1.1 2>/dev/null || true
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
EOF
chmod +x /root/konfigurasi_alice.sh

# ---- NODE MIKA ----
cat << 'EOF' > /root/konfigurasi_mika.sh
#!/bin/sh
ip link set eth0 up
ip addr add 10.96.1.3/24 dev eth0 2>/dev/null || true
ip route add default via 10.96.1.1 2>/dev/null || true
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
EOF
chmod +x /root/konfigurasi_mika.sh

# ---- NODE CHISA ----
cat << 'EOF' > /root/konfigurasi_chisa.sh
#!/bin/sh
ip link set eth0 up
ip addr add 10.96.2.2/24 dev eth0 2>/dev/null || true
ip route add default via 10.96.2.1 2>/dev/null || true
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
EOF
chmod +x /root/konfigurasi_chisa.sh

# ---- NODE KNIGHTS ----
cat << 'EOF' > /root/konfigurasi_knights.sh
#!/bin/sh
ip link set eth0 up
ip addr add 10.96.3.2/24 dev eth0 2>/dev/null || true
ip route add default via 10.96.3.1 2>/dev/null || true
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
EOF
chmod +x /root/konfigurasi_knights.sh

# ---- NODE EIRI ----
cat << 'EOF' > /root/konfigurasi_eiri.sh
#!/bin/sh
ip link set eth0 up
ip addr add 10.96.3.3/24 dev eth0 2>/dev/null || true
ip route add default via 10.96.3.1 2>/dev/null || true
echo "nameserver 192.168.122.1" > /etc/resolv.conf
echo "nameserver 8.8.8.8" >> /etc/resolv.conf
EOF
chmod +x /root/konfigurasi_eiri.sh
