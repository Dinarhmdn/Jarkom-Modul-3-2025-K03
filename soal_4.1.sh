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
