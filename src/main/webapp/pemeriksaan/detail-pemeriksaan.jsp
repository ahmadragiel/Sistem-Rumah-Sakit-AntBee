<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Detail Pemeriksaan" scope="request" />
<c:set var="menuAktif" value="pemeriksaan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-clipboard2-pulse"></i>Pemeriksaan - <c:out value="${empty data.namaPasien ? '-' : data.namaPasien}" /></h2>
            <p class="kartu-sub">Rincian hasil pemeriksaan pasien pada ${empty data.tanggalPemeriksaan ? '-' : data.tanggalPemeriksaan}.</p>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-light" href="${ctx}/pemeriksaan"><i class="bi bi-arrow-left"></i>Kembali</a>
            <c:if test="${user.role eq 'ADMIN' or (user.role eq 'DOKTER' and data.idDokter eq sessionScope.idDokter)}">
                <a class="btn btn-warning" href="${ctx}/pemeriksaan?aksi=edit&id=${data.idPemeriksaan}"><i class="bi bi-pencil"></i>Ubah Data</a>
            </c:if>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Identitas Pemeriksaan</h6>
            <div class="detail-baris"><span class="label">Nomor Pemeriksaan</span><span class="nilai">${empty data.idPemeriksaan ? '-' : data.idPemeriksaan}</span></div>
            <div class="detail-baris"><span class="label">Tanggal Pemeriksaan</span><span class="nilai">${empty data.tanggalPemeriksaan ? '-' : data.tanggalPemeriksaan}</span></div>
            <div class="detail-baris"><span class="label">Nama Pasien</span><span class="nilai">${empty data.namaPasien ? '-' : data.namaPasien}</span></div>
            <div class="detail-baris"><span class="label">NIK Pasien</span><span class="nilai">${empty data.nik ? '-' : data.nik}</span></div>
            <div class="detail-baris"><span class="label">Dokter Pemeriksa</span><span class="nilai">${empty data.namaDokter ? 'Belum ditentukan' : data.namaDokter}</span></div>
        </div>
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Hasil Pemeriksaan</h6>
            <div class="detail-baris"><span class="label">Tekanan Darah</span><span class="nilai">${empty data.tekananDarah ? 'Tidak diperiksa' : data.tekananDarah}</span></div>
            <div class="detail-baris"><span class="label">Suhu Tubuh</span><span class="nilai"><c:choose><c:when test="${empty data.suhu}">Tidak diperiksa</c:when><c:otherwise>${data.suhu} °C</c:otherwise></c:choose></span></div>
            <div class="detail-baris"><span class="label">Berat Badan</span><span class="nilai"><c:choose><c:when test="${empty data.beratBadan}">Tidak diperiksa</c:when><c:otherwise>${data.beratBadan} kg</c:otherwise></c:choose></span></div>
            <div class="detail-baris"><span class="label">Keluhan</span><span class="nilai">${empty data.keluhan ? '-' : data.keluhan}</span></div>
            <div class="detail-baris"><span class="label">Diagnosa</span><span class="nilai">${empty data.diagnosa ? '-' : data.diagnosa}</span></div>
        </div>
    </div>
</div>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-journal-medical"></i>Tindakan dan Catatan</h2>
            <p class="kartu-sub">Tindakan yang diberikan serta catatan tambahan dari pemeriksaan ini.</p>
        </div>
    </div>
    <div class="detail-baris"><span class="label">Tindakan</span><span class="nilai">${empty data.tindakan ? 'Tidak ada tindakan' : data.tindakan}</span></div>
    <div class="detail-baris"><span class="label">Catatan Tambahan</span><span class="nilai">${empty data.catatan ? 'Tidak ada catatan tambahan' : data.catatan}</span></div>
</div>

<%@ include file="/fragments/footer.jspf" %>
