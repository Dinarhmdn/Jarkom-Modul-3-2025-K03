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


