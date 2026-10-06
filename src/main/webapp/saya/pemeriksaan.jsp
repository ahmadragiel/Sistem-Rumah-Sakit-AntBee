<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="judulHalaman" value="Riwayat Pemeriksaan" scope="request" />
<c:set var="menuAktif" value="pemeriksaan" scope="request" />
<%@ include file="/fragments/head.jspf" %>

<div class="row g-3 g-xl-4">
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-biru"><i class="bi bi-clipboard2-pulse"></i></div>
            <div class="min-w-0">
                <div class="angka">${fn:length(daftar)}</div>
                <div class="keterangan">Total Pemeriksaan Anda</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-hijau"><i class="bi bi-calendar-day"></i></div>
            <div class="min-w-0">
                <div class="angka">${empty daftar ? '-' : daftar[0].tanggalPemeriksaan}</div>
                <div class="keterangan">Pemeriksaan Terakhir</div>
            </div>
        </div>
    </div>
    <div class="col-6 col-xl-4">
        <div class="kartu kartu-stat h-100">
            <div class="ikon-kotak ikon-kuning"><i class="bi bi-person-badge"></i></div>
            <div class="min-w-0">
                <div class="angka">${empty daftar ? '-' : daftar[0].namaDokter}</div>
                <div class="keterangan">Dokter Pemeriksaan Terakhir</div>
            </div>
        </div>
    </div>
</div>

<div class="kartu mt-1">
    <div class="kartu-kepala">
        <div>
            <h2 class="kartu-judul"><i class="bi bi-clipboard2-pulse"></i>Riwayat Pemeriksaan Anda</h2>
            <p class="kartu-sub">Seluruh hasil pemeriksaan Anda di rumah sakit, terdapat <strong>${fn:length(daftar)}</strong> data pemeriksaan.</p>
        </div>
        <a class="btn btn-outline-primary btn-sm" href="${ctx}/saya"><i class="bi bi-calendar-check"></i>Jadwal Saya</a>
    </div>

    <c:choose>
        <c:when test="${empty daftar}">
            <div class="kosong">
                <i class="bi bi-clipboard-x"></i>
                <h6>Belum ada riwayat pemeriksaan.</h6>
                <p class="mb-0">Hasil pemeriksaan Anda akan tampil di sini setelah diperiksa oleh dokter.</p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="bungkus-tabel">
                <table class="table table-hover table-striped align-middle">
                    <thead>
                        <tr>
                            <th>Tanggal</th>
                            <th>Dokter</th>
                            <th>Keluhan</th>
                            <th>Tekanan Darah</th>
                            <th>Suhu (&deg;C)</th>
                            <th>Berat Badan (kg)</th>
                            <th>Diagnosa</th>
                            <th>Tindakan</th>
                            <th>Catatan</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${daftar}" var="p">
                            <tr>
                                <td>${p.tanggalPemeriksaan}</td>
                                <td class="fw-semibold">${empty p.namaDokter ? '-' : p.namaDokter}</td>
                                <td>${empty p.keluhan ? '-' : p.keluhan}</td>
                                <td>${empty p.tekananDarah ? '-' : p.tekananDarah}</td>
                                <td>${empty p.suhu ? '-' : p.suhu}</td>
                                <td>${empty p.beratBadan ? '-' : p.beratBadan}</td>
                                <td>${empty p.diagnosa ? '-' : p.diagnosa}</td>
                                <td>${empty p.tindakan ? '-' : p.tindakan}</td>
                                <td>${empty p.catatan ? '-' : p.catatan}</td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<%@ include file="/fragments/footer.jspf" %>
