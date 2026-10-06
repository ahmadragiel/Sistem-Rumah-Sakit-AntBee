<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Detail Catatan Perawatan" scope="request" />
<c:set var="menuAktif" value="catatan-perawatan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-journal-medical"></i>Catatan Perawatan - <c:out value="${empty data.namaPasien ? '-' : data.namaPasien}" /></h2>
            <p class="kartu-sub">Rincian catatan perawatan pasien pada ${empty data.tanggal ? '-' : data.tanggal}.</p>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-light" href="${ctx}/catatan-perawatan"><i class="bi bi-arrow-left"></i>Kembali</a>
            <c:if test="${user.role eq 'ADMIN' or user.role eq 'PERAWAT'}">
                <a class="btn btn-warning" href="${ctx}/catatan-perawatan?aksi=edit&id=${data.idCatatan}"><i class="bi bi-pencil"></i>Ubah Data</a>
            </c:if>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Informasi Catatan</h6>
            <div class="detail-baris"><span class="label">Nomor Catatan</span><span class="nilai">${empty data.idCatatan ? '-' : data.idCatatan}</span></div>
            <div class="detail-baris"><span class="label">Tanggal Catatan</span><span class="nilai">${empty data.tanggal ? '-' : data.tanggal}</span></div>
            <div class="detail-baris"><span class="label">Nama Pasien</span><span class="nilai">${empty data.namaPasien ? '-' : data.namaPasien}</span></div>
            <div class="detail-baris"><span class="label">Status Pasien</span>
                <span class="nilai">
                    <c:choose>
                        <c:when test="${data.statusPasien eq 'DIRAWAT'}"><span class="badge badge-dirawat">DIRAWAT</span></c:when>
                        <c:when test="${data.statusPasien eq 'PULANG'}"><span class="badge badge-pulang">PULANG</span></c:when>
                        <c:otherwise><span class="badge badge-rawatjalan">RAWAT JALAN</span></c:otherwise>
                    </c:choose>
                </span>
            </div>
            <div class="detail-baris"><span class="label">Perawat Pelapor</span><span class="nilai">${empty data.namaPerawat ? '-' : data.namaPerawat}</span></div>
            <div class="detail-baris"><span class="label">Status Kondisi</span>
                <span class="nilai">
                    <c:choose>
                        <c:when test="${data.status eq 'KRITIS'}"><span class="badge badge-kritis">KRITIS</span></c:when>
                        <c:when test="${data.status eq 'SEDANG'}"><span class="badge badge-sedang">SEDANG</span></c:when>
                        <c:otherwise><span class="badge badge-baik">BAIK</span></c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Rincian Perawatan</h6>
            <div class="detail-baris"><span class="label">Kondisi Pasien</span><span class="nilai">${empty data.kondisiPasien ? '-' : data.kondisiPasien}</span></div>
            <div class="detail-baris"><span class="label">Catatan</span><span class="nilai">${empty data.catatan ? '-' : data.catatan}</span></div>
            <div class="detail-baris"><span class="label">Tindakan</span><span class="nilai">${empty data.tindakan ? '-' : data.tindakan}</span></div>
        </div>
    </div>
</div>

<%@ include file="/fragments/footer.jspf" %>
