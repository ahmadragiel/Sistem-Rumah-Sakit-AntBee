<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Notifikasi Saya" scope="request" />
<c:set var="menuAktif" value="notifikasi" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="row g-3 g-xl-4">
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-biru"><i class="bi bi-bell"></i></div>
            <div class="min-w-0">
                <div class="angka">${fn:length(daftarNotifikasi)}</div>
                <div class="keterangan">Jumlah Notifikasi Untuk Anda</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-hijau"><i class="bi bi-person-check"></i></div>
            <div class="min-w-0">
                <div class="angka">${empty pasien.statusPasien ? '-' : pasien.statusPasien}</div>
                <div class="keterangan">Status Anda Saat Ini</div>
            </div>
        </div>
    </div>
</div>

<div class="kartu mt-1">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-bell"></i>Notifikasi Untuk Anda</h2>
            <p class="kartu-sub">Terdapat <strong>${fn:length(daftarNotifikasi)}</strong> notifikasi mengenai jadwal pemeriksaan, rawat inap, dan tagihan Anda.</p>
        </div>
        <a class="btn btn-outline-primary btn-sm" href="${ctx}/saya"><i class="bi bi-arrow-left"></i>Kembali ke Jadwal</a>
    </div>

    <c:choose>
        <c:when test="${empty daftarNotifikasi}">
            <div class="kosong">
                <i class="bi bi-bell-slash"></i>
                <h6>Belum ada notifikasi.</h6>
                <p class="mb-0">Informasi terbaru mengenai layanan Anda akan tampil di sini.</p>
            </div>
        </c:when>
        <c:otherwise>
            <ul class="list-unstyled mb-0">
                <c:forEach items="${daftarNotifikasi}" var="n" varStatus="loop">
                    <li class="py-2 d-flex gap-2 <c:if test="${not loop.last}">border-bottom</c:if>">
                        <i class="bi bi-info-circle-fill text-primary mt-1"></i>
                        <span><c:out value="${n}" /></span>
                    </li>
                </c:forEach>
            </ul>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="/fragments/footer.jspf" %>
