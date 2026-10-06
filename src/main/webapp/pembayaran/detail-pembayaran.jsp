<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Detail Pembayaran" scope="request" />
<c:set var="menuAktif" value="pembayaran" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-credit-card"></i>Pembayaran - <c:out value="${empty data.namaPasien ? '-' : data.namaPasien}" /></h2>
            <p class="kartu-sub">Rincian tagihan dan pembayaran pasien pada ${empty data.tanggalPembayaran ? '-' : data.tanggalPembayaran}.</p>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-light" href="${ctx}/pembayaran"><i class="bi bi-arrow-left"></i>Kembali</a>
            <a class="btn btn-success" href="${ctx}/pembayaran?aksi=cetak&id=${data.idPembayaran}"><i class="bi bi-printer"></i>Cetak Bukti</a>
            <c:if test="${user.role eq 'ADMIN' or user.role eq 'PETUGAS'}">
                <a class="btn btn-warning" href="${ctx}/pembayaran?aksi=edit&id=${data.idPembayaran}"><i class="bi bi-pencil"></i>Ubah Data</a>
            </c:if>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Informasi Pembayaran</h6>
            <div class="detail-baris"><span class="label">Nomor Pembayaran</span><span class="nilai">${empty data.idPembayaran ? '-' : data.idPembayaran}</span></div>
            <div class="detail-baris"><span class="label">Nama Pasien</span><span class="nilai">${empty data.namaPasien ? '-' : data.namaPasien}</span></div>
            <div class="detail-baris"><span class="label">Nomor Kamar</span><span class="nilai">${empty data.nomorKamar ? 'Tidak terkait rawat inap' : data.nomorKamar}</span></div>
            <div class="detail-baris"><span class="label">Tanggal Pembayaran</span><span class="nilai">${empty data.tanggalPembayaran ? '-' : data.tanggalPembayaran}</span></div>
            <div class="detail-baris"><span class="label">Metode Pembayaran</span><span class="nilai">${empty data.metodePembayaran ? '-' : data.metodePembayaran}</span></div>
            <div class="detail-baris"><span class="label">Status Pembayaran</span>
                <span class="nilai">
                    <c:choose>
                        <c:when test="${data.statusPembayaran eq 'LUNAS'}"><span class="badge badge-lunas">LUNAS</span></c:when>
                        <c:when test="${data.statusPembayaran eq 'MENUNGGU'}"><span class="badge badge-menunggu">MENUNGGU</span></c:when>
                        <c:otherwise><span class="badge badge-belum">BELUM DIBAYAR</span></c:otherwise>
                    </c:choose>
                </span>
            </div>
        </div>
        <div class="col-lg-6">
            <h6 class="text-uppercase text-muted fw-bold mb-2">Rincian Biaya</h6>
            <div class="detail-baris"><span class="label">Biaya Kamar</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty data.biayaKamar ? 0 : data.biayaKamar}" type="number" maxFractionDigits="0" /></span></div>
            <div class="detail-baris"><span class="label">Biaya Dokter</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty data.biayaDokter ? 0 : data.biayaDokter}" type="number" maxFractionDigits="0" /></span></div>
            <div class="detail-baris"><span class="label">Biaya Obat</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty data.biayaObat ? 0 : data.biayaObat}" type="number" maxFractionDigits="0" /></span></div>
            <div class="detail-baris"><span class="label">Biaya Tindakan</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty data.biayaTindakan ? 0 : data.biayaTindakan}" type="number" maxFractionDigits="0" /></span></div>
            <div class="detail-baris"><span class="label">Biaya Lain</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty data.biayaLain ? 0 : data.biayaLain}" type="number" maxFractionDigits="0" /></span></div>
            <div class="detail-baris"><span class="label">Total Biaya (dihitung sistem)</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty data.totalBiaya ? 0 : data.totalBiaya}" type="number" maxFractionDigits="0" /></span></div>
        </div>
    </div>
</div>

<%@ include file="/fragments/footer.jspf" %>
