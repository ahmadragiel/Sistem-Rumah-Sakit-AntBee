<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Beranda - RS AntBee</title>
<link rel="stylesheet" href="${ctx}/assets/css/bootstrap.min.css">
<link rel="stylesheet" href="${ctx}/assets/css/bootstrap-icons.min.css">
<link rel="stylesheet" href="${ctx}/assets/css/style.css">
</head>
<body>

<nav class="beranda-nav">
    <div class="wadah">
        <img class="logo-navbar" src="${ctx}/assets/img/logoo.png" alt="RS AntBee">
        <div>
            <div class="nama">RS AntBee</div>
            <div style="font-size:.76rem;color:var(--teks-redup)">Sistem Informasi Manajemen Rumah Sakit</div>
        </div>
        <div class="ms-auto d-flex gap-2">
            <a href="${ctx}/login" class="btn btn-primary"></i>Masuk</a>
        </div>
    </div>
</nav>

<header class="hero">
    <h1>Sistem Informasi Manajemen Rumah Sakit</h1>
    <p>Aplikasi web untuk mengelola data pasien, dokter, perawat, ruangan, rawat inap, pemeriksaan,
        catatan perawatan, hingga pembayaran dalam satu sistem yang terintegrasi dan mudah digunakan.</p>
    <a href="${ctx}/login" class="btn btn-light btn-lg"></i>Lihat Dashboard</a>
</header>

<section class="beranda-isi">
    <h5 class="fw-bold mb-3">Fitur Utama</h5>
    <div class="beranda-fitur">
        <div class="fitur-kartu">
            <div class="ikon-kotak ikon-biru"><i class="bi bi-shield-lock"></i></div>
            <h6>Login Multi-Role</h6>
            <p>Lima role dengan hak akses berbeda: Admin, Dokter, Perawat, Petugas, dan Pasien.</p>
        </div>
        <div class="fitur-kartu">
            <div class="ikon-kotak ikon-hijau"><i class="bi bi-people"></i></div>
            <h6>Manajemen Data</h6>
            <p>CRUD lengkap untuk pasien, dokter, perawat, penyakit, dan ruangan dengan pencarian serta filter.</p>
        </div>
        <div class="fitur-kartu">
            <div class="ikon-kotak ikon-kuning"><i class="bi bi-hospital"></i></div>
            <h6>Rawat Inap &amp; Pemeriksaan</h6>
            <p>Pengelolaan kamar, status rawat inap, pemeriksaan dokter, dan catatan perawatan perawat.</p>
        </div>
        <div class="fitur-kartu">
            <div class="ikon-kotak ikon-merah"><i class="bi bi-receipt"></i></div>
            <h6>Pembayaran &amp; Laporan</h6>
            <p>Perhitungan total biaya otomatis, bukti pembayaran, dan laporan yang siap dicetak.</p>
        </div>
    </div>

</section>

<footer class="beranda-kaki">
    Sistem Informasi Manajemen Rumah Sakit &copy; 2026 &mdash; Tugas Mata Kuliah Pemrograman 2
</footer>

</body>
</html>
