<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Masuk - RS AntBee</title>
<link rel="stylesheet" href="${ctx}/assets/css/bootstrap.min.css">
<link rel="stylesheet" href="${ctx}/assets/css/bootstrap-icons.min.css">
<link rel="stylesheet" href="${ctx}/assets/css/style.css">
</head>
<body>
<div class="halaman-login">

    <div class="login-kiri">
        <div class="d-flex align-items-center gap-3">
            <img class="logo-login" src="${ctx}/assets/img/logoo.png" alt="RS AntBee">
            <div>
                <div class="fw-bold" style="font-size:1.2rem">RS AntBee</div>
                <div style="font-size:.85rem;color:#EBDACB">Sistem Informasi Manajemen Rumah Sakit</div>
            </div>
        </div>
        <h2>Kelola layanan rumah sakit dalam satu sistem</h2>
        <p>Mulai dari registrasi pasien, pemeriksaan dokter, perawatan perawat, sampai pembayaran &mdash;
            semuanya tercatat rapi dan dapat dipantau sesuai hak akses setiap pengguna.</p>
        <div class="fitur-login">
            <span><i class="bi bi-check2 me-1"></i>Dashboard Real-time</span>
            <span><i class="bi bi-check2 me-1"></i>Laporan Siap Cetak</span>
        </div>
    </div>

    <div class="login-kanan">
        <div class="login-kartu">
            <h1>Selamat Datang</h1>
            <p class="sub">Silakan masuk menggunakan akun Anda untuk melanjutkan.</p>

            <c:if test="${not empty sessionScope.pesan}">
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <i class="bi bi-check-circle me-2"></i><c:out value="${sessionScope.pesan}" />
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Tutup"></button>
                </div>
                <c:remove var="pesan" scope="session" />
                <c:remove var="tipePesan" scope="session" />
            </c:if>

            <c:if test="${not empty error}">
                <div class="alert alert-danger" role="alert">
                    <i class="bi bi-exclamation-triangle me-2"></i><c:out value="${error}" />
                </div>
            </c:if>

            <form action="${ctx}/login" method="post" autocomplete="off">
                <div class="mb-3">
                    <label class="form-label" for="username">Username</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white"><i class="bi bi-person"></i></span>
                        <input class="form-control" type="text" id="username" name="username"
                               value="<c:out value='${username}'/>" placeholder="Masukkan username" required autofocus>
                    </div>
                </div>
                <div class="mb-3">
                    <label class="form-label" for="password">Password</label>
                    <div class="input-group">
                        <span class="input-group-text bg-white"><i class="bi bi-lock"></i></span>
                        <input class="form-control" type="password" id="password" name="password"
                               placeholder="Masukkan password" required>
                    </div>
                </div>
                <button type="submit" class="btn btn-primary w-100">
                    Masuk
                </button>
            </form>

           

            <div class="text-center mt-3" style="font-size:.82rem">
                <a href="${ctx}/"><i class="bi bi-arrow-left me-1"></i>Kembali ke beranda</a>
            </div>
        </div>
    </div>

</div>
<script src="${ctx}/assets/js/bootstrap.bundle.min.js"></script>
</body>
</html>
