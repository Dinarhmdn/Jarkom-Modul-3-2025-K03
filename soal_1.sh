# Durin
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 10.65.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.65.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 10.65.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 10.65.4.1
    netmask 255.255.255.0

auto eth5
iface eth5 inet static
    address 10.65.5.1
    netmask 255.255.255.0

up echo 1 > /proc/sys/net/ipv4/ip_forward
up echo 'net.ipv4.ip_forward=1' > /etc/sysctl.conf

up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.65.0.0/16

# Elendil

auto eth0
iface eth0 inet static
    address 10.65.1.2
    netmask 255.255.255.0
    gateway 10.65.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Isildur

auto eth0
iface eth0 inet static
    address 10.65.1.3
    netmask 255.255.255.0
    gateway 10.65.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Anarion

auto eth0
iface eth0 inet static
    address 10.65.1.4
    netmask 255.255.255.0
    gateway 10.65.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Miriel

auto eth0
iface eth0 inet static
    address 10.65.1.5
    netmask 255.255.255.0
    gateway 10.65.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Amandil

auto eth0
iface eth0 inet dhcp
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Elros

auto eth0
iface eth0 inet static
    address 10.65.1.7
    netmask 255.255.255.0
    gateway 10.65.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Gilgalad

auto eth0
iface eth0 inet dhcp
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Celebrimbor

auto eth0
iface eth0 inet static
    address 10.65.2.3
    netmask 255.255.255.0
    gateway 10.65.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Pharazon

auto eth0
iface eth0 inet static
    address 10.65.2.4
    netmask 255.255.255.0
    gateway 10.65.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Galadriel

auto eth0
iface eth0 inet static
    address 10.65.2.5
    netmask 255.255.255.0
    gateway 10.65.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Celeborn

auto eth0
iface eth0 inet static
    address 10.65.2.6
    netmask 255.255.255.0
    gateway 10.65.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Oropher

auto eth0
iface eth0 inet static
    address 10.65.2.7
    netmask 255.255.255.0
    gateway 10.65.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Khamul

auto eth0
iface eth0 inet dhcp
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Erendis

auto eth0
iface eth0 inet static
    address 10.65.3.3
    netmask 255.255.255.0
    gateway 10.65.3.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Amdir

auto eth0
iface eth0 inet static
    address 10.65.3.4
    netmask 255.255.255.0
    gateway 10.65.3.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Aldarion

auto eth0
iface eth0 inet static
    address 10.65.4.2
    netmask 255.255.255.0
    gateway 10.65.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Palantir

auto eth0
iface eth0 inet static
    address 10.65.4.3
    netmask 255.255.255.0
    gateway 10.65.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Narvi

auto eth0
iface eth0 inet static
    address 10.65.4.4
    netmask 255.255.255.0
    gateway 10.65.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

# Minastir

auto eth0
iface eth0 inet static
    address 10.65.5.2
    netmask 255.255.255.0
    gateway 10.65.5.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf

