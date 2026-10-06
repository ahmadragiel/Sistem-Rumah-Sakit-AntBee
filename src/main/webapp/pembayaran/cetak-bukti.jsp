<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Bukti Pembayaran" scope="request" />
<c:set var="menuAktif" value="pembayaran" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="kartu">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-printer"></i>Bukti Pembayaran</h2>
            <p class="kartu-sub">Nomor pembayaran <strong>${empty data.idPembayaran ? '-' : data.idPembayaran}</strong> atas nama <strong>${empty data.namaPasien ? '-' : data.namaPasien}</strong>.</p>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-light" href="${ctx}/pembayaran"><i class="bi bi-arrow-left"></i>Kembali</a>
            <button class="btn btn-primary tombol-print" onclick="window.print()"><i class="bi bi-printer"></i>Cetak Bukti</button>
        </div>
    </div>

    <div class="area-cetak">
        <div class="kop">
        <img class="logo-cetak" src="${ctx}/assets/img/logoo.png" alt="RS AntBee">
            <h2>RS AntBee</h2>
            <p>Jl. Kesehatan Raya No. 88, Jakarta Selatan 12190 - Telp. (021) 7654 3210</p>
            <p><strong>Bukti Pembayaran</strong></p>
        </div>

        <div class="detail-baris"><span class="label">Nomor Pembayaran</span><span class="nilai">${empty data.idPembayaran ? '-' : data.idPembayaran}</span></div>
        <div class="detail-baris"><span class="label">Nama Pasien</span><span class="nilai">${empty data.namaPasien ? '-' : data.namaPasien}</span></div>
        <div class="detail-baris"><span class="label">Nomor Kamar</span><span class="nilai">${empty data.nomorKamar ? 'Tidak terkait rawat inap' : data.nomorKamar}</span></div>
        <div class="detail-baris"><span class="label">Tanggal Pembayaran</span><span class="nilai">${empty data.tanggalPembayaran ? '-' : data.tanggalPembayaran}</span></div>
        <div class="detail-baris"><span class="label">Metode Pembayaran</span><span class="nilai">${empty data.metodePembayaran ? '-' : data.metodePembayaran}</span></div>

        <h6 class="text-uppercase text-muted fw-bold mt-4 mb-2">Rincian Biaya</h6>
        <div class="detail-baris"><span class="label">Biaya Kamar</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty data.biayaKamar ? 0 : data.biayaKamar}" type="number" maxFractionDigits="0" /></span></div>
        <div class="detail-baris"><span class="label">Biaya Dokter</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty data.biayaDokter ? 0 : data.biayaDokter}" type="number" maxFractionDigits="0" /></span></div>
        <div class="detail-baris"><span class="label">Biaya Obat</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty data.biayaObat ? 0 : data.biayaObat}" type="number" maxFractionDigits="0" /></span></div>
        <div class="detail-baris"><span class="label">Biaya Tindakan</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty data.biayaTindakan ? 0 : data.biayaTindakan}" type="number" maxFractionDigits="0" /></span></div>
        <div class="detail-baris"><span class="label">Biaya Lain</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty data.biayaLain ? 0 : data.biayaLain}" type="number" maxFractionDigits="0" /></span></div>
        <div class="detail-baris"><span class="label fw-bold">Total Biaya (dihitung sistem)</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty data.totalBiaya ? 0 : data.totalBiaya}" type="number" maxFractionDigits="0" /></span></div>
        <div class="detail-baris"><span class="label">Status Pembayaran</span>
            <span class="nilai">
                <c:choose>
                    <c:when test="${data.statusPembayaran eq 'LUNAS'}"><span class="badge badge-lunas">LUNAS</span></c:when>
                    <c:when test="${data.statusPembayaran eq 'MENUNGGU'}"><span class="badge badge-menunggu">MENUNGGU</span></c:when>
                    <c:otherwise><span class="badge badge-belum">BELUM DIBAYAR</span></c:otherwise>
                </c:choose>
            </span>
        </div>

        <div class="row mt-4">
            <div class="col-md-6">
                <p class="mb-0">Diterima di RS AntBee,<br>${empty data.tanggalPembayaran ? '-' : data.tanggalPembayaran}</p>
            </div>
            <div class="col-md-6 text-end">
                <p class="mb-0">Petugas Penerima,<br><br><br><strong>${empty user.namaLengkap ? '-' : user.namaLengkap}</strong><br>
                    <c:choose>
                        <c:when test="${user.role eq 'ADMIN'}">Administrator</c:when>
                        <c:otherwise>Petugas Administrasi</c:otherwise>
                    </c:choose>
                </p>
            </div>
        </div>
        <p class="text-muted text-center mt-3 mb-0">Dokumen ini dicetak dari sistem informasi manajemen rumah sakit dan sah tanpa tanda tangan basah.</p>
    </div>
</div>

<%@ include file="/fragments/footer.jspf" %>
