<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Tagihan Saya" scope="request" />
<c:set var="menuAktif" value="tagihan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<c:set var="jumlahBelumLunas" value="0" />
<c:forEach items="${daftar}" var="tf">
    <c:if test="${tf.statusPembayaran ne 'LUNAS'}">
        <c:set var="jumlahBelumLunas" value="${jumlahBelumLunas + 1}" />
    </c:if>
</c:forEach>

<div class="row g-3 g-xl-4">
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-merah"><i class="bi bi-receipt"></i></div>
            <div class="min-w-0">
                <div class="angka">
                    <c:choose>
                        <c:when test="${not empty tagihanBelum}">Rp&nbsp;<fmt:formatNumber value="${tagihanBelum}" type="number" maxFractionDigits="0" /></c:when>
                        <c:otherwise>Rp&nbsp;0</c:otherwise>
                    </c:choose>
                </div>
                <div class="keterangan">Total Tagihan Belum Lunas</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-kuning"><i class="bi bi-hourglass-split"></i></div>
            <div class="min-w-0">
                <div class="angka">${jumlahBelumLunas}</div>
                <div class="keterangan">Tagihan Belum Dibayar &amp; Menunggu</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-biru"><i class="bi bi-files"></i></div>
            <div class="min-w-0">
                <div class="angka">${fn:length(daftar)}</div>
                <div class="keterangan">Total Seluruh Tagihan Anda</div>
            </div>
        </div>
    </div>
</div>

<div class="kartu mt-1">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-receipt"></i>Rincian Tagihan Anda</h2>
            <p class="kartu-sub">Seluruh tagihan layanan Anda, terdapat <strong>${fn:length(daftar)}</strong> tagihan. Total biaya dihitung otomatis oleh sistem.</p>
        </div>
        <a class="btn btn-outline-primary btn-sm" href="${ctx}/saya?aksi=pembayaran"><i class="bi bi-credit-card"></i>Riwayat Pembayaran</a>
    </div>

    <c:choose>
        <c:when test="${empty daftar}">
            <div class="kosong">
                <i class="bi bi-receipt"></i>
                <h6>Belum ada tagihan.</h6>
                <p class="mb-0">Tagihan Anda akan tampil di sini setelah layanan rumah sakit diberikan.</p>
            </div>
        </c:when>
        <c:otherwise>
            <c:forEach items="${daftar}" var="by">
                <div class="kartu">
                    <div class="kartu-kepala">
                        <div>
                            <h3 class="kartu-judul"><i class="bi bi-file-earmark-text"></i>Tagihan No. ${by.idPembayaran}</h3>
                            <p class="kartu-sub">Kamar ${empty by.nomorKamar ? 'tidak tercatat' : by.nomorKamar} &middot; Tanggal pembayaran ${empty by.tanggalPembayaran ? 'belum tersedia' : by.tanggalPembayaran}.</p>
                        </div>
                        <c:choose>
                            <c:when test="${by.statusPembayaran eq 'LUNAS'}"><span class="badge badge-lunas">LUNAS</span></c:when>
                            <c:when test="${by.statusPembayaran eq 'MENUNGGU'}"><span class="badge badge-menunggu">MENUNGGU</span></c:when>
                            <c:otherwise><span class="badge badge-belum">BELUM DIBAYAR</span></c:otherwise>
                        </c:choose>
                    </div>

                    <div class="row g-4">
                        <div class="col-lg-6">
                            <h6 class="text-uppercase text-muted fw-bold mb-2">Komponen Biaya</h6>
                            <div class="detail-baris"><span class="label">Biaya Kamar</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty by.biayaKamar ? 0 : by.biayaKamar}" type="number" maxFractionDigits="0" /></span></div>
                            <div class="detail-baris"><span class="label">Biaya Dokter</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty by.biayaDokter ? 0 : by.biayaDokter}" type="number" maxFractionDigits="0" /></span></div>
                            <div class="detail-baris"><span class="label">Biaya Obat</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty by.biayaObat ? 0 : by.biayaObat}" type="number" maxFractionDigits="0" /></span></div>
                            <div class="detail-baris"><span class="label">Biaya Tindakan</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty by.biayaTindakan ? 0 : by.biayaTindakan}" type="number" maxFractionDigits="0" /></span></div>
                            <div class="detail-baris"><span class="label">Biaya Lain</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty by.biayaLain ? 0 : by.biayaLain}" type="number" maxFractionDigits="0" /></span></div>
                        </div>
                        <div class="col-lg-6">
                            <h6 class="text-uppercase text-muted fw-bold mb-2">Total dan Status</h6>
                            <div class="detail-baris"><span class="label">Total Biaya</span><span class="nilai">Rp&nbsp;<fmt:formatNumber value="${empty by.totalBiaya ? 0 : by.totalBiaya}" type="number" maxFractionDigits="0" /></span></div>
                            <div class="detail-baris"><span class="label">Metode Pembayaran</span><span class="nilai">${empty by.metodePembayaran ? 'Belum ada metode' : by.metodePembayaran}</span></div>
                            <div class="detail-baris"><span class="label">Tanggal Pembayaran</span><span class="nilai">${empty by.tanggalPembayaran ? 'Belum dibayar' : by.tanggalPembayaran}</span></div>
                            <div class="detail-baris"><span class="label">Status Tagihan</span>
                                <span class="nilai">
                                    <c:choose>
                                        <c:when test="${by.statusPembayaran eq 'LUNAS'}"><span class="badge badge-lunas">LUNAS</span></c:when>
                                        <c:when test="${by.statusPembayaran eq 'MENUNGGU'}"><span class="badge badge-menunggu">MENUNGGU</span></c:when>
                                        <c:otherwise><span class="badge badge-belum">BELUM DIBAYAR</span></c:otherwise>
                                    </c:choose>
                                </span>
                            </div>
                            <p class="kartu-sub mt-2 mb-0">Total biaya dihitung otomatis oleh sistem dari kelima komponen biaya dan tidak dapat diubah.</p>
                        </div>
                    </div>
                </div>
            </c:forEach>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="/fragments/footer.jspf" %>
