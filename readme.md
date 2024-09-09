# 🚀Auto DNS
Skrip Bash yang ampuh ini akan membantu Anda mengatur dan mengkonfigurasi Bind9 DNS server di sistem Linux Anda dengan cepat dan efisien.

## ✨Fitur Utama
Instalasi Otomatis: Jika Bind9 belum terinstal, jangan khawatir! Skrip ini akan menanganinya untuk Anda.
Backup Aman: Skrip ini akan membuat salinan cadangan file konfigurasi Anda, sehingga Anda dapat kembali ke pengaturan sebelumnya jika diperlukan.
Konfigurasi Zona: Cukup masukkan nama domain dan alamat IP Anda, dan skrip ini akan menangani konfigurasi zona forward dan reverse untuk Anda.
Restart Otomatis: Setelah konfigurasi selesai, Bind9 akan dimulai ulang secara otomatis untuk menerapkan perubahan.
## 🛠️Cara Instalasi & Penggunaan
Akses Root: Pastikan Anda memiliki hak akses root.
clone : 
```bash
git clone https://github.com/MbahPinguinSakti/DndServerAutomation.git && cd ~/DndServerAutomation
```
Berikan Hak Akses:
```bash
chmod +x bind9_setup.sh.
```
eksekusi:
```bash
./install.sh
```
Ikuti Instruksi: Masukkan nama domain dan alamat IP Anda saat diminta.
## 💡Catatan Penting
Linux Only: Skrip ini hanya berfungsi pada sistem Linux.
Bind9 Diperlukan: Pastikan Bind9 sudah terinstal atau skrip ini akan menginstalnya untuk Anda.

## 🤝Kontribusi
Kontribusi sangat dihargai! Jika Anda memiliki saran atau perbaikan, jangan ragu untuk membuka issue atau pull request.
Mari buat konfigurasi Bind9 menjadi lebih mudah! 🚀