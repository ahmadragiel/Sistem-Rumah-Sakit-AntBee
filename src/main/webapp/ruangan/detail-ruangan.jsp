<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Detail Ruangan" scope="request" />
<c:set var="menuAktif" value="ruangan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<c:set var="persen" value="${data.kapasitas > 0 ? (data.jumlahTerisi * 100.0) / data.kapasitas : 0}"/>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-door-open"></i><c:out value="${empty data.namaRuangan ? 'Detail Ruangan' : data.namaRuangan}" /></h2>
            <p class="kartu-sub">Kamar <strong><c:out value="${empty data.nomorKamar ? '-' : data.nomorKamar}" /></strong> pada lantai <strong>${empty data.lantai ? '-' : data.lantai}</strong>.</p>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-light" href="${ctx}/ruangan"><i class="bi bi-arrow-left"></i>Kembali</a>
            <c:if test="${user.role eq 'ADMIN'}">
                <a class="btn btn-warning" href="${ctx}/ruangan?aksi=edit&id=${data.idRuangan}"><i class="bi bi-pencil"></i>Perbarui Data</a>
            </c:if>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Informasi Ruangan</h6>
            <div class="detail-baris"><span class="label">ID Ruangan</span><span class="nilai">${empty data.idRuangan ? '-' : data.idRuangan}</span></div>
            <div class="detail-baris"><span class="label">Nama Ruangan</span><span class="nilai">${empty data.namaRuangan ? '-' : data.namaRuangan}</span></div>
            <div class="detail-baris"><span class="label">Jenis Ruangan</span><span class="nilai">${empty data.jenisRuangan ? '-' : data.jenisRuangan}</span></div>
            <div class="detail-baris"><span class="label">Nomor Kamar</span><span class="nilai">${empty data.nomorKamar ? '-' : data.nomorKamar}</span></div>
            <div class="detail-baris"><span class="label">Lantai</span><span class="nilai">${empty data.lantai ? '-' : data.lantai}</span></div>
            <div class="detail-baris"><span class="label">Status Ruangan</span>
                <span class="nilai">
                    <c:choose>
                        <c:when test="${data.statusRuangan eq 'TERSEDIA'}"><span class="badge badge-baik">TERSEDIA</span></c:when>
                        <c:when test="${data.statusRuangan eq 'TERISI'}"><span class="badge badge-dirawat">TERISI</span></c:when>
                        <c:when test="${data.statusRuangan eq 'PERAWATAN'}"><span class="badge badge-menunggu">PERAWATAN</span></c:when>
                        <c:otherwise><span class="badge badge-nonaktif">${empty data.statusRuangan ? '-' : data.statusRuangan}</span></c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Kapasitas dan Tarif</h6>
            <div class="detail-baris"><span class="label">Kapasitas</span><span class="nilai">${empty data.kapasitas ? 0 : data.kapasitas} tempat tidur</span></div>
            <div class="detail-baris"><span class="label">Jumlah Terisi</span><span class="nilai">${empty data.jumlahTerisi ? 0 : data.jumlahTerisi} tempat tidur</span></div>
            <div class="detail-baris"><span class="label">Sisa Kapasitas</span><span class="nilai">${empty data.sisaKapasitas ? 0 : data.sisaKapasitas} tempat tidur</span></div>
            <div class="detail-baris"><span class="label">Tarif per Hari</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty data.tarifPerHari ? 0 : data.tarifPerHari}" type="number" maxFractionDigits="0"/> / hari</span></div>
            <div class="detail-baris"><span class="label">Fasilitas</span><span class="nilai">${empty data.fasilitas ? 'Belum ada fasilitas tercatat' : data.fasilitas}</span></div>
        </div>
    </div>
</div>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-graph-up-arrow"></i>Okupansi Kamar</h2>
            <p class="kartu-sub">Jumlah tempat tidur yang sudah terisi dibanding kapasitas ruangan.</p>
        </div>
        <span class="badge ${data.statusRuangan eq 'TERSEDIA' ? 'badge-baik' : (data.statusRuangan eq 'TERISI' ? 'badge-dirawat' : 'badge-menunggu')}">${empty data.statusRuangan ? '-' : data.statusRuangan}</span>
    </div>

    <div class="row text-center g-3">
        <div class="col-4">
            <div class="fs-3 fw-bold text-primary">${empty data.kapasitas ? 0 : data.kapasitas}</div>
            <div class="kartu-sub">Total Kapasitas</div>
        </div>
        <div class="col-4">
            <div class="fs-3 fw-bold text-success">${empty data.jumlahTerisi ? 0 : data.jumlahTerisi}</div>
            <div class="kartu-sub">Tempat Tidur Terisi</div>
        </div>
        <div class="col-4">
            <div class="fs-3 fw-bold text-warning">${empty data.sisaKapasitas ? 0 : data.sisaKapasitas}</div>
            <div class="kartu-sub">Tempat Tidur Kosong</div>
        </div>
    </div>

    <div class="progres mt-3">
        <div class="progres-bar${persen >= 80 ? '' : (persen >= 50 ? ' kuning' : ' hijau')}" style="width: <fmt:formatNumber value="${persen}" type="number" maxFractionDigits="0"/>%;"></div>
    </div>
    <p class="kartu-sub mt-2 mb-0">Okupansi kamar terpakai <fmt:formatNumber value="${persen}" type="number" maxFractionDigits="0"/>% dari total kapasitas.</p>
</div>

<%@ include file="/fragments/footer.jspf" %>
