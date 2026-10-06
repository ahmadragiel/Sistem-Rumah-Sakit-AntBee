<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Riwayat Pembayaran" scope="request" />
<c:set var="menuAktif" value="pembayaran" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="row g-3 g-xl-4">
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-biru"><i class="bi bi-wallet2"></i></div>
            <div class="min-w-0">
                <div class="angka">Rp&nbsp;<fmt:formatNumber value="${empty totalSemua ? 0 : totalSemua}" type="number" maxFractionDigits="0" /></div>
                <div class="keterangan">Total Seluruh Biaya Anda</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-hijau"><i class="bi bi-check2-circle"></i></div>
            <div class="min-w-0">
                <div class="angka">Rp&nbsp;<fmt:formatNumber value="${empty totalLunas ? 0 : totalLunas}" type="number" maxFractionDigits="0" /></div>
                <div class="keterangan">Total Yang Sudah Dibayar</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-kuning"><i class="bi bi-credit-card"></i></div>
            <div class="min-w-0">
                <div class="angka">${fn:length(daftar)}</div>
                <div class="keterangan">Jumlah Transaksi Pembayaran</div>
            </div>
        </div>
    </div>
</div>

<div class="kartu mt-1">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-credit-card"></i>Riwayat Pembayaran Anda</h2>
            <p class="kartu-sub">Rincian seluruh pembayaran yang pernah Anda lakukan, terdapat <strong>${fn:length(daftar)}</strong> transaksi.</p>
        </div>
        <a class="btn btn-outline-primary btn-sm" href="${ctx}/saya?aksi=tagihan"><i class="bi bi-receipt"></i>Tagihan Saya</a>
    </div>

    <c:choose>
        <c:when test="${empty daftar}">
            <div class="kosong">
                <i class="bi bi-credit-card-2-front"></i>
                <h6>Belum ada riwayat pembayaran.</h6>
                <p class="mb-0">Pembayaran Anda akan tampil di sini setelah tagihan diterbitkan.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>No.</th>
                            <th class="text-end">Biaya Kamar</th>
                            <th class="text-end">Biaya Dokter</th>
                            <th class="text-end">Biaya Obat</th>
                            <th class="text-end">Biaya Tindakan</th>
                            <th class="text-end">Biaya Lain</th>
                            <th class="text-end">Total Biaya</th>
                            <th>Metode</th>
                            <th>Tanggal</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftar}" var="b" varStatus="loop">
                            <tr>
                                <td>${loop.index + 1}</td>
                                <td class="text-end">Rp&nbsp;<fmt:formatNumber value="${empty b.biayaKamar ? 0 : b.biayaKamar}" type="number" maxFractionDigits="0" /></td>
                                <td class="text-end">Rp&nbsp;<fmt:formatNumber value="${empty b.biayaDokter ? 0 : b.biayaDokter}" type="number" maxFractionDigits="0" /></td>
                                <td class="text-end">Rp&nbsp;<fmt:formatNumber value="${empty b.biayaObat ? 0 : b.biayaObat}" type="number" maxFractionDigits="0" /></td>
                                <td class="text-end">Rp&nbsp;<fmt:formatNumber value="${empty b.biayaTindakan ? 0 : b.biayaTindakan}" type="number" maxFractionDigits="0" /></td>
                                <td class="text-end">Rp&nbsp;<fmt:formatNumber value="${empty b.biayaLain ? 0 : b.biayaLain}" type="number" maxFractionDigits="0" /></td>
                                <td class="text-end fw-semibold">Rp&nbsp;<fmt:formatNumber value="${empty b.totalBiaya ? 0 : b.totalBiaya}" type="number" maxFractionDigits="0" /></td>
                                <td>${empty b.metodePembayaran ? '-' : b.metodePembayaran}</td>
                                <td>${empty b.tanggalPembayaran ? '-' : b.tanggalPembayaran}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${b.statusPembayaran eq 'LUNAS'}"><span class="badge badge-lunas">LUNAS</span></c:when>
                                        <c:when test="${b.statusPembayaran eq 'MENUNGGU'}"><span class="badge badge-menunggu">MENUNGGU</span></c:when>
                                        <c:otherwise><span class="badge badge-belum">BELUM DIBAYAR</span></c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="/fragments/footer.jspf" %>
