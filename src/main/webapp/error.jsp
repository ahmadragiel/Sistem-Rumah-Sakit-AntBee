<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Terjadi Kesalahan - RS AntBee</title>
<link rel="stylesheet" href="${ctx}/assets/css/bootstrap.min.css">
<link rel="stylesheet" href="${ctx}/assets/css/bootstrap-icons.min.css">
<link rel="stylesheet" href="${ctx}/assets/css/style.css">
</head>
<body>
<div class="halaman-error">
    <div class="kotak">
        <div class="ikon-besar"><i class="bi bi-exclamation-triangle"></i></div>
        <h1>Terjadi Kesalahan</h1>
        <p>Maaf, terjadi kesalahan saat memproses data. Silakan coba beberapa saat lagi.
            Bila masalah berlanjut, silakan hubungi administrator aplikasi.</p>
        <div class="d-flex gap-2 justify-content-center flex-wrap">
            <a href="${ctx}/dashboard" class="btn btn-primary"><i class="bi bi-speedometer2"></i>Kembali ke Dashboard</a>
            <a href="${ctx}/" class="btn btn-light"><i class="bi bi-house"></i>Beranda</a>
        </div>
    </div>
</div>
</body>
</html>
