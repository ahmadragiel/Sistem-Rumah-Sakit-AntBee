-- ==========================================================================
-- Sistem Informasi Manajemen Rumah Sakit (SIMRS)
-- File      : database.sql
-- Database  : rumah_sakit
-- Server    : MySQL / MariaDB (XAMPP) dengan charset utf8mb4
-- Keterangan: File ini bisa dijalankan berulang kali (rerunnable).
--             Seluruh database akan dibuat ulang dari awal setiap kali
--             file dieksekusi, sehingga data selalu konsisten.
--
-- Hubungan antar tabel (foreign key):
--   pasien.id_pengguna        -> pengguna.id_pengguna
--   pasien.id_dokter          -> dokter.id_dokter
--   pasien.id_penyakit        -> penyakit.id_penyakit
--   dokter.id_pengguna        -> pengguna.id_pengguna
--   perawat.id_pengguna       -> pengguna.id_pengguna
--   rawat_inap.id_pasien      -> pasien.id_pasien
--   rawat_inap.id_dokter      -> dokter.id_dokter
--   rawat_inap.id_ruangan     -> ruangan.id_ruangan
--   pemeriksaan.id_pasien     -> pasien.id_pasien
--   pemeriksaan.id_dokter     -> dokter.id_dokter
--   catatan_perawatan.id_pasien  -> pasien.id_pasien
--   catatan_perawatan.id_perawat -> perawat.id_perawat
--   pembayaran.id_pasien      -> pasien.id_pasien
--   pembayaran.id_rawat_inap  -> rawat_inap.id_rawat_inap
--
-- Catatan password: disimpan sebagai hash SHA-256 (lihat PasswordUtil.java).
-- ==========================================================================

DROP DATABASE IF EXISTS rumah_sakit;
CREATE DATABASE rumah_sakit DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE rumah_sakit;

-- --------------------------------------------------------------------------
-- 1. Tabel pengguna (akun login seluruh role)
-- --------------------------------------------------------------------------
CREATE TABLE pengguna (
    id_pengguna   INT AUTO_INCREMENT PRIMARY KEY,
    username      VARCHAR(50)  NOT NULL UNIQUE,
    password      VARCHAR(64)  NOT NULL COMMENT 'Hash SHA-256',
    nama_lengkap  VARCHAR(100) NOT NULL,
    email         VARCHAR(100) NULL,
    no_telepon    VARCHAR(20)  NULL,
    alamat        VARCHAR(255) NULL,
    role          VARCHAR(10)  NOT NULL COMMENT 'ADMIN, DOKTER, PERAWAT, PETUGAS, PASIEN',
    status        VARCHAR(10)  NOT NULL DEFAULT 'AKTIF' COMMENT 'AKTIF, NONAKTIF',
    created_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- --------------------------------------------------------------------------
-- 2. Tabel penyakit (master diagnosis)
-- --------------------------------------------------------------------------
CREATE TABLE penyakit (
    id_penyakit       INT AUTO_INCREMENT PRIMARY KEY,
    kode_penyakit     VARCHAR(20)  NOT NULL UNIQUE,
    nama_penyakit     VARCHAR(100) NOT NULL,
    jenis_penyakit    VARCHAR(50)  NULL,
    gejala            TEXT         NULL,
    penyebab          TEXT         NULL,
    tingkat_keparahan VARCHAR(10)  NULL COMMENT 'RINGAN, SEDANG, BERAT, KRITIS',
    penanganan        TEXT         NULL,
    obat_utama        VARCHAR(100) NULL,
    keterangan        VARCHAR(255) NULL
) ENGINE=InnoDB;

-- --------------------------------------------------------------------------
-- 3. Tabel dokter
-- --------------------------------------------------------------------------
CREATE TABLE dokter (
    id_dokter      INT AUTO_INCREMENT PRIMARY KEY,
    id_pengguna    INT          NULL,
    nip            VARCHAR(30)  NOT NULL UNIQUE,
    nama_dokter    VARCHAR(100) NOT NULL,
    jenis_kelamin  VARCHAR(20)  NULL,
    tempat_lahir   VARCHAR(50)  NULL,
    tanggal_lahir  DATE         NULL,
    spesialisasi   VARCHAR(80)  NULL,
    alamat         VARCHAR(255) NULL,
    no_telepon     VARCHAR(20)  NULL,
    email          VARCHAR(100) NULL,
    jadwal_praktik VARCHAR(100) NULL,
    status         VARCHAR(10)  NOT NULL DEFAULT 'AKTIF',
    CONSTRAINT fk_dokter_pengguna FOREIGN KEY (id_pengguna)
        REFERENCES pengguna (id_pengguna) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------------------------
-- 4. Tabel perawat
-- --------------------------------------------------------------------------
CREATE TABLE perawat (
    id_perawat     INT AUTO_INCREMENT PRIMARY KEY,
    id_pengguna    INT          NULL,
    nip            VARCHAR(30)  NOT NULL UNIQUE,
    nama_perawat   VARCHAR(100) NOT NULL,
    jenis_kelamin  VARCHAR(20)  NULL,
    tempat_lahir   VARCHAR(50)  NULL,
    tanggal_lahir  DATE         NULL,
    pendidikan     VARCHAR(60)  NULL,
    alamat         VARCHAR(255) NULL,
    no_telepon     VARCHAR(20)  NULL,
    shift          VARCHAR(10)  NULL COMMENT 'Pagi, Siang, Malam',
    ruangan        VARCHAR(80)  NULL,
    status         VARCHAR(10)  NOT NULL DEFAULT 'AKTIF',
    CONSTRAINT fk_perawat_pengguna FOREIGN KEY (id_pengguna)
        REFERENCES pengguna (id_pengguna) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------------------------
-- 5. Tabel ruangan
--    jumlah_terisi wajib selalu <= kapasitas (dikendalikan aplikasi).
-- --------------------------------------------------------------------------
CREATE TABLE ruangan (
    id_ruangan    INT AUTO_INCREMENT PRIMARY KEY,
    nama_ruangan  VARCHAR(80)   NOT NULL,
    jenis_ruangan VARCHAR(30)   NULL COMMENT 'Kelas I, Kelas II, Kelas III, ICU, Anak, Isolasi',
    nomor_kamar   VARCHAR(20)   NOT NULL,
    lantai        INT           NULL,
    kapasitas     INT           NOT NULL DEFAULT 0,
    jumlah_terisi INT           NOT NULL DEFAULT 0,
    tarif_per_hari DECIMAL(12,2) NOT NULL DEFAULT 0,
    fasilitas     VARCHAR(255)  NULL,
    status_ruangan VARCHAR(15)  NOT NULL DEFAULT 'TERSEDIA' COMMENT 'TERSEDIA, TERISI, PERAWATAN',
    CONSTRAINT chk_kapasitas CHECK (kapasitas >= 0 AND jumlah_terisi >= 0)
) ENGINE=InnoDB;

-- --------------------------------------------------------------------------
-- 6. Tabel pasien
-- --------------------------------------------------------------------------
CREATE TABLE pasien (
    id_pasien      INT AUTO_INCREMENT PRIMARY KEY,
    id_pengguna    INT          NULL,
    nik            CHAR(16)     NOT NULL UNIQUE,
    nama_pasien    VARCHAR(100) NOT NULL,
    jenis_kelamin  VARCHAR(20)  NULL,
    tempat_lahir   VARCHAR(50)  NULL,
    tanggal_lahir  DATE         NULL,
    alamat         VARCHAR(255) NULL,
    no_telepon     VARCHAR(20)  NULL,
    golongan_darah VARCHAR(5)   NULL,
    id_penyakit    INT          NULL,
    id_dokter      INT          NULL,
    tanggal_masuk  DATE         NULL,
    tanggal_keluar DATE         NULL,
    status_pasien  VARCHAR(15)  NOT NULL DEFAULT 'RAWAT JALAN' COMMENT 'RAWAT JALAN, DIRAWAT, PULANG',
    CONSTRAINT fk_pasien_pengguna FOREIGN KEY (id_pengguna)
        REFERENCES pengguna (id_pengguna) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_pasien_penyakit FOREIGN KEY (id_penyakit)
        REFERENCES penyakit (id_penyakit) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_pasien_dokter FOREIGN KEY (id_dokter)
        REFERENCES dokter (id_dokter) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_tanggal_pasien CHECK (tanggal_keluar IS NULL OR tanggal_masuk IS NULL
                                         OR tanggal_keluar >= tanggal_masuk)
) ENGINE=InnoDB;

-- --------------------------------------------------------------------------
-- 7. Tabel rawat_inap
-- --------------------------------------------------------------------------
CREATE TABLE rawat_inap (
    id_rawat_inap INT AUTO_INCREMENT PRIMARY KEY,
    id_pasien     INT      NOT NULL,
    id_dokter     INT      NOT NULL,
    id_ruangan    INT      NOT NULL,
    nomor_kamar   VARCHAR(20) NULL,
    diagnosa      TEXT     NULL,
    keluhan       TEXT     NULL,
    tanggal_masuk DATE     NOT NULL,
    tanggal_keluar DATE    NULL,
    lama_rawat    INT      NULL COMMENT 'dihitung sistem dari tanggal masuk-keluar',
    status_rawat  VARCHAR(15) NOT NULL DEFAULT 'MENUNGGU'
                  COMMENT 'MENUNGGU, DIRAWAT, SELESAI, DIPULANGKAN',
    CONSTRAINT fk_rawat_pasien FOREIGN KEY (id_pasien)
        REFERENCES pasien (id_pasien) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_rawat_dokter FOREIGN KEY (id_dokter)
        REFERENCES dokter (id_dokter) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_rawat_ruangan FOREIGN KEY (id_ruangan)
        REFERENCES ruangan (id_ruangan) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT chk_tanggal_rawat CHECK (tanggal_keluar IS NULL OR tanggal_keluar >= tanggal_masuk)
) ENGINE=InnoDB;

-- --------------------------------------------------------------------------
-- 8. Tabel pemeriksaan
-- --------------------------------------------------------------------------
CREATE TABLE pemeriksaan (
    id_pemeriksaan      INT AUTO_INCREMENT PRIMARY KEY,
    id_pasien           INT           NOT NULL,
    id_dokter           INT           NOT NULL,
    tanggal_pemeriksaan DATE          NOT NULL,
    keluhan             TEXT          NULL,
    tekanan_darah       VARCHAR(10)   NULL,
    suhu                DECIMAL(4,1)  NULL,
    berat_badan         DECIMAL(5,1)  NULL,
    diagnosa            TEXT          NULL,
    tindakan            TEXT          NULL,
    catatan             TEXT          NULL,
    CONSTRAINT fk_periksa_pasien FOREIGN KEY (id_pasien)
        REFERENCES pasien (id_pasien) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_periksa_dokter FOREIGN KEY (id_dokter)
        REFERENCES dokter (id_dokter) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------------------------
-- 9. Tabel catatan_perawatan
-- --------------------------------------------------------------------------
CREATE TABLE catatan_perawatan (
    id_catatan      INT AUTO_INCREMENT PRIMARY KEY,
    id_pasien       INT      NOT NULL,
    id_perawat      INT      NOT NULL,
    tanggal         DATE     NOT NULL,
    kondisi_pasien  TEXT     NULL,
    catatan         TEXT     NULL,
    tindakan        TEXT     NULL,
    status          VARCHAR(10) NOT NULL DEFAULT 'BAIK' COMMENT 'BAIK, SEDANG, KRITIS',
    CONSTRAINT fk_catatan_pasien FOREIGN KEY (id_pasien)
        REFERENCES pasien (id_pasien) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_catatan_perawat FOREIGN KEY (id_perawat)
        REFERENCES perawat (id_perawat) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- --------------------------------------------------------------------------
-- 10. Tabel pembayaran
--     total_biaya selalu dihitung sistem = jumlah 5 komponen biaya.
-- --------------------------------------------------------------------------
CREATE TABLE pembayaran (
    id_pembayaran      INT AUTO_INCREMENT PRIMARY KEY,
    id_pasien          INT            NOT NULL,
    id_rawat_inap      INT            NULL,
    biaya_kamar        DECIMAL(14,2)  NOT NULL DEFAULT 0,
    biaya_dokter       DECIMAL(14,2)  NOT NULL DEFAULT 0,
    biaya_obat         DECIMAL(14,2)  NOT NULL DEFAULT 0,
    biaya_tindakan     DECIMAL(14,2)  NOT NULL DEFAULT 0,
    biaya_lain         DECIMAL(14,2)  NOT NULL DEFAULT 0,
    total_biaya        DECIMAL(14,2)  NOT NULL DEFAULT 0,
    metode_pembayaran  VARCHAR(30)    NULL COMMENT 'Tunai, Transfer Bank, Kartu Debit, QRIS, BPJS, Asuransi',
    tanggal_pembayaran DATE           NULL,
    status_pembayaran  VARCHAR(15)    NOT NULL DEFAULT 'BELUM DIBAYAR'
                       COMMENT 'BELUM DIBAYAR, MENUNGGU, LUNAS',
    CONSTRAINT fk_bayar_pasien FOREIGN KEY (id_pasien)
        REFERENCES pasien (id_pasien) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_bayar_rawat FOREIGN KEY (id_rawat_inap)
        REFERENCES rawat_inap (id_rawat_inap) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT chk_total_bayar CHECK (total_biaya >= 0 AND biaya_kamar >= 0 AND biaya_dokter >= 0
                                      AND biaya_obat >= 0 AND biaya_tindakan >= 0 AND biaya_lain >= 0)
) ENGINE=InnoDB;

-- ==========================================================================
-- DATA MASTER
-- ==========================================================================

-- --------------------------------------------------------------------------
-- A. Pengguna (27 akun)
--    Hash SHA-256:
--      admin123    -> 240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9
--      dokter123   -> b3959dee9b178b030c2b8373da55a04ab3adb318edeb178953ff8b77301a360a
--      perawat123  -> f44dcd1a0fb5c13451ebf183c7833c9d881865469c4ebb33c4e247e777a63db3
--      petugas123  -> 2dad904f71aa0dcf6ea1addaa084a5865ffe448e4d3f900668e1cc7e7b6153d7
--      pasien123   -> b3cb1bf1350e826eafc2250c570837e1ef1a0e8d6fece2c3478740670ce8fed1
-- --------------------------------------------------------------------------
INSERT INTO pengguna (id_pengguna, username, password, nama_lengkap, email, no_telepon, alamat, role, status) VALUES
(1,  'admin',     '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', 'Administrator SIMRS', 'admin@sehatsentosa.id',  '0215551000', 'Jl. Merdeka No. 1, Jakarta',              'ADMIN',    'AKTIF'),
(2,  'dokter01',  'b3959dee9b178b030c2b8373da55a04ab3adb318edeb178953ff8b77301a360a', 'Andi Pratama',        'andi.pratama@sehatsentosa.id',  '081211110001', 'Jl. Kenanga No. 12, Jakarta',           'DOKTER',   'AKTIF'),
(3,  'dokter02',  'b3959dee9b178b030c2b8373da55a04ab3adb318edeb178953ff8b77301a360a', 'Rina Kusuma',         'rina.kusuma@sehatsentosa.id',  '081211110002', 'Jl. Melati No. 5, Bandung',             'DOKTER',   'AKTIF'),
(4,  'dokter03',  'b3959dee9b178b030c2b8373da55a04ab3adb318edeb178953ff8b77301a360a', 'Bambang Sutopo',      'bambang.sutopo@sehatsentosa.id','081211110003', 'Jl. Anggrek No. 8, Yogyakarta',        'DOKTER',   'AKTIF'),
(5,  'dokter04',  'b3959dee9b178b030c2b8373da55a04ab3adb318edeb178953ff8b77301a360a', 'Maya Anggraini',      'maya.anggraini@sehatsentosa.id','081211110004','Jl. Cendana No. 3, Surabaya',          'DOKTER',   'AKTIF'),
(6,  'dokter05',  'b3959dee9b178b030c2b8373da55a04ab3adb318edeb178953ff8b77301a360a', 'Yusuf Hakim',         'yusuf.hakim@sehatsentosa.id',  '081211110005', 'Jl. Diponegoro No. 21, Semarang',      'DOKTER',   'AKTIF'),
(7,  'dokter06',  'b3959dee9b178b030c2b8373da55a04ab3adb318edeb178953ff8b77301a360a', 'Lina Hartati',        'lina.hartati@sehatsentosa.id', '081211110006', 'Jl. Rajawali No. 7, Malang',           'DOKTER',   'AKTIF'),
(8,  'dokter07',  'b3959dee9b178b030c2b8373da55a04ab3adb318edeb178953ff8b77301a360a', 'Dimas Wibowo',        'dimas.wibowo@sehatsentosa.id', '081211110007', 'Jl. Pahlawan No. 15, Bekasi',          'DOKTER',   'AKTIF'),
(9,  'dokter08',  'b3959dee9b178b030c2b8373da55a04ab3adb318edeb178953ff8b77301a360a', 'Sari Nurhaliza',      'sari.nurhaliza@sehatsentosa.id','081211110008','Jl. Dharmawangsa No. 2, Denpasar',     'DOKTER',   'AKTIF'),
(10, 'dokter09',  'b3959dee9b178b030c2b8373da55a04ab3adb318edeb178953ff8b77301a360a', 'Rizal Firmansyah',    'rizal.firmansyah@sehatsentosa.id','081211110009','Jl. Sudirman No. 44, Medan',        'DOKTER',   'AKTIF'),
(11, 'dokter10',  'b3959dee9b178b030c2b8373da55a04ab3adb318edeb178953ff8b77301a360a', 'Fitria Handayani',    'fitria.handayani@sehatsentosa.id','081211110010','Jl. Gajah Mada No. 9, Palembang',   'DOKTER',   'AKTIF'),
(12, 'perawat01', 'f44dcd1a0fb5c13451ebf183c7833c9d881865469c4ebb33c4e247e777a63db3', 'Nur Aisyah',          'nur.aisyah@sehatsentosa.id',   '081322220001', 'Jl. Melur No. 4, Jakarta',             'PERAWAT',  'AKTIF'),
(13, 'perawat02', 'f44dcd1a0fb5c13451ebf183c7833c9d881865469c4ebb33c4e247e777a63db3', 'Wulan Sari',          'wulan.sari@sehatsentosa.id',   '081322220002', 'Jl. Flamboyan No. 11, Bandung',        'PERAWAT',  'AKTIF'),
(14, 'perawat03', 'f44dcd1a0fb5c13451ebf183c7833c9d881865469c4ebb33c4e247e777a63db3', 'Rudi Santoso',        'rudi.santoso@sehatsentosa.id', '081322220003', 'Jl. Kamboja No. 6, Yogyakarta',        'PERAWAT',  'AKTIF'),
(15, 'perawat04', 'f44dcd1a0fb5c13451ebf183c7833c9d881865469c4ebb33c4e247e777a63db3', 'Hasan Basri',         'hasan.basri@sehatsentosa.id',  '081322220004', 'Jl. Teratai No. 18, Surabaya',         'PERAWAT',  'AKTIF'),
(16, 'perawat05', 'f44dcd1a0fb5c13451ebf183c7833c9d881865469c4ebb33c4e247e777a63db3', 'Intan Permata',       'intan.permata@sehatsentosa.id','081322220005', 'Jl. Bougenville No. 2, Semarang',      'PERAWAT',  'AKTIF'),
(17, 'perawat06', 'f44dcd1a0fb5c13451ebf183c7833c9d881865469c4ebb33c4e247e777a63db3', 'Joko Susilo',         'joko.susilo@sehatsentosa.id',  '081322220006', 'Jl. Dahlia No. 13, Malang',            'PERAWAT',  'AKTIF'),
(18, 'perawat07', 'f44dcd1a0fb5c13451ebf183c7833c9d881865469c4ebb33c4e247e777a63db3', 'Kartika Dewi',        'kartika.dewi@sehatsentosa.id', '081322220007', 'Jl. Kemuning No. 7, Bekasi',           'PERAWAT',  'AKTIF'),
(19, 'perawat08', 'f44dcd1a0fb5c13451ebf183c7833c9d881865469c4ebb33c4e247e777a63db3', 'Lukman Hakim',        'lukman.hakim@sehatsentosa.id', '081322220008', 'Jl. Cempaka No. 20, Denpasar',         'PERAWAT',  'AKTIF'),
(20, 'perawat09', 'f44dcd1a0fb5c13451ebf183c7833c9d881865469c4ebb33c4e247e777a63db3', 'Mira Andayani',       'mira.andayani@sehatsentosa.id','081322220009', 'Jl. Palma No. 5, Medan',              'PERAWAT',  'AKTIF'),
(21, 'perawat10', 'f44dcd1a0fb5c13451ebf183c7833c9d881865469c4ebb33c4e247e777a63db3', 'Nanda Saputra',       'nanda.saputra@sehatsentosa.id','081322220010', 'Jl. Sakura No. 17, Palembang',        'PERAWAT',  'AKTIF'),
(22, 'petugas01', '2dad904f71aa0dcf6ea1addaa084a5865ffe448e4d3f900668e1cc7e7b6153d7', 'Bagus Setiawan',      'bagus.setiawan@sehatsentosa.id','081433330001','Jl. Hayam Wuruk No. 30, Jakarta',    'PETUGAS',  'AKTIF'),
(23, 'pasien01',  'b3cb1bf1350e826eafc2250c570837e1ef1a0e8d6fece2c3478740670ce8fed1', 'Budi Santoso',        'budi.santoso@mail.id',        '081544440001', 'Jl. Kembang No. 3, Jakarta',           'PASIEN',   'AKTIF'),
(24, 'pasien02',  'b3cb1bf1350e826eafc2250c570837e1ef1a0e8d6fece2c3478740670ce8fed1', 'Siti Aminah',         'siti.aminah@mail.id',         '081544440002', 'Jl. Mawar No. 9, Bandung',             'PASIEN',   'AKTIF'),
(25, 'pasien03',  'b3cb1bf1350e826eafc2250c570837e1ef1a0e8d6fece2c3478740670ce8fed1', 'Dewi Lestari',        'dewi.lestari@mail.id',        '081544440003', 'Jl. Melati No. 21, Surabaya',          'PASIEN',   'AKTIF'),
(26, 'pasien04',  'b3cb1bf1350e826eafc2250c570837e1ef1a0e8d6fece2c3478740670ce8fed1', 'Hendra Gunawan',      'hendra.gunawan@mail.id',      '081544440004', 'Jl. Kenanga No. 8, Bekasi',            'PASIEN',   'AKTIF'),
(27, 'pasien05',  'b3cb1bf1350e826eafc2250c570837e1ef1a0e8d6fece2c3478740670ce8fed1', 'Maya Putri',          'maya.putri@mail.id',          '081544440005', 'Jl. Pandan No. 2, Denpasar',           'PASIEN',   'AKTIF');

-- --------------------------------------------------------------------------
-- B. Penyakit (10 baris)
-- --------------------------------------------------------------------------
INSERT INTO penyakit (id_penyakit, kode_penyakit, nama_penyakit, jenis_penyakit, gejala, penyebab, tingkat_keparahan, penanganan, obat_utama, keterangan) VALUES
(1,  'P-001', 'Demam Berdarah Dengue', 'Infeksi',        'Demam tinggi mendadak, nyeri otot, muncul bintik merah pada kulit', 'Gigitan nyamuk Aedes aegypti', 'BERAT',    'Pemberian cairan intravena dan pemantauan trombosit', 'Parasetamol, cairan elektrolit', 'Wajib kontrol trombosit setiap hari'),
(2,  'P-002', 'Hipertensi',            'Kardiovaskular', 'Sakit kepala, pusing, telinga berdengung', 'Pola makan tinggi garam, stres, riwayat keluarga', 'SEDANG', 'Perubahan pola hidup dan terapi antihipertensi', 'Amlodipine, Lisinopril',         'Kontrol tekanan darah secara rutin'),
(3,  'P-003', 'Diabetes Melitus Tipe 2','Metabolik',     'Sering haus, sering kencing, luka sulit sembuh', 'Resistensi insulin dan faktor genetik', 'SEDANG', 'Diet terkontrol, olahraga, dan terapi hipoglikemik', 'Metformin',                      'Cek gula darah puasa secara berkala'),
(4,  'P-004', 'Asma Bronkial',         'Pernapasan',     'Sesak napas, mengi, batuk berdahak', 'Alergen, infeksi saluran napas, udara dingin', 'SEDANG', 'Terapi inhalasi dan penghindaran pemicu', 'Salbutamol, budesonide',          'Selalu bawa inhaler ke mana saja'),
(5,  'P-005', 'Gastritis',             'Pencernaan',     'Nyeri ulu hati, mual, kembung', 'Pola makan tidak teratur, konsumsi obat NSAID, infeksi H. pylori', 'RINGAN', 'Pola makan teratur dan terapi penurun asam lambung', 'Antasida, Omeprazole',           'Hindari makanan pedas dan berlemak'),
(6,  'P-006', 'Demam Tifoid',          'Infeksi',        'Demam bertahap, sakit perut, nafsu makan menurun', 'Bakteri Salmonella typhi melalui makanan terkontaminasi', 'BERAT', 'Pemberian antibiotik dan cairan tubuh', 'Azithromycin, Ceftriaxone',       'Pastikan makanan matang dan air bersih'),
(7,  'P-007', 'Pneumonia',             'Pernapasan',     'Batuk berdahak, demam, sesak napas', 'Infeksi bakteri atau virus pada paru-paru', 'KRITIS', 'Terapi antibiotik dan oksigen', 'Amoxicillin, Oksigen nasal kanal', 'Perlu observasi saturasi oksigen'),
(8,  'P-008', 'Gagal Ginjal Kronis',   'Ginjal',         'Pembengkakan kaki, lelah, penurunan produksi urine', 'Hipertensi dan diabetes yang tidak terkontrol', 'KRITIS', 'Dialisis dan pembatasan cairan', 'Eritropoietin, keto analog',       'Kadar kreatinin dipantau rutin'),
(9,  'P-009', 'Stroke Iskemik',        'Neurologi',      'Kelemahan satu sisi tubuh, bicara pelo, miring mulut', 'Penyumbatan pembuluh darah otak', 'KRITIS', 'Trombolisis dan rehabilitasi', 'Aspirin, Atorvastatin',           'Penanganan dalam 3 jam pertama'),
(10, 'P-010', 'Katarak',               'Mata',           'Penglihatan kabur, silau saat cahaya', 'Penuaan dan paparan sinar UV berlebih', 'RINGAN', 'Tindakan bedak katarak', 'Tetes mata, vitamin mata',         'Operasi katarak bersifat tindakan umum');

-- --------------------------------------------------------------------------
-- C. Dokter (10 baris, seluruhnya terhubung ke akun pengguna)
-- --------------------------------------------------------------------------
INSERT INTO dokter (id_dokter, id_pengguna, nip, nama_dokter, jenis_kelamin, tempat_lahir, tanggal_lahir, spesialisasi, alamat, no_telepon, email, jadwal_praktik, status) VALUES
(1,  2,  '198503122015031001', 'Andi Pratama',     'Laki-laki', 'Jakarta',   '1985-03-12', 'Penyakit Dalam',   'Jl. Kenanga No. 12, Jakarta',    '081211110001', 'andi.pratama@sehatsentosa.id',   'Senin - Jumat, 08.00 - 14.00', 'AKTIF'),
(2,  3,  '198711052016041002', 'Rina Kusuma',      'Perempuan', 'Bandung',   '1987-11-05', 'Poli Anak',        'Jl. Melati No. 5, Bandung',       '081211110002', 'rina.kusuma@sehatsentosa.id',    'Senin - Sabtu, 09.00 - 15.00',  'AKTIF'),
(3,  4,  '198307222014021003', 'Bambang Sutopo',   'Laki-laki', 'Yogyakarta','1983-07-22', 'Bedah Umum',       'Jl. Anggrek No. 8, Yogyakarta',   '081211110003', 'bambang.sutopo@sehatsentosa.id', 'Selasa - Jumat, 08.00 - 13.00', 'AKTIF'),
(4,  5,  '198902182017011004', 'Maya Anggraini',   'Perempuan', 'Surabaya',  '1989-02-18', 'Kandungan',        'Jl. Cendana No. 3, Surabaya',     '081211110004', 'maya.anggraini@sehatsentosa.id', 'Senin - Kamis, 10.00 - 16.00',  'AKTIF'),
(5,  6,  '198410092015081005', 'Yusuf Hakim',      'Laki-laki', 'Semarang',  '1984-10-09', 'Jantung',          'Jl. Diponegoro No. 21, Semarang', '081211110005', 'yusuf.hakim@sehatsentosa.id',    'Rabu - Minggu, 08.00 - 14.00',  'AKTIF'),
(6,  7,  '199012242018031006', 'Lina Hartati',     'Perempuan', 'Malang',    '1990-12-24', 'Kulit dan Kelamin','Jl. Rajawali No. 7, Malang',      '081211110006', 'lina.hartati@sehatsentosa.id',   'Senin - Jumat, 13.00 - 18.00',  'AKTIF'),
(7,  8,  '198605302016071007', 'Dimas Wibowo',     'Laki-laki', 'Bekasi',    '1986-05-30', 'THT',              'Jl. Pahlawan No. 15, Bekasi', '081211110007', 'dimas.wibowo@sehatsentosa.id', 'Selasa - Sabtu, 09.00 - 14.00', 'AKTIF'),
(8,  9,  '198809172019011008', 'Sari Nurhaliza',   'Perempuan', 'Denpasar',  '1988-09-17', 'Paru',             'Jl. Dharmawangsa No. 2, Denpasar','081211110008', 'sari.nurhaliza@sehatsentosa.id', 'Senin - Jumat, 08.00 - 12.00',  'AKTIF'),
(9,  10, '198212032013111009', 'Rizal Firmansyah', 'Laki-laki', 'Medan',     '1982-12-03', 'Saraf',            'Jl. Sudirman No. 44, Medan',      '081211110009', 'rizal.firmansyah@sehatsentosa.id','Rabu - Minggu, 10.00 - 15.00', 'AKTIF'),
(10, 11, '199106112020021010', 'Fitria Handayani', 'Perempuan', 'Palembang', '1991-06-11', 'Mata',             'Jl. Gajah Mada No. 9, Palembang', '081211110010', 'fitria.handayani@sehatsentosa.id','Senin - Sabtu, 09.00 - 13.00', 'AKTIF');

-- --------------------------------------------------------------------------
-- D. Perawat (10 baris, seluruhnya terhubung ke akun pengguna)
-- --------------------------------------------------------------------------
INSERT INTO perawat (id_perawat, id_pengguna, nip, nama_perawat, jenis_kelamin, tempat_lahir, tanggal_lahir, pendidikan, alamat, no_telepon, shift, ruangan, status) VALUES
(1,  12, '199204152017032001', 'Nur Aisyah',   'Perempuan', 'Jakarta',   '1992-04-15', 'D3 Keperawatan',   'Jl. Melur No. 4, Jakarta',     '081322220001', 'Pagi',  'Ruang Kelas I',   'AKTIF'),
(2,  13, '199509282019042002', 'Wulan Sari',   'Perempuan', 'Bandung',   '1995-09-28', 'S1 Keperawatan',   'Jl. Flamboyan No. 11, Bandung','081322220002', 'Siang', 'Ruang Kelas II',  'AKTIF'),
(3,  14, '199001122016052003', 'Rudi Santoso', 'Laki-laki', 'Yogyakarta','1990-01-12', 'D3 Keperawatan',   'Jl. Kamboja No. 6, Yogyakarta','081322220003', 'Malam', 'Ruang ICU',       'AKTIF'),
(4,  15, '199312052018062004', 'Hasan Basri',  'Laki-laki', 'Surabaya',  '1993-12-05', 'D3 Keperawatan',   'Jl. Teratai No. 18, Surabaya','081322220004', 'Pagi',  'Ruang Anak',      'AKTIF'),
(5,  16, '199707192020072005', 'Intan Permata','Perempuan', 'Semarang',  '1997-07-19', 'S1 Keperawatan',   'Jl. Bougenville No. 2, Semarang','081322220005','Pagi', 'Ruang Kelas III', 'AKTIF'),
(6,  17, '198903232015082006', 'Joko Susilo',  'Laki-laki', 'Malang',    '1989-03-23', 'D3 Keperawatan',   'Jl. Dahlia No. 13, Malang',    '081322220006', 'Siang', 'Ruang Isolasi',   'AKTIF'),
(7,  18, '199611022019092007', 'Kartika Dewi', 'Perempuan', 'Bekasi',    '1996-11-02', 'D3 Keperawatan',   'Jl. Kemuning No. 7, Bekasi',   '081322220007', 'Malam', 'Ruang Kelas I',   'AKTIF'),
(8,  19, '199108252017102008', 'Lukman Hakim', 'Laki-laki', 'Denpasar',  '1991-08-25', 'S1 Keperawatan',   'Jl. Cempaka No. 20, Denpasar', '081322220008', 'Pagi',  'Ruang ICU',       'AKTIF'),
(9,  20, '199802142021012009', 'Mira Andayani','Perempuan', 'Medan',     '1998-02-14', 'D3 Keperawatan',   'Jl. Palma No. 5, Medan',       '081322220009', 'Siang', 'Ruang Kelas II',  'AKTIF'),
(10, 21, '199406302018112010', 'Nanda Saputra','Laki-laki', 'Palembang', '1994-06-30', 'D3 Keperawatan',   'Jl. Sakura No. 17, Palembang', '081322220010', 'Malam', 'Ruang Kelas III', 'AKTIF');

-- --------------------------------------------------------------------------
-- E. Ruangan (10 baris)
--    jumlah_terisi disesuaikan dengan jumlah rawat inap berstatus DIRAWAT
-- --------------------------------------------------------------------------
INSERT INTO ruangan (id_ruangan, nama_ruangan, jenis_ruangan, nomor_kamar, lantai, kapasitas, jumlah_terisi, tarif_per_hari, fasilitas, status_ruangan) VALUES
(1,  'Ruang Anggrek',   'Kelas I',   'A-01', 1, 4, 2, 500000, 'AC, TV, Kamar mandi dalam, Sofa penunggu', 'TERISI'),
(2,  'Ruang Melati',    'Kelas II',  'A-02', 1, 6, 2, 350000, 'AC, Kipas angin, Kamar mandi dalam',       'TERISI'),
(3,  'Ruang Cempaka',   'Kelas III', 'B-01', 2, 8, 2, 250000, 'Kipas angin, Kamar mandi bersama',         'TERISI'),
(4,  'Ruang ICU Utama', 'ICU',       'ICU-01',3, 4, 2, 900000, 'Monitor pasien, Ventilator, Infusion pump','TERISI'),
(5,  'Ruang Kenanga Anak','Anak',    'C-01', 2, 6, 1, 300000, 'AC, Mainan edukatif, Kamar mandi dalam',   'TERISI'),
(6,  'Ruang Isolasi',   'Isolasi',   'D-01', 3, 4, 1, 400000, 'HEPA filter, AC, Kamar mandi khusus',      'TERISI'),
(7,  'Ruang Flamboyan', 'Kelas I',   'A-03', 1, 4, 0, 500000, 'AC, TV, Kamar mandi dalam, Balkon',        'TERSEDIA'),
(8,  'Ruang Dahlia',    'Kelas II',  'B-02', 2, 6, 0, 350000, 'AC, Kipas angin, Kamar mandi dalam',       'TERSEDIA'),
(9,  'Ruang ICU Cadangan','ICU',     'ICU-02',3, 4, 0, 900000, 'Monitor pasien, Ventilator, Defibrilator','TERSEDIA'),
(10, 'Ruang Bougenville','Kelas III','B-03', 2, 8, 0, 250000, 'Kipas angin, Lemari pasien, Ruang tunggu', 'PERAWATAN');

-- --------------------------------------------------------------------------
-- F. Pasien (20 baris, 5 di antaranya memiliki akun login)
-- --------------------------------------------------------------------------
INSERT INTO pasien (id_pasien, id_pengguna, nik, nama_pasien, jenis_kelamin, tempat_lahir, tanggal_lahir, alamat, no_telepon, golongan_darah, id_penyakit, id_dokter, tanggal_masuk, tanggal_keluar, status_pasien) VALUES
(1,  23, '3171011203850001', 'Budi Santoso',   'Laki-laki', 'Jakarta',   '1985-03-12', 'Jl. Kembang No. 3, Jakarta',      '081544440001', 'O',  1,  1,  DATE_SUB(CURDATE(), INTERVAL 2 DAY),  NULL,              'DIRAWAT'),
(2,  24, '3273012307900002', 'Siti Aminah',    'Perempuan', 'Bandung',   '1990-07-23', 'Jl. Mawar No. 9, Bandung',        '081544440002', 'A',  2,  2,  DATE_SUB(CURDATE(), INTERVAL 1 DAY),  NULL,              'DIRAWAT'),
(3,  NULL,'3471010211780003', 'Agus Wijaya',   'Laki-laki', 'Yogyakarta','1978-11-02', 'Jl. Prawirotaman No. 4, Yogyakarta','081544440003','B', 6,  3,  CURDATE(),                             NULL,              'RAWAT JALAN'),
(4,  25, '3578011701950004', 'Dewi Lestari',   'Perempuan', 'Surabaya',  '1995-01-17', 'Jl. Melati No. 21, Surabaya',     '081544440003', 'AB', 4,  4,  DATE_SUB(CURDATE(), INTERVAL 3 DAY),  NULL,              'DIRAWAT'),
(5,  NULL,'3374013009680005', 'Joko Prasetyo', 'Laki-laki', 'Semarang',  '1968-09-30', 'Jl. Pandanaran No. 10, Semarang', '081544440005', 'O',  3,  5,  DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'PULANG'),
(6,  NULL,'3579010805010006', 'Rina Kartika',  'Perempuan', 'Malang',    '2001-05-08', 'Jl. Ijen No. 25, Malang',         '081544440006', 'A',  6,  6,  CURDATE(),                             NULL,              'RAWAT JALAN'),
(7,  26, '3276012512820007', 'Hendra Gunawan','Laki-laki', 'Bekasi',    '1982-12-25', 'Jl. Kenanga No. 8, Bekasi',       '081544440004', 'B',  7,  7,  DATE_SUB(CURDATE(), INTERVAL 4 DAY),  NULL,              'DIRAWAT'),
(8,  27, '5171011404930008', 'Maya Putri',     'Perempuan', 'Denpasar',  '1993-04-14', 'Jl. Pandan No. 2, Denpasar',      '081544440005', 'O',  4,  8,  DATE_SUB(CURDATE(), INTERVAL 1 DAY),  NULL,              'DIRAWAT'),
(9,  NULL,'3372012106590009', 'Slamet Riyadi', 'Laki-laki', 'Solo',      '1959-06-21', 'Jl. Slamet Riyadi No. 55, Solo',  '081544440009', 'A',  9,  9,  DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_SUB(CURDATE(), INTERVAL 12 DAY), 'PULANG'),
(10, NULL,'7371010508980010', 'Fitriani',      'Perempuan', 'Makassar',  '1998-08-05', 'Jl. Pettarani No. 12, Makassar',  '081544440010', 'B',  10, 10, CURDATE(),                             NULL,              'RAWAT JALAN'),
(11, NULL,'3271011902880011', 'Rudi Hartono',  'Laki-laki', 'Bogor',     '1988-02-19', 'Jl. Pajajaran No. 7, Bogor',      '081544440011', 'O',  5,  2,  DATE_SUB(CURDATE(), INTERVAL 2 DAY),  NULL,              'DIRAWAT'),
(12, NULL,'3275011110960012', 'Anisa Rahmawati','Perempuan','Depok',     '1996-10-11', 'Jl. Margonda Raya No. 30, Depok', '081544440012', 'A',  6,  3,  DATE_SUB(CURDATE(), INTERVAL 5 DAY),  NULL,              'DIRAWAT'),
(13, NULL,'3671010303750013', 'Bayu Nugroho',  'Laki-laki', 'Tangerang', '1975-03-03', 'Jl. BSD Raya No. 3, Tangerang',   '081544440013', 'AB', 3,  4,  DATE_SUB(CURDATE(), INTERVAL 1 DAY),  NULL,              'RAWAT JALAN'),
(14, NULL,'1671010912920014', 'Citra Maharani','Perempuan', 'Palembang', '1992-12-09', 'Jl. Sudirman No. 88, Palembang',  '081544440014', 'O',  2,  5,  DATE_SUB(CURDATE(), INTERVAL 6 DAY),  NULL,              'DIRAWAT'),
(15, NULL,'1271012707840015', 'Doni Kurniawan','Laki-laki', 'Medan',     '1984-07-27', 'Jl. Gatot Subroto No. 41, Medan', '081544440015', 'B',  5,  6,  DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL 14 DAY), 'PULANG'),
(16, NULL,'3374011609990016', 'Eka Wulandari', 'Perempuan', 'Semarang',  '1999-09-16', 'Jl. Ahmad Yani No. 19, Semarang', '081544440016', 'A',  6,  7,  CURDATE(),                             NULL,              'RAWAT JALAN'),
(17, NULL,'1371012901710017', 'Farhan Abdul',  'Laki-laki', 'Padang',    '1971-01-29', 'Jl. Khatib Sulaiman No. 9, Padang','081544440017','O', 9,  8,  DATE_SUB(CURDATE(), INTERVAL 3 DAY),  NULL,              'DIRAWAT'),
(18, NULL,'2171010611030018', 'Gita Permata',  'Perempuan', 'Batam',     '2003-11-06', 'Jl. Imam Bonjol No. 60, Batam',   '081544440018', 'AB', 8,  9,  DATE_SUB(CURDATE(), INTERVAL 1 DAY),  NULL,              'DIRAWAT'),
(19, NULL,'3471012205650019', 'Hadi Sucipto',  'Laki-laki', 'Yogyakarta','1965-05-22', 'Jl. Kaliurang KM 5, Yogyakarta',  '081544440019', 'A',  10, 10, DATE_SUB(CURDATE(), INTERVAL 25 DAY), DATE_SUB(CURDATE(), INTERVAL 18 DAY), 'PULANG'),
(20, NULL,'3578013008910020', 'Indah Sari',    'Perempuan', 'Surabaya',  '1991-08-30', 'Jl. Rungkut Asri No. 2, Surabaya','081544440020', 'B',  5,  1,  DATE_SUB(CURDATE(), INTERVAL 2 DAY),  NULL,              'RAWAT JALAN');

-- --------------------------------------------------------------------------
-- G. Rawat inap (15 baris)
--    Baris berstatus DIRAWAT sesuai dengan jumlah_terisi tiap ruangan
-- --------------------------------------------------------------------------
INSERT INTO rawat_inap (id_rawat_inap, id_pasien, id_dokter, id_ruangan, nomor_kamar, diagnosa, keluhan, tanggal_masuk, tanggal_keluar, lama_rawat, status_rawat) VALUES
(1,  1,  1, 1, 'A-01',   'Demam Berdarah Dengue',      'Demam tinggi sejak tiga hari, nyeri otot',        DATE_SUB(CURDATE(), INTERVAL 2 DAY),  NULL, 2, 'DIRAWAT'),
(2,  2,  2, 2, 'A-02',   'Hipertensi grade II',        'Sakit kepala berulang dan telinga berdengung',    DATE_SUB(CURDATE(), INTERVAL 1 DAY),  NULL, 1, 'DIRAWAT'),
(3,  4,  4, 3, 'B-01',   'Preeklampsia berat',         'Nyeri perut bawah dan pembengkakan kaki',         DATE_SUB(CURDATE(), INTERVAL 3 DAY),  NULL, 3, 'DIRAWAT'),
(4,  7,  7, 4, 'ICU-01', 'Pneumonia berat',            'Sesak napas menetap dan batuk berdahak',           DATE_SUB(CURDATE(), INTERVAL 4 DAY),  NULL, 4, 'DIRAWAT'),
(5,  8,  8, 5, 'C-01',   'Asma bronkial eksaserbasi',  'Mengi berulang terutama malam hari',               DATE_SUB(CURDATE(), INTERVAL 1 DAY),  NULL, 1, 'DIRAWAT'),
(6,  11, 2, 1, 'A-01',   'Gastritis erosi antrum',     'Nyeri ulu hati setelah makan',                     DATE_SUB(CURDATE(), INTERVAL 2 DAY),  NULL, 2, 'DIRAWAT'),
(7,  12, 3, 2, 'A-02',   'Demam tifoid',               'Demam berhari-hari disertai lemas',                DATE_SUB(CURDATE(), INTERVAL 5 DAY),  NULL, 5, 'DIRAWAT'),
(8,  14, 5, 3, 'B-01',   'Gagal jantung kongestif',    'Sesak saat beraktivitas dan kaki bengkak',         DATE_SUB(CURDATE(), INTERVAL 6 DAY),  NULL, 6, 'DIRAWAT'),
(9,  17, 9, 4, 'ICU-01', 'Stroke iskemik akut',        'Kelemahan anggota badan sisi kanan',               DATE_SUB(CURDATE(), INTERVAL 3 DAY),  NULL, 3, 'DIRAWAT'),
(10, 18, 10,6, 'D-01',   'Gagal ginjal kronis stadio 4','Kadar kreatinin meningkat dan pipih berat',       DATE_SUB(CURDATE(), INTERVAL 1 DAY),  NULL, 1, 'DIRAWAT'),
(11, 5,  5, 7, 'A-03',   'Diabetes melitus tipe 2',    'Luka pada kaki sulit sembuh',                      DATE_SUB(CURDATE(), INTERVAL 10 DAY), DATE_SUB(CURDATE(), INTERVAL 6 DAY),  4, 'DIPULANGKAN'),
(12, 9,  9, 8, 'B-02',   'Stroke hemoragik ringan',    'Pusing dan bicara sedikit pelo',                   DATE_SUB(CURDATE(), INTERVAL 15 DAY), DATE_SUB(CURDATE(), INTERVAL 12 DAY), 3, 'DIPULANGKAN'),
(13, 15, 6, 9, 'ICU-02', 'Dermatitis kontak berat',    'Ruam merah menyebar ke seluruh tubuh',             DATE_SUB(CURDATE(), INTERVAL 20 DAY), DATE_SUB(CURDATE(), INTERVAL 14 DAY), 6, 'DIPULANGKAN'),
(14, 19, 10,6, 'D-01',   'Katarak komplikasi',         'Penglihatan menurun drastis',                      DATE_SUB(CURDATE(), INTERVAL 25 DAY), DATE_SUB(CURDATE(), INTERVAL 18 DAY), 7, 'DIPULANGKAN'),
(15, 3,  3, 7, 'A-03',   'Demam tifoid suspek',        'Demam disertai nyeri perut ringan',                CURDATE(),                          NULL, 0, 'MENUNGGU');

-- --------------------------------------------------------------------------
-- H. Pemeriksaan (12 baris)
-- --------------------------------------------------------------------------
INSERT INTO pemeriksaan (id_pemeriksaan, id_pasien, id_dokter, tanggal_pemeriksaan, keluhan, tekanan_darah, suhu, berat_badan, diagnosa, tindakan, catatan) VALUES
(1,  1,  1,  DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Demam dan nyeri otot',            '110/70', 38.5, 68.0, 'Demam berdarah dengue',      'Pemberian cairan intravena',       'Pantau trombosit setiap hari'),
(2,  3,  3,  CURDATE(),                           'Demam dan nyeri perut',           '120/80', 38.2, 74.5, 'Demam tifoid suspek',        'Antipiretik dan diet lunak',       'Kontrol tiga hari lagi'),
(3,  2,  2,  DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Sakit kepala bagian belakang',    '160/95', 36.8, 62.0, 'Hipertensi grade II',        'Terapi antihipertensi oral',       'Kontrol tekanan darah dua kali sehari'),
(4,  6,  6,  CURDATE(),                           'Ruam merah pada lengan',          '118/76', 36.9, 55.5, 'Dermatitis alergi',          'Salep kortikosteroid topikal',     'Hindari pencetus alergi'),
(5,  4,  4,  DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'Nyeri perut bawah',               '145/92', 37.1, 70.0, 'Preeklampsia berat',         'Observasi ketat dan magnesium sulfat','Pantau tekanan darah tiap empat jam'),
(6,  10, 10, CURDATE(),                           'Pandangan kabur saat membaca',    '125/80', 36.7, 58.0, 'Katarak stadium dewasa',     'Rencana tindakan bedah katarak',    'Jadwalkan operasi minggu depan'),
(7,  7,  7,  DATE_SUB(CURDATE(), INTERVAL 4 DAY), 'Sesak napas dan batuk berdahak',  '130/85', 38.9, 77.0, 'Pneumonia',                  'Antibiotik dan oksigen',            'Evaluasi saturasi oksigen tiap jam'),
(8,  13, 4,  DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Nyeri punggung bawah',            '128/82', 36.6, 81.0, 'Nyeri punggung non spesifik','Analgesik dan fisioterapi',         'Hindari mengangkat beban berat'),
(9,  16, 7,  CURDATE(),                           'Gatal pada leher dan dada',        '122/78', 36.8, 52.0, 'Dermatitis seboroik',        'Sampo antijamur mingguan',         'Kontrol dua minggu lagi'),
(10, 8,  8,  DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Mengi dan sesak napas ringan',     '118/74', 37.0, 49.5, 'Asma bronkial',              'Inhaler dan bronkodilator',         'Gunakan inhaler secara teratur'),
(11, 20, 1,  CURDATE(),                           'Nyeri ulu hati setelah makan',     '135/88', 36.9, 66.0, 'Gastritis',                  'Antasida dan perbaikan pola makan', 'Hindari makanan pedas dan asam'),
(12, 12, 3,  DATE_SUB(CURDATE(), INTERVAL 5 DAY), 'Demam tinggi dan lemas',           '115/72', 39.0, 60.5, 'Demam tifoid',               'Cairan intravena dan antibiotik',   'Pantau suhu setiap enam jam');

-- --------------------------------------------------------------------------
-- I. Catatan perawatan (12 baris)
-- --------------------------------------------------------------------------
INSERT INTO catatan_perawatan (id_catatan, id_pasien, id_perawat, tanggal, kondisi_pasien, catatan, tindakan, status) VALUES
(1,  1,  1,  CURDATE(),                           'Kesadaran compos mentis, demam menurun menjadi 38 derajat', 'Memantau tanda perdarahan setiap empat jam',            'Pemberian cairan intravena',            'BAIK'),
(2,  2,  2,  CURDATE(),                           'Tekanan darah masih fluktuatif, pasien mengeluh pusing',   'Istirahat cukup dan pembatasan asupan garam',           'Pengukuran tekanan darah dua kali sehari','SEDANG'),
(3,  4,  5,  DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Nyeri perut sedang dengan tekanan darah terus naik',       'Posisi miring ke kiri dan pantau gerakan janin',         'Pemasangan infus dan monitor janin',    'KRITIS'),
(4,  7,  4,  DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Sesak napas sedang saat berbaring, saturasi oksigen 94%',  'Elevasi kepala 45 derajat dan monitor saturasi',         'Pemberian oksigen empat liter per menit','SEDANG'),
(5,  8,  3,  CURDATE(),                           'Mengi berkurang setelah terapi inhalasi',                  'Pantau frekuensi napas setiap dua jam',                  'Terapi inhalasi rutin',                'BAIK'),
(6,  11, 6,  DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Nyeri perut berkurang setelah pemberian antasida',         'Pemberian makanan lunak bertahap tiga kali sehari',      'Pemberian antasida sesuai jadwal',     'BAIK'),
(7,  12, 7,  DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Demam masih tinggi disertai badan lemas',                  'Kompres dahi dan tambah asupan cairan oral',             'Pemberian antipiretik tiap enam jam',  'SEDANG'),
(8,  14, 8,  DATE_SUB(CURDATE(), INTERVAL 2 DAY), 'Sesak napas berat saat beraktivitas ringan',               'Posisi duduk dan batasi aktivitas fisik',                'Monitor denyut jantung setiap jam',    'KRITIS'),
(9,  17, 9,  DATE_SUB(CURDATE(), INTERVAL 3 DAY), 'Kelemahan sisi kanan, kesadaran baik',                     'Latihan rentang gerak pasif dan pencegahan dekubitus',   'Fisioterapi dan mobilisasi dini',      'SEDANG'),
(10, 18, 10, DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Pembengkakan pada kedua kaki dan urine berkurang',         'Pantau berat badan serta volume urine harian',           'Pembatasan cairan dan pemberian obat', 'SEDANG'),
(11, 3,  1,  CURDATE(),                           'Demam menurun setelah pemberian antipiretik',              'Pantau suhu tubuh setiap enam jam',                      'Pemberian antipiretik',               'BAIK'),
(12, 5,  2,  DATE_SUB(CURDATE(), INTERVAL 6 DAY), 'Luka pada kaki mulai menutup sebelum pulang',              'Edukasi perawatan luka mandiri di rumah',                'Perawatan luka dan kontrol gula darah','BAIK');

-- --------------------------------------------------------------------------
-- J. Pembayaran (12 baris)
--    total_biaya = biaya_kamar + biaya_dokter + biaya_obat + biaya_tindakan + biaya_lain
-- --------------------------------------------------------------------------
INSERT INTO pembayaran (id_pembayaran, id_pasien, id_rawat_inap, biaya_kamar, biaya_dokter, biaya_obat, biaya_tindakan, biaya_lain, total_biaya, metode_pembayaran, tanggal_pembayaran, status_pembayaran) VALUES
(1,  1,  1,  700000,  450000, 320000, 250000,  50000, 1770000, 'BPJS',           NULL,                                        'MENUNGGU'),
(2,  5,  11, 2000000, 600000, 450000, 300000,  75000, 3425000, 'Tunai',          DATE_SUB(CURDATE(), INTERVAL 6 DAY),         'LUNAS'),
(3,  9,  12, 1050000, 700000, 550000, 400000, 100000, 2800000, 'Transfer Bank',  DATE_SUB(CURDATE(), INTERVAL 12 DAY),        'LUNAS'),
(4,  15, 13, 5400000, 900000, 1250000,1500000, 200000, 9250000, 'Asuransi',       DATE_SUB(CURDATE(), INTERVAL 14 DAY),        'LUNAS'),
(5,  19, 14, 2800000, 1500000,650000, 3500000, 150000, 8600000, 'Kartu Debit',    DATE_SUB(CURDATE(), INTERVAL 18 DAY),        'LUNAS'),
(6,  3,  NULL, 0,     250000, 180000, 0,        25000,  455000, 'Tunai',          CURDATE(),                                   'LUNAS'),
(7,  6,  NULL, 0,     200000, 150000, 0,        25000,  375000, 'QRIS',           CURDATE(),                                   'LUNAS'),
(8,  2,  2,  350000,  400000, 300000, 100000,  50000, 1200000, 'BPJS',           NULL,                                        'BELUM DIBAYAR'),
(9,  4,  3,  750000,  500000, 400000, 600000,  75000, 2325000, 'BPJS',           NULL,                                        'BELUM DIBAYAR'),
(10, 7,  4,  3600000, 800000, 950000, 1200000, 150000, 6700000, 'Asuransi',       NULL,                                        'BELUM DIBAYAR'),
(11, 12, 7,  1750000, 650000, 700000, 300000, 100000, 3500000, 'Transfer Bank',  NULL,                                        'MENUNGGU'),
(12, 8,  5,  300000,  350000, 250000, 150000,  50000, 1100000, 'Tunai',          NULL,                                        'MENUNGGU');

-- ==========================================================================
-- Ringkasan data:
--   pengguna 27 | pasien 20 | dokter 10 | perawat 10 | penyakit 10 | ruangan 10
--   rawat_inap 15 | pemeriksaan 12 | catatan_perawatan 12 | pembayaran 12
-- Akun demo:
--   admin/admin123 | dokter01/dokter123 | perawat01/perawat123
--   petugas01/petugas123 | pasien01/pasien123 (juga pasien02 - pasien05)
-- ==========================================================================
