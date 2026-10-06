# RS AntBee — Sistem Informasi Manajemen Rumah Sakit (SIMRS)

Aplikasi web **Java** untuk pengelolaan data rumah sakit: pendaftaran pasien, master dokter/perawat/penyakit/ruangan,
rawat inap, pemeriksaan, catatan perawatan, pembayaran, laporan, dan portal pasien.
Dibangun dengan **Jakarta EE 10 / JSP / JDBC / MySQL**.

Antarmuka memakai tema **RS AntBee** (merah marun `#7A1C1C`, charcoal `#222222`, krem `#FDFBF7`)
dengan Bootstrap 5.3.3 yang dibundel lokal.

---

## 1. Persyaratan Sistem

| Komponen | Versi |
|---|---|
| JDK | 21 |
| Maven | 3.9+ (di NetBeans: Maven bawaan) |
| Server | Apache **Tomcat 10.1+ / 11** (wajib, karena pakai namespace `jakarta.*`) |
| Database | MySQL 8 / MariaDB 10.4 (XAMPP) |
| IDE | Apache NetBeans 20 |
| Browser | Chrome / Edge / Firefox (HTML5, CSS3, JavaScript vanilla, Bootstrap 5.3.3 lokal) |

> **Penting:** Tomcat 8.5/9 (javax) **tidak bisa** dipakai. Aplikasi ini memakai `jakarta.servlet`,
> sehingga hanya berjalan di Tomcat 10.x ke atas.

---

## 2. Struktur Proyek

```
rumahsakit/
├── database.sql                     # Skema + FK + data contoh (rerunnable)
├── README.md
├── pom.xml                          # packaging = war, Jakarta EE 10
├── logoo.png                        # aset logo sumber (disalin ke webapp/assets/img/)
├── tools/                           # Skrip uji fungsional (PowerShell)
│   ├── uji-fungsional.ps1
│   └── uji-halaman.ps1
└── src/main/
    ├── java/com/mycompany/rumahsakit/
    │   ├── config/DBConnection.java         # Koneksi JDBC (bisa di-override -Ddb.*)
    │   ├── filter/AuthenticationFilter.java # Filter sesi + RBAC per path
    │   ├── model/      (10 class)           # Pasien, Dokter, Perawat, Ruangan, dst.
    │   ├── dao/        (10 class)           # SQL per tabel (tanpa ORM)
    │   ├── servlet/    (16 class)           # Controller / halaman
    │   └── util/       (4 class)            # Auth, Validasi, Notifikasi, PasswordUtil
    └── webapp/
        ├── index.jsp, login.jsp, access-denied.jsp, error.jsp
        ├── fragments/   head, sidebar, topbar, footer  (layout)
        ├── assets/css/  bootstrap.min.css, bootstrap-icons.min.css, style.css
        ├── assets/js/   bootstrap.bundle.min.js, app.js
        ├── assets/img/  logoo.png
        ├── dashboard/   5 halaman dashboard (admin, dokter, perawat, petugas, pasien)
        ├── pasien/ dokter/ perawat/ penyakit/ ruangan/ rawat-inap/
        ├── pemeriksaan/ catatan-perawatan/ pembayaran/ pengguna/
        ├── profil/ laporan/ saya/            # modul + 6 laporan + portal pasien
```

Jumlah file: **62 halaman JSP**, **14 fragment JSPF**, 16 servlet, 10 DAO, 10 model, 6 util/config/filter.

---

## 3. Menyiapkan Database

1. Nyalakan **MySQL/MariaDB** (XAMPP → Start pada modul *MySQL*).
2. Buka terminal / phpMyAdmin, lalu import file `database.sql`:

   ```bat
   C:\xampp\mysql\bin\mysql.exe -u root < database.sql
   ```

   atau lewat phpMyAdmin: **Import → pilih `database.sql` → Go**.

3. File ini **bisa dijalankan berulang kali** (rerunnable): setiap kali dieksekusi database
   `rumah_sakit` dibuat ulang sehingga data selalu konsisten.

**Koneksi default:** `jdbc:mysql://localhost:3306/rumah_sakit`, user `root`, password kosong.
Bila berbeda, tidak perlu mengubah kode — cukup tambahkan system property pada JVM server:

```
-Ddb.host=localhost -Ddb.port=3306 -Ddb.name=rumah_sakit -Ddb.user=root -Ddb.password=rahasia
```

(NetBeans: Run → Set Project Configuration → Edit Project Properties → Run → VM Options.)

---

## 4. Menjalankan di NetBeans + Tomcat 10.1+

1. **File → Open Project…** → pilih folder `rumahsakit` (ikon gudang Maven).
2. Registrasi Tomcat 10.1: **Tools → Servers → Add Server → Apache Tomcat 10.1** (unduh dari
   <https://tomcat.apache.org/download-10.cgi> bila belum ada).
3. Klik kanan project → **Properties → Run → Server** → pilih Tomcat 10.1,
   **Context Path** = `/rumahsakit`.
4. Tekan **F6** (Run Project). Tomcat akan mem-build `rumahsakit.war` lalu membuka:

   ```
   http://localhost:8080/rumahsakit/
   ```

**Cara manual (tanpa NetBeans):**

```bat
mvn -B clean package
copy target\rumahsakit.war "%CATALINA_HOME%\webapps\"
"%CATALINA_HOME%\bin\catalina.bat" start
```

---

## 5. Akun Demo

| Role | Username | Password | Keterangan |
|---|---|---|---|
| ADMIN | `admin` | `admin123` | Akses penuh ke seluruh modul + laporan |
| DOKTER | `dokter01` | `dokter123` | Pasien, pemeriksaan, catatan perawatan, rawat inap |
| PERAWAT | `perawat01` | `perawat123` | Pasien, ruangan, rawat inap, catatan perawatan |
| PETUGAS | `petugas01` | `petugas123` | Pasien, rawat inap, pembayaran |
| PASIEN | `pasien01` | `pasien123` | Portal pribadi `/saya` (jadwal, tagihan, notifikasi) |

Akun cadangan: `dokter02`…`dokter10`, `perawat02`…`perawat10`, `pasien02`…`pasien05`
(semua memakai password yang sama per role).
Password disimpan sebagai **hash SHA-256** (`PasswordUtil`) — cukup untuk tugas kuliah,
untuk sistem nyata gunakan BCrypt/Argon2.

---

## 6. Hak Akses (Server-Side Session RBAC)

| Path | ADMIN | DOKTER | PERAWAT | PETUGAS | PASIEN |
|:--|:-:|:-:|:-:|:-:|:-:|
| `/pasien` | ✔ | ✔ | ✔ | ✔ | ✖ |
| `/dokter`, `/perawat`, `/penyakit`, `/pengguna`, `/laporan` | ✔ | ✖ | ✖ | ✖ | ✖ |
| `/ruangan` | ✔ | ✖ | ✔ | ✖ | ✖ |
| `/rawat-inap` | ✔ | ✔ | ✔ | ✔ | ✖ |
| `/pemeriksaan` | ✔ | ✔ | ✖ | ✖ | ✖ |
| `/catatan-perawatan` | ✔ | ✔(baca) | ✔ | ✖ | ✖ |
| `/pembayaran` | ✔ | ✖ | ✖ | ✔ | ✖ |
| `/profil` | ✔ | ✔ | ✔ | ✔ | ✔ |
| `/saya` (portal) | ✖ | ✖ | ✖ | ✖ | ✔ |

Pembatasan dipasang **dua lapis**: `AuthenticationFilter` (prefix path → role) **dan**
panggilan `Auth.wajibLogin/wajibRole` di setiap servlet. File `.jsp` modul tidak bisa dibuka
langsung (dialihkan ke `/dashboard`). Data pasien hanya dibaca dari `idPasien` pada session —
bukan dari parameter URL.

---

## 7. Aturan Bisnis

1. **Kapasitas ruangan tidak pernah terlampaui.** `jumlah_terisi ≤ kapasitas`;
   bertambah saat status rawat inap menjadi `DIRAWAT`, berkurang saat `SELESAI/DIPULANGKAN/dihapus`.
   Bila kamar penuh, penyimpanan ditolak dengan pesan *"Kamar A-01 (…) sudah penuh. Pilih kamar lain."*
2. **Lama rawat dihitung sistem** dari tanggal masuk–keluar (minimum 1 hari).
3. **Total biaya dihitung sistem** = biaya kamar + dokter + obat + tindakan + lain-lain
   (input total tidak bisa diubah pengguna), dan tidak boleh negatif.
4. **Dashboard** memakai `COUNT/SUM` SQL langsung — tidak ada angka hard-coded.
5. **Validasi**: NIK 16 digit & unik, NIP/username unik, nama & tempat lahir wajib,
   format telepon, format tanggal, tanggal keluar ≥ tanggal masuk, FK harus ada,
   status harus termasuk daftar yang diizinkan.

---

## 8. Data Contoh (setelah import `database.sql`)

| Tabel | Jumlah baris | Tabel | Jumlah baris |
|---|---:|---|---:|
| pengguna | 27 | rawat_inap | 15 |
| pasien | **20** | pemeriksaan | 12 |
| dokter | 10 | catatan_perawatan | 12 |
| perawat | 10 | pembayaran | 12 |
| penyakit | 10 | | |
| ruangan | 10 | **Total** | **138 baris** |

Setiap tampilan data memuat ≥ 10 atribut/kolom, dan seluruh foreign key konsisten.

---

## 9. Uji Fungsional

Dua skrip PowerShell (dijalankan saat aplikasi sudah hidup di `localhost:8080/rumahsakit`):

```powershell
powershell -ExecutionPolicy Bypass -File tools\uji-fungsional.ps1   # 121 pemeriksaan
powershell -ExecutionPolicy Bypass -File tools\uji-halaman.ps1       # pemeriksaan 74 halaman
```

Cakupan: halaman publik & proteksi, login 5 role, matriks RBAC (25 kombinasi),
seluruh halaman tiap role, CRUD pasien + validasi + duplikasi NIK, aturan kapasitas kamar,
total biaya dihitung sistem, biaya negatif ditolak, portal pasien, filter/pencarian,
dan integritas database (FK, kapasitas, NIK).

Hasil terakhir: **121/121 pemeriksaan lulus** dan **74 halaman bersih** (tanpa error,
tanpa teks Inggris/placeholder, layout utuh).

---

## 10. Catatan

- Seluruh teks antarmuka berbahasa Indonesia.
- Aset (Bootstrap 5.3.3 + Bootstrap Icons) dibundel lokal, tanpa CDN.
- Navigasi memakai halaman penuh (bukan SPA).
- Password SHA-256 tanpa salt dipakai **hanya untuk keperluan akademik**.
