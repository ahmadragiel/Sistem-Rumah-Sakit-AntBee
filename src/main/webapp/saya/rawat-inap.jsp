<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Riwayat Rawat Inap" scope="request" />
<c:set var="menuAktif" value="rawat-inap" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<c:set var="sedangDirawat" value="0" />
<c:forEach items="${daftar}" var="ri">
    <c:if test="${ri.statusRawat eq 'DIRAWAT'}">
        <c:set var="sedangDirawat" value="${sedangDirawat + 1}" />
    </c:if>
</c:forEach>

<div class="row g-3 g-xl-4">
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-biru"><i class="bi bi-hospital"></i></div>
            <div class="min-w-0">
                <div class="angka">${fn:length(daftar)}</div>
                <div class="keterangan">Total Rawat Inap Anda</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-hijau"><i class="bi bi-heart-pulse"></i></div>
            <div class="min-w-0">
                <div class="angka">${sedangDirawat}</div>
                <div class="keterangan">Sedang Dirawat Sekarang</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-kuning"><i class="bi bi-door-open"></i></div>
            <div class="min-w-0">
                <div class="angka">${empty daftar ? '-' : daftar[0].namaRuangan}</div>
                <div class="keterangan">Ruangan Rawat Inap Terakhir</div>
            </div>
        </div>
    </div>
</div>

<div class="kartu mt-1">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-hospital"></i>Riwayat Rawat Inap Anda</h2>
            <p class="kartu-sub">Seluruh perawatan inap Anda di rumah sakit, terdapat <strong>${fn:length(daftar)}</strong> data rawat inap.</p>
        </div>
        <a class="btn btn-outline-primary btn-sm" href="${ctx}/saya"><i class="bi bi-calendar-check"></i>Jadwal Saya</a>
    </div>

    <c:choose>
        <c:when test="${empty daftar}">
            <div class="kosong">
                <i class="bi bi-bed"></i>
                <h6>Belum ada riwayat rawat inap.</h6>
                <p class="mb-0">Anda belum pernah menjalani rawat inap. Riwayat rawat inap akan tampil di sini.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>Ruangan</th>
                            <th>Nomor Kamar</th>
                            <th>Dokter</th>
                            <th>Diagnosa</th>
                            <th>Masuk</th>
                            <th>Keluar</th>
                            <th>Lama</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftar}" var="r">
                            <tr>
                                <td class="fw-semibold">${empty r.namaRuangan ? '-' : r.namaRuangan}</td>
                                <td>${empty r.nomorKamar ? '-' : r.nomorKamar}</td>
                                <td>${empty r.namaDokter ? '-' : r.namaDokter}</td>
                                <td>${empty r.diagnosa ? '-' : r.diagnosa}</td>
                                <td>${empty r.tanggalMasuk ? '-' : r.tanggalMasuk}</td>
                                <td>${empty r.tanggalKeluar ? '-' : r.tanggalKeluar}</td>
                                <td>${empty r.lamaRawat ? '-' : r.lamaRawat}${empty r.lamaRawat ? '' : ' hari'}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${r.statusRawat eq 'DIRAWAT'}"><span class="badge badge-dirawat">DIRAWAT</span></c:when>
                                        <c:when test="${r.statusRawat eq 'SELESAI'}"><span class="badge badge-selesai">SELESAI</span></c:when>
                                        <c:when test="${r.statusRawat eq 'DIPULANGKAN'}"><span class="badge badge-pulang">DIPULANGKAN</span></c:when>
                                        <c:when test="${r.statusRawat eq 'MENUNGGU'}"><span class="badge badge-menunggu">MENUNGGU</span></c:when>
                                        <c:otherwise><span class="badge badge-rawatjalan">${empty r.statusRawat ? '-' : r.statusRawat}</span></c:otherwise>
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
