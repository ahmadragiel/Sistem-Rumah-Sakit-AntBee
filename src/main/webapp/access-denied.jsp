<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Akses Ditolak - RS AntBee</title>
<link rel="stylesheet" href="${ctx}/assets/css/bootstrap.min.css">
<link rel="stylesheet" href="${ctx}/assets/css/bootstrap-icons.min.css">
<link rel="stylesheet" href="${ctx}/assets/css/style.css">
</head>
<body>
<div class="halaman-error">
    <div class="kotak">
        <div class="ikon-besar"><i class="bi bi-shield-exclamation"></i></div>
        <h1>Akses Ditolak</h1>
        <p>Maaf, akun Anda tidak memiliki hak akses untuk membuka halaman tersebut.
            Silakan kembali ke dashboard atau hubungi administrator bila Anda merasa hal ini keliru.</p>
        <c:choose>
            <c:when test="${not empty sessionScope.user}">
                <a href="${ctx}/dashboard" class="btn btn-primary"><i class="bi bi-speedometer2"></i>Kembali ke Dashboard</a>
            </c:when>
            <c:otherwise>
                <a href="${ctx}/login" class="btn btn-primary"><i class="bi bi-box-arrow-in-right"></i>Ke Halaman Login</a>
            </c:otherwise>
        </c:choose>
    </div>
</div>
</body>
</html>
