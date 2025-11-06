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
