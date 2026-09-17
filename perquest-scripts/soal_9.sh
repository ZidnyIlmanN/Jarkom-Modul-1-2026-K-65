#!/bin/bash

# ==============================================================================
# SOAL 9: Pengunduhan protocol7_manifesto.txt dan Pengujian Hak Akses Read-Only Mika
# Server: Chisa (10.96.2.2) | Client: Mika (10.96.1.3)
# File Size: 3476 bytes | Passive Port: 30002
# ==============================================================================

# ---- NODE CHISA (10.96.2.2) - PERSIAPAN BERKAS ----
# Membuat berkas manifesto berukuran 3476 bytes
head -c 3476 /dev/zero | tr '\0' '7' > /var/wired/data/protocol7_manifesto.txt
chmod 644 /var/wired/data/protocol7_manifesto.txt
ls -la /var/wired/data/protocol7_manifesto.txt

# ---- NODE MIKA (10.96.1.3) - PENGUJIAN ----
# 1. Download file manifesto (Harus SUKSES - Read Access)
lftp -d -u mika,mika123 10.96.2.2 <<EOF
lcd /root
get protocol7_manifesto.txt
bye
EOF

# Verifikasi file terunduh di Mika
ls -la /root/protocol7_manifesto.txt
wc -c /root/protocol7_manifesto.txt

# 2. Percobaan Upload file oleh Mika (Harus DITOLAK - 550 Permission denied)
lftp -u mika,mika123 10.96.2.2 <<EOF
put protocol7_manifesto.txt
bye
EOF
