#!/bin/bash

# ==============================================================================
# SOAL 8: Upload Intelligence Report dari Knights ke Chisa
# Source: Knights (10.96.3.2) -> Destination: Chisa (10.96.2.2)
# User: alice, Mode: Passive (Port Data: 30009)
# Ukuran Berkas: Tepat 1111 bytes
# ==============================================================================

# ---- NODE KNIGHTS (10.96.3.2) ----
# 1. Generate file laporan tepat 1111 bytes
python3 -c "with open('/root/knights_report.txt', 'wb') as f: f.write(b'K' * 1111)" 2>/dev/null || \
head -c 1111 /dev/zero | tr '\0' 'K' > /root/knights_report.txt

# Verifikasi ukuran berkas lokal
wc -c /root/knights_report.txt

# 2. Upload file via lftp ke FTP server Chisa
lftp -d -u alice,alice123 10.96.2.2 <<EOF
lcd /root
put knights_report.txt
bye
EOF

# ---- NODE CHISA (10.96.2.2) - VERIFIKASI ----
# ls -la /var/wired/data/knights_report.txt
# wc -c /var/wired/data/knights_report.txt
