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
