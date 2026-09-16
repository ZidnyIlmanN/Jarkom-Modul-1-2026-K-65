# LAPORAN RESMI PRAKTIKUM JARINGAN KOMPUTER
## MODUL 1: PENGALAMATAN IP, ROUTING, NAT, DAN AUTOMATION SCRIPT

---

| Informasi Praktikum | Keterangan |
| :--- | :--- |
| **Mata Kuliah** | Praktikum Jaringan Komputer 2026 |
| **Modul** | Modul 1 |
| **Kelompok** | K-65 |
| **Prefix IP Jaringan** | `10.96.x.x` |
| **Simulator** | GNS3 (Docker Container & Open vSwitch/Switch) |

---

## DAFTAR ISI
1. [Tujuan Praktikum](#1-tujuan-praktikum)
2. [Dasar Teori Singkat](#2-dasar-teori-singkat)
3. [Topologi Jaringan dan Tabel Pengalamatan](#3-topologi-jaringan-dan-tabel-pengalamatan)
4. [Langkah Pengerjaan Soal 1 - 4](#4-langkah-pengerjaan-soal-1---4)
   - 4.1. Setup Topologi di GNS3
   - 4.2. Konfigurasi Interface Router `Lain`
   - 4.3. Konfigurasi Interface Client (`Alice`, `Mika`, `Chisa`, `Knights`, `Eiri`)
   - 4.4. Aktivasi Kernel IP Forwarding pada Router
   - 4.5. Konfigurasi Source NAT (iptables MASQUERADE)
   - 4.6. Konfigurasi DNS Resolver pada Client
   - 4.7. Verifikasi dan Pengujian Konektivitas End-to-End
5. [Langkah Pengerjaan Soal 5 (Persistensi Konfigurasi Pasca-Reboot)](#5-langkah-pengerjaan-soal-5-persistensi-konfigurasi-pasca-reboot)
   - 5.1. Analisis Kebutuhan Persistensi pada Docker GNS3
   - 5.2. Pembuatan Script Router `Lain` (`konfigurasi_lain.sh` & `cek_status.sh`)
   - 5.3. Pembuatan Script Client (`konfigurasi_client.sh` & `cek_status.sh`)
   - 5.4. Integrasi Otomatisasi Startup Command pada GNS3
   - 5.5. Pengujian Reboot Node dan Validasi Hasil
6. [Analisis dan Pembahasan](#6-analisis-dan-pembahasan)
7. [Kesimpulan](#7-kesimpulan)

---

## 1. TUJUAN PRAKTIKUM
1. Mampu merancang dan mengimplementasikan topologi jaringan komputer menggunakan simulator GNS3.
2. Mampu melakukan konfigurasi pengalamatan IP statis dan dinamis (DHCP) dengan prefix kelompok `10.96.x.x`.
3. Memahami dan mengimplementasikan mekanisme *routing* dan aktivasi *Kernel IP Forwarding* pada sistem operasi Linux.
4. Mengimplementasikan Network Address Translation (NAT) dengan metode *MASQUERADE* melalui `iptables` agar subnet lokal dapat terhubung ke Internet.
5. Mampu mengonfigurasi Domain Name System (DNS) resolver pada node client.
6. Mampu membuat script automasi berbasis shell script yang *idempotent* dan persisten terhadap proses *reboot/restart* container pada lingkungan GNS3.

---

## 2. DASAR TEORI SINGKAT

### 2.1 Pengalamatan IP & Subnetting
Pengalamatan IP (IPv4) adalah label numerik yang ditetapkan untuk setiap perangkat yang terhubung ke jaringan komputer. Subnetting dengan subnet mask `/24` (`255.255.255.0`) membagi jaringan ke dalam blok-blok berisi maksimum 254 host yang dapat dialokasikan (`.1` sampai `.254`).

### 2.2 IP Forwarding
Secara *default*, sistem operasi Linux menonaktifkan fitur forwarding paket antar antarmuka (interface). Untuk memfungsikan Linux sebagai router yang meneruskan paket antar subnet atau dari LAN ke WAN, parameter kernel `net.ipv4.ip_forward` harus diaktifkan (`value = 1`).

### 2.3 Network Address Translation (NAT) MASQUERADE
NAT adalah teknik yang digunakan untuk mentranslasikan alamat IP privat menjadi alamat IP publik (atau IP yang dapat dijangkau oleh interface upstream/Internet). Dengan `iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE`, paket yang keluar melalui interface `eth0` router akan diubah IP sumbernya (*source IP*) menjadi IP dari `eth0` secara dinamis.

### 2.4 DNS Resolver
DNS resolver menerjemahkan nama domain (seperti `google.com`) menjadi alamat IP. Pada Linux, konfigurasi resolver disimpan pada file `/etc/resolv.conf`.

### 2.5 Persistensi pada Docker Container di GNS3
Secara default, container Docker di GNS3 bersifat *ephemeral* pada layer runtime memory tertentu; interface jaringan yang dibuat secara manual lewat CLI sering kali ter-reset saat container dimatikan (*stop/restart*). Untuk menjamin konfigurasi tetap berjalan, dibuat shell script automasi yang dieksekusi secara otomatis saat container dinyalakan kembali (*Startup Command*).

---

## 3. TOPOLOGI JARINGAN DAN TABEL PENGALAMATAN

### 3.1 Diagram Topologi

```
                     +---------------+
                     |   Internet    |
                     |     (NAT)     |
                     +-------+-------+
                             | nat0
                             |
                             | eth0 (DHCP)
                     +-------+-------+
                     |    Router     |
                     |     Lain      |
                     +---+---+---+---+
           eth1 (10.96.1.1)|   |   |eth3 (10.96.3.1)
                           |   |eth2 (10.96.2.1)
       +-------------------+   |   +-------------------+
       |                       |                       |
       | e0                    | e0                    | e0
+------+------+         +------+------+         +------+------+
|   Switch1   |         |   Switch2   |         |   Switch3   |
+---+------+--+         +------+------+         +---+------+--+
    | e1   | e2                | e1                 | e1   | e2
    |      |                   |                    |      |
+---+--+ +-+----+       +------+------+         +---+--+ +-+----+
|Alice | | Mika |       |    Chisa    |         |Knights| |Eiri |
+------+ +------+       +-------------+         +------+ +------+
```

### 3.2 Tabel Alokasi Pengalamatan IP (Prefix: `10.96.x.x`)

| Node | Interface | Tipe Konfigurasi | IP Address | Netmask | Gateway | DNS |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Lain (Router)** | `eth0` | DHCP (Internet) | Dinamis (192.168.122.x) | 255.255.255.0 | Dari DHCP | - |
| | `eth1` | Static (LAN 1) | `10.96.1.1` | 255.255.255.0 | - | - |
| | `eth2` | Static (LAN 2) | `10.96.2.1` | 255.255.255.0 | - | - |
| | `eth3` | Static (LAN 3) | `10.96.3.1` | 255.255.255.0 | - | - |
| **Alice (Client)** | `eth0` | Static | `10.96.1.2` | 255.255.255.0 | `10.96.1.1` | `8.8.8.8` |
| **Mika (Client)** | `eth0` | Static | `10.96.1.3` | 255.255.255.0 | `10.96.1.1` | `8.8.8.8` |
| **Chisa (Client)** | `eth0` | Static | `10.96.2.2` | 255.255.255.0 | `10.96.2.1` | `8.8.8.8` |
| **Knights (Client)** | `eth0` | Static | `10.96.3.2` | 255.255.255.0 | `10.96.3.1` | `8.8.8.8` |
| **Eiri (Client)** | `eth0` | Static | `10.96.3.3` | 255.255.255.0 | `10.96.3.1` | `8.8.8.8` |

---

## 4. LANGKAH PENGERJAAN SOAL 1 - 4

### 4.1. Setup Topologi di GNS3
1. Buka aplikasi GNS3 dan buat *blank project* baru dengan nama `Praktikum_Jarkom_Modul1_K65`.
2. Letakkan komponen-komponen berikut ke dalam workspace:
   - 1 node Cloud/NAT bernama `Internet`.
   - 1 node Router berbasis Linux Docker bernama `Lain`.
   - 3 node Switch/Ethernet Switch bernama `Switch1`, `Switch2`, dan `Switch3`.
   - 5 node Client berbasis Linux Docker bernama `Alice`, `Mika`, `Chisa`, `Knights`, dan `Eiri`.
3. Hubungkan antarmuka sesuai topologi:
   - `Internet` (`nat0`) <---> `Lain` (`eth0`)
   - `Lain` (`eth1`) <---> `Switch1` (`e0`)
   - `Switch1` (`e1`) <---> `Alice` (`eth0`)
   - `Switch1` (`e2`) <---> `Mika` (`eth0`)
   - `Lain` (`eth2`) <---> `Switch2` (`e0`)
   - `Switch2` (`e1`) <---> `Chisa` (`eth0`)
   - `Lain` (`eth3`) <---> `Switch3` (`e0`)
   - `Switch3` (`e1`) <---> `Knights` (`eth0`)
   - `Switch3` (`e2`) <---> `Eiri` (`eth0`)

> **[SCREENSHOT 1: Topologi Jaringan pada GNS3]**  
> *(Sertakan gambar tangkapan layar keseluruhan topologi yang telah tersambung dan node berwarna hijau/running)*

---

### 4.2. Konfigurasi Interface Router `Lain`

Buka konsol terminal pada node **Lain**, lalu edit file konfigurasi jaringan `/etc/network/interfaces`:

```bash
nano /etc/network/interfaces
```

Tambahkan konfigurasi berikut:

```text
auto eth0
iface eth0 inet dhcp
    up sysctl -w net.ipv4.ip_forward=1    
    up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

auto eth1
iface eth1 inet static
    address 10.96.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.96.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 10.96.3.1
    netmask 255.255.255.0
```

Terapkan konfigurasi dengan me-restart networking atau mengeksekusi:
```bash
ifdown -a && ifup -a
# atau
service networking restart
```

Verifikasi alamat IP pada Router `Lain`:
```bash
ip -br a
```
Output yang diharapkan:
```text
lo               UNKNOWN        127.0.0.1/8 ::1/128 
eth0             UP             192.168.122.x/24 ...
eth1             UP             10.96.1.1/24 ...
eth2             UP             10.96.2.1/24 ...
eth3             UP             10.96.3.1/24 ...
```

> **[SCREENSHOT 2: Konfigurasi /etc/network/interfaces & Output 'ip -br a' pada Router Lain]**

---

### 4.3. Konfigurasi Interface Client

Buka konsol masing-masing node client dan ubah file `/etc/network/interfaces`:

#### a. Client Alice (Subnet 1)
```text
auto eth0
iface eth0 inet static
    address 10.96.1.2
    netmask 255.255.255.0
    gateway 10.96.1.1
```

#### b. Client Mika (Subnet 1)
```text
auto eth0
iface eth0 inet static
    address 10.96.1.3
    netmask 255.255.255.0
    gateway 10.96.1.1
```

#### c. Client Chisa (Subnet 2)
```text
auto eth0
iface eth0 inet static
    address 10.96.2.2
    netmask 255.255.255.0
    gateway 10.96.2.1
```

#### d. Client Knights (Subnet 3)
```text
auto eth0
iface eth0 inet static
    address 10.96.3.2
    netmask 255.255.255.0
    gateway 10.96.3.1
```

#### e. Client Eiri (Subnet 3)
```text
auto eth0
iface eth0 inet static
    address 10.96.3.3
    netmask 255.255.255.0
    gateway 10.96.3.1
```

> **[SCREENSHOT 3: Konfigurasi /etc/network/interfaces pada Client (Contoh: Alice dan Chisa)]**

---

### 4.4. Aktivasi Kernel IP Forwarding pada Router

Agar router dapat meneruskan paket antar interface (antar subnet internal serta dari LAN ke WAN), aktifkan fitur forwarding pada kernel:

```bash
sysctl -w net.ipv4.ip_forward=1
```

Untuk memastikan pengaturan ini terbaca permanen oleh kernel, pastikan baris berikut terdapat pada `/etc/sysctl.conf`:
```text
net.ipv4.ip_forward=1
```

Pengecekan status IP forwarding:
```bash
sysctl net.ipv4.ip_forward
# Output: net.ipv4.ip_forward = 1
```

> **[SCREENSHOT 4: Eksekusi 'sysctl -w net.ipv4.ip_forward=1' dan Pengecekan Nilai Kernel di Router Lain]**

---

### 4.5. Konfigurasi Source NAT (iptables MASQUERADE)

Agar client pada jaringan lokal (`10.96.1.0/24`, `10.96.2.0/24`, `10.96.3.0/24`) dapat mengakses Internet melalui interface `eth0` milik Router `Lain`, terapkan aturan NAT MASQUERADE:

```bash
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
```

Periksa tabel NAT untuk memastikan rule berhasil ditambahkan:
```bash
iptables -t nat -L -v -n
```
Output akan menunjukkan baris:
```text
Chain POSTROUTING (policy ACCEPT 0 packets, 0 bytes)
 pkts bytes target     prot opt in     out     source               destination         
    0     0 MASQUERADE  all  --  *      eth0    0.0.0.0/0            0.0.0.0/0
```

> **[SCREENSHOT 5: Output 'iptables -t nat -L -v -n' pada Router Lain]**

---

### 4.6. Konfigurasi Client dan DNS Resolver

Agar client dapat mengenali nama domain (URL) Internet, arahkan DNS resolver ke Google Public DNS (`8.8.8.8`). Jalankan perintah ini di setiap client (`Alice`, `Mika`, `Chisa`, `Knights`, `Eiri`):

```bash
echo "nameserver 8.8.8.8" > /etc/resolv.conf
```

Verifikasi isi file:
```bash
cat /etc/resolv.conf
```

> **[SCREENSHOT 6: Konfigurasi DNS Resolver (/etc/resolv.conf) pada Client Alice]**

---

### 4.7. Verifikasi dan Pengujian Konektivitas End-to-End

Lakukan serangkaian pengujian konektivitas (*ping*) untuk memvalidasi pengerjaan Soal 1-4:

#### 1. Uji Ping dari Client ke Gateway Masing-Masing
- **Dari Alice:** `ping -c 4 10.96.1.1`
- **Dari Chisa:** `ping -c 4 10.96.2.1`
- **Dari Knights:** `ping -c 4 10.96.3.1`
*Hasil:* 0% packet loss (Konektivitas host ke gateway berfungsi sempurna).

#### 2. Uji Ping Antar-Subnet (Inter-VLAN / Inter-Subnet Routing)
- **Dari Alice (`10.96.1.2`) ke Chisa (`10.96.2.2`):**
  ```bash
  ping -c 4 10.96.2.2
  ```
- **Dari Alice (`10.96.1.2`) ke Knights (`10.96.3.2`):**
  ```bash
  ping -c 4 10.96.3.2
  ```
*Hasil:* 0% packet loss (Routing antar interface pada router `Lain` bekerja berkat `ip_forward=1`).

#### 3. Uji Ping ke Alamat IP Publik (Verifikasi NAT MASQUERADE)
- **Dari Client Alice:**
  ```bash
  ping -c 4 8.8.8.8
  ```
*Hasil:* 0% packet loss (Paket ICMP berhasil diteruskan keluar melalui NAT `eth0` menuju Internet).

#### 4. Uji Ping ke Domain Internet (Verifikasi DNS Resolver)
- **Dari Client Alice:**
  ```bash
  ping -c 4 google.com
  ```
*Hasil:* Domain ter-resolve ke alamat IP publik Google dan reply berhasil didapatkan (Konektivitas End-to-End Lengkap).

> **[SCREENSHOT 7: Hasil Uji Ping Gateway, Ping Antar-Subnet, Ping 8.8.8.8, dan Ping google.com dari Client Alice]**

---

## 5. LANGKAH PENGERJAAN SOAL 5 (PERSISTENSI KONFIGURASI PASCA-REBOOT)

### 5.1. Analisis Kebutuhan Persistensi pada Docker GNS3
Pada platform GNS3 berbasis container Docker, file konfigurasi kernel atau interface jaringan tertentu dapat kembali ke kondisi awal (*reset*) saat container dimatikan (*stop*) atau di-reboot. 

Untuk memenuhi kriteria Soal 5:
- Konfigurasi **tidak boleh hilang** setelah seluruh node di-restart.
- Seluruh IP, Routing, IP Forwarding, dan NAT MASQUERADE harus otomatis aktif kembali.
- Client harus langsung bisa berkomunikasi antar-subnet dan mengakses internet tanpa intervensi manual.
- Script dibuat secara **aman dan idempotent** (dapat dijalankan berulang kali tanpa menghasilkan error atau aturan duplikat).

---

### 5.2. Pembuatan Script Router `Lain`

Pada node **Lain**, dibuat dua buah script di direktori `/root/`:
1. `/root/konfigurasi_lain.sh` (Untuk inisialisasi jaringan)
2. `/root/cek_status.sh` (Untuk inspeksi dan verifikasi)

#### a. Membuat `/root/konfigurasi_lain.sh`
Buka editor:
```bash
nano /root/konfigurasi_lain.sh
```
Masukkan kode script berikut:
```bash
#!/bin/sh

echo "======================================"
echo "   KONFIGURASI ROUTER LAIN"
echo "======================================"

# Aktifkan interface LAN
ip link set eth1 up
ip link set eth2 up
ip link set eth3 up

# Konfigurasi IP LAN (idempotent dengan penanganan error)
ip addr add 10.96.1.1/24 dev eth1 2>/dev/null || true
ip addr add 10.96.2.1/24 dev eth2 2>/dev/null || true
ip addr add 10.96.3.1/24 dev eth3 2>/dev/null || true

# Aktifkan DHCP pada interface Internet
dhclient eth0 2>/dev/null || true

# Aktifkan IP forwarding
sysctl -w net.ipv4.ip_forward=1

# NAT Masquerade (Cek apakah rule sudah ada sebelum menambahkan agar tidak duplikat)
iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

echo ""
echo "Konfigurasi Router Lain selesai."
```
Beri hak akses eksekusi:
```bash
chmod +x /root/konfigurasi_lain.sh
```

#### b. Membuat `/root/cek_status.sh`
Buka editor:
```bash
nano /root/cek_status.sh
```
Masukkan script verifikasi:
```bash
#!/bin/sh

echo "======================================"
echo "       STATUS ROUTER LAIN"
echo "======================================"

echo ""
echo "[INTERFACE]"
echo "--------------------------------------"
ip -br a

echo ""
echo "[NAT TABLE]"
echo "--------------------------------------"
iptables -t nat -L -v -n

echo ""
echo "======================================"
echo "       VERIFIKASI SELESAI"
echo "======================================"
```
Beri hak akses eksekusi:
```bash
chmod +x /root/cek_status.sh
```

#### c. Pengujian Langsung Sebelum Reboot
Eksekusi script untuk memastikan tidak ada sintaks error:
```bash
/root/konfigurasi_lain.sh
/root/cek_status.sh
```

> **[SCREENSHOT 8: Eksekusi /root/konfigurasi_lain.sh dan /root/cek_status.sh pada Router Lain]**

---

### 5.3. Pembuatan Script Client

Pada setiap node client, dibuat script `/root/konfigurasi_client.sh` dan `/root/cek_status.sh`.

#### a. Node Alice
```bash
nano /root/konfigurasi_client.sh
```
Isi:
```bash
#!/bin/sh

ip link set eth0 up
ip addr add 10.96.1.2/24 dev eth0 2>/dev/null || true
ip route del default 2>/dev/null || true
ip route add default via 10.96.1.1 2>/dev/null || true
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "Konfigurasi Alice selesai."
```
Beri permission:
```bash
chmod +x /root/konfigurasi_client.sh
```

#### b. Node Mika
```bash
nano /root/konfigurasi_client.sh
```
Isi:
```bash
#!/bin/sh

ip link set eth0 up
ip addr add 10.96.1.3/24 dev eth0 2>/dev/null || true
ip route del default 2>/dev/null || true
ip route add default via 10.96.1.1 2>/dev/null || true
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "Konfigurasi Mika selesai."
```
Beri permission:
```bash
chmod +x /root/konfigurasi_client.sh
```

#### c. Node Chisa
```bash
nano /root/konfigurasi_client.sh
```
Isi:
```bash
#!/bin/sh

ip link set eth0 up
ip addr add 10.96.2.2/24 dev eth0 2>/dev/null || true
ip route del default 2>/dev/null || true
ip route add default via 10.96.2.1 2>/dev/null || true
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "Konfigurasi Chisa selesai."
```
Beri permission:
```bash
chmod +x /root/konfigurasi_client.sh
```

#### d. Node Knights
```bash
nano /root/konfigurasi_client.sh
```
Isi:
```bash
#!/bin/sh

ip link set eth0 up
ip addr add 10.96.3.2/24 dev eth0 2>/dev/null || true
ip route del default 2>/dev/null || true
ip route add default via 10.96.3.1 2>/dev/null || true
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "Konfigurasi Knights selesai."
```
Beri permission:
```bash
chmod +x /root/konfigurasi_client.sh
```

#### e. Node Eiri
```bash
nano /root/konfigurasi_client.sh
```
Isi:
```bash
#!/bin/sh

ip link set eth0 up
ip addr add 10.96.3.3/24 dev eth0 2>/dev/null || true
ip route del default 2>/dev/null || true
ip route add default via 10.96.3.1 2>/dev/null || true
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "Konfigurasi Eiri selesai."
```
Beri permission:
```bash
chmod +x /root/konfigurasi_client.sh
```

#### f. Script Cek Status pada Client (`/root/cek_status.sh`)
Buat script ini pada client (misal: Alice):
```bash
nano /root/cek_status.sh
```
Isi:
```bash
#!/bin/sh
echo "======================================"
echo "         STATUS NODE CLIENT"
echo "======================================"
echo ""
echo "[IP ADDRESS]"
ip -br a
echo ""
echo "[ROUTING TABLE]"
ip route
echo ""
echo "[DNS RESOLVER]"
cat /etc/resolv.conf
echo ""
echo "======================================"
```
Beri permission:
```bash
chmod +x /root/cek_status.sh
```

> **[SCREENSHOT 9: Pembuatan Script /root/konfigurasi_client.sh dan /root/cek_status.sh pada Client]**

---

### 5.4. Integrasi Otomatisasi Startup Command pada GNS3

Agar script dieksekusi secara otomatis setiap kali node di-boot ulang oleh GNS3:

#### Metode A: Melalui Node Properties di GNS3 (Direkomendasikan)
1. Matikan node terlebih dahulu (atau klik kanan saat stop).
2. Klik kanan pada node **Lain** -> pilih **Configure**.
3. Buka tab atau opsi **Startup command** / **Command**.
4. Masukkan perintah eksekusi berikut:
   ```bash
   sh -c "/root/konfigurasi_lain.sh; exec /bin/sh"
   ```
   *(atau disesuaikan dengan shell bawaan container seperti `/bin/bash`)*.
5. Lakukan hal yang sama pada masing-masing Client (**Alice**, **Mika**, **Chisa**, **Knights**, **Eiri**):
   - Masukkan perintah:
     ```bash
     sh -c "/root/konfigurasi_client.sh; exec /bin/sh"
     ```
6. Klik **Apply** lalu **OK**.

#### Metode B: Alternatif Melalui Profile / Bashrc
Apabila template container GNS3 menggunakan interactive shell:
Tambahkan pemanggilan script pada `/root/.bashrc` atau `/etc/profile`:
```bash
echo "/root/konfigurasi_lain.sh" >> /root/.bashrc
```
(Pada client: `echo "/root/konfigurasi_client.sh" >> /root/.bashrc`)

> **[SCREENSHOT 10: Pengaturan Start Command pada Node Configuration di GNS3]**

---

### 5.5. Pengujian Reboot Node dan Validasi Hasil

Untuk membuktikan bahwa sistem telah memenuhi syarat Soal 5:

1. Di GNS3 GUI, klik tombol **Stop all nodes** (tunggu hingga semua node mati/lingkaran merah).
2. Klik tombol **Start all nodes** (tunggu hingga semua node menyala/lingkaran hijau).
3. Buka konsol node **Lain**:
   - Jalankan `/root/cek_status.sh`.
   - Pastikan interface `eth0` mendapatkan IP DHCP, serta `eth1`, `eth2`, `eth3` memiliki IP `10.96.1.1`, `10.96.2.1`, `10.96.3.1`.
   - Pastikan tabel NAT `POSTROUTING` memuat rule `MASQUERADE`.
4. Buka konsol node **Alice**:
   - Jalankan `/root/cek_status.sh`.
   - Pastikan IP `10.96.1.2/24` terpasang, default gateway mengarah ke `10.96.1.1`, dan DNS berisi `nameserver 8.8.8.8`.
5. Lakukan pengujian konektivitas langsung tanpa konfigurasi manual:
   ```bash
   ping -c 4 10.96.1.1
   ping -c 4 8.8.8.8
   ping -c 4 google.com
   ```

**Hasil:**  
Semua ping berhasil (0% packet loss). Hal ini membuktikan bahwa konfigurasi berhasil dipulihkan secara otomatis saat sistem menyala, sehingga seluruh kebutuhan Soal 5 terpenuhi dengan sempurna.

> **[SCREENSHOT 11: Pengujian Pasca-Reboot: Output /root/cek_status.sh di Router Lain]**  
> **[SCREENSHOT 12: Pengujian Pasca-Reboot: Output /root/cek_status.sh & Ping google.com di Client Alice]**

---

## 6. ANALISIS DAN PEMBAHASAN

1. **Peran Idempotensi pada Script:**  
   Penggunaan opsi `2>/dev/null || true` pada perintah penambahan IP dan rute sangat krusial. Jika perintah dijalankan lebih dari satu kali, Linux tidak akan menghentikan eksekusi script dengan status error (*exit code non-zero*), melainkan tetap melanjutkan baris berikutnya.
2. **Pencegahan Redundansi Rule NAT:**  
   Perintah `iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE` berfungsi mengecek (*Check*) apakah rule MASQUERADE sudah terpasang. Simbol `||` memastikan penambahan rule (`-A`) hanya dilakukan jika pengecekan gagal (rule belum ada), mencegah duplikasi rule saat script dijalankan berulang kali.
3. **Pemisahan Broadcast Domain:**  
   Dengan membagi jaringan menjadi 3 subnet berbeda (`10.96.1.0/24`, `10.96.2.0/24`, `10.96.3.0/24`) yang dihubungkan melalui interface berbeda pada Router Lain (`eth1`, `eth2`, `eth3`), beban broadcast terisolasi di masing-masing switch, meningkatkan efisiensi dan keamanan jaringan.
4. **Fungsi Router Linux:**  
   Router `Lain` sukses menjalankan dua fungsi utama:
   - *Interior Router*: Meneruskan paket antar-subnet lokal secara langsung via routing table kernel.
   - *Edge Gateway / NAT*: Mentranslasikan IP privat kelompok (`10.96.x.x`) ke IP upstream interface `eth0` yang terkoneksi ke Cloud Internet.

---

## 7. KESIMPULAN
1. Konfigurasi topologi dengan prefix kelompok `10.96.x.x` berhasil diimplementasikan di GNS3 menggunakan node Router `Lain` dan 5 node client (`Alice`, `Mika`, `Chisa`, `Knights`, `Eiri`).
2. Fitur *Kernel IP Forwarding* (`net.ipv4.ip_forward=1`) dan *Source NAT* (`iptables MASQUERADE`) pada Router `Lain` berhasil menghubungkan seluruh client dari berbagai subnet ke jaringan luar (Internet).
3. Konfigurasi DNS resolver `8.8.8.8` pada client memungkinkan resolusi nama domain secara lancar.
4. Tantangan *statelessness* pada Docker container GNS3 berhasil diselesaikan melalui perancangan shell script automasi `/root/konfigurasi_lain.sh` dan `/root/konfigurasi_client.sh` yang bersifat *idempotent* dan diintegrasikan dengan *Startup Command* GNS3, sehingga seluruh konfigurasi jaringan tetap utuh dan aktif kembali setelah reboot.
