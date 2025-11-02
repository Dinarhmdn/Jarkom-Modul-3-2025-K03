# Soal 3 
#!/bin/bash

# Update package list
apt-get update

# Install dnsmasq sebagai DNS forwarder
apt-get install -y dnsmasq

# Konfigurasi dnsmasq
cat > /etc/dnsmasq.conf <<EOF
# Listen pada semua interface
interface=eth0

# Forward DNS queries ke nameserver external (Valinor/Internet)
server=192.168.122.1

# Cache size (opsional)
cache-size=1000

# Log queries (opsional untuk debugging)
log-queries
EOF

# Restart dnsmasq menggunakan service
service dnsmasq restart

# Jika service tidak bekerja, gunakan:
# /etc/init.d/dnsmasq restart

# Cek status dnsmasq
service dnsmasq status








