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
