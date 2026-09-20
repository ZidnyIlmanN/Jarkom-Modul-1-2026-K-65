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
   - 5.2. Organisasi dan Struktur Penyimpanan Skrip (`perquest-scripts/` & `scripts/`)
   - 5.3. Pembuatan Script Lengkap Router `Lain` (`konfigurasi_lain.sh` & `cek_status.sh`)
   - 5.4. Pembuatan Script Lengkap Client (`konfigurasi_<node>.sh` & `cek_status.sh`)
   - 5.5. Implementasi Skrip Modular Per-Soal (`perquest-scripts/soal_1.sh` s.d. `soal_10.sh`)
   - 5.6. Integrasi Otomatisasi Startup Command pada GNS3
   - 5.7. Pengujian Reboot Node dan Validasi Hasil
6. [Langkah Pengerjaan Soal 6 (Analisis Trafik ICMP dan DNS Menggunakan Wireshark)](#6-langkah-pengerjaan-soal-6-analisis-trafik-icmp-dan-dns-menggunakan-wireshark)
   - 6.1. Metodologi Packet Capture di GNS3
   - 6.2. Analisis Komunikasi Protokol ICMP
   - 6.3. Analisis Komunikasi Protokol DNS
   - 6.4. Ringkasan dan Kesimpulan Analisis Wireshark
7. [Langkah Pengerjaan Soal 7 (FTP Server dan Access Policy pada Node Chisa)](#7-langkah-pengerjaan-soal-7-ftp-server-dan-access-policy-pada-node-chisa)
   - 7.1. Konfigurasi Dasar dan Shared Folder FTP Server
   - 7.2. Konfigurasi Utama Daemon vsftpd (`/etc/vsftpd.conf`)
   - 7.3. Implementasi Access Policy dan Blacklist User
   - 7.4. Pengujian Hak Akses User Alice (Read & Write)
   - 7.5. Pengujian Hak Akses User Mika (Read Only)
   - 7.6. Pengujian Hak Akses User Eiri (Blacklist / 530 Permission Denied)
   - 7.7. Ringkasan dan Kesimpulan Implementasi FTP
8. [Langkah Pengerjaan Soal 8 (Upload Intelligence Report dari Knights ke Chisa)](#8-langkah-pengerjaan-soal-8-upload-intelligence-report-dari-knights-ke-chisa)
   - 8.1. Skenario Transfer Data Antar-Subnet
   - 8.2. Rincian Alur Komunikasi dan Analisis Paket FTP
   - 8.3. Perhitungan Port Data Pasif (Formula Matematis)
   - 8.4. Verifikasi Integritas dan Ukuran File di Server Chisa
   - 8.5. Ringkasan dan Kesimpulan Soal 8
9. [Langkah Pengerjaan Soal 9 (Download Protocol Seven dan Pengujian Hak Akses Mika)](#9-langkah-pengerjaan-soal-9-download-protocol-seven-dan-pengujian-hak-akses-mika)
   - 9.1. Skenario dan Tujuan Pengujian Hak Akses Read-Only Mika
   - 9.2. Pengunduhan Berkas `protocol7_manifesto.txt` (Perintah RETR & Port 30002)
   - 9.3. Pengujian Percobaan Unggah (Upload) oleh Mika (Penolakan 550 Permission Denied)
   - 9.4. Analisis Paket Wireshark (Korelasi Perintah Kontrol dan Kode Status)
   - 9.5. Ringkasan dan Kesimpulan Soal 9
10. [Langkah Pengerjaan Soal 10 (Analisis ICMP Ping Knights ke Chisa)](#10-langkah-pengerjaan-soal-10-analisis-icmp-ping-knights-ke-chisa)
    - 10.1. Skenario Pengujian Ping ICMP Antar-Subnet (Knights ke Chisa)
    - 10.2. Penggunaan Display Filter Wireshark
    - 10.3. Analisis Paket ICMP Echo Request dan Echo Reply
    - 10.4. Tabulasi Hasil Pengukuran dan Statistik RTT
    - 10.5. Ringkasan dan Kesimpulan Soal 10
11. [Analisis dan Pembahasan](#11-analisis-dan-pembahasan)
12. [Kesimpulan](#12-kesimpulan)

---

## 1. TUJUAN PRAKTIKUM
1. Mampu merancang dan mengimplementasikan topologi jaringan komputer menggunakan simulator GNS3.
2. Mampu melakukan konfigurasi pengalamatan IP statis dan dinamis (DHCP) dengan prefix kelompok `10.96.x.x`.
3. Memahami dan mengimplementasikan mekanisme *routing* dan aktivasi *Kernel IP Forwarding* pada sistem operasi Linux.
4. Mengimplementasikan Network Address Translation (NAT) dengan metode *MASQUERADE* melalui `iptables` agar subnet lokal dapat terhubung ke Internet.
5. Mampu mengonfigurasi Domain Name System (DNS) resolver pada node client.
6. Mampu membuat script automasi berbasis shell script yang *idempotent* dan persisten terhadap proses *reboot/restart* container pada lingkungan GNS3.
7. Mampu melakukan analisis paket trafik jaringan (ICMP dan DNS) menggunakan packet analyzer Wireshark pada node client.
8. Mampu mengimplementasikan File Transfer Protocol (FTP) Server menggunakan `vsftpd` pada node Chisa serta menerapkan *access control policy* (read & write, read-only, dan blacklist) berbasis user.
9. Mampu melakukan dan menganalisis mekanisme transfer data file (upload) antar-subnet melalui protokol FTP mode pasif (*Passive FTP*), serta membedah alur paket kontrol TCP port 21, negosiasi port pasif `227 Entering Passive Mode`, perintah `STOR`, dan kode respon `226 Transfer complete` menggunakan packet capture Wireshark.
10. Mampu melakukan dan menganalisis mekanisme pengunduhan file (download) via perintah `RETR` serta membuktikan penegakan kebijakan hak akses *read-only* (penolakan perintah upload dengan error `550 Permission denied`) pada akun pengguna FTP tertentu melalui inspeksi paket Wireshark.
11. Mampu menganalisis karakteristik transmisi paket ICMP antar-subnet (Knights ke Chisa) dengan parameter kustom (jumlah paket, ukuran payload, interval) serta mengevaluasi performa statistik Round-Trip Time (RTT min/avg/max/mdev), packet loss, dan inspeksi Type 8/Type 0 menggunakan Wireshark.

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

### 2.6 Analisis Paket Jaringan dengan Wireshark
Wireshark adalah network packet analyzer yang menangkap data secara real-time pada antarmuka jaringan.
- **ICMP (Internet Control Message Protocol)**: Protokol kontrol pada layer Network yang digunakan untuk diagnostik konektivitas. Paket *Echo Request* (Type 8) dikirimkan ke target dan mengharapkan balasan *Echo Reply* (Type 0). Nilai Time to Live (TTL) menunjukkan batas masa hidup paket dalam jaringan dan berkurang 1 setiap kali melewati router (hop).
- **DNS (Domain Name System)**: Protokol layer aplikasi yang beroperasi di atas UDP port 53 untuk memetakan nama domain (*Fully Qualified Domain Name*) ke alamat IP (*Query Type A* untuk IPv4). Respon DNS memuat *Answer Section* yang berisi record IP dari domain yang diminta.

### 2.7 File Transfer Protocol (FTP) Server & Access Policy vsftpd
FTP adalah protokol transfer berkas client-server yang menggunakan port 21 untuk kanal kontrol (*control connection*) dan port dinamis/tetap untuk kanal data (*data connection*). `vsftpd` (*Very Secure FTP Daemon*) merupakan daemon FTP berkinerja tinggi dan aman pada Linux. Fitur keamanannya meliputi:
- **Chroot Jail (`chroot_local_user=YES`)**: Membatasi ruang navigasi user hanya pada direktori tertentu (shared root `/var/wired/data`) sehingga user tidak dapat mengakses sistem direktori Linux induk.
- **Per-User Configuration (`user_config_dir`)**: Memungkinkan direktif khusus didefinisikan per user, seperti pemberian hak tulis (`write_enable=YES`) untuk user Read & Write atau penonaktifan hak tulis (`write_enable=NO`) untuk user Read-Only.
- **User Blacklisting (`userlist_enable=YES`, `userlist_deny=YES`)**: Memblokir autentikasi user tertentu yang terdaftar di `vsftpd.userlist` dengan memberikan balasan penolakan akses `530 Permission denied`.

### 2.8 Mode Pasif FTP (Passive Mode / PASV) dan Perhitungan Port Data
Pada arsitektur jaringan modern dengan router dan firewall, *Active Mode* sering kali mengalami kendala karena firewall pada sisi client menolak inisiasi koneksi data yang dibuka langsung oleh server. Oleh karena itu, *Passive Mode* (`PASV`) digunakan agar client membuka kedua koneksi (kontrol dan data).
1. Saat client mengirim perintah `PASV`, server merespons dengan:
   ```text
   227 Entering Passive Mode (h1,h2,h3,h4,p1,p2)
   ```
2. Port data yang dibuka oleh server dihitung menggunakan formula:
   $$\text{Port Data} = (p1 \times 256) + p2$$
3. Client membuka koneksi TCP ke `(h1.h2.h3.h4:Port Data)`, lalu mengirim perintah `STOR <filename>` pada koneksi kontrol untuk mengunggah file. Server menjawab `150 Ok to send data`, dan setelah seluruh payload data terkirim, server mengonfirmasi penyelesaian transfer dengan respon `226 Transfer complete`.

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

![Topologi Jaringan pada GNS3](bukti/Screenshot%202026-09-17%20010946.png)
*Gambar 4.1: Topologi Jaringan Praktikum Modul 1 pada Simulator GNS3*

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

![Konfigurasi Interfaces Router Lain pada GNS3](bukti/Screenshot%202026-09-17%20180315.png)
*Gambar 4.2: Konfigurasi Antarmuka Jaringan Router Lain pada Node Configuration GNS3*

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

![Konfigurasi Interfaces Client Alice pada GNS3](bukti/Screenshot%202026-09-17%20180340.png)
*Gambar 4.3: Konfigurasi Antarmuka Jaringan Client Alice pada Node Configuration GNS3*

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

### 5.2. Organisasi dan Struktur Penyimpanan Skrip

Berdasarkan kebutuhan pengujian dan dokumentasi praktikum, seluruh skrip otomasi dikelompokkan ke dalam dua model struktur penyimpanan:

1. **Skrip Modular Per-Soal (`perquest-scripts/`)**:  
   Skrip yang disimpan per nomor soal (`soal_1.sh` sampai dengan `soal_10.sh`) dengan blok node terpisah (`# ---- NODE <NAMA> ----`), memudahkan pengujian modular dan pemeriksaan independen untuk masing-masing soal praktikum.
2. **Skrip Lengkap Per-Node (`scripts/`)**:  
   Skrip konfigurasi utuh untuk masing-masing node (`router/` dan `client/`) yang dirancang untuk dieksekusi saat container pertama kali menyala (startup persistensi).

```text
├── perquest-scripts/               # Skrip Modular per Nomor Soal
│   ├── soal_1.sh                  # Setup Topologi Jaringan GNS3
│   ├── soal_2.sh                  # Konfigurasi Interface Router Lain
│   ├── soal_3.sh                  # Konfigurasi Interface Seluruh Node Client
│   ├── soal_4.sh                  # IP Forwarding, NAT Masquerade, dan DNS Resolver
│   ├── soal_5.sh                  # Skrip Otomasi Persistensi Startup Pasca-Reboot
│   ├── soal_6.sh                  # Pemicu Trafik ICMP dan DNS (Analisis Wireshark)
│   ├── soal_7.sh                  # Konfigurasi FTP Server vsftpd & Access Policy Chisa
│   ├── soal_8.sh                  # Upload Intelligence Report Knights ke Chisa (1111B)
│   ├── soal_9.sh                  # Download Manifesto (3476B) & Uji Tolak Upload Mika
│   └── soal_10.sh                 # Eksekusi Ping 77 Paket Knights ke Chisa
│
└── scripts/                        # Skrip Otomasi Lengkap per Node
    ├── router/
    │   ├── konfigurasi_lain.sh     # Konfigurasi lengkap startup Router Lain
    │   └── cek_status.sh           # Pemeriksaan status interface, IP & NAT Router
    └── client/
        ├── konfigurasi_alice.sh    # Konfigurasi startup node Alice
        ├── konfigurasi_mika.sh     # Konfigurasi startup node Mika
        ├── konfigurasi_chisa.sh    # Konfigurasi startup node Chisa
        ├── konfigurasi_knights.sh  # Konfigurasi startup node Knights
        ├── konfigurasi_eiri.sh     # Konfigurasi startup node Eiri
        └── cek_status.sh           # Pemeriksaan status interface, IP, route & DNS Client
```

#### Tabel Pemetaan Skrip Per-Soal (`perquest-scripts/`)

| File Skrip | Nomor Soal | Target Node | Deskripsi & Fungsi Utama |
|---|---|---|---|
| [`soal_1.sh`](perquest-scripts/soal_1.sh) | Soal 1 | GNS3 Topology | Metadata dan verifikasi topologi 1 router, 3 switch, dan 5 client. |
| [`soal_2.sh`](perquest-scripts/soal_2.sh) | Soal 2 | Lain | Konfigurasi `/etc/network/interfaces` Router Lain (DHCP, NAT, IP statis LAN). |
| [`soal_3.sh`](perquest-scripts/soal_3.sh) | Soal 3 | Alice, Mika, Chisa, Knights, Eiri | Konfigurasi antarmuka `/etc/network/interfaces` setiap node client. |
| [`soal_4.sh`](perquest-scripts/soal_4.sh) | Soal 4 | Lain & Clients | Aktivasi `ip_forward=1`, iptables MASQUERADE, dan DNS resolver `/etc/resolv.conf`. |
| [`soal_5.sh`](perquest-scripts/soal_5.sh) | Soal 5 | Seluruh Node | Pembuatan script persistensi startup `/root/konfigurasi_*.sh` pada semua node. |
| [`soal_6.sh`](perquest-scripts/soal_6.sh) | Soal 6 | Mika | Pemicu pengiriman paket ICMP ping (8.8.8.8, 1.1.1.1) dan query DNS domain. |
| [`soal_7.sh`](perquest-scripts/soal_7.sh) | Soal 7 | Chisa | Setup FTP vsftpd (user Alice R/W, Mika Read-Only, Eiri Blacklist, port pasif). |
| [`soal_8.sh`](perquest-scripts/soal_8.sh) | Soal 8 | Knights & Chisa | Pembuatan berkas 1111 bytes dan upload via akun Alice mode pasif port 30009. |
| [`soal_9.sh`](perquest-scripts/soal_9.sh) | Soal 9 | Chisa & Mika | Unduh manifesto 3476 bytes dan validasi penolakan upload akun Mika (550). |
| [`soal_10.sh`](perquest-scripts/soal_10.sh) | Soal 10 | Knights | Eksekusi ping 77 paket dengan payload 128 bytes dan interval 0.3s ke Chisa. |

---

### 5.3. Pembuatan Script Lengkap Router `Lain`

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

### 5.4. Pembuatan Script Lengkap Client

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

### 5.5. Implementasi Skrip Modular Per-Soal (`perquest-scripts/`)

Sebagai pelengkap dari skrip startup per-node, setiap instruksi konfigurasi dan pengujian soal juga dienkapsulasi dalam berkas skrip terpisah pada direktori `perquest-scripts/`:

#### 1. Skrip Soal 2 (`perquest-scripts/soal_2.sh`)
Mengonfigurasi `/etc/network/interfaces` pada Router Lain dengan penanganan DHCP dan IP statis ketiga interface LAN.

#### 2. Skrip Soal 3 (`perquest-scripts/soal_3.sh`)
Mengonfigurasi `/etc/network/interfaces` untuk seluruh client (Alice, Mika, Chisa, Knights, Eiri) dengan alokasi IP statis dan gateway yang presisi per subnet.

#### 3. Skrip Soal 4 (`perquest-scripts/soal_4.sh`)
Mengaktifkan kernel parameter `net.ipv4.ip_forward=1`, aturan `iptables NAT MASQUERADE` pada Router Lain, serta DNS nameserver pada setiap client.

#### 4. Skrip Soal 5 (`perquest-scripts/soal_5.sh`)
Menyusun template script persistensi startup otomatis pada router dan seluruh client.

#### 5. Skrip Soal 6 (`perquest-scripts/soal_6.sh`)
Mengeksekusi perintah pemicu lalu lintas data ICMP echo request dan resolusi nama DNS untuk keperluan inspeksi paket Wireshark.

#### 6. Skrip Soal 7 (`perquest-scripts/soal_7.sh`)
Menginstalasi, mengonfigurasi daemon `vsftpd`, mengatur shared storage, serta menetapkan kebijakan akses (Alice R/W, Mika R-O, Eiri blacklist).

#### 7. Skrip Soal 8 (`perquest-scripts/soal_8.sh`)
Menghasilkan payload berkas tepat 1111 bytes dan melakukan transfer upload FTP pasif port 30009 dari Knights ke Chisa.

#### 8. Skrip Soal 9 (`perquest-scripts/soal_9.sh`)
Mengunduh berkas manifesto 3476 bytes dan memvalidasi penolakan izin unggah (550 Permission Denied) untuk user Mika.

#### 9. Skrip Soal 10 (`perquest-scripts/soal_10.sh`)
Mengeksekusi perintah diagnostik ICMP 77 paket data dengan interval 0.3s dan payload 128 bytes dari Knights ke Chisa.

---

### 5.6. Integrasi Otomatisasi Startup Command pada GNS3

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

### 5.7. Pengujian Reboot Node dan Validasi Hasil

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

## 6. LANGKAH PENGERJAAN SOAL 6 (ANALISIS TRAFIK ICMP DAN DNS MENGGUNAKAN WIRESHARK)

### 6.1. Metodologi Packet Capture di GNS3
Pengujian analisis paket dilakukan pada antarmuka jaringan node **Mika** (IP `10.96.1.3/24`) yang terhubung ke interface `e2` pada **Switch1**.

1. Pada workspace GNS3, klik kanan pada kabel/link yang menghubungkan **Switch1** (`e2`) dengan **Mika** (`eth0`), lalu pilih **Start capture**.
2. Pilih opsi untuk meluncurkan **Wireshark** secara otomatis (*Start capture and start Wireshark*).
3. Atur display filter pada Wireshark dengan filter:
   ```text
   icmp || dns
   ```
4. Buka terminal node **Mika** (`10.96.1.3`), lalu jalankan serangkaian pengujian ICMP dan DNS:
   - Ping ICMP ke Google Public DNS (`8.8.8.8`) dan Cloudflare DNS (`1.1.1.1`):
     ```bash
     ping -c 4 8.8.8.8
     ping -c 4 1.1.1.1
     ```
   - DNS Lookup terhadap beberapa domain menggunakan resolver `8.8.8.8` dan `1.1.1.1`:
     ```bash
     nslookup example.com 8.8.8.8
     nslookup github.com 1.1.1.1
     nslookup its.ac.id 8.8.8.8
     nslookup google.com 8.8.8.8
     nslookup cloudflare.com 1.1.1.1
     ```

---

### 6.2. Analisis Komunikasi Protokol ICMP

Berdasarkan hasil capture Wireshark, node `10.96.1.3` melakukan pengiriman paket ICMP *Echo (ping) Request* menuju dua server DNS publik global:
* `8.8.8.8` (Google Public DNS)
* `1.1.1.1` (Cloudflare DNS)

#### Contoh Alur Paket ICMP:
```text
10.96.1.3 → 8.8.8.8    ICMP Echo (ping) request  (id=0x..., seq=1, ttl=64)
8.8.8.8 → 10.96.1.3    ICMP Echo (ping) reply    (id=0x..., seq=1, ttl=110)

10.96.1.3 → 1.1.1.1    ICMP Echo (ping) request  (id=0x..., seq=1, ttl=64)
1.1.1.1 → 10.96.1.3    ICMP Echo (ping) reply    (id=0x..., seq=1, ttl=50)
```

#### Analisis Rinci Paket ICMP:
1. **Pasangan Request & Reply**:
   Dari jendela capture Wireshark terlihat bahwa setiap paket *Echo Request* selalu mendapatkan balasan *Echo Reply* secara konsisten. Contohnya pada paket nomor 3 (Request ke `8.8.8.8`) yang dijawab pada paket nomor 10 (Reply dari `8.8.8.8`), serta paket nomor 4 (Request ke `1.1.1.1`) yang dijawab pada paket nomor 11 (Reply dari `1.1.1.1`). Hal ini membuktikan bahwa jalur routing end-to-end melalui Router Lain serta translasi Source NAT (MASQUERADE) berfungsi secara dua arah (*bidirectional*).
2. **Evaluasi Nilai Time to Live (TTL)**:
   - **TTL Paket Keluar (Request)**: Bernilai `64`. Nilai ini adalah *default initial TTL* untuk stack TCP/IP sistem operasi berbasis Linux (Docker container Mika).
   - **TTL Balasan dari `8.8.8.8` (Google)**: Diterima dengan nilai `110`. Umumnya server Google memulai transmisi dengan initial TTL `128`. Nilai `110` mengindikasikan bahwa paket menempuh sebanyak 18 hop router perantara sebelum tiba di node lokal ($128 - 18 = 110$).
   - **TTL Balasan dari `1.1.1.1` (Cloudflare)**: Diterima dengan nilai `50`. Umumnya Cloudflare memulai transmisi dengan initial TTL `64`. Nilai `50` mengindikasikan bahwa paket menempuh sebanyak 14 hop router perantara di internet ($64 - 14 = 50$).

![Packet Capture Wireshark - ICMP Echo Request dan Reply Node 10.96.1.3](bukti/Screenshot%202026-09-17%20143048.png)
*Gambar 6.1: Packet Capture Wireshark - Aliran Paket ICMP Echo Request dan Reply antara Node 10.96.1.3 dan DNS 8.8.8.8 serta 1.1.1.1*

---

### 6.3. Analisis Komunikasi Protokol DNS

Selain komunikasi ICMP, node `10.96.1.3` mengeksekusi *DNS Query* berbasis protokol transport UDP port `53` menuju DNS server eksternal `8.8.8.8` dan `1.1.1.1`.

Beberapa domain yang diminta untuk resolusi alamat (*Standard query Type A*):
* `example.com`
* `github.com`
* `its.ac.id`
* `google.com`
* `cloudflare.com`

#### Contoh Alur Paket DNS:
```text
10.96.1.3 → 8.8.8.8    DNS query A example.com
8.8.8.8 → 10.96.1.3    DNS response A example.com

10.96.1.3 → 1.1.1.1    DNS query A github.com
1.1.1.1 → 10.96.1.3    DNS response A github.com
```

#### Analisis Rinci Paket DNS:
1. **Pencocokan Transaction ID**:
   Setiap DNS query membawa *Transaction ID* unik 16-bit (misal: `0x1a2b`). DNS server tujuan mengembalikan *DNS Response* dengan Transaction ID yang sama persis, memastikan pencocokan respon pada layer aplikasi tanpa tertukar dengan query lainnya.
2. **Hasil Resolusi Domain (Answers)**:
   Paket response Wireshark menunjukkan flag *Standard query response, No error* (RCODE = 0), dengan data record IPv4 yang valid:
   - Domain `github.com` berhasil dipetakan ke alamat IPv4: `20.205.243.166`.
   - Domain `its.ac.id` berhasil dipetakan ke alamat IPv4: `103.94.189.5`.
   - Domain `example.com`, `google.com`, dan `cloudflare.com` juga mendapatkan respon IP address publik yang bersesuaian.

![Packet Capture Wireshark - DNS Query dan Response](bukti/Screenshot%202026-09-17%20170844.png)
*Gambar 6.2: Packet Capture Wireshark - Analisis Query dan Response DNS untuk Domain example.com, github.com, its.ac.id, dan google.com*

---

### 6.4. Ringkasan dan Kesimpulan Analisis Wireshark

Berdasarkan hasil capture Wireshark, node `10.96.1.3` (Mika) berhasil melakukan komunikasi jaringan menggunakan protokol ICMP dan DNS. Paket ICMP Echo Request mendapatkan Echo Reply dari `8.8.8.8` dan `1.1.1.1`, sedangkan DNS query terhadap beberapa domain juga mendapatkan response dari server DNS tujuan. Seluruh paket berhasil melewati router Linux dan tabel NAT tanpa mengalami fragmentasi, dropping, atau corruption.

---

## 7. LANGKAH PENGERJAAN SOAL 7 (FTP SERVER DAN ACCESS POLICY PADA NODE CHISA)

### 7.1. Konfigurasi Dasar dan Shared Folder FTP Server

Layanan FTP Server dibangun pada node **Chisa** menggunakan paket daemon `vsftpd` (*Very Secure FTP Daemon*).

#### Spesifikasi Server:
* **Node**: `Chisa`
* **Alamat IP**: `10.96.2.2/24` (Subnet 2)
* **Default Gateway**: `10.96.2.1` (Router Lain `eth2`)
* **Shared Folder**: `/var/wired/data`

#### Langkah Persiapan Lingkungan pada Node Chisa:
1. Buka konsol terminal node **Chisa**.
2. Pastikan paket `vsftpd`, `ftp`, dan `lftp` telah terinstal:
   ```bash
   apt-get update
   apt-get install -y vsftpd ftp lftp
   ```
3. Buat shared folder direktori FTP `/var/wired/data`:
   ```bash
   mkdir -p /var/wired/data
   chmod -R 777 /var/wired/data
   ```
4. Buat user sistem Linux untuk masing-masing user yang dibutuhkan:
   ```bash
   # User Alice (Read & Write)
   useradd -m -s /bin/bash alice
   echo "alice:alice123" | chpasswd

   # User Mika (Read Only)
   useradd -m -s /bin/bash mika
   echo "mika:mika123" | chpasswd

   # User Eiri (Blacklist)
   useradd -m -s /bin/bash eiri
   echo "eiri:eiri123" | chpasswd
   ```

---

### 7.2. Konfigurasi Utama Daemon vsftpd (`/etc/vsftpd.conf`)

Edit file konfigurasi utama vsftpd:
```bash
nano /etc/vsftpd.conf
```

Terapkan konfigurasi utama berikut:

```text
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
```

#### Penjelasan Parameter Konfigurasi:
* `listen=YES`: Menjalankan daemon vsftpd dalam mode standalone.
* `anonymous_enable=NO`: Menolak akses user anonim demi keamanan.
* `local_enable=YES`: Mengizinkan user lokal sistem Linux untuk login.
* `write_enable=YES`: Mengaktifkan hak tulis global (dapat di-override secara spesifik per user).
* `local_root=/var/wired/data`: Menjadikan direktori `/var/wired/data` sebagai direktori root default saat user login.
* `chroot_local_user=YES`: Mengurung user lokal di dalam direktori root (*chroot jail*), mencegah navigasi ke direktori sistem lainnya.
* `allow_writeable_chroot=YES`: Mengizinkan direktori chroot memiliki permission yang dapat ditulis.
* `userlist_enable=YES` & `userlist_deny=YES`: Mengaktifkan mekanisme blacklist user berdasarkan daftar file `userlist_file`. User yang terdaftar di dalamnya langsung ditolak login.
* `userlist_file=/etc/vsftpd.userlist`: Lokasi file penyimpan daftar blacklist user.
* `pasv_enable=YES`: Mengaktifkan mode pasif (*Passive FTP*).
* `pasv_min_port=30000` & `pasv_max_port=30009`: Menetapkan range port data pasif (30000-30009).
* `pasv_address=10.96.2.2`: Alamat IP server yang diiklankan kepada client pada mode pasif.
* `user_config_dir=/etc/vsftpd/user_conf`: Lokasi direktori tempat menyimpan konfigurasi hak akses individual per-user.
* `seccomp_sandbox=NO`: Menonaktifkan seccomp filter sandbox agar kompatibel dengan lingkungan Docker container GNS3.

---

### 7.3. Implementasi Access Policy dan Blacklist User

Tabel kebijakan akses (*Access Policy*) yang ditetapkan:

| User | Hak Akses | Kebijakan Konfigurasi |
| :--- | :--- | :--- |
| `alice` | **Read & Write** | Diizinkan membaca dan mengunggah/membuat file di shared folder |
| `mika` | **Read Only** | Hanya diizinkan membaca/mengunduh file, operasi tulis ditolak |
| `eiri` | **Blacklist** | Ditolak total mengakses FTP Server (*530 Permission denied*) |

#### 1. Konfigurasi Blacklist User (`/etc/vsftpd.userlist`)
Daftarkan user `eiri` ke dalam file blacklist:
```bash
echo "eiri" > /etc/vsftpd.userlist
```

#### 2. Konfigurasi Per-User Directory (`/etc/vsftpd/user_conf`)
Buat direktori konfigurasi per-user:
```bash
mkdir -p /etc/vsftpd/user_conf
```

- **Konfigurasi untuk User Alice (Read & Write)**:
  ```bash
  echo "write_enable=YES" > /etc/vsftpd/user_conf/alice
  ```

- **Konfigurasi untuk User Mika (Read Only)**:
  ```bash
  echo "write_enable=NO" > /etc/vsftpd/user_conf/mika
  ```

#### 3. Restart Service vsftpd
Terapkan seluruh konfigurasi baru:
```bash
service vsftpd restart
# atau
/etc/init.d/vsftpd restart
```

![Konfigurasi vsftpd.conf pada Server Chisa](bukti/Screenshot%202026-09-17%20163920.png)
*Gambar 7.1: Konfigurasi Utama /etc/vsftpd/vsftpd.conf pada Server Chisa*

![Konfigurasi User Policy dan Port 21](bukti/Screenshot%202026-09-17%20163943.png)
*Gambar 7.2: Konfigurasi Direktori user_conf (Alice & Mika), vsftpd.userlist (Eiri), dan Verifikasi Port 21*

![Verifikasi Service vsftpd](bukti/Screenshot%202026-09-17%20154815.png)
*Gambar 7.3: Pengecekan Service vsftpd yang Berjalan dan Listening Port 21 pada Server Chisa*

---

### 7.4. Pengujian Hak Akses User Alice (Read & Write)

Pengujian dilakukan dari node client (misal: node **Alice** `10.96.1.2` atau client lainnya) menuju FTP server `10.96.2.2`:

1. Buat file lokal pengujian di node client:
   ```bash
   echo "Signal from Alice: Channel Alpha Secure" > /root/signal_alice.txt
   ```
2. Hubungkan ke FTP server Chisa menggunakan user `alice`:
   ```bash
   lftp -u alice,alice123 10.96.2.2
   ```
3. Unggah (*upload*) file pengujian ke FTP shared folder:
   ```text
   lftp alice@10.96.2.2:~> put /root/signal_alice.txt
   lftp alice@10.96.2.2:~> ls
   -rw-r--r--    1 1001     1001           39 Sep 17 00:00 signal_alice.txt
   lftp alice@10.96.2.2:~> quit
   ```
4. Verifikasi keberadaan file di server Chisa (`/var/wired/data`):
   ```bash
   ls -la /var/wired/data/signal_alice.txt
   cat /var/wired/data/signal_alice.txt
   ```

**Hasil Pengujian:**  
File `/var/wired/data/signal_alice.txt` berhasil dibuat dan disimpan pada shared folder. Hal tersebut membuktikan bahwa user `alice` memiliki hak akses penuh (**Read & Write**) pada FTP Server.

![Pengujian Hak Akses User Alice](bukti/Screenshot%202026-09-17%20164014.png)
*Gambar 7.4: Pengujian Hak Akses User Alice - Berhasil Melakukan Upload (put) dan Penghapusan File (rm)*

---

### 7.5. Pengujian Hak Akses User Mika (Read Only)

Pengujian dilakukan dari node client untuk memastikan bahwa user `mika` hanya dapat membaca file dan dilarang membuat/mengunggah file baru:

1. Buat file percobaan upload di client:
   ```bash
   echo "Test upload dari Mika" > /root/signal_mika.txt
   ```
2. Hubungkan ke FTP Server Chisa menggunakan user `mika`:
   ```bash
   lftp -u mika,mika123 10.96.2.2
   ```
3. Uji operasi baca / unduh (*Read/Download*):
   ```text
   lftp mika@10.96.2.2:~> ls
   -rw-r--r--    1 1001     1001           39 Sep 17 00:00 signal_alice.txt
   lftp mika@10.96.2.2:~> get signal_alice.txt
   39 bytes transferred
   ```
   Operasi pembacaan dan pengunduhan file berhasil dilakukan.
4. Uji operasi tulis / unggah (*Write/Upload*):
   ```text
   lftp mika@10.96.2.2:~> put /root/signal_mika.txt
   put: Access failed: 550 Permission denied. (signal_mika.txt)
   lftp mika@10.96.2.2:~> quit
   ```

**Hasil Pengujian:**  
User `mika` sukses melakukan operasi baca/unduh (*Read*), namun ketika melakukan operasi unggah (*Write*) server memberikan respons penolakan:
```text
550 Permission denied.
```
Hal ini membuktikan bahwa pembatasan hak akses **Read Only** pada user `mika` melalui file konfigurasi `/etc/vsftpd/user_conf/mika` berjalan dengan tepat.

![Pengujian Hak Akses User Mika Read Only](bukti/Screenshot%202026-09-17%20164114.png)
*Gambar 7.5: Pengujian Hak Akses User Mika - Operasi Upload Ditolak dengan Status 550 Permission denied*

---

### 7.6. Pengujian Hak Akses User Eiri (Blacklist / 530 Permission Denied)

Pengujian dilakukan dari node Alice menggunakan `lftp` dengan flag debug (`-d`) untuk melihat dialog komunikasi FTP secara terperinci:

```bash
lftp -d -u eiri 10.96.2.2
```

Saat perintah `ls` dijalankan, proses autentikasi menghasilkan dialog berikut:

```text
---- Connecting to 10.96.2.2 (10.96.2.2) port 21
<--- 220 (vsFTPd 3.0.3)
---> USER eiri
<--- 530 Permission denied.
**** 530 Permission denied.
---> QUIT
<--- 221 Goodbye.
```

**Hasil Pengujian:**  
Respons `530 Permission denied` langsung dikembalikan oleh vsftpd saat perintah `USER eiri` dikirimkan (bahkan sebelum proses verifikasi password diminta). Hal ini membuktikan bahwa mekanisme blacklist pada file `/etc/vsftpd.userlist` dengan opsi `userlist_deny=YES` berhasil menolak user `eiri` secara mutlak.

![Percobaan Login User Eiri](bukti/Screenshot%202026-09-17%20164204.png)
*Gambar 7.6a: Percobaan Koneksi User Eiri ke FTP Server Chisa Menggunakan lftp*

![Penolakan Login User Eiri 530 Permission Denied](bukti/Screenshot%202026-09-17%20170712.png)
*Gambar 7.6b: Penolakan Login User Eiri dengan Status 530 Permission denied (Blacklist)*

---

### 7.7. Ringkasan dan Kesimpulan Implementasi FTP

FTP Server pada node Chisa berhasil dikonfigurasi menggunakan `vsftpd` dengan shared folder `/var/wired/data`. User `alice` diberikan hak read & write, user `mika` dikonfigurasi sebagai read-only, sedangkan user `eiri` dimasukkan ke dalam blacklist sehingga proses autentikasinya ditolak oleh FTP Server dengan respons `530 Permission denied`.

---

## 8. LANGKAH PENGERJAAN SOAL 8 (UPLOAD INTELLIGENCE REPORT DARI KNIGHTS KE CHISA)

### 8.1. Skenario Transfer Data Antar-Subnet
Pada skenario pengujian ini, komunikasi FTP dilakukan lintas subnet antar node client:
* **Node Pengirim (Client)**: `Knights`
  - Alamat IP: `10.96.3.2/24` (Subnet 3)
  - Default Gateway: `10.96.3.1` (Router Lain `eth3`)
* **Node Penerima (FTP Server)**: `Chisa`
  - Alamat IP: `10.96.2.2/24` (Subnet 2)
  - Layanan: `vsFTPd 3.0.5`
  - Direktori Tujuan: `/var/wired/data`
* **Kredensial Autentikasi**: Akun `alice` (memiliki hak akses *Read & Write*)
* **Berkas yang Ditransfer**: `knights_report.txt` dengan ukuran file tepat **1111 bytes**.

Transfer paket data melintasi Router `Lain` yang merutekan paket dari interface `eth3` (Subnet 3) menuju interface `eth2` (Subnet 2) secara langsung melalui tabel routing kernel Linux.

---

### 8.2. Rincian Alur Komunikasi dan Analisis Paket FTP

Pengujian dilakukan dari terminal node **Knights** (`10.96.3.2`). Paket ditangkap menggunakan Wireshark pada antarmuka link antara **Switch3** dan **Knights** serta link antara **Switch2** dan **Chisa**.

#### 1. Pembuatan Berkas Uji pada Node Knights
Di terminal node Knights, berkas `knights_report.txt` dibuat dengan ukuran presisi 1111 bytes:
```bash
# Membuat berkas intelligence report berukuran 1111 bytes
head -c 1111 /dev/urandom > /root/knights_report.txt
# atau mengisi teks laporan sepanjang 1111 bytes:
ls -la /root/knights_report.txt
```
Output verifikasi ukuran file:
```text
-rw-r--r-- 1 root root 1111 Sep 17 00:00 /root/knights_report.txt
```

#### 2. Eksekusi Perintah Transfer FTP
Koneksi dan transfer dilakukan menggunakan client FTP (`lftp` atau `ftp`) dengan mode debug aktif:
```bash
lftp -d -u alice,alice123 10.96.2.2
```
Perintah transfer berkas yang dijalankan pada prompt `lftp`:
```text
lftp alice@10.96.2.2:~> set ftp:passive-mode true
lftp alice@10.96.2.2:~> put /root/knights_report.txt
1111 bytes transferred
lftp alice@10.96.2.2:~> ls -l knights_report.txt
-rw-r--r--    1 1001     1001         1111 Sep 17 00:00 knights_report.txt
lftp alice@10.96.2.2:~> quit
```

#### 3. Rekonstruksi Alur Paket Berdasarkan Wireshark dan Debug Output
Berdasarkan hasil tangkapan paket Wireshark dan output debug konsol FTP, proses transfer berlangsung secara sekuensial melalui 10 tahapan:

1. **Inisiasi Koneksi Kontrol TCP (Port 21)**:  
   Client Knights (`10.96.3.2`) melakukan *three-way handshake* TCP (SYN, SYN-ACK, ACK) menuju FTP Server Chisa (`10.96.2.2`) pada port `21`. Server mengirimkan respon banner:
   ```text
   <--- 220 (vsFTPd 3.0.5)
   ```
2. **Pengiriman Username**:  
   Client mengirim perintah `USER alice`:
   ```text
   ---> USER alice
   <--- 331 Please specify the password.
   ```
3. **Autentikasi Password dan Verifikasi Sukses**:  
   Client mengirim password via perintah `PASS alice123`. Server merespons dengan kode status:
   ```text
   ---> PASS *****
   <--- 230 Login successful.
   ```
   Respons `230 Login successful` membuktikan bahwa kredensial user `alice` valid dan diizinkan masuk ke dalam lingkungan chroot jail `/var/wired/data`.
4. **Permintaan Mode Pasif (PASV)**:  
   Client mengirim perintah `PASV` untuk menginstruksikan server agar membuka port data di sisi server:
   ```text
   ---> PASV
   ```
5. **Respon Parameter Pasif dari Server**:  
   Server memberikan respon:
   ```text
   <--- 227 Entering Passive Mode (10,96,2,2,117,57).
   ```
6. **Kalkulasi Port Data Pasif**:  
   Port data dihitung berdasarkan dua oktet terakhir `(117, 57)` menggunakan formula matematis:
   $$\text{Port Data} = (117 \times 256) + 57 = 29952 + 57 = 30009$$
   Port data FTP yang disepakati dan dibuka pada server Chisa adalah **30009** (berada dalam rentang `pasv_min_port=30000` dan `pasv_max_port=30009` pada `vsftpd.conf`).
7. **Pengiriman Perintah Penyimpanan Berkas (STOR)**:  
   Client Knights membuka koneksi TCP baru ke port `10.96.2.2:30009`, kemudian pada kanal kontrol mengirim perintah:
   ```text
   ---> STOR knights_report.txt
   ```
   Perintah `STOR` (*Store*) merupakan instruksi standar protokol FTP (RFC 959) untuk mentransmisikan dan menyimpan file dari client ke server.
8. **Kesiapan Penerimaan Data oleh Server**:  
   Server Chisa merespons dengan kode:
   ```text
   <--- 150 Ok to send data.
   ```
   Respon ini menandakan bahwa kanal data pada port 30009 telah siap menerima *stream* biner dari client.
9. **Transmisi Payload dan Penyelesaian Transfer**:  
   Client Knights memompa seluruh isi berkas melalui kanal data TCP port 30009. Setelah seluruh payload terkirim, client mengirim sinyal FIN/ACK untuk menutup sesi koneksi data. Server kemudian mengirim respon konfirmasi pada kanal kontrol:
   ```text
   <--- 226 Transfer complete.
   ```
10. **Total Volume Data**:  
    Volume data yang berhasil ditransfer tercatat tepat sebesar **1111 bytes**.

![Output Terminal Knights Upload knights_report.txt](bukti/Screenshot%202026-09-17%20172513.png)
*Gambar 8.1: Output Terminal Knights - Berhasil Mengunggah knights_report.txt (1111 bytes) ke FTP Chisa*

---

### 8.3. Perhitungan Port Data Pasif (Formula Matematis)

Format standar respon `227 Entering Passive Mode` adalah:
```text
227 Entering Passive Mode (h1,h2,h3,h4,p1,p2)
```
Pada pengujian ini, server Chisa mengembalikan:
```text
227 Entering Passive Mode (10,96,2,2,117,57)
```
Di mana:
* Alamat IP Server = $10.96.2.2$
* Oktet Port Tinggi ($p_1$) = $117$
* Oktet Port Rendah ($p_2$) = $57$

Perhitungan nilai integer port:
$$\text{Port Data FTP} = (p_1 \times 256) + p_2$$
$$\text{Port Data FTP} = (117 \times 256) + 57$$
$$\text{Port Data FTP} = 29952 + 57 = 30009$$

Hasil perhitungan **30009** membuktikan konsistensi penerapan konfigurasi `pasv_min_port=30000` dan `pasv_max_port=30009` pada file `/etc/vsftpd.conf` di node Chisa.

![Wireshark TCP Handshake dan Login Alice](bukti/Screenshot%202026-09-17%20172533.png)
*Gambar 8.2: Wireshark Capture - TCP Handshake dan Autentikasi FTP User Alice pada Port Kontrol 21*

![Wireshark Aliran Perintah FTP](bukti/Screenshot%202026-09-17%20172939.png)
*Gambar 8.3: Wireshark Capture - Aliran Perintah FTP (PASV, STOR knights_report.txt, dan 226 Transfer complete)*

![Wireshark Detail Respon PASV 30009](bukti/Screenshot%202026-09-17%20173029.png)
*Gambar 8.4: Wireshark Packet Details - Frame Respon 227 Entering Passive Mode (10,96,2,2,117,57) Menunjukkan Port Data 30009*

---

### 8.4. Verifikasi Integritas dan Ukuran File di Server Chisa

Pemeriksaan berkas dilakukan secara langsung di server **Chisa** pada direktori root shared folder:

```bash
ls -lh /var/wired/data/knights_report.txt
wc -c /var/wired/data/knights_report.txt
```

Output pada konsol node Chisa:
```text
-rw-r--r-- 1 alice alice 1111 Sep 17 00:00 /var/wired/data/knights_report.txt
1111 /var/wired/data/knights_report.txt
```

Hasil verifikasi menunjukkan bahwa file `knights_report.txt` tersimpan dengan sempurna di `/var/wired/data` dengan kepemilikan user `alice` dan ukuran persis **1111 bytes** tanpa terjadi kehilangan byte data sedikit pun.

![Wireshark Verifikasi Transfer File 1111 Bytes](bukti/Screenshot%202026-09-17%20173035.png)
*Gambar 8.5: Wireshark Packet Details - Frame 40 STOR knights_report.txt dengan Respon Ukuran Transfer 1111 Bytes*

![Wireshark Konfirmasi Transfer Complete](bukti/Screenshot%202026-09-17%20173047.png)
*Gambar 8.6: Wireshark Packet Details - Frame 47 Response 226 Transfer complete*

---

### 8.5. Ringkasan dan Kesimpulan Soal 8

FTP pada node Chisa (`10.96.2.2`) berhasil menerima file `knights_report.txt` berukuran 1111 bytes dari node Knights (`10.96.3.2`) melalui akun `alice`. Koneksi kontrol menggunakan TCP port `21`, sedangkan koneksi data dinegosiasikan secara pasif menggunakan port **30009** melalui perhitungan formula $(117 \times 256) + 57$. Paket `STOR` menandai proses upload file, sementara response `226 Transfer complete` menjadi indikator bahwa proses transfer data antar-subnet telah berhasil 100%.

---

## 9. LANGKAH PENGERJAAN SOAL 9 (DOWNLOAD PROTOCOL SEVEN DAN PENGUJIAN HAK AKSES MIKA)

### 9.1. Skenario dan Tujuan Pengujian Hak Akses Read-Only Mika
Pada pengujian ini, komunikasi FTP dilakukan antara node client **Mika** dengan FTP Server **Chisa**:
* **Node Penguji (Client)**: `Mika`
  - Alamat IP: `10.96.1.3/24` (Subnet 1)
  - Default Gateway: `10.96.1.1` (Router Lain `eth1`)
* **Node FTP Server**: `Chisa`
  - Alamat IP: `10.96.2.2/24` (Subnet 2)
  - Layanan: `vsFTPd 3.0.5`
  - Direktori Root Shared: `/var/wired/data`
* **Kredensial Akun**: `mika` (dikonfigurasi dengan hak akses **Read Only** via `/etc/vsftpd/user_conf/mika` berisi `write_enable=NO`)
* **Berkas Target**: `protocol7_manifesto.txt` (berkas manifest intelijen yang berada pada shared folder server)

**Tujuan Pengujian**:
Membuktikan secara empiris bahwa akun `mika` hanya memiliki hak akses **read-only**, yaitu diizinkan melihat informasi dan mengunduh berkas (*download*) dari FTP server, namun ditolak secara mutlak ketika mencoba mengunggah (*upload*) atau memodifikasi berkas di server.

---

### 9.2. Pengunduhan Berkas `protocol7_manifesto.txt` (Perintah RETR & Port 30002)

#### 1. Persiapan Berkas pada Server Chisa
Pastikan berkas `protocol7_manifesto.txt` telah berada di shared folder `/var/wired/data` pada server Chisa dengan ukuran tepat **3476 bytes**:
```bash
# Verifikasi di node Chisa
ls -la /var/wired/data/protocol7_manifesto.txt
wc -c /var/wired/data/protocol7_manifesto.txt
```
Output:
```text
-rw-r--r-- 1 root root 3476 Sep 17 00:00 /var/wired/data/protocol7_manifesto.txt
3476 /var/wired/data/protocol7_manifesto.txt
```

#### 2. Proses Login dan Pengecekan Ukuran Berkas oleh Mika
Dari konsol terminal node **Mika** (`10.96.1.3`), koneksi dibuka menuju server Chisa (`10.96.2.2`) pada port 21:
```bash
lftp -d -u mika,mika123 10.96.2.2
```
Dialog autentikasi pada kanal kontrol:
```text
---- Connecting to 10.96.2.2 (10.96.2.2) port 21
<--- 220 (vsFTPd 3.0.5)
---> USER mika
<--- 331 Please specify the password.
---> PASS *****
<--- 230 Login successful.
```
Setelah login berhasil, Mika meminta informasi ukuran berkas menggunakan perintah FTP `SIZE`:
```text
---> SIZE protocol7_manifesto.txt
<--- 213 3476
```
Respon kode status `213 3476` mengonfirmasi bahwa ukuran berkas pada server adalah tepat **3476 bytes**.

#### 3. Negosiasi Passive Mode dan Perhitungan Port Data
Mika menginisiasi transfer dalam mode pasif dengan mengirim perintah `PASV`:
```text
---> PASV
<--- 227 Entering Passive Mode (10,96,2,2,117,50).
```
Port data pasif dihitung menggunakan rumus matematis:
$$\text{Port Data} = (117 \times 256) + 50 = 29952 + 50 = 30002$$
Sehingga koneksi data FTP dibuka pada port **30002** (sesuai alokasi rentang pasif `30000-30009` pada `vsftpd.conf`).

#### 4. Pengambilan Berkas (RETR)
Client Mika mengirimkan perintah `RETR` (*Retrieve*) untuk mengunduh berkas:
```text
---> RETR protocol7_manifesto.txt
<--- 150 Opening BINARY mode data connection for protocol7_manifesto.txt (3476 bytes).
```
Seluruh aliran data biner sebanyak 3476 bytes dialirkan melalui koneksi TCP port 30002. Setelah transmisi tuntas, server mengirimkan respon penyelesaian:
```text
<--- 226 Transfer complete.
3476 bytes transferred
```
Hasil pengujian ini membuktikan bahwa user `mika` berhasil melakukan operasi baca dan pengunduhan berkas `protocol7_manifesto.txt` secara utuh.

![Output Terminal Mika Download protocol7_manifesto.txt](bukti/Screenshot%202026-09-17%20174917.png)
*Gambar 9.1: Output Terminal Mika - Berhasil Mengunduh protocol7_manifesto.txt (3476 bytes) via Passive Port 30002*

---

### 9.3. Pengujian Percobaan Unggah (Upload) oleh Mika (Penolakan 550 Permission Denied)

Setelah proses download selesai, dilakukan pengujian untuk memverifikasi restriksi hak tulis. Dari terminal node Mika, dicoba mengunggah kembali file `protocol7_manifesto.txt` ke server FTP:

```text
lftp mika@10.96.2.2:~> put protocol7_manifesto.txt
---> STOR protocol7_manifesto.txt
<--- 550 Permission denied.
put: Access failed: 550 Permission denied. (protocol7_manifesto.txt)
```

**Hasil Pengujian:**  
Server vsFTPd pada Chisa secara tegas menolak perintah `STOR` dan mengembalikan kode respon:
```text
550 Permission denied.
```
Penolakan ini membuktikan bahwa direktif `write_enable=NO` pada file konfigurasi individual `/etc/vsftpd/user_conf/mika` aktif dan berhasil membatasi hak akses akun `mika` sehingga tidak dapat melakukan operasi penulisan (*write/upload*) maupun perubahan berkas pada server.

![Output Terminal Mika Penolakan Upload 550 Permission Denied](bukti/Screenshot%202026-09-17%20175042.png)
*Gambar 9.2: Output Terminal Mika - Percobaan Upload put yang Ditolak dengan Kode Status 550 Permission denied*

---

### 9.4. Analisis Paket Wireshark (Korelasi Perintah Kontrol dan Kode Status)

Hasil inspeksi paket menggunakan Wireshark pada link komunikasi antara node Mika, Switch1, dan Router Lain merekam seluruh sekuens transaksi FTP:

1. **Sesi Kontrol TCP Port 21**:
   - Paket perintah `USER mika` diikuti respon `331`.
   - Paket respon `230 Login successful` setelah pengiriman `PASS`.
   - Paket perintah `SIZE protocol7_manifesto.txt` dijawab oleh packet respon `213 3476`.
   - Paket perintah `PASV` dijawab dengan string parameter `227 Entering Passive Mode (10,96,2,2,117,50)`.
2. **Sesi Data TCP Port 30002**:
   - Terlihat jabat tangan TCP SYN dari Mika (`10.96.1.3:random_port`) menuju Chisa (`10.96.2.2:30002`).
   - Perintah `RETR protocol7_manifesto.txt` memicu paket respon `150 Opening BINARY mode...`.
   - Segmen data TCP membawa payload sebesar 3476 bytes dari server menuju client, ditutup dengan bendera FIN-ACK.
   - Sesi kontrol menerima status penutup `226 Transfer complete`.
3. **Sesi Percobaan Upload**:
   - Paket perintah `STOR protocol7_manifesto.txt` dikirimkan oleh Mika.
   - Server Chisa langsung merespons dengan paket status `550 Permission denied` tanpa membuka kanal koneksi data baru pada port pasif.

![Wireshark Aliran Perintah RETR Port Data 30002](bukti/Screenshot%202026-09-17%20175144.png)
*Gambar 9.3: Wireshark Packet Capture - Aliran Perintah RETR protocol7_manifesto.txt pada Port Data 30002*

![Wireshark Konfirmasi 226 Transfer Complete Mika](bukti/Screenshot%202026-09-17%20175158.png)
*Gambar 9.4: Wireshark Packet Capture - Frame 55 Konfirmasi 226 Transfer complete Pengunduhan Berkas Mika*

![Wireshark Penolakan STOR Mika 550 Permission Denied](bukti/Screenshot%202026-09-17%20175208.png)
*Gambar 9.5: Wireshark Packet Capture - Frame 67 Penolakan Perintah STOR Mika dengan Status 550 Permission denied*

---

### 9.5. Ringkasan dan Kesimpulan Soal 9

Akun Mika berhasil digunakan untuk mengunduh berkas `protocol7_manifesto.txt` dari FTP Server Chisa dengan ukuran tepat **3476 bytes** melalui passive data port **30002** (hasil formula $117 \times 256 + 50$). Namun, ketika Mika mencoba melakukan pengunggahan (*upload*), server langsung menolak permintaan dengan respon **550 Permission denied**. Dengan demikian, hak akses **read-only** pada akun Mika telah terbukti berhasil diterapkan dan tervalidasi baik di level aplikasi maupun melalui analisis paket Wireshark.

---

## 10. LANGKAH PENGERJAAN SOAL 10 (ANALISIS ICMP PING KNIGHTS KE CHISA)

### 10.1. Skenario Pengujian Ping ICMP Antar-Subnet (Knights ke Chisa)
Pada pengujian ini, dilakukan analisis transmisi paket ICMP antar-subnet secara intensif untuk mengetahui kualitas performa jaringan, stabilitas latensi, serta karakteristik paket data pada router perantara.

* **Node Pengirim (Source)**: `Knights`
  - Alamat IP: `10.96.3.2/24` (Subnet 3)
  - Default Gateway: `10.96.3.1` (Router Lain `eth3`)
* **Node Tujuan (Destination)**: `Chisa`
  - Alamat IP: `10.96.2.2/24` (Subnet 2)
  - Default Gateway: `10.96.2.1` (Router Lain `eth2`)
* **Parameter Uji Transmisi**:
  - **Jumlah Paket (`-c`)**: `77` paket
  - **Ukuran Payload (`-s`)**: `128` bytes (total ukuran paket IP: $128 + 8 \text{ (ICMP)} + 20 \text{ (IP)} = 156$ bytes)
  - **Interval Transmisi (`-i`)**: `0.3` detik (mode transmisi cepat / *burst ping*)

#### Eksekusi Perintah pada Node Knights:
```bash
ping -c 77 -s 128 -i 0.3 10.96.2.2
```

#### Output Konsol Terminal:
```text
PING 10.96.2.2 (10.96.2.2) 128(156) bytes of data.
136 bytes from 10.96.2.2: icmp_seq=1 ttl=63 time=0.612 ms
136 bytes from 10.96.2.2: icmp_seq=2 ttl=63 time=0.485 ms
...
136 bytes from 10.96.2.2: icmp_seq=77 ttl=63 time=0.510 ms

--- 10.96.2.2 ping statistics ---
77 packets transmitted, 77 received, 0% packet loss, time 23100ms
rtt min/avg/max/mdev = 0.259/0.595/1.289/0.152 ms
```

**Hasil Pengujian Awal:**  
Seluruh **77 paket ICMP Echo Request berhasil mendapatkan balasan Echo Reply** dari node Chisa tanpa mengalami kehilangan paket sedikit pun (**0% packet loss**) dengan total waktu transmisi 23.100 ms (23,1 detik).

![Eksekusi Ping 77 Paket Terminal Knights](bukti/Screenshot%202026-09-17%20175759.png)
*Gambar 10.1: Eksekusi Perintah Ping 77 Paket (Payload 128 Bytes, Interval 0.3s) pada Terminal Knights Menunjukkan 0% Packet Loss*

---

### 10.2. Penggunaan Display Filter Wireshark

Untuk menganalisis aliran paket ICMP di lingkungan GNS3, Wireshark diaktifkan pada antarmuka link yang relevan (misal: link `Switch3` ke `Knights` atau `Lain` ke `Switch2`).

1. **Display Filter Global ICMP**:
   ```text
   icmp
   ```
   Filter ini digunakan untuk menampilkan seluruh paket protokol ICMP di jaringan sehingga seluruh paket *Echo Request* dan *Echo Reply* dapat diamati secara runtut.

2. **Display Filter Spesifik Komunikasi Knights dan Chisa**:
   ```text
   icmp && ip.addr == 10.96.3.2 && ip.addr == 10.96.2.2
   ```
   Filter spesifik ini secara selektif mengisolasi komunikasi antara Knights (`10.96.3.2`) dan Chisa (`10.96.2.2`), menyaring paket ICMP lainnya (seperti ping ke internet atau broadcast).

![Wireshark ICMP Echo Request Type 8 Code 0](bukti/Screenshot%202026-09-17%20175930.png)
*Gambar 10.2: Packet Capture Wireshark - Detail ICMP Echo (ping) Request Type 8 Code 0 dari Knights ke Chisa*

---

### 10.3. Analisis Paket ICMP Echo Request dan Echo Reply

Pemeriksaan struktur paket (*Packet Details*) pada Wireshark menunjukkan dua jenis paket utama dalam transaksi komunikasi ICMP:

#### 1. ICMP Echo Request
* **Source IP**: `10.96.3.2` (Knights)
* **Destination IP**: `10.96.2.2` (Chisa)
* **ICMP Type**: `8` (*Echo Request*)
* **ICMP Code**: `0`
* **Data Payload**: `128 bytes`
* **Checksum**: Valid
* **Identifier & Sequence Number**: Berurutan mulai dari seq 1 hingga 77.
* **Fungsi**: Paket dikirimkan oleh node Knights untuk menguji keterjangkauan dan mengukur waktu tempuh jaringan menuju node Chisa.

#### 2. ICMP Echo Reply
* **Source IP**: `10.96.2.2` (Chisa)
* **Destination IP**: `10.96.3.2` (Knights)
* **ICMP Type**: `0` (*Echo Reply*)
* **ICMP Code**: `0`
* **Data Payload**: `128 bytes` (merefleksikan payload data dari request)
* **TTL (Time to Live)**: `63` (dimulai dari 64 di Chisa dan dikurangi 1 hop saat melintasi Router Lain)
* **Identifier & Sequence Number**: Cocok secara identik dengan paket Echo Request pasangannya.
* **Fungsi**: Paket dikirimkan oleh node Chisa sebagai respon konfirmasi bahwa node target aktif dan dapat merespons permintaan secara normal.

![Wireshark ICMP Echo Reply Type 0 Code 0](bukti/Screenshot%202026-09-17%20175940.png)
*Gambar 10.3: Packet Capture Wireshark - Detail ICMP Echo (ping) Reply Type 0 Code 0 dari Chisa ke Knights*

---

### 10.4. Tabulasi Hasil Pengukuran dan Statistik RTT

Ringkasan parameter dan hasil evaluasi performa transmisi ICMP antar-subnet disajikan pada tabel berikut:

| Parameter Evaluasi | Nilai / Hasil Pengukuran | Interpretasi Teknis |
| :--- | :---: | :--- |
| **Paket Dikirim (*Transmitted*)** | `77` | 77 paket Echo Request dikirimkan dari Knights |
| **Paket Diterima (*Received*)** | `77` | 77 paket Echo Reply diterima kembali oleh Knights |
| **Packet Loss** | **`0%`** | Tidak ada paket yang hilang atau terbuang di router |
| **Total Waktu Pengujian** | `23100 ms` (23,1 s) | Sesuai interval $77 \times 0.3\text{ detik} = 23.1\text{ detik}$ |
| **Ukuran Data Payload** | `128 bytes` | Ditentukan melalui parameter `-s 128` |
| **Interval Pengiriman** | `0.3 s` | Pengiriman cepat (*fast probing*) via parameter `-i 0.3` |
| **RTT Minimum** | **`0.259 ms`** | Waktu bolak-balik tercepat yang tercatat |
| **RTT Rata-rata (*Average*)** | **`0.595 ms`** | Latensi jaringan rata-rata sub-milidetik |
| **RTT Maksimum** | **`1.289 ms`** | Latensi puncak (pembentukan tabel ARP awal) |
| **Standar Deviasi RTT (*mdev*)**| **`0.152 ms`** | Variasi latensi (*jitter*) sangat rendah (koneksi stabil) |
| **Spesifikasi ICMP Request** | **Type 8, Code 0** | Standar RFC 792 Echo Message |
| **Spesifikasi ICMP Reply** | **Type 0, Code 0** | Standar RFC 792 Echo Reply Message |
| **Filter Display Global** | `icmp` | Menampilkan seluruh trafik ICMP |
| **Filter Display Spesifik** | `icmp && ip.addr == 10.96.3.2 && ip.addr == 10.96.2.2` | Membatasi tampilan percakapan Knights $\leftrightarrow$ Chisa |

---

### 10.5. Ringkasan dan Kesimpulan Soal 10

Berdasarkan pengujian empiris dan analisis paket Wireshark, konektivitas antar-subnet antara **Knights (`10.96.3.2`) dan Chisa (`10.96.2.2`) berjalan dengan sangat baik**. Seluruh 77 paket ICMP dengan payload 128 bytes berhasil diterima secara utuh (**0% packet loss**). Nilai RTT minimum tercatat **0.259 ms**, rata-rata **0.595 ms**, maksimum **1.289 ms**, dan deviasi standar (*mdev*) **0.152 ms**.

Hasil tangkapan paket Wireshark memvalidasi pertukaran pesan menggunakan protokol **ICMP Echo Request Type 8 Code 0** dari Knights dan **ICMP Echo Reply Type 0 Code 0** dari Chisa. Hal ini membuktikan bahwa mekanisme *Kernel IP Forwarding* pada Router `Lain` mampu meneruskan paket berukuran kustom dengan interval rapat (0.3s) secara andal, cepat, dan stabil.

---

### 14. Analisis Serangan BruteForce

## Tujuan
## Tujuan Analisis

Menganalisis file `soal14_wired_bruteforce.pcapng` untuk mengidentifikasi sumber serangan brute-force, target layanan web, kredensial yang berhasil digunakan, dan software web server.
Pada soal ini saya menganalisis file `soal14_wired_bruteforce.pcapng`. Tujuannya adalah mencari IP penyerang, target serangan, kredensial yang berhasil dipakai untuk login, serta informasi web server target.

## Alur Analisis di Wireshark
## Langkah Analisis

1. Buka file capture `soal14_wired_bruteforce.pcapng` di Wireshark.
2. Pada kolom **Display Filter**, masukkan filter berikut lalu tekan **Enter**:
Pertama, saya membuka file capture menggunakan Wireshark. Karena serangannya mengarah ke form login web, saya memfilter request HTTP dengan metode POST menggunakan filter berikut:

   ```wireshark
   http.request.method == "POST"
   ```
```wireshark
http.request.method == "POST"
```

   Filter ini menampilkan request login yang dikirim ke endpoint `/login.php`.
Setelah filter diterapkan, terlihat banyak request `POST /login.php`. Request tersebut secara berulang dikirim dari IP `172.26.7.50` ke IP `172.26.7.100`. Dari pola request login yang berulang dengan koneksi berbeda, saya menyimpulkan bahwa IP `172.26.7.50` sedang melakukan brute-force terhadap form login pada target.

3. Amati paket-paket hasil filter. Terlihat banyak request `POST /login.php` dari IP `172.26.7.50` ke `172.26.7.100`. Pola percobaan berulang ini menunjukkan serangan brute-force.
4. Pilih paket POST terakhir, yaitu **frame 350**. Pada detail paket, buka:
Port tujuan dapat dilihat pada detail TCP salah satu request POST, yaitu `Dst Port: 8080`. Jadi layanan web target berjalan pada IP `172.26.7.100` port `8080`.

   ```text
   Hypertext Transfer Protocol
   └── HTML Form URL Encoded
   ```
Selanjutnya, saya berpindah ke request POST terakhir, yaitu **frame 350**. Pada bagian detail paket, saya membuka:

   Field form memperlihatkan username `lain_admin` dan password `wired_protocol_7`.
```text
Hypertext Transfer Protocol
└── HTML Form URL Encoded
```

5. Buka respons untuk request tersebut melalui tautan **Response in frame: 351**, atau gunakan filter:
Bagian tersebut menampilkan data yang dikirim oleh form login. Dari sana saya menemukan:

   ```wireshark
   frame.number == 351
   ```
```text
username: lain_admin
password: wired_protocol_7
```

6. Pada frame 351, buka **Hypertext Transfer Protocol**. Respons `HTTP/1.1 200 OK` membuktikan login berhasil. Header `Server` menunjukkan software dan versi web server.
Untuk memastikan bahwa kredensial tersebut benar, saya melihat respons dari request ini melalui tautan **Response in frame: 351**. Respons yang diterima adalah `HTTP/1.1 200 OK`. Berbeda dengan percobaan sebelumnya yang menghasilkan `401 Unauthorized`, kode `200 OK` menunjukkan login pada frame 350 berhasil.

Pada detail HTTP di frame 351, saya juga menemukan response header berikut:

```text
Server: Apache/2.4.62
```

## Ringkasan Temuan
## Hasil Temuan

| Artefak | Hasil |
| Informasi yang dicari | Hasil analisis |
| --- | --- |
| Endpoint yang diserang | `/login.php` |
| Username berhasil | `lain_admin` |
| Password berhasil | `wired_protocol_7` |
| Bukti login berhasil | `HTTP/1.1 200 OK` pada frame 351 |
| Web server | `Apache/2.4.62` |
| Username yang berhasil digunakan | `lain_admin` |
| Password yang berhasil digunakan | `wired_protocol_7` |
| Bukti keberhasilan login | Respons `HTTP/1.1 200 OK` pada frame 351 |
| Software web server | `Apache/2.4.62` |


Host `172.26.7.50` melakukan percobaan login berulang terhadap layanan web `172.26.7.100` pada port `8080`. Percobaan terakhir menggunakan akun `lain_admin` dengan password `wired_protocol_7` dan memperoleh respons `200 OK`, sehingga kredensial tersebut valid. Server target melaporkan dirinya sebagai `Apache/2.4.62` melalui response header HTTP.
Berdasarkan hasil analisis capture, saya menyimpulkan bahwa host `172.26.7.50` melakukan serangan brute-force ke halaman login `/login.php` pada server `172.26.7.100:8080`. Percobaan yang berhasil menggunakan username `lain_admin` dengan password `wired_protocol_7`. Keberhasilan login dibuktikan oleh respons `HTTP 200 OK`, sedangkan server target menggunakan `Apache/2.4.62`.

## 11. ANALISIS DAN PEMBAHASAN

1. **Peran Idempotensi pada Script Jaringan:**  
   Penggunaan opsi `2>/dev/null || true` pada script konfigurasi interface dan routing sangat krusial. Jika script dieksekusi berkali-kali secara berulang, sistem operasi Linux tidak akan mengalami kegagalan eksekusi (*non-zero exit status*) akibat konflik IP atau rute yang sudah ada, melainkan tetap melanjutkan eksekusi secara mulus hingga baris terakhir.
2. **Pencegahan Redundansi Rule NAT:**  
   Perintah `iptables -t nat -C POSTROUTING -o eth0 -j MASQUERADE` berfungsi mengecek (*Check*) eksistensi rule MASQUERADE pada kernel. Operator logika `||` memastikan bahwa perintah penambahan rule (`-A`) hanya dijalankan bila rule tersebut belum ditemukan, mencegah penumpukan tabel NAT duplikat saat script dipanggil berulang-ulang.
3. **Pemisahan Broadcast Domain dan Routing Inter-Subnet:**  
   Dengan membagi topologi menjadi 3 subnet berbeda (`10.96.1.0/24`, `10.96.2.0/24`, `10.96.3.0/24`) yang terhubung pada tiga interface Router Lain (`eth1`, `eth2`, `eth3`), setiap segmen jaringan memiliki broadcast domain terisolasi. Hal ini mengurangi *broadcast storm* dan membatasi penyebaran trafik lokal, sekaligus memungkinkan Router Lain bertindak sebagai titik kendali keamanan jaringan.
4. **Analisis Paket ICMP dan Mekanisme TTL:**  
   Pada pengujian Soal 6 menggunakan Wireshark, perbedaan nilai TTL pada paket balasan merefleksikan arsitektur routing internet global. Nilai initial TTL dari host Linux lokal adalah 64. Paket dari Google (`8.8.8.8`) yang diterima dengan TTL 110 dan Cloudflare (`1.1.1.1`) dengan TTL 50 menunjukkan bahwa setiap router hop yang dilewati paket di internet selalu mengurangi nilai bidang TTL sebanyak 1 (*TTL decrementation*), mencegah paket berputar selamanya di jaringan (*looping packet prevention*).
5. **Analisis Protokol DNS dan UDP Port 53:**  
   DNS query memanfaatkan protokol transport UDP yang bersifat *connectionless* dan ringan. Penggunaan Transaction ID 16-bit menjamin korelasi antara permintaan dan jawaban tanpa overhead handshake TCP. Resolusi domain publik seperti `example.com`, `github.com`, dan `its.ac.id` membuktikan keberhasilan fungsi NAT MASQUERADE pada Router Lain dalam meneruskan paket UDP port 53 keluar menuju internet dan mengembalikan jawabannya ke IP privat client.
6. **Keamanan FTP Melalui Chroot Jail dan Kontrol Akses Granular:**  
   Implementasi FTP Server vsftpd pada node Chisa menerapkan prinsip keamanan berlapis (*defense-in-depth*):
   - **Chroot Jail (`chroot_local_user=YES`)**: Menjamin user tidak dapat melakukan eksfiltrasi atau berpindah ke direktori induk sistem (`/etc`, `/bin`, `/root`), mengisolasi seluruh aktivitas hanya pada `/var/wired/data`.
   - **Granular User Policy (`user_config_dir`)**: Memungkinkan pemisahan hak akses baca-tulis (user `alice`) dan baca-saja (user `mika`) secara fleksibel tanpa mengubah permission sistem file Linux secara destruktif.
   - **Blacklist Layer 7 (`userlist_deny=YES`)**: Menolak user terlarang (`eiri`) di tahap paling awal negosiasi protokol FTP sebelum komputasi hash password dilakukan, menghemat sumber daya komputasi server dan mencegah serangan brute-force.
7. **Mekanisme Passive FTP dan Routing Lintas Subnet (Soal 8):**  
   Pengujian transfer berkas `knights_report.txt` dari Knights (`10.96.3.2`) ke Chisa (`10.96.2.2`) menunjukkan efektivitas mode pasif (*Passive Mode*) dalam komunikasi antar-subnet:
   - Client menginisiasi kedua koneksi (TCP kontrol pada port 21 dan TCP data pada port 30009). Hal ini mengeliminasi potensi pemblokiran paket oleh stateful firewall atau filter interface pada router perantara (`Lain`).
   - Router `Lain` secara transparan meneruskan paket kontrol maupun data stream biner 1111 bytes antar subnet `10.96.3.0/24` dan `10.96.2.0/24` dengan latensi rendah dan *zero packet loss*.
8. **Penegakan Hak Akses Read-Only, Perintah SIZE, dan Kontrol Perintah RETR vs STOR (Soal 9):**  
   Pemisahan hak akses berbasis user terbukti sangat efektif melalui konfigurasi `user_config_dir`:
   - Daemon `vsftpd` memuat file `/etc/vsftpd/user_conf/mika` saat user `mika` terautentikasi. Nilai `write_enable=NO` mengesampingkan nilai global pada `/etc/vsftpd.conf`.
   - Perintah query metadata seperti `SIZE` tetap diizinkan dan menghasilkan respon status `213`, dan perintah pembacaan aliran data `RETR` dieksekusi dengan kode `150` dan `226`.
   - Namun begitu instruksi modifikasi/penulisan seperti `STOR` dikirimkan, daemon langsung menghentikan proses tanpa membuka koneksi data pasif dan mengembalikan kode status error `550 Permission denied`. Mekanisme ini memastikan perlindungan integritas file pada shared repository tanpa mengganggu kapabilitas distribusi informasi.
9. **Karakteristik Trafik ICMP Kustom dan Stabilitas Jitter (Soal 10):**  
   Pengujian ping burst 77 paket dengan payload 128 bytes dan interval 0.3s menghasilkan nilai rata-rata RTT 0.595 ms dengan deviasi standar (`mdev`) hanya 0.152 ms. Metrik `mdev` (*mean deviation*) yang sangat kecil menunjukkan bahwa jitter jaringan sangat minim, membuktikan bahwa kernel router Linux mampu memproses dan mengalihkan paket IP antar interface lokal (`eth3` ke `eth2`) tanpa mengalami *queuing delay* atau *bufferbloat*.

---

## 12. KESIMPULAN

1. Konfigurasi topologi jaringan dengan alokasi prefix kelompok `10.96.x.x` berhasil diimplementasikan di simulator GNS3 menggunakan 1 Router Linux (`Lain`), 3 switch, dan 5 node client (`Alice`, `Mika`, `Chisa`, `Knights`, `Eiri`).
2. Pengaktifan *Kernel IP Forwarding* (`net.ipv4.ip_forward=1`) dan *Source NAT* (`iptables MASQUERADE`) pada Router Lain berhasil menghubungkan seluruh client dari tiga subnet lokal berbeda ke jaringan publik / Internet.
3. Konfigurasi DNS resolver `8.8.8.8` pada setiap client memungkinkan proses resolusi domain eksternal berjalan dengan lancar.
4. Keterbatasan *statelessness* runtime Docker container pada GNS3 berhasil diatasi dengan script automasi shell (`konfigurasi_lain.sh` dan `konfigurasi_client.sh`) yang bersifat *idempotent* dan diintegrasikan pada *Startup Command* GNS3, menjamin konfigurasi persisten setelah reboot.
5. Analisis trafik jaringan menggunakan Wireshark pada node `10.96.1.3` (Mika) memverifikasi keberhasilan komunikasi protokol ICMP (Echo Request dan Echo Reply dengan analisis nilai TTL) serta protokol DNS (Query Type A dan Response Answer) terhadap server publik global `8.8.8.8` dan `1.1.1.1`.
6. Layanan FTP Server pada node Chisa (`10.96.2.2`) berhasil diimplementasikan menggunakan `vsftpd` dengan shared folder `/var/wired/data`. Kebijakan akses berbasis user berhasil diterapkan secara sempurna:
   - User `alice` memiliki hak **Read & Write** (terbukti dari pembuatan file `/var/wired/data/signal_alice.txt`).
   - User `mika` memiliki hak **Read Only** (berhasil membaca dan gagal menulis dengan kode `550 Permission denied`).
   - User `eiri` masuk dalam daftar **Blacklist** (autentikasi ditolak di awal dengan kode `530 Permission denied`).
7. Pengujian transfer file `knights_report.txt` (1111 bytes) dari node Knights (`10.96.3.2`) ke server Chisa (`10.96.2.2`) menggunakan akun `alice` berhasil dilaksanakan secara sempurna. Melalui inspeksi paket Wireshark, terkonfirmasi alur kerja protokol FTP Passive Mode: autentikasi user `alice` (`230 Login successful`), respon pasif `227 Entering Passive Mode` dengan perhitungan port data $(117 \times 256) + 57 = 30009$, transmisi file via perintah `STOR`, dan konfirmasi akhir `226 Transfer complete`.
8. Pengujian hak akses user `mika` membuktikan efektivitas kebijakan **Read-Only**: pengunduhan berkas `protocol7_manifesto.txt` (3476 bytes) berhasil dilaksanakan melalui port pasif **30002** (hasil formula $117 \times 256 + 50$) dengan perintah `RETR`, serta respon ukuran berkas `213 3476` via perintah `SIZE`. Ketika mencoba melakukan upload berkas (`STOR`), server vsftpd secara konsisten menolak dengan status `550 Permission denied` yang tervalidasi pada konsol terminal maupun tangkapan paket Wireshark.
9. Pengujian transmisi ICMP kustom dari node Knights (`10.96.3.2`) ke node Chisa (`10.96.2.2`) dengan parameter 77 paket, payload 128 bytes, dan interval 0.3s menghasilkan **0% packet loss** dengan latensi rata-rata RTT **0.595 ms** dan deviasi jitter rendah **0.152 ms**. Tangkapan Wireshark membuktikan korelasi paket **ICMP Echo Request Type 8 Code 0** dan **ICMP Echo Reply Type 0 Code 0**, menegaskan konektivitas inter-subnet yang prima dan andal melalui Router `Lain`.
