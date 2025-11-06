# Jarkom-Modul-3-2025-K03


# 👥 Anggota Kelompok / Tim


| Peran | Nama Lengkap | NRP |
| :--- | :--- | :--- |
| Anggota 1 | **Mochkamad Maulana Syafaat** | 5027241021 |
| Anggota 2 | **Dina Rahmadani** | 5027241065 |

---

# Soal 1
Di awal Zaman Kedua, setelah kehancuran Beleriand, para Valar menugaskan untuk membangun kembali jaringan komunikasi antar kerajaan. Para Valar menyalakan Minastir, Aldarion, Erendis, Amdir, Palantir, Narvi, Elros, Pharazon, Elendil, Isildur, Anarion, Galadriel, Celeborn, Oropher, Miriel, Amandil, Gilgalad, Celebrimbor, Khamul, dan pastikan setiap node (selain Durin sang penghubung antar dunia) dapat sementara berkomunikasi dengan Valinor/Internet (nameserver 192.168.122.1) untuk menerima instruksi awal.-

# Penyelesaian 
Memberikan IP static kepada node node yang static dan menambahkan nameserver ``192.168.122.1``
```
auto eth0
iface eth0 inet static
    address 10.65.1.2
    netmask 255.255.255.0
    gateway 10.65.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
```
![Uploading image.png…](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20213742.png)
![c](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20214104.png)
# Soal 2
Raja Pelaut Aldarion, penguasa wilayah Númenor, memutuskan cara pembagian tanah client secara dinamis. Ia menetapkan:
Client Dinamis Keluarga Manusia: Mendapatkan tanah di rentang [prefix ip].1.6 - [prefix ip].1.34 dan [prefix ip].1.68 - [prefix ip].1.94.
Client Dinamis Keluarga Peri: Mendapatkan tanah di rentang [prefix ip].2.35 - [prefix ip].2.67 dan [prefix ip].2.96 - [prefix ip].2.121.
Khamul yang misterius: Diberikan tanah tetap di [prefix ip].3.95, agar keberadaannya selalu diketahui. Pastikan Durin dapat menyampaikan dekrit ini ke semua wilayah yang terhubung dengannya.

# Penyelesaian
a.Konfigurasi Durin (Router & DHCP Relay)
membuat file .sh yang berisi konfigurasi seperti ini
```
#!/bin/bash

apt-get update
apt-get install isc-dhcp-relay -y
service isc-dhcp-relay start


# Nama file konfigurasi default untuk isc-dhcp-relay
CONFIG_FILE="/etc/default/isc-dhcp-relay"

echo " Membuat konfigurasi DHCP Relay di $CONFIG_FILE"

# Membersihkan file konfigurasi lama dan menambahkan konfigurasi baru
# Menggunakan 'cat <<EOF' (Heredoc) untuk menulis konten
cat <<EOF > $CONFIG_FILE
# Konfigurasi Default untuk isc-dhcp-relay
# Dibuat oleh skrip shell

# Apa saja server yang harus diteruskan oleh relay DHCP
SERVERS="10.65.4.2"

# Pada antarmuka apa relay DHCP (dhrelay) harus melayani permintaan DHCP
INTERFACES="eth1 eth2 eth3 eth4"

# Opsi tambahan yang diteruskan ke daemon relay DHCP?
OPTIONS=""
EOF

echo " Konfigurasi DHCP Relay telah selesai dibuat."

sysctl -p
service isc-dhcp-relay restart

```
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20214449.png)

Tidak lupa Aktifkan IP Forwarding:
![Uploading image.png…](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20224510.png)

b.Konfigurasi Aldarion (DHCP Server)
membuat file .sh yang berisi konfigurasi seperti ini
```
#!/bin/bash
apt-get update
apt-get install isc-dhcp-server

# Nama file konfigurasi DHCPD (umumnya digunakan)
CONFIG_FILE="/etc/dhcp/dhcpd.conf"

echo " Membuat konfigurasi DHCPD di $CONFIG_FILE"

# Membersihkan file konfigurasi lama dan menambahkan konfigurasi baru
cat <<EOF > $CONFIG_FILE
# DHCP Configuration for K03
ddns-update-style none;
option domain-name "K03.com";
option domain-name-servers 10.65.3.2, 10.65.3.3;

default-lease-time 1800;
max-lease-time 3600;

authoritative;

# Subnet Server (K03)
subnet 10.65.4.0 netmask 255.255.255.0 {
    # Gateway untuk subnet ini adalah port Durin (eth5)
    option routers 10.65.4.1;
    # Karena subnet ini hanya berisi server, kita bisa membiarkan range kosong
    # atau menempatkan range kecil untuk testing jika perlu.
    # range 10.65.4.50 10.65.4.55;
}

# Subnet untuk jaringan Aldarion sendiri
subnet 10.65.0.0 netmask 255.255.255.0 {
    range 10.65.0.100 10.65.0.150;
    option routers 10.65.0.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.65.0.255;
}

# Subnet Keluarga Manusia
subnet 10.65.1.0 netmask 255.255.255.0 {
    range 10.65.1.6 10.65.1.34;
    range 10.65.1.68 10.65.1.94;
    option routers 10.65.1.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.65.1.255;
    default-lease-time 1800;
    max-lease-time 3600;
}

# Subnet Keluarga Peri
subnet 10.65.2.0 netmask 255.255.255.0 {
    range 10.65.2.35 10.65.2.67;
    range 10.65.2.96 10.65.2.121;
    option routers 10.65.2.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.65.2.255;
    default-lease-time 600;
    max-lease-time 3600;
}

#  subnet Khamul
subnet 10.65.3.0 netmask 255.255.255.0 {
    #menambahkan range jika ada klien lain selain Khamul
    option routers 10.65.3.1;
}

# Fixed address untuk Khamul
host Khamul {
    hardware ethernet 02:42:29:d3:43:00;
    fixed-address 10.65.3.95;
}
EOF

echo " Konfigurasi DHCPD telah selesai dibuat."

# Menambahkan langkah opsional untuk me-restart service DHCP
```
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20214339.png)
jangan lupa Mengganti isi dari nano /etc/default/isc-dhcp-server sesuikan dengan port mana yang digunakan dhcp server yang terhubung dengan switch
![Uploading image.png…](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20214311.png)

cek ip Gigalad,Amandil,dan khamul dengan menggunakan ip a
AMANDIL
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20214630.png)
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20214642.png)
GIGALAD
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20214741.png)
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20214751.png)
KHAMUL
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20214845.png)
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20214902.png)

# Soal 3
Untuk mengontrol arus informasi ke dunia luar (Valinor/Internet), sebuah menara pengawas, Minastir didirikan. Minastir mengatur agar semua node (kecuali Durin) hanya dapat mengirim pesan ke luar Arda setelah melewati pemeriksaan di Minastir.
# Penyelesaian
membuat file .sh yang berisi konfigurasi seperti ini
```
#!/bin/bash

echo "================================================"
echo "    MINASTIR - BIND9 DNS FORWARDER"
echo "================================================"
echo

# Step 1: Hentikan semua service DNS yang mungkin berjalan
echo "[1/7] Menghentikan service DNS yang berjalan..."
pkill -9 dnsmasq
pkill named
pkill systemd-resolve
fuser -k 53/udp 53/tcp > /dev/null 2>&1
sleep 3

# Step 2: Install BIND9
echo "[2/7] Menginstall BIND9..."
apt-get update > /dev/null 2>&1
apt-get install -y bind9 bind9utils bind9-doc > /dev/null 2>&1
echo "✓ BIND9 installed"

# Step 3: Backup konfigurasi lama
echo "[3/7] Backup konfigurasi lama..."
cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup 2>/dev/null || true

# Step 4: Buat konfigurasi BIND9 sebagai forwarder
echo "[4/7] Membuat konfigurasi BIND9 forwarder..."
cat > /etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";
    
    // Listen pada semua interface dan IP Minastir
    listen-on port 53 { any; };
    listen-on-v6 port 53 { any; };
    
    // Izinkan query dari mana saja
    allow-query { any; };
    
    // Recursion enabled untuk forwarding
    recursion yes;
    
    // Forwarder ke DNS external (Valinor/Internet)
    forwarders {
        192.168.122.1;
    };
    
    // Hanya forward, jangan coba root servers
    forward only;
    
    // DNS security
    dnssec-validation auto;
    
    // Optional: Cache settings
    max-cache-size 256M;
    
    // Auth nxdomain
    auth-nxdomain no;
};
EOF

# Step 5: Set permissions
echo "[5/7] Mengatur permissions..."
chown bind:bind /etc/bind/named.conf.options
chmod 644 /etc/bind/named.conf.options

# Step 6: Start BIND9
echo "[6/7] Menjalankan BIND9..."
# Hentikan BIND9 jika sudah running
pkill named
sleep 2

# Start BIND9
named -u bind -c /etc/bind/named.conf > /dev/null 2>&1 &
sleep 5

# Step 7: Verifikasi
echo "[7/7] Verifikasi..."
if netstat -tulpn | grep :53 | grep named > /dev/null; then
    echo "✓ BIND9 berhasil berjalan di port 53"
    echo "✓ Process ID: $(pgrep named)"
else
    echo "✗ BIND9 gagal start, mencoba metode alternatif..."
    # Coba start dengan cara lain
    /usr/sbin/named -u bind &
    sleep 3
    if netstat -tulpn | grep :53 | grep named > /dev/null; then
        echo "✓ BIND9 berhasil dengan metode alternatif"
    else
        echo "✗ BIND9 masih gagal, cek log..."
        # Coba jalankan di foreground untuk melihat error
        echo "Debug info:"
        named -u bind -f -g &
        sleep 2
        exit 1
    fi
fi

echo
echo "================================================"
echo "           TESTING DNS FORWARDING"
echo "================================================"

# Test dari localhost
echo "1. Testing dari localhost (127.0.0.1):"
if nslookup google.com 127.0.0.1 > /dev/null 2>&1; then
    echo "   ✓ SUCCESS - DNS forwarding berfungsi"
else
    echo "   ✗ FAILED - DNS forwarding tidak berfungsi"
fi

# Test dari IP Minastir
echo "2. Testing dari IP Minastir (10.65.5.2):"
if nslookup google.com 10.65.5.2 > /dev/null 2>&1; then
    echo "   ✓ SUCCESS - DNS accessible via network"
else
    echo "   ✗ FAILED - DNS tidak accessible via network"
fi

# Test internal domain (harusnya tidak resolve, karena kita forwarder only)
echo "3. Testing internal domain (K03.com):"
nslookup K03.com 127.0.0.1

echo
echo "================================================"
echo "    MINASTIR BIND9 FORWARDER SELESAI"
echo "    IP: 10.65.5.2"
echo "    Forwarding ke: 192.168.122.1"
echo "================================================"

# Buat script testing sederhana
cat > /root/test-minastir.sh <<'EOF'
#!/bin/bash
echo "=== TEST MINASTIR DNS FORWARDER ==="
echo "Testing external DNS:"
nslookup google.com 127.0.0.1
nslookup debian.org 127.0.0.1
echo
echo "Status BIND9:"
netstat -tulpn | grep :53
ps aux | grep named | grep -v grep
EOF

chmod +x /root/test-minastir.sh

echo "Untuk testing, jalankan: /root/test-minastir.sh"
```
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20215708.png)
diclient ganti Nameserver menjadi ip minastir 
```
echo "nameserver 10.65.5.2" > /etc/resolv.con
```
Tes diclient manapun untuk mengetahui apakah jaringan melewati ip minastir

![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20220336.png)

# Soal 4

Ratu Erendis, sang pembuat peta, menetapkan nama resmi untuk wilayah utama (<xxxx>.com). Ia menunjuk dirinya (ns1.<xxxx>.com) dan muridnya Amdir (ns2.<xxxx>.com) sebagai penjaga peta resmi. Setiap lokasi penting (Palantir, Elros, Pharazon, Elendil, Isildur, Anarion, Galadriel, Celeborn, Oropher) diberikan nama domain unik yang menunjuk ke lokasi fisik tanah mereka. Pastikan Amdir selalu menyalin peta (master-slave) dari Erendis dengan setia

# Penyelesaian
membuat file .sh yang berisi konfigurasi seperti ini

a.DNS MASTER
```
#!/bin/bash

echo "================================================"
echo "    KONFIGURASI ERENDIS (DNS MASTER) - FIX"
echo "    Domain: K03.com | IP: 10.65.3.2"
echo "================================================"
echo

# Step 1: Install BIND9
echo "[1/8] Installing BIND9..."
apt-get update > /dev/null 2>&1
apt-get install -y bind9 bind9utils bind9-doc dnsutils > /dev/null 2>&1
echo "✓ BIND9 installed"

# Step 2: Stop any running BIND processes
echo "[2/8] Stopping existing BIND processes..."
pkill named > /dev/null 2>&1
sleep 2

# Step 3: Create named.conf.options
echo "[3/8] Configuring named.conf.options..."
cat > /etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";
    listen-on { any; };
    listen-on-v6 { any; };
    allow-query { any; };
    recursion yes;
    
    // Forwarder ke Minastir
    forwarders {
        10.65.5.2;
    };
    
    dnssec-validation auto;
    auth-nxdomain no;
    listen-on-v6 { any; };
};
EOF
echo "✓ named.conf.options configured"

# Step 4: Create named.conf.local
echo "[4/8] Configuring named.conf.local..."
cat > /etc/bind/named.conf.local <<'EOF'
// Zone forward untuk domain K03.com
zone "K03.com" {
    type master;
    file "/etc/bind/db.K03.com";
    allow-transfer { 10.65.3.3; }; // IP Amdir (DNS Slave)
};

// Zone reverse untuk network 10.65.0.0/16
zone "65.10.in-addr.arpa" {
    type master;
    file "/etc/bind/db.10.65";
    allow-transfer { 10.65.3.3; }; // IP Amdir (DNS Slave)
};
EOF
echo "✓ named.conf.local configured"

# Step 5: Create forward zone file
echo "[5/8] Creating forward zone db.K03.com..."
cat > /etc/bind/db.K03.com <<'EOF'
$TTL    604800
@       IN      SOA     ns1.K03.com. admin.K03.com. (
                              2025110501 ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

; Name Server records
@       IN      NS      ns1.K03.com.
@       IN      NS      ns2.K03.com.

; A record for base domain - FIX: This was missing!
@       IN      A       10.65.3.2

; A records untuk server utama
ns1     IN      A       10.65.3.2
ns2     IN      A       10.65.3.3

; A records untuk lokasi penting
minastir    IN      A       10.65.5.2
aldarion    IN      A       10.65.4.2
palantir    IN      A       10.65.4.3
narvi       IN      A       10.65.4.4
elros       IN      A       10.65.5.3
pharazon    IN      A       10.65.2.5

; A records untuk worker Laravel
elendil     IN      A       10.65.1.2
isildur     IN      A       10.65.1.3
anarion     IN      A       10.65.1.4

; A records untuk worker PHP
galadriel   IN      A       10.65.2.2
celeborn    IN      A       10.65.2.3
oropher     IN      A       10.65.2.4

; A records untuk client
miriel      IN      A       10.65.1.5
celebrimbor IN      A       10.65.2.6

; CNAME untuk www
www         IN      CNAME   K03.com.
EOF
echo "✓ Forward zone created"

# Step 6: Create reverse zone file
echo "[6/8] Creating reverse zone db.10.65..."
cat > /etc/bind/db.10.65 <<'EOF'
$TTL    604800
@       IN      SOA     ns1.K03.com. admin.K03.com. (
                              2025110501 ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

; Name Server records
@       IN      NS      ns1.K03.com.
@       IN      NS      ns2.K03.com.

; PTR records
2.3      IN      PTR     ns1.K03.com.
3.3      IN      PTR     ns2.K03.com.
2.5      IN      PTR     minastir.K03.com.
2.4      IN      PTR     aldarion.K03.com.
3.4      IN      PTR     palantir.K03.com.
4.4      IN      PTR     narvi.K03.com.
3.5      IN      PTR     elros.K03.com.
5.2      IN      PTR     pharazon.K03.com.
2.1      IN      PTR     elendil.K03.com.
3.1      IN      PTR     isildur.K03.com.
4.1      IN      PTR     anarion.K03.com.
2.2      IN      PTR     galadriel.K03.com.
3.2      IN      PTR     celeborn.K03.com.
4.2      IN      PTR     oropher.K03.com.
5.1      IN      PTR     miriel.K03.com.
6.2      IN      PTR     celebrimbor.K03.com.
EOF
echo "✓ Reverse zone created"

# Step 7: Set permissions and check syntax
echo "[7/8] Setting permissions and checking syntax..."
chown bind:bind /etc/bind/db.K03.com
chown bind:bind /etc/bind/db.10.65

# Check configuration syntax
if named-checkconf /etc/bind/named.conf.local > /dev/null 2>&1; then
    echo "✓ named.conf.local syntax OK"
else
    echo "✗ named.conf.local syntax ERROR"
    exit 1
fi

if named-checkzone K03.com /etc/bind/db.K03.com > /dev/null 2>&1; then
    echo "✓ Forward zone syntax OK"
else
    echo "✗ Forward zone syntax ERROR"
    exit 1
fi

if named-checkzone 65.10.in-addr.arpa /etc/bind/db.10.65 > /dev/null 2>&1; then
    echo "✓ Reverse zone syntax OK"
else
    echo "✗ Reverse zone syntax ERROR"
    exit 1
fi

# Step 8: Start BIND9
echo "[8/8] Starting BIND9 service..."
named -u bind -c /etc/bind/named.conf > /dev/null 2>&1 &
sleep 5

# Check if BIND9 is running
if pgrep named > /dev/null; then
    echo "✓ BIND9 service started successfully"
else
    echo "✗ Failed to start BIND9"
    echo "Trying alternative method..."
    # Alternative start method
    /usr/sbin/named -u bind &
    sleep 3
    if pgrep named > /dev/null; then
        echo "✓ BIND9 started with alternative method"
    else
        echo "✗ BIND9 still failed to start"
        exit 1
    fi
fi

echo
echo "================================================"
echo "           TESTING DNS MASTER"
echo "================================================"

# Test DNS resolution locally
echo "Testing local resolution:"
test_domains=("K03.com" "www.K03.com" "minastir.K03.com" "palantir.K03.com")

for domain in "${test_domains[@]}"; do
    if nslookup "$domain" localhost > /dev/null 2>&1; then
        echo "✓ $domain -> OK"
    else
        echo "✗ $domain -> FAILED"
    fi
done

echo
echo "Testing reverse lookup:"
if nslookup 10.65.3.2 localhost > /dev/null 2>&1; then
    echo "✓ 10.65.3.2 -> OK"
else
    echo "✗ 10.65.3.2 -> FAILED"
fi

echo
echo "Testing external DNS (via Minastir):"
if nslookup google.com localhost > /dev/null 2>&1; then
    echo "✓ External DNS -> OK"
else
    echo "✗ External DNS -> FAILED"
fi

echo
echo "================================================"
echo "    ERENDIS (DNS MASTER) KONFIGURASI SELESAI"
echo "    DNS Server: 10.65.3.2"
echo "    Domain: K03.com"
echo "================================================"
```
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20220431.png)

b.DNS SLAVE
```
#!/bin/bash

echo "================================================"
echo "    KONFIGURASI AMDIR (DNS SLAVE) - FIX"
echo "    Domain: K03.com | IP: 10.65.3.3"
echo "================================================"
echo

# Step 1: Install BIND9
echo "[1/7] Installing BIND9..."
apt-get update > /dev/null 2>&1
apt-get install -y bind9 bind9utils bind9-doc dnsutils > /dev/null 2>&1
echo "✓ BIND9 installed"

# Step 2: Stop any running BIND processes
echo "[2/7] Stopping existing BIND processes..."
pkill named > /dev/null 2>&1
sleep 2

# Step 3: Create named.conf.options
echo "[3/7] Configuring named.conf.options..."
cat > /etc/bind/named.conf.options <<'EOF'
options {
    directory "/var/cache/bind";
    listen-on { any; };
    listen-on-v6 { any; };
    allow-query { any; };
    recursion yes;
    
    // Forwarder ke Minastir
    forwarders {
        10.65.5.2;
    };
    
    dnssec-validation auto;
    auth-nxdomain no;
    listen-on-v6 { any; };
};
EOF
echo "✓ named.conf.options configured"

# Step 4: Create named.conf.local for slave
echo "[4/7] Configuring named.conf.local (slave)..."
cat > /etc/bind/named.conf.local <<'EOF'
// Zone forward untuk domain K03.com (Slave)
zone "K03.com" {
    type slave;
    file "/var/cache/bind/db.K03.com";
    masters { 10.65.3.2; }; // IP Erendis (DNS Master)
};

// Zone reverse untuk network 10.65.0.0/16 (Slave)
zone "65.10.in-addr.arpa" {
    type slave;
    file "/var/cache/bind/db.10.65";
    masters { 10.65.3.2; }; // IP Erendis (DNS Master)
};
EOF
echo "✓ named.conf.local configured"

# Step 5: Set permissions for slave directory
echo "[5/7] Setting permissions..."
mkdir -p /var/cache/bind
chown bind:bind /var/cache/bind
chmod 755 /var/cache/bind
echo "✓ Permissions set"

# Step 6: Start BIND9
echo "[6/7] Starting BIND9 service..."
named -u bind -c /etc/bind/named.conf > /dev/null 2>&1 &
sleep 5

# Check if BIND9 is running
if pgrep named > /dev/null; then
    echo "✓ BIND9 service started successfully"
else
    echo "✗ Failed to start BIND9"
    echo "Trying alternative method..."
    /usr/sbin/named -u bind &
    sleep 3
    if pgrep named > /dev/null; then
        echo "✓ BIND9 started with alternative method"
    else
        echo "✗ BIND9 still failed to start"
        exit 1
    fi
fi

# Step 7: Wait for zone transfer
echo "[7/7] Waiting for zone transfer from master..."
echo "This may take 30-60 seconds..."
sleep 40

echo
echo "================================================"
echo "           TESTING DNS SLAVE"
echo "================================================"

# Check if zone files were transferred
echo "Checking zone files:"
if [ -f "/var/cache/bind/db.K03.com" ]; then
    echo "✓ Forward zone file transferred"
    records_count=$(grep -c "IN A" /var/cache/bind/db.K03.com 2>/dev/null || echo "0")
    echo "  Found $records_count A records"
else
    echo "✗ Forward zone file missing"
fi

if [ -f "/var/cache/bind/db.10.65" ]; then
    echo "✓ Reverse zone file transferred"
else
    echo "✗ Reverse zone file missing"
fi

# Test DNS resolution locally
echo
echo "Testing DNS resolution:"
test_domains=("K03.com" "www.K03.com" "minastir.K03.com")

for domain in "${test_domains[@]}"; do
    if nslookup "$domain" localhost > /dev/null 2>&1; then
        echo "✓ $domain -> OK"
    else
        echo "✗ $domain -> FAILED"
    fi
done

echo
echo "Testing external DNS (via Minastir):"
if nslookup google.com localhost > /dev/null 2>&1; then
    echo "✓ External DNS -> OK"
else
    echo "✗ External DNS -> FAILED"
fi

echo
echo "================================================"
echo "    AMDIR (DNS SLAVE) KONFIGURASI SELESAI"
echo "    DNS Server: 10.65.3.3"
echo "    Master Server: 10.65.3.2"
echo "================================================"
```
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20231429.png)

lakukan tes ini
Test Forward Lookup
nslookup K03.com
nslookup minastir.K03.com
nslookup aldarion.K03.com
nslookup palantir.K03.com
nslookup elros.K03.com
nslookup pharazon.K03.com
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20221218.png)

Test Reverse Lookup 
nslookup 10.65.3.2
nslookup 10.65.3.3
nslookup 10.65.5.2
nslookup 10.65.4.3
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20221303.png)

# Soal 5
Untuk memudahkan, nama alias www.<xxxx>.com dibuat untuk peta utama <xxxx>.com. Reverse PTR juga dibuat agar lokasi Erendis dan Amdir dapat dilacak dari alamat fisik tanahnya. Erendis juga menambahkan pesan rahasia (TXT record) pada petanya: "Cincin Sauron" yang menunjuk ke lokasi Elros, dan "Aliansi Terakhir" yang menunjuk ke lokasi Pharazon. Pastikan Amdir juga mengetahui pesan rahasia ini.
Aldarion menetapkan aturan waktu peminjaman tanah. Ia mengatur:

# Penyelesaian
membuat file .sh yang berisi konfigurasi seperti ini
a.DNS MASTER(TXT RECORD)
```
#!/bin/bash

echo "================================================"
echo "    SOAL NO 5 - KONFIGURASI TXT RECORDS"
echo "          DAN REVERSE PTR LENGKAP"
echo "================================================"
echo

# Step 1: Backup zone files
echo "[1/6] Backup zone files..."
cp /etc/bind/db.K03.com /etc/bind/db.K03.com.backup
cp /etc/bind/db.10.65 /etc/bind/db.10.65.backup

# Step 2: Update forward zone dengan TXT records
echo "[2/6] Update forward zone dengan TXT records..."
cat > /etc/bind/db.K03.com <<'EOF'
$TTL    604800
@       IN      SOA     ns1.K03.com. admin.K03.com. (
                              2025110502 ; Serial - INCREASED
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

; Name Server records
@       IN      NS      ns1.K03.com.
@       IN      NS      ns2.K03.com.

; A record for base domain
@       IN      A       10.65.3.2

; A records untuk server utama
ns1     IN      A       10.65.3.2
ns2     IN      A       10.65.3.3

; A records untuk lokasi penting
minastir    IN      A       10.65.5.2
aldarion    IN      A       10.65.4.2
palantir    IN      A       10.65.4.3
narvi       IN      A       10.65.4.4
elros       IN      A       10.65.5.3
pharazon    IN      A       10.65.2.5

; A records untuk worker Laravel
elendil     IN      A       10.65.1.2
isildur     IN      A       10.65.1.3
anarion     IN      A       10.65.1.4

; A records untuk worker PHP
galadriel   IN      A       10.65.2.2
celeborn    IN      A       10.65.2.3
oropher     IN      A       10.65.2.4

; A records untuk client
miriel      IN      A       10.65.1.5
celebrimbor IN      A       10.65.2.6

; CNAME untuk www
www         IN      CNAME   K03.com.

; TXT Records untuk pesan rahasia - SOAL NO 5
@           IN      TXT     "Cincin Sauron menunjuk ke elros"
@           IN      TXT     "Aliansi Terakhir menunjuk ke pharazon"
elros       IN      TXT     "Cincin Sauron"
pharazon    IN      TXT     "Aliansi Terakhir"
EOF

# Step 3: Update reverse zone dengan PTR lengkap
echo "[3/6] Update reverse zone dengan PTR records lengkap..."
cat > /etc/bind/db.10.65 <<'EOF'
$TTL    604800
@       IN      SOA     ns1.K03.com. admin.K03.com. (
                              2025110502 ; Serial - INCREASED
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL

; Name Server records
@       IN      NS      ns1.K03.com.
@       IN      NS      ns2.K03.com.

; PTR records untuk server DNS
2.3      IN      PTR     ns1.K03.com.    ; Erendis (10.65.3.2)
3.3      IN      PTR     ns2.K03.com.    ; Amdir (10.65.3.3)

; PTR records untuk server lainnya
2.5      IN      PTR     minastir.K03.com.
2.4      IN      PTR     aldarion.K03.com.
3.4      IN      PTR     palantir.K03.com.
4.4      IN      PTR     narvi.K03.com.
3.5      IN      PTR     elros.K03.com.
5.2      IN      PTR     pharazon.K03.com.

; PTR records untuk worker Laravel
2.1      IN      PTR     elendil.K03.com.
3.1      IN      PTR     isildur.K03.com.
4.1      IN      PTR     anarion.K03.com.

; PTR records untuk worker PHP
2.2      IN      PTR     galadriel.K03.com.
3.2      IN      PTR     celeborn.K03.com.
4.2      IN      PTR     oropher.K03.com.

; PTR records untuk client
5.1      IN      PTR     miriel.K03.com.
6.2      IN      PTR     celebrimbor.K03.com.
EOF

# Step 4: Set permissions
echo "[4/6] Set permissions..."
chown bind:bind /etc/bind/db.K03.com
chown bind:bind /etc/bind/db.10.65

# Step 5: Check syntax
echo "[5/6] Check syntax..."
named-checkzone K03.com /etc/bind/db.K03.com
named-checkzone 65.10.in-addr.arpa /etc/bind/db.10.65

# Step 6: Restart BIND9
echo "[6/6] Restart BIND9..."
pkill named
sleep 2
named -u bind &
sleep 3

echo
echo "================================================"
echo "           TESTING SOAL NO 5"
echo "================================================"

# Test TXT records
echo "1. Testing TXT Records:"
nslookup -type=TXT K03.com localhost
nslookup -type=TXT elros.K03.com localhost
nslookup -type=TXT pharazon.K03.com localhost

# Test Reverse PTR
echo
echo "2. Testing Reverse PTR:"
nslookup 10.65.3.2 localhost
nslookup 10.65.3.3 localhost
nslookup 10.65.5.2 localhost

echo
echo "================================================"
echo "    SOAL NO 5 - KONFIGURASI SELESAI"
echo "================================================"
```

![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20221344.png)

b.DNS SALVE (Refresh Zones)
```
#!/bin/bash

echo "================================================"
echo "    AMDIR - REFRESH ZONES DARI MASTER"
echo "================================================"
echo

# Step 1: Refresh zones
echo "[1/3] Refreshing zones from master..."
rndc refresh K03.com
rndc refresh 65.10.in-addr.arpa

# Jika rndc tidak bekerja, restart BIND9
if [ $? -ne 0 ]; then
    echo "rndc failed, restarting BIND9..."
    pkill named
    sleep 2
    named -u bind &
    sleep 10
fi

# Step 2: Wait for transfer
echo "[2/3] Waiting for zone transfer..."
sleep 15

# Step 3: Verify transfer
echo "[3/3] Verifying zone transfer..."
echo "Zone files in cache:"
ls -la /var/cache/bind/

echo
echo "Testing TXT records from slave:"
nslookup -type=TXT K03.com localhost
nslookup -type=TXT elros.K03.com localhost

echo
echo "================================================"
echo "    ZONE REFRESH COMPLETE"
echo "================================================"
```
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20231429.png)

lakukan tes menggunakan : nslookup -type=TXT K03.com
nslookup -type=TXT elros.K03.com
nslookup -type=TXT pharazon.K03.com
![](https://github.com/Dinarhmdn/Jarkom-Modul-3-2025-K03/blob/main/image/Screenshot%202025-11-06%20232421.png)







