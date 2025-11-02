# Durin

apt update
apt install isc-dhcp-relay -y

nano /etc/default/isc-dhcp-relay

# SERVERS="10.64.4.2"
# NTERFACES="eth1 eth2 eth3 eth4"
# OPTIONS=""

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

sysctl -p
service isc-dhcp-relay restart

SOAL NO 2 code mentah
dhcp realy  Defaults for isc-dhcp-relay initscript
# sourced by /etc/init.d/isc-dhcp-relay
# installed at /etc/default/isc-dhcp-relay by the maintainer scripts

#
# This is a POSIX shell fragment
#

# What servers should the DHCP relay forward requests to?
SERVERS="10.65.4.2"

# On what interfaces should the DHCP relay (dhrelay) serve DHCP requests?
INTERFACES="eth1 eth2 eth3 eth4"

# Additional options that are passed to the DHCP relay daemon?
OPTIONS=""


dhcp server code mentah


# DHCP Configuration for K03
ddns-update-style none;
option domain-name "k03.com";
option domain-name-servers 10.65.0.3, 10.65.0.4;

default-lease-time 1800;
max-lease-time 3600;

authoritative;

subnet 10.65.4.0 netmask 255.255.255.0 {
    # Gateway untuk subnet ini adalah port Durin (eth5)
    option routers 10.65.4.1;
    # Karena subnet ini hanya berisi server, kita bisa membiarkan range kosong
    # atau menempatkan range kecil untuk testing jika perlu.
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

# Contoh untuk subnet Khamul (jika klien di subnet ini butuh IP)
subnet 10.65.3.0 netmask 255.255.255.0 {
    # Anda mungkin perlu menambahkan range jika ada klien lain selain Khamul
    option routers 10.65.3.1;
}


# Fixed address untuk Khamul
# CATATAN: Ganti dengan MAC address sebenarnya dari node Khamul
host Khamul {
    hardware ethernet 02:42:29:d3:43:00;
    fixed-address 10.65.3.95;
}




SOAL NO 2,1 SCRIPT.SH
#!/bin/bash

# Nama file konfigurasi DHCPD (umumnya digunakan)
CONFIG_FILE="/etc/dhcp/dhcpd.conf"

echo "📝 Membuat konfigurasi DHCPD di $CONFIG_FILE"

# Membersihkan file konfigurasi lama dan menambahkan konfigurasi baru
cat <<EOF > $CONFIG_FILE
# DHCP Configuration for K03
ddns-update-style none;
option domain-name "k03.com";
option domain-name-servers 10.65.0.3, 10.65.0.4;

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

# Contoh untuk subnet Khamul
subnet 10.65.3.0 netmask 255.255.255.0 {
    # Anda mungkin perlu menambahkan range jika ada klien lain selain Khamul
    option routers 10.65.3.1;
}

# Fixed address untuk Khamul
# CATATAN: Ganti dengan MAC address sebenarnya dari node Khamul
host Khamul {
    hardware ethernet 02:42:29:d3:43:00;
    fixed-address 10.65.3.95;
}
EOF

echo "✅ Konfigurasi DHCPD telah selesai dibuat."

# Menambahkan langkah opsional untuk me-restart service DHCP
if command -v systemctl &> /dev/null; then
    echo "🔄 Mencoba me-restart layanan dhcpd (atau isc-dhcp-server)..."
    # Ganti 'isc-dhcp-server' jika nama service berbeda (misalnya 'dhcpd' pada RHEL/CentOS)
    systemctl restart isc-dhcp-server || systemctl restart dhcpd
    echo "💡 Periksa status layanan untuk memastikan tidak ada error: systemctl status isc-dhcp-server"
else
    echo "💡 Skrip ini tidak secara otomatis me-restart DHCPD. Harap restart layanan secara manual."
fi

SOAL NO 2.2 SCRIPT.SH

#!/bin/bash

# Nama file konfigurasi default untuk isc-dhcp-relay
CONFIG_FILE="/etc/default/isc-dhcp-relay"

echo "📝 Membuat konfigurasi DHCP Relay di $CONFIG_FILE"

# Membersihkan file konfigurasi lama dan menambahkan konfigurasi baru
# Menggunakan 'cat <<EOF' (Heredoc) untuk menulis konten
cat <<EOF > $CONFIG_FILE
# Konfigurasi Default untuk isc-dhcp-relay
# Dibuat oleh skrip shell

# Apa saja server yang harus diteruskan oleh relay DHCP?
SERVERS="10.65.4.2"

# Pada antarmuka apa relay DHCP (dhrelay) harus melayani permintaan DHCP?
INTERFACES="eth1 eth2 eth3 eth4"

# Opsi tambahan yang diteruskan ke daemon relay DHCP?
OPTIONS=""
EOF

echo "✅ Konfigurasi DHCP Relay telah selesai dibuat."

# ---

# Langkah opsional: Me-restart layanan DHCP Relay
if command -v systemctl &> /dev/null; then
    echo "🔄 Mencoba me-restart layanan isc-dhcp-relay..."
    # Perintah restart mungkin sedikit berbeda tergantung OS (misalnya 'dhcrelay' atau 'isc-dhcp-relay')
    systemctl restart isc-dhcp-relay 2>/dev/null || echo "💡 Gagal me-restart isc-dhcp-relay. Pastikan nama layanannya benar."
    echo "💡 Periksa status layanan untuk memverifikasi: systemctl status isc-dhcp-relay"
else
    echo "💡 Skrip ini tidak secara otomatis me-restart layanan. Harap restart layanan DHCP Relay secara manual."
fi


