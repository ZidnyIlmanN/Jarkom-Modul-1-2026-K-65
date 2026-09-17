#!/bin/bash

# ==============================================================================
# SOAL 7: Konfigurasi FTP Server vsftpd dan Access Policy pada Node Chisa
# Node: Chisa (10.96.2.2)
# ==============================================================================

# ---- NODE CHISA ----
# 1. Instalasi paket vsftpd dan lftp
apt-get update && apt-get install -y vsftpd lftp

# 2. Pembuatan direktori shared data dan direktori user_conf
mkdir -p /var/wired/data
mkdir -p /etc/vsftpd/user_conf

# 3. Pembuatan user Alice, Mika, dan Eiri
useradd -m -s /bin/bash alice 2>/dev/null || true
echo "alice:alice123" | chpasswd

useradd -m -s /bin/bash mika 2>/dev/null || true
echo "mika:mika123" | chpasswd

useradd -m -s /bin/bash eiri 2>/dev/null || true
echo "eiri:eiri123" | chpasswd

chown -R alice:alice /var/wired/data
chmod 777 /var/wired/data

# 4. File konfigurasi utama /etc/vsftpd/vsftpd.conf
cat <<EOF > /etc/vsftpd/vsftpd.conf
listen=YES
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022

local_root=/var/wired/data

chroot_local_user=YES
allow_writeable_chroot=YES

userlist_enable=YES
userlist_deny=YES
userlist_file=/etc/vsftpd.userlist

pasv_enable=YES
pasv_min_port=30000
pasv_max_port=30009
pasv_address=10.96.2.2
user_config_dir=/etc/vsftpd/user_conf

seccomp_sandbox=NO
EOF

# 5. Access Policy User Alice: Read & Write
cat <<EOF > /etc/vsftpd/user_conf/alice
write_enable=YES
EOF

# 6. Access Policy User Mika: Read-Only
cat <<EOF > /etc/vsftpd/user_conf/mika
write_enable=NO
EOF

# 7. Blacklist User Eiri
cat <<EOF > /etc/vsftpd.userlist
eiri
EOF

# 8. Jalankan daemon vsftpd di background
vsftpd /etc/vsftpd/vsftpd.conf &

# Verifikasi port listening
ss -lntp | grep ':21'
