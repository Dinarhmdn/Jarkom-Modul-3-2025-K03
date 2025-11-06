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
